INSERT INTO suricata.events (timestamp, hostname, event_json) VALUES
    (now(), 'ripnix', '{"foo": "bar"}'),
    (now() + 5, 'ripnix', '{"foo": "baz"}')
