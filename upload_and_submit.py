#!/usr/bin/env python3
import jwt, time, json, urllib.request, urllib.error, ssl, os, sys, hashlib

KEY_ID = "JYA5G4738Z"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_JYA5G4738Z.p8")

with open(KEY_PATH, "r") as f:
    PRIVATE_KEY = f.read()

APP_ID = "6762166030"
VERSION_ID = "3e3f7241-21c8-4a08-b902-0f2732befbcf"
LOC_ID = "321f0054-810f-4cbd-94ba-e8cc65caaba6"
SET_67 = "6556ff13-71b7-4a6d-bd3e-e3fc6f9e5b12"
SET_65 = "da1a4230-83c6-4912-aedf-6e3e6bd0c7ee"

def get_token():
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID}
    )

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
        print(f"  ERROR {e.code}: {err[:300]}")
        return json.loads(err) if err else {}

def upload_screenshot(file_path, set_id, label):
    if not os.path.exists(file_path):
        print(f"  File not found: {file_path}")
        return False

    file_size = os.path.getsize(file_path)
    file_name = os.path.basename(file_path)

    with open(file_path, "rb") as f:
        file_data = f.read()

    print(f"  Reserving {file_name} for {label}...")
    reserve = api("POST", "appScreenshots", {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": file_name,
                "fileSize": file_size
            },
            "relationships": {
                "appScreenshotSet": {
                    "data": {"type": "appScreenshotSets", "id": set_id}
                }
            }
        }
    })

    if "data" not in reserve:
        return False

    screenshot_id = reserve["data"]["id"]
    upload_ops = reserve["data"]["attributes"].get("uploadOperations", [])

    if not upload_ops:
        print(f"  No upload operations")
        return False

    for op in upload_ops:
        url = op["url"]
        offset = op["offset"]
        length = op["length"]
        headers = {h["name"]: h["value"] for h in op["requestHeaders"]}
        chunk = file_data[offset:offset + length]
        req = urllib.request.Request(url, data=chunk, method="PUT")
        for k, v in headers.items():
            req.add_header(k, v)
        ctx = ssl.create_default_context()
        urllib.request.urlopen(req, context=ctx)

    # Commit
    md5 = hashlib.md5(file_data).hexdigest()
    api("PATCH", f"appScreenshots/{screenshot_id}", {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {
                "uploaded": True,
                "sourceFileChecksum": md5
            }
        }
    })
    print(f"  Uploaded to {label}!")
    return True

# Upload 6.7 inch screenshots
print("=== Uploading 6.7 inch screenshots ===")
base = os.path.expanduser("~/StoneFortuneAI")
for f in ["ss_67_fortune_resized.png", "ss_67_book_resized.png", "ss_67_settings_resized.png"]:
    upload_screenshot(os.path.join(base, f), SET_67, "6.7 inch")

# Upload 6.5 inch screenshots
print("\n=== Uploading 6.5 inch screenshots ===")
for f in ["ss_65_fortune_resized.png", "ss_65_book_resized.png", "ss_65_settings_resized.png"]:
    upload_screenshot(os.path.join(base, f), SET_65, "6.5 inch")

# Wait for processing
print("\nWaiting 5 seconds for processing...")
time.sleep(5)

# Submit for review
print("\n=== Submitting for review ===")
# Use reviewSubmissions API
submit = api("POST", "reviewSubmissions", {
    "data": {
        "type": "reviewSubmissions",
        "attributes": {
            "platform": "IOS"
        },
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}}
        }
    }
})

if "data" in submit:
    sub_id = submit["data"]["id"]
    print(f"Review submission created: {sub_id}")

    # Add version item
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
        print(f"Added version to submission")

    # Confirm submission
    confirm = api("PATCH", f"reviewSubmissions/{sub_id}", {
        "data": {
            "type": "reviewSubmissions",
            "id": sub_id,
            "attributes": {
                "submitted": True
            }
        }
    })
    if "data" in confirm:
        state = confirm["data"]["attributes"].get("state", "?")
        print(f"Review submitted! State: {state}")
    else:
        print("Submission may need manual completion")
else:
    print("Could not create review submission")

print("\n=== All done! ===")
