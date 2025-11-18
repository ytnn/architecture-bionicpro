import os
import json
import base64
from typing import Optional

import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, Depends, HTTPException, Header, Query
from fastapi.middleware.cors import CORSMiddleware


DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://reports_user:reports_password@reports_db:5432/bionic_reports",
)

app = FastAPI(title="BionicPRO Reports API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

def get_db():
    conn = psycopg2.connect(DATABASE_URL)
    try:
        yield conn
    finally:
        conn.close()


def get_email_from_token(authorization: Optional[str]) -> str:
    
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Unauthorized")

    token = authorization.split(" ", 1)[1].strip()
    parts = token.split(".")
    if len(parts) != 3:
        raise HTTPException(status_code=401, detail="Invalid token format")

    payload_b64 = parts[1]
    padding = "=" * (-len(payload_b64) % 4)
    payload_b64 += padding

    try:
        payload_json = base64.urlsafe_b64decode(payload_b64.encode("utf-8")).decode("utf-8")
        payload = json.loads(payload_json)
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token payload")

    email = payload.get("email") or payload.get("preferred_username")
    if not email:
        raise HTTPException(status_code=403, detail="Email not found in token")

    return email


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/reports")
def get_report(
    client_id: int = Query(..., description="ID пользователя (client_id из CRM)"),
    authorization: Optional[str] = Header(None),
    db=Depends(get_db),
):
    """
    Возвращает подготовленный отчёт по заданному пользователю
    из витрины user_usage_report.
    """

    token_email = get_email_from_token(authorization)

    with db.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT client_id
            FROM user_usage_report
            WHERE client_id = %s AND email = %s
            ORDER BY generated_at DESC
            LIMIT 1
            """,
            (client_id, token_email),
        )
        owner_row = cur.fetchone()

        if not owner_row:
            raise HTTPException(
                status_code=403,
                detail="You are not allowed to access report for this user",
            )

        cur.execute(
            """
            SELECT
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
                last_event_at,
                generated_at
            FROM user_usage_report
            WHERE client_id = %s
            ORDER BY generated_at DESC
            LIMIT 1
            """,
            (client_id,),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="Report not found")

    return row
    
@app.get("/users/current")
def get_current_user(
    authorization: Optional[str] = Header(None),
    db=Depends(get_db),
):
    """
    Возвращает client_id и базовую информацию о текущем пользователе
    по его email из access token.
    """
    token_email = get_email_from_token(authorization)

    with db.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT
                client_id,
                full_name,
                email,
                country,
                prosthesis_type,
                MAX(generated_at) AS last_generated_at
            FROM user_usage_report
            WHERE email = %s
            GROUP BY client_id, full_name, email, country, prosthesis_type
            ORDER BY last_generated_at DESC
            LIMIT 1
            """,
            (token_email,),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="Report not found for this user")

    return row
