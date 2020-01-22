from flask import Flask, request
app = Flask(__name__)

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def dump_headers(path):
  #print('{}\n\n'.format(request.method + ' ' + request.url))
  #print(request.headers)
  return '{}\n\nHEADERS:\n{}'.format(request.method + ' ' + request.url, str(request.headers)), 200, {'Content-Type': 'text/plain; charset=utf-8'}
