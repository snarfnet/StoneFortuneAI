#!/usr/bin/env python3
import jwt, time, json, urllib.request, urllib.error, ssl, os

KEY_ID = "JYA5G4738Z"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_JYA5G4738Z.p8")
with open(KEY_PATH, "r") as f:
    PRIVATE_KEY = f.read()

VERSION_ID = "3e3f7241-21c8-4a08-b902-0f2732befbcf"

def get_token():
    now = int(time.time())
    return jwt.encode({"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}, PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID})

url = "https://api.appstoreconnect.apple.com/v1/reviewSubmissionItems"
data = json.dumps({
    "data": {
        "type": "reviewSubmissionItems",
        "relationships": {
            "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": "ef5db3e6-142c-4ab6-9daa-898ea846a1db"}},
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
        }
    }
}).encode()

req = urllib.request.Request(url, data=data, method="POST")
req.add_header("Authorization", f"Bearer {get_token()}")
req.add_header("Content-Type", "application/json")
ctx = ssl.create_default_context()
try:
    with urllib.request.urlopen(req, context=ctx) as resp:
        print(json.dumps(json.loads(resp.read()), indent=2))
except urllib.error.HTTPError as e:
    err = e.read().decode()
    print(json.dumps(json.loads(err), indent=2))
