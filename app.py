import os

from flask import Flask, Response, request, send_file, jsonify

app = Flask(__name__)

ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "*")


@app.after_request
def add_headers(resp):
    resp.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    resp.headers['Pragma'] = 'no-cache'
    resp.headers['Access-Control-Allow-Origin'] = ALLOWED_ORIGIN
    resp.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    resp.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return resp


@app.route('/health', methods=['GET'])
def health():
    return jsonify(status='ok'), 200


@app.route('/speedtest/', methods=['GET'])
def speedtest_html():
    return send_file('speedtest.html')


@app.route('/speedtest/api/ping', methods=['GET', 'OPTIONS'])
def ping():
    if request.method == 'OPTIONS':
        return ('', 204)
    return ('', 204)


@app.route('/speedtest/api/download', methods=['GET', 'OPTIONS'])
def download():
    if request.method == 'OPTIONS':
        return ('', 204)
    try:
        size = int(request.args.get('size', 25 * 1024 * 1024))
    except ValueError:
        size = 25 * 1024 * 1024

    chunk = 64 * 1024

    def gen(total):
        remaining = total
        buf = b'\0' * chunk
        while remaining > 0:
            n = buf if remaining >= chunk else b'\0' * remaining
            yield n
            remaining -= len(n)

    resp = Response(gen(size), mimetype='application/octet-stream')
    resp.headers['Content-Length'] = str(size)
    resp.headers['Content-Encoding'] = 'identity'
    return resp


@app.route('/speedtest/api/upload', methods=['POST', 'OPTIONS'])
def upload():
    if request.method == 'OPTIONS':
        return ('', 204)
    for _ in iter(lambda: request.stream.read(64 * 1024), b''):
        pass
    return ('', 204)


@app.route('/speedtest/api/health', methods=['GET'])
def health():
    return {'status': 'ok'}, 200
