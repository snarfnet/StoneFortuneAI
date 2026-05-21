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

def api(method, path, data=None):
    url = f"https://api.appstoreconnect.apple.com/v1/{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Authorization", f"Bearer {get_token()}")
    req.add_header("Content-Type", "application/json")
    ctx = ssl.create_default_context()
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            return json.loads(resp.read()) if resp.status != 204 else {}
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"ERROR {e.code}: {err[:600]}")
        return json.loads(err) if err else {}

# Get all existing submissions
subs = api("GET", f"apps/{APP_ID}/reviewSubmissions")
sub_ids = [s["id"] for s in subs.get("data", []) if s["attributes"].get("state") == "READY_FOR_REVIEW"]
print(f"Found {len(sub_ids)} READY_FOR_REVIEW submissions")

# Try each one: add item then submit
for sub_id in sub_ids:
    print(f"\n--- Trying submission {sub_id} ---")

    # Check existing items
    items = api("GET", f"reviewSubmissions/{sub_id}/items")
    existing_items = items.get("data", [])
    print(f"  Existing items: {len(existing_items)}")

    # Add version if no items
    if not existing_items:
        item = api("POST", "reviewSubmissionItems", {
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
                    "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
                }
            }
        })
        if "data" in item:
            print(f"  Version added!")
        else:
            print(f"  Failed to add version, trying next...")
            continue

    # Submit
    confirm = api("PATCH", f"reviewSubmissions/{sub_id}", {
        "data": {
            "type": "reviewSubmissions",
            "id": sub_id,
            "attributes": {"submitted": True}
        }
    })
    if "data" in confirm:
        state = confirm["data"]["attributes"].get("state")
        print(f"  SUBMITTED! State: {state}")
        break
    else:
        print(f"  Submit failed, trying next...")
