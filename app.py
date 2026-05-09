import os
from flask import Flask, jsonify
import psycopg2
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "dev-key")

def get_db():
    return psycopg2.connect(os.getenv("DATABASE_URL"))

@app.route("/")
def index():
    return jsonify({"status": "ok", "message": "Flask app is running"})

@app.route("/health")
def health():
    try:
        conn = get_db()
        conn.close()
        return jsonify({"status": "healthy", "db": "connected"})
    except Exception as e:
        return jsonify({"status": "unhealthy", "db": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
