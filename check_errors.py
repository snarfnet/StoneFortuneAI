#!/usr/bin/env python3
import jwt, time, json, urllib.request, urllib.error, ssl, os

KEY_ID = "JYA5G4738Z"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_JYA5G4738Z.p8")
with open(KEY_PATH, "r") as f:
    PRIVATE_KEY = f.read()

APP_ID = "6762166030"
VERSION_ID = "3e3f7241-21c8-4a08-b902-0f2732befbcf"

def get_token():
    now = int(time.time())
    return jwt.encode({"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}, PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID})

def api_raw(method, path, data=None):
    url = f"https://api.appstoreconnect.apple.com/v1/{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Authorization", f"Bearer {get_token()}")
    req.add_header("Content-Type", "application/json")
    ctx = ssl.create_default_context()
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            return resp.status, json.loads(resp.read())
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        return e.code, json.loads(err) if err else {}

# Try to create a submission and get FULL error
print("=== Attempting submission to get full error details ===")
code, result = api_raw("POST", "reviewSubmissions", {
    "data": {
        "type": "reviewSubmissions",
        "attributes": {"platform": "IOS"},
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}}
        }
    }
})

print(f"Status: {code}")
print(json.dumps(result, indent=2))
