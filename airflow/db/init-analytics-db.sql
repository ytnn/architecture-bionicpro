DROP TABLE IF EXISTS telemetry_event;
DROP TABLE IF EXISTS crm_client;

CREATE TABLE crm_client (
    client_id          INTEGER PRIMARY KEY,
    full_name          VARCHAR(200) NOT NULL,
    email              VARCHAR(200) NOT NULL UNIQUE,
    country            VARCHAR(50)  NOT NULL,
    registration_date  DATE         NOT NULL,
    prosthesis_type    VARCHAR(50)  NOT NULL
);

CREATE TABLE telemetry_event (
    event_id     SERIAL PRIMARY KEY,
    client_id    INTEGER NOT NULL REFERENCES crm_client(client_id),
    event_time   TIMESTAMP NOT NULL,
    device_sn    VARCHAR(50) NOT NULL,
    channel      VARCHAR(40) NOT NULL, 
    signal_value NUMERIC(10,4) NOT NULL, 
    action_type  VARCHAR(40) NOT NULL
);

INSERT INTO crm_client (client_id, full_name, email, country, registration_date, prosthesis_type)
VALUES
 (101, 'Игорь Смирнов',    'igor.smirnov@example.com',    'RU', '2024-01-10', 'upper_limb'),
 (102, 'Анна Сергеева',    'anna.sergeeva@example.com',   'RU', '2024-02-15', 'lower_limb'),
 (103, 'Павел Орлов',      'pavel.orlov@example.com',     'KZ', '2024-03-02', 'upper_limb'),
 (104, 'Ольга Кузнецова',  'olga.kuznetsova@example.com', 'BY', '2024-04-20', 'lower_limb'),
 (105, 'Денис Власов',     'denis.vlasov@example.com',    'RU', '2024-05-05', 'upper_limb');

INSERT INTO telemetry_event (client_id, event_time, device_sn, channel, signal_value, action_type)
VALUES
 (101, '2024-12-01 08:00:00', 'P001', 'muscle_ch1', 0.81, 'grasp'),
 (101, '2024-12-01 08:03:00', 'P001', 'muscle_ch1', 0.93, 'release'),
 (101, '2024-12-01 08:05:00', 'P001', 'position',   42.5, 'flex'),
 (101, '2024-12-02 09:10:00', 'P001', 'muscle_ch1', 0.78, 'grasp'),
 (102, '2024-12-01 09:00:00', 'P010', 'muscle_ch1', 0.76, 'walk'),
 (102, '2024-12-01 09:07:00', 'P010', 'muscle_ch1', 0.88, 'walk'),
 (102, '2024-12-02 09:30:00', 'P010', 'pressure',   11.2, 'step'),
 (103, '2024-12-01 10:00:00', 'P020', 'muscle_ch1', 0.97, 'grasp'),
 (103, '2024-12-01 10:06:00', 'P020', 'muscle_ch1', 0.91, 'release'),
 (103, '2024-12-03 11:15:00', 'P020', 'position',   39.8, 'extend'),
 (104, '2024-12-01 11:00:00', 'P030', 'muscle_ch1', 0.83, 'walk'),
 (104, '2024-12-01 11:04:00', 'P030', 'pressure',   12.0, 'step'),
 (104, '2024-12-02 12:10:00', 'P030', 'muscle_ch1', 0.90, 'stand'),
 (104, '2024-12-03 12:15:00', 'P030', 'muscle_ch1', 0.87, 'walk'),
 (105, '2024-12-01 12:00:00', 'P040', 'muscle_ch1', 0.85, 'grasp'),
 (105, '2024-12-01 12:06:00', 'P040', 'muscle_ch1', 0.92, 'release'),
 (105, '2024-12-02 13:10:00', 'P040', 'position',   41.3, 'flex');
