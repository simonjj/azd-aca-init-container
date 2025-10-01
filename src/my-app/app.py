import os
import time
from flask import Flask

app = Flask(__name__)
SHARED_FILE_PATH = "/shared/data.txt"

@app.route("/")
def hello():
    try:
        # Wait a moment for the file to be written by the init container
        # In a real app, you might have a more robust check
        time.sleep(1)
        with open(SHARED_FILE_PATH, 'r') as f:
            content = f.read()
        return f"<h1>Main App is Running!</h1><p>Message from init container: <strong>{content}</strong></p>"
    except FileNotFoundError:
        return "<h1>Main App is Running!</h1><p>Could not read from shared volume. Init container may have failed.</p>", 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
