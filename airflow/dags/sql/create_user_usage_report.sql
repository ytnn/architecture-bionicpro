CREATE TABLE IF NOT EXISTS user_usage_report (
    report_id        SERIAL PRIMARY KEY,
    client_id        INTEGER NOT NULL,
    full_name        VARCHAR(200) NOT NULL,
    email            VARCHAR(200) NOT NULL,
    country          VARCHAR(50)  NOT NULL,
    prosthesis_type  VARCHAR(50)  NOT NULL,
    days_active      INTEGER,           
    total_events     INTEGER,           
    avg_signal       NUMERIC(10,4),     
    max_signal       NUMERIC(10,4),
    min_signal       NUMERIC(10,4),
    first_event_at   TIMESTAMP,
    last_event_at    TIMESTAMP,
    generated_at     TIMESTAMP DEFAULT now()
);

TRUNCATE TABLE user_usage_report;

INSERT INTO user_usage_report (
    client_id,
    full_name,
    email,
    country,
    prosthesis_type,
    days_active,
    total_events,
    avg_signal,
    max_signal,
    min_signal,
    first_event_at,
    last_event_at
)
SELECT
    c.client_id,
    c.full_name,
    c.email,
    c.country,
    c.prosthesis_type,
    COUNT(DISTINCT DATE(t.event_time))               AS days_active,
    COUNT(t.event_id)                                AS total_events,
    AVG(CASE WHEN t.channel = 'muscle_ch1'
             THEN t.signal_value END)                AS avg_signal,
    MAX(CASE WHEN t.channel = 'muscle_ch1'
             THEN t.signal_value END)                AS max_signal,
    MIN(CASE WHEN t.channel = 'muscle_ch1'
             THEN t.signal_value END)                AS min_signal,
    MIN(t.event_time)                                AS first_event_at,
    MAX(t.event_time)                                AS last_event_at
FROM crm_client c
LEFT JOIN telemetry_event t
       ON t.client_id = c.client_id
GROUP BY
    c.client_id, c.full_name, c.email, c.country, c.prosthesis_type;
