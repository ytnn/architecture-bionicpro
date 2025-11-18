from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "start_date": datetime(2024, 1, 1),
}

with DAG(
    dag_id="user_reports_etl",
    default_args=default_args,
    description="ETL витрины отчетов по пользователям (CRM + телеметрия)",
    schedule_interval="0 3 * * *",
    catchup=False,
    max_active_runs=1,
) as dag:

    build_user_usage_report = PostgresOperator(
        task_id="build_user_usage_report",
        postgres_conn_id="reports_postgres",
        sql="sql/create_user_usage_report.sql",
    )
