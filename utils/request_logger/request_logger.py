from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def dump_headers():
    print(request.headers)
    return str(request.headers)
