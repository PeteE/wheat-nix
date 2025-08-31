-- NOTE: files must live in `/var/lib/clickhouse/user_files/` in order to use file() 
INSERT INTO suricata.events (timestamp, hostname, event_json)
SELECT
    parseDateTime64BestEffort(JSONExtractString(line, 'timestamp')) as timestamp,
    'ripnix' as hostname,
    line as event_json
FROM file('eve.json', 'LineAsString');
