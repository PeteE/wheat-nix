-- Suricata ClickHouse output script using clickhouse-lua module
-- Inserts all event types into ClickHouse database

local clickhouse = require("clickhouse")
local json = require("cjson")

-- ClickHouse configuration
local CLICKHOUSE_CONFIG = {
    host = "localhost",
    port = 8123,
    username = "default",
    password = "",
    database = "suricata"
}
local TABLE = "events"
local HOSTNAME = "ripnix"

-- Global client and buffer
local client = nil
local event_buffer = {}
local BATCH_SIZE = 50

function init(args)
    local needs = {}
    -- We want all event types, not just a specific protocol
    return needs
end

function setup(args)
    -- Initialize ClickHouse client
    client = clickhouse.ClickHouseClient.new(CLICKHOUSE_CONFIG)
    
    -- Test connection
    local success, err = client:ping()
    if success then
        SCLogInfo("ClickHouse output initialized - connection successful")
    else
        SCLogError("ClickHouse connection failed: " .. tostring(err))
        return 1
    end
    
    return 0
end

function log(args)
    -- Get basic event information
    local event_type = SCEvtType()
    if not event_type then
        return
    end
    
    -- Get timestamp in proper format
    local timestring = SCPacketTimeString()
    
    -- Get flow information
    local ip_version, src_ip, dst_ip, protocol, src_port, dst_port = SCFlowTuple()
    
    -- Build comprehensive event JSON object
    local event_data = {
        timestamp = timestring,
        event_type = event_type,
        src_ip = src_ip or "",
        dest_ip = dst_ip or "",
        proto = protocol or "",
        src_port = src_port or 0,
        dest_port = dst_port or 0,
        flow_id = SCFlowId() or 0
    }
    
    -- Add protocol-specific data based on event type
    if event_type == "alert" then
        local alert_msg = SCRuleMsg()
        if alert_msg then
            event_data.alert = {
                signature = alert_msg,
                signature_id = SCRuleSid() or 0,
                gid = SCRuleGid() or 0,
                rev = SCRuleRev() or 0,
                action = "allowed" -- Default, could be enhanced
            }
        end
    elseif event_type == "http" then
        local http_uri = HttpGetRequestUriRaw()
        local http_host = HttpGetRequestHost()
        local http_method = HttpGetRequestMethod()
        local http_user_agent = HttpGetRequestUserAgent()
        if http_uri or http_host or http_method then
            event_data.http = {
                hostname = http_host or "",
                uri = http_uri or "",
                method = http_method or "",
                user_agent = http_user_agent or ""
            }
        end
    elseif event_type == "dns" then
        local dns_query = DnsGetQueries()
        if dns_query then
            event_data.dns = {
                queries = dns_query
            }
        end
    elseif event_type == "tls" then
        local tls_sni = TlsGetSNI()
        local tls_subject = TlsGetSubject()
        local tls_version = TlsGetVersion()
        if tls_sni or tls_subject then
            event_data.tls = {
                sni = tls_sni or "",
                subject = tls_subject or "",
                version = tls_version or ""
            }
        end
    elseif event_type == "flow" then
        -- Add flow-specific information
        event_data.flow = {
            state = "active" -- Could be enhanced with actual flow state
        }
    end
    
    -- Add interface information if available
    local in_iface = SCPacketInterface()
    if in_iface then
        event_data.in_iface = in_iface
    end
    
    -- Convert event data to JSON string
    local json_event = json.encode(event_data)
    
    -- Add to buffer with proper timestamp format for ClickHouse
    table.insert(event_buffer, {
        timestamp = format_timestamp(timestring),
        hostname = HOSTNAME,
        event_json = json_event
    })
    
    -- Send batch if buffer is full
    if #event_buffer >= BATCH_SIZE then
        send_batch_to_clickhouse()
    end
end

function format_timestamp(timestring)
    -- Convert Suricata timestamp to ClickHouse DateTime format
    -- Suricata format: "12/30/2009-10:17:44.408711"
    -- ClickHouse needs: "2009-12-30 10:17:44"
    if not timestring then
        return "1970-01-01 00:00:00"
    end
    
    -- Simple parsing - may need adjustment based on actual format
    local formatted = timestring:gsub("(%d+)/(%d+)/(%d+)%-(%d+:%d+:%d+)%.%d+", "%3-%1-%2 %4")
    return formatted
end

function send_batch_to_clickhouse()
    if #event_buffer == 0 then
        return
    end
    
    -- Build INSERT query with proper escaping
    local values = {}
    for _, event in ipairs(event_buffer) do
        -- Properly escape single quotes in JSON
        local escaped_json = event.event_json:gsub("'", "''")
        local value = string.format("('%s', '%s', '%s')", 
            event.timestamp, event.hostname, escaped_json)
        table.insert(values, value)
    end
    
    local query = string.format(
        "INSERT INTO %s (timestamp, hostname, event_json) VALUES %s",
        TABLE, table.concat(values, ",")
    )
    
    -- Execute the query
    local result, err = client:query(query)
    if result then
        SCLogInfo(string.format("Successfully inserted %d events to ClickHouse", #event_buffer))
    else
        SCLogError("Failed to insert events to ClickHouse: " .. tostring(err))
        -- Could implement retry logic here
    end
    
    -- Clear buffer regardless of success/failure to prevent memory buildup
    event_buffer = {}
end

function deinit(args)
    -- Send any remaining events in buffer
    if #event_buffer > 0 then
        send_batch_to_clickhouse()
    end
    
    -- Close connection if needed (clickhouse-lua handles this automatically)
    SCLogInfo("ClickHouse output deinitialized")
end