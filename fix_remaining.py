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
    if "/v2/" in path:
        url = f"https://api.appstoreconnect.apple.com/v2/{path.replace('/v2/', '')}"
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
        print(f"  ERROR {e.code}: {err[:500]}")
        return json.loads(err) if err else {}

# 1. Set content rights declaration
print("=== 1. Content Rights Declaration ===")
result = api("PATCH", f"apps/{APP_ID}", {
    "data": {
        "type": "apps",
        "id": APP_ID,
        "attributes": {
            "contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"
        }
    }
})
if "data" in result:
    print("Content rights set: DOES_NOT_USE_THIRD_PARTY_CONTENT")
else:
    print("Failed to set content rights")

# 2. Set pricing (free)
print("\n=== 2. Setting Price (Free) ===")
# Get price schedules
price_result = api("GET", f"apps/{APP_ID}/appPriceSchedule")
print(f"Current price schedule: {json.dumps(price_result.get('data', {}).get('id', 'none'))}")

# Set free pricing using v2 API
price_url = f"https://api.appstoreconnect.apple.com/v1/appPriceSchedules"
price_data = {
    "data": {
        "type": "appPriceSchedules",
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}},
            "baseTerritory": {"data": {"type": "territories", "id": "JPN"}},
            "manualPrices": {
                "data": [{"type": "appPrices", "id": "${price1}"}]
            }
        }
    },
    "included": [
        {
            "type": "appPrices",
            "id": "${price1}",
            "attributes": {
                "startDate": None
            },
            "relationships": {
                "priceTier": {"data": {"type": "appPriceTiers", "id": "0"}},
                "appPricePoint": {
                    "data": {"type": "appPricePoints", "id": "eyJzIjoiNjc2MjE2NjAzMCIsInQiOiJKUE4iLCJwIjoiMTAwMDAifQ"}
                }
            }
        }
    ]
}

# Try simpler approach - just set price tier 0 (free)
# First check if there's already a price point
existing_price = api("GET", f"apps/{APP_ID}/appPriceSchedule/manualPrices")
print(f"Existing prices: {json.dumps(existing_price, indent=2)[:300]}")

# Get free price point for JPN
pp_result = api("GET", f"apps/{APP_ID}/appPricePoints?filter[territory]=JPN&filter[priceTier]=0")
if "data" in pp_result and pp_result["data"]:
    free_pp_id = pp_result["data"][0]["id"]
    print(f"Free price point ID: {free_pp_id}")

    # Create price schedule
    schedule = api("POST", "appPriceSchedules", {
        "data": {
            "type": "appPriceSchedules",
            "relationships": {
                "app": {"data": {"type": "apps", "id": APP_ID}},
                "baseTerritory": {"data": {"type": "territories", "id": "JPN"}},
                "manualPrices": {"data": [{"type": "appPrices", "id": "${p1}"}]}
            }
        },
        "included": [{
            "type": "appPrices",
            "id": "${p1}",
            "attributes": {"startDate": None},
            "relationships": {
                "appPricePoint": {"data": {"type": "appPricePoints", "id": free_pp_id}}
            }
        }]
    })
    if "data" in schedule:
        print("Price set to FREE!")
    else:
        print("Price setting may need manual action")
else:
    print("Could not find free price point, trying alternative...")
    # Alternative: just try to create with tier 0
    schedule = api("POST", "appPriceSchedules", {
        "data": {
            "type": "appPriceSchedules",
            "relationships": {
                "app": {"data": {"type": "apps", "id": APP_ID}},
                "baseTerritory": {"data": {"type": "territories", "id": "JPN"}},
                "manualPrices": {"data": [{"type": "appPrices", "id": "${p1}"}]}
            }
        },
        "included": [{
            "type": "appPrices",
            "id": "${p1}",
            "attributes": {"startDate": None},
            "relationships": {
                "priceTier": {"data": None}
            }
        }]
    })
    if "data" in schedule:
        print("Price set!")

# 3. App Privacy / Data Usage
print("\n=== 3. App Privacy (Data Usage) ===")
# Publish empty privacy (no data collected except ads)
# First, we need to declare advertising data usage
# Get existing data usages
usages = api("GET", f"apps/{APP_ID}/appDataUsages")
print(f"Current usages: {len(usages.get('data', []))} entries")

# For AdMob: need to declare "Advertising Data" for "Third-Party Advertising"
# Category: ADVERTISING_DATA, Purpose: THIRD_PARTY_ADVERTISING
usage = api("POST", "appDataUsages", {
    "data": {
        "type": "appDataUsages",
        "attributes": {},
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}},
            "category": {"data": {"type": "appDataUsageCategories", "id": "ADVERTISING_DATA"}},
            "grouping": {"data": {"type": "appDataUsageGroupings", "id": "THIRD_PARTY_ADVERTISING"}}
        }
    }
})
if "data" in usage:
    print("Advertising data usage declared!")

# Publish the privacy responses
publish = api("POST", f"appDataUsagePublications", {
    "data": {
        "type": "appDataUsagePublications",
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}}
        }
    }
})
if "data" in publish:
    print("Privacy responses published!")

# 4. Now try to submit
print("\n=== 4. Submitting for review ===")
sub_id = "ef5db3e6-142c-4ab6-9daa-898ea846a1db"

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
    print("Version added!")

    confirm = api("PATCH", f"reviewSubmissions/{sub_id}", {
        "data": {
            "type": "reviewSubmissions",
            "id": sub_id,
            "attributes": {"submitted": True}
        }
    })
    if "data" in confirm:
        print(f"SUBMITTED! State: {confirm['data']['attributes'].get('state')}")
    else:
        print("Submit confirmation failed - check App Store Connect")
else:
    print("Still cannot add version - check App Store Connect manually")

print("\nDone!")
