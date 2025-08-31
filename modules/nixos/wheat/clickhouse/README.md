# Overview
Goal of this feature/poc is:
- publish data from suricata into some kind of queryable storage
  - Ex: all flow log records stored in clickhouse
- Send security related events to some kind of alerting pipeline
  - Ex: suricata event -> nats.io stream -> (pagerduty|slack|email)

# TODO
- create lua script to insert data into clickhouse from suricata (bypass the log)
    - ideally use buffering for good throughput (may not be possible)
    - would love to log entire flows
- Create another lua script to send alerts to NATs
