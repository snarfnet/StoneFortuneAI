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
        print(f"ERROR: {err[:500]}")
        return json.loads(err) if err else {}

# Get age rating declaration ID
infos = api("GET", f"apps/{APP_ID}/appInfos")
ar_id = None
for info in infos.get("data", []):
    state = info["attributes"].get("appStoreState")
    if state == "PREPARE_FOR_SUBMISSION":
        info_id = info["id"]
        ar = api("GET", f"appInfos/{info_id}/ageRatingDeclaration")
        ar_id = ar["data"]["id"]
        print(f"Age Rating ID: {ar_id}")
        break

if ar_id:
    result = api("PATCH", f"ageRatingDeclarations/{ar_id}", {
        "data": {
            "type": "ageRatingDeclarations",
            "id": ar_id,
            "attributes": {
                "alcoholTobaccoOrDrugUseOrReferences": "NONE",
                "contests": "NONE",
                "gambling": False,
                "gamblingSimulated": "NONE",
                "horrorOrFearThemes": "NONE",
                "matureOrSuggestiveThemes": "NONE",
                "medicalOrTreatmentInformation": "NONE",
                "profanityOrCrudeHumor": "NONE",
                "sexualContentGraphicAndNudity": "NONE",
                "sexualContentOrNudity": "NONE",
                "violenceCartoonOrFantasy": "NONE",
                "violenceRealistic": "NONE",
                "violenceRealisticProlongedGraphicOrSadistic": "NONE",
                "unrestrictedWebAccess": False,
                "parentalControls": False,
                "advertising": True,
                "userGeneratedContent": False,
                "messagingAndChat": False,
                "healthOrWellnessTopics": False,
                "lootBox": False,
                "ageAssurance": False,
                "gunsOrOtherWeapons": "NONE",
                "ageRatingOverride": None
            }
        }
    })
    if "data" in result:
        print("Age rating updated!")

# Create review detail
print("\n=== Setting review details ===")
review = api("POST", "appStoreReviewDetails", {
    "data": {
        "type": "appStoreReviewDetails",
        "attributes": {
            "contactFirstName": "Satoshi",
            "contactLastName": "Amasaki",
            "contactEmail": "snarfnet@gmail.com",
            "contactPhone": "+81 80 2368 9194",
            "demoAccountRequired": False,
            "notes": "Fortune-telling app using local stone database. No account required. All data stored locally on device."
        },
        "relationships": {
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
        }
    }
})
if "data" in review:
    print("Review details set!")
else:
    # May already exist, try PATCH
    existing = api("GET", f"appStoreVersions/{VERSION_ID}/appStoreReviewDetail")
    if "data" in existing:
        rd_id = existing["data"]["id"]
        api("PATCH", f"appStoreReviewDetails/{rd_id}", {
            "data": {
                "type": "appStoreReviewDetails",
                "id": rd_id,
                "attributes": {
                    "contactFirstName": "Satoshi",
                    "contactLastName": "Amasaki",
                    "contactEmail": "snarfnet@gmail.com",
                    "contactPhone": "+81 80 2368 9194",
                    "demoAccountRequired": False,
                    "notes": "Fortune-telling app using local stone database. No account required."
                }
            }
        })
        print("Review details updated!")

# Submit for review
print("\n=== Submitting for review ===")
sub = api("POST", "reviewSubmissions", {
    "data": {
        "type": "reviewSubmissions",
        "attributes": {"platform": "IOS"},
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}}
        }
    }
})

if "data" in sub:
    sub_id = sub["data"]["id"]
    print(f"Submission: {sub_id}")

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
        print("Version added")

    confirm = api("PATCH", f"reviewSubmissions/{sub_id}", {
        "data": {
            "type": "reviewSubmissions",
            "id": sub_id,
            "attributes": {"submitted": True}
        }
    })
    if "data" in confirm:
        state = confirm["data"]["attributes"].get("state")
        print(f"SUBMITTED! State: {state}")
    else:
        print("Submit confirmation failed")
else:
    print("Could not create submission")
