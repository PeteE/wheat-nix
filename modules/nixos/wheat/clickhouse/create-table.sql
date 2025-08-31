CREATE DATABASE IF NOT EXISTS suricata;
CREATE TABLE suricata.events
(
    timestamp DateTime,
    hostname String,
    event_json JSON
)
ENGINE = MergeTree
PRIMARY KEY (timestamp, hostname);
