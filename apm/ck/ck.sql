CREATE TABLE IF NOT EXISTS  otel.access_logs (
    RemoteAddr String,
    RemoteUser String,
    TimeLocal DateTime,
    RequestMethod String,
    Request String,
    HttpVersion String,
    Status Int32,
    BytesSent Int64,
    UserAgent String,
    Client String,
    LogTime DateTime64(3),
    OriginalMessage String
)
ENGINE = MergeTree()
ORDER BY LogTime

SELECT * from  otel.access_logs limit 10
