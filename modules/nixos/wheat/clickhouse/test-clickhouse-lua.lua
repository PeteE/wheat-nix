#!/usr/bin/env lua

-- Test script for ClickHouse Lua integration
-- This simulates Suricata function calls to test our script locally

local clickhouse = require("clickhouse")
local json = require("cjson")

-- Mock Suricata functions for testing
function SCLogInfo(msg)
    print("[INFO] " .. msg)
end

function SCLogError(msg)
    print("[ERROR] " .. msg)
end

function SCEvtType()
    return "alert"
end

function SCPacketTimeString()
    return "08/28/2025-22:45:30.123456"
end

function SCFlowTuple()
    return 4, "192.168.1.100", "8.8.8.8", "TCP", 443, 80
end

function SCFlowId()
    return 12345678
end

function SCRuleMsg()
    return "Test alert signature"
end

function SCRuleSid()
    return 1001
end

function SCRuleGid()
    return 1
end

function SCRuleRev()
    return 2
end

function SCPacketInterface()
    return "eth0"
end

-- Include our ClickHouse output script functions
dofile("clickhouse-output.lua")

-- Test the script
print("Testing ClickHouse Lua output script...")

-- Test initialization
print("\n1. Testing init()...")
local needs = init({})
print("Init returned needs table:", json.encode(needs))

-- Test setup
print("\n2. Testing setup()...")
local setup_result = setup({})
if setup_result == 0 then
    print("Setup successful!")
else
    print("Setup failed with code:", setup_result)
    os.exit(1)
end

-- Test logging multiple events
print("\n3. Testing log() with multiple events...")

-- Simulate different event types
local event_types = {"alert", "http", "dns", "tls", "flow"}
local src_ips = {"192.168.1.100", "10.0.0.15", "172.16.1.50"}
local dest_ips = {"8.8.8.8", "1.1.1.1", "208.67.222.222"}

-- Override SCEvtType to cycle through different types
local event_index = 1
function SCEvtType()
    local evt_type = event_types[((event_index - 1) % #event_types) + 1]
    return evt_type
end

-- Override SCFlowTuple to vary IPs
function SCFlowTuple()
    local src = src_ips[((event_index - 1) % #src_ips) + 1]
    local dest = dest_ips[((event_index - 1) % #dest_ips) + 1]
    return 4, src, dest, "TCP", 443, 80
end

-- Generate test events
for i = 1, 75 do  -- More than BATCH_SIZE to test batching
    event_index = i
    print(string.format("Generating event %d (type: %s)", i, SCEvtType()))
    log({})
end

-- Test cleanup
print("\n4. Testing deinit()...")
deinit({})

print("\nTest completed! Check your ClickHouse database for inserted events:")
print("clickhouse client -q \"SELECT COUNT(*) FROM suricata.events WHERE hostname = 'ripnix'\"")
print("clickhouse client -q \"SELECT * FROM suricata.events WHERE hostname = 'ripnix' ORDER BY timestamp DESC LIMIT 10 FORMAT Vertical\"")