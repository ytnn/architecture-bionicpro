## Инструкция по запуску BionicPRO Reports

### 1. Запуск всей системы через Docker Compose

 ``` docker-compose up --build -d ```


### 2. Создание подключения в Airflow

```
docker exec -it architecture-bionicpro-airflow-scheduler-1 \
  airflow connections add reports_postgres \
  --conn-type postgres \
  --conn-host reports_db \
  --conn-schema bionic_reports \
  --conn-login reports_user \
  --conn-password reports_password \
  --conn-port 5432
```


### 3. Создание пользователей в Keycloak

Открыть админку Keycloak:
http://localhost:8080/admin

Логин: admin

Пароль: admin

Выбрать realm reports-realm

- Создать пользователя: Users → Add User
- Выставить: Email = email из таблицы crm_client
- Установить пароль: Credentials → Set Password → password123 → Temporary = OFF

Добавить одного или всех пользователей из таблицы [crm_client](https://github.com/ytnn/architecture-bionicpro/blob/319200b1e82c222fa7aa1162c7302e2e56c07b95/airflow/db/init-analytics-db.sql#L25)

**Важно**: поля email должны совпадать с таблицей [crm_client](https://github.com/ytnn/architecture-bionicpro/blob/319200b1e82c222fa7aa1162c7302e2e56c07b95/airflow/db/init-analytics-db.sql#L25), иначе отчёт не откроется.

### 4. Содать отчеты в DAG

Открыть: http://localhost:8081/home
- Войти под admin/admin

- Включить переключатель user_reports_etl

- Нажать на кнопку "Trigger DAG"

### 4. Проверка UI

Открыть: http://localhost:3000

- Войти через Keycloak

- Нажать Download Report

Появится таблица с отчётом только для текущего пользователя 
