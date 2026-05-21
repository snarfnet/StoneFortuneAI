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
        print(f"ERROR {e.code}: {err[:500]}")
        return json.loads(err) if err else {}

def upload_file(upload_url, file_path):
    with open(file_path, "rb") as f:
        data = f.read()
    req = urllib.request.Request(upload_url, data=data, method="PUT")
    req.add_header("Content-Type", "image/png")
    ctx = ssl.create_default_context()
    with urllib.request.urlopen(req, context=ctx) as resp:
        return resp.status

# Step 1: Get or create screenshot set for iPhone 6.7"
print("=== Getting screenshot sets ===")
sets_result = api("GET", f"appStoreVersionLocalizations/{LOC_ID}/appScreenshotSets")
sets = sets_result.get("data", [])

# We need APP_IPHONE_67 (6.7 inch - iPhone 15 Pro Max / 16 Pro Max)
target_type = "APP_IPHONE_67"
set_id = None
for s in sets:
    if s["attributes"]["screenshotDisplayType"] == target_type:
        set_id = s["id"]
        print(f"Found existing set: {set_id}")
        break

if not set_id:
    print(f"Creating screenshot set for {target_type}...")
    create_set = api("POST", "appScreenshotSets", {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {
                "screenshotDisplayType": target_type
            },
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {"type": "appStoreVersionLocalizations", "id": LOC_ID}
                }
            }
        }
    })
    if "data" in create_set:
        set_id = create_set["data"]["id"]
        print(f"Created set: {set_id}")
    else:
        print("Failed to create screenshot set")
        sys.exit(1)

# Also need 6.5 inch set
target_type_65 = "APP_IPHONE_65"
set_id_65 = None
for s in sets:
    if s["attributes"]["screenshotDisplayType"] == target_type_65:
        set_id_65 = s["id"]
        break

if not set_id_65:
    create_set_65 = api("POST", "appScreenshotSets", {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {
                "screenshotDisplayType": target_type_65
            },
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {"type": "appStoreVersionLocalizations", "id": LOC_ID}
                }
            }
        }
    })
    if "data" in create_set_65:
        set_id_65 = create_set_65["data"]["id"]
        print(f"Created 6.5 inch set: {set_id_65}")

# Step 2: Take screenshots on different simulators and upload
screenshots = [
    os.path.expanduser("~/StoneFortuneAI/ss_67_fortune_resized.png"),
    os.path.expanduser("~/StoneFortuneAI/ss_67_book_resized.png"),
    os.path.expanduser("~/StoneFortuneAI/ss_67_settings_resized.png"),
]

for idx, ss_path in enumerate(screenshots):
    if not os.path.exists(ss_path):
        print(f"Screenshot not found: {ss_path}")
        continue

    file_size = os.path.getsize(ss_path)
    file_name = os.path.basename(ss_path)

    # Calculate MD5
    with open(ss_path, "rb") as f:
        file_data = f.read()
    md5 = hashlib.md5(file_data).hexdigest()

    print(f"\nUploading {file_name} ({file_size} bytes)...")

    # Upload to both sets
    for sid, label in [(set_id, "6.7"), (set_id_65, "6.5")]:
        if not sid:
            continue
        # Create reservation
        reserve = api("POST", "appScreenshots", {
            "data": {
                "type": "appScreenshots",
                "attributes": {
                    "fileName": file_name,
                    "fileSize": file_size
                },
                "relationships": {
                    "appScreenshotSet": {
                        "data": {"type": "appScreenshotSets", "id": sid}
                    }
                }
            }
        })

        if "data" not in reserve:
            print(f"  Failed to reserve for {label} inch")
            continue

        screenshot_id = reserve["data"]["id"]
        upload_ops = reserve["data"]["attributes"].get("uploadOperations", [])

        if upload_ops:
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
            print(f"  Uploaded to {label} inch set!")
        else:
            print(f"  No upload operations returned for {label} inch")

print("\n=== Screenshots uploaded! ===")

# Step 3: Submit for review
print("\n=== Submitting for review ===")
submit_result = api("POST", "appStoreVersionSubmissions", {
    "data": {
        "type": "appStoreVersionSubmissions",
        "relationships": {
            "appStoreVersion": {
                "data": {"type": "appStoreVersions", "id": VERSION_ID}
            }
        }
    }
})
if "data" in submit_result:
    print("Successfully submitted for review!")
else:
    print("Submit may need additional info. Check App Store Connect.")
    # Try alternative submission endpoint
    submit2 = api("POST", "reviewSubmissions", {
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
    if "data" in submit2:
        sub_id = submit2["data"]["id"]
        print(f"Review submission created: {sub_id}")
        # Add item
        api("POST", "reviewSubmissionItems", {
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
                    "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
                }
            }
        })
        # Confirm
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
            print("Review submitted successfully!")
        else:
            print("Review submission needs manual completion in App Store Connect")

print("\nDone!")
