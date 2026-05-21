#!/usr/bin/env python3
import jwt, time, json, urllib.request, urllib.error, ssl, os, sys

KEY_ID = "JYA5G4738Z"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_JYA5G4738Z.p8")
BUNDLE_ID = "com.tokyonasu.StoneFortuneAI"

with open(KEY_PATH, "r") as f:
    PRIVATE_KEY = f.read()

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
        print(f"ERROR {e.code}: {err}")
        return json.loads(err) if err else {}

# Step 1: Check if app already exists
print("=== Step 1: Checking existing apps ===")
result = api("GET", f"apps?filter[bundleId]={BUNDLE_ID}")
apps = result.get("data", [])

if apps:
    app_id = apps[0]["id"]
    print(f"App exists: {app_id}")
else:
    print("App not found. Creating...")
    # Need to create the app
    # First get bundle ID resource
    bid_result = api("GET", f"bundleIds?filter[identifier]={BUNDLE_ID}")
    bid_data = bid_result.get("data", [])
    if not bid_data:
        print("Bundle ID not registered. Register it in Apple Developer Portal first.")
        print("Creating bundle ID...")
        bid_create = api("POST", "bundleIds", {
            "data": {
                "type": "bundleIds",
                "attributes": {
                    "identifier": BUNDLE_ID,
                    "name": "StoneFortuneAI",
                    "platform": "IOS"
                }
            }
        })
        if "data" in bid_create:
            bundle_id_resource = bid_create["data"]["id"]
            print(f"Bundle ID created: {bundle_id_resource}")
        else:
            print("Failed to create bundle ID")
            sys.exit(1)
    else:
        bundle_id_resource = bid_data[0]["id"]
        print(f"Bundle ID resource: {bundle_id_resource}")

    # Create the app
    create_result = api("POST", "apps", {
        "data": {
            "type": "apps",
            "attributes": {
                "name": "天然石占い - Stone Fortune",
                "primaryLocale": "ja",
                "bundleId": BUNDLE_ID,
                "sku": "StoneFortuneAI2026"
            },
            "relationships": {
                "bundleId": {
                    "data": {"type": "bundleIds", "id": bundle_id_resource}
                }
            }
        }
    })
    if "data" in create_result:
        app_id = create_result["data"]["id"]
        print(f"App created: {app_id}")
    else:
        print("Failed to create app")
        sys.exit(1)

print(f"\nApp ID: {app_id}")

# Step 2: Get app info and latest version
print("\n=== Step 2: Getting app info ===")
version_result = api("GET", f"apps/{app_id}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION,READY_FOR_REVIEW")
versions = version_result.get("data", [])

if not versions:
    # Create version
    print("Creating version 1.0.0...")
    ver_result = api("POST", "appStoreVersions", {
        "data": {
            "type": "appStoreVersions",
            "attributes": {
                "versionString": "1.0.0",
                "platform": "IOS"
            },
            "relationships": {
                "app": {"data": {"type": "apps", "id": app_id}}
            }
        }
    })
    if "data" in ver_result:
        version_id = ver_result["data"]["id"]
        print(f"Version created: {version_id}")
    else:
        print("Failed to create version")
        print(ver_result)
        sys.exit(1)
else:
    version_id = versions[0]["id"]
    print(f"Version found: {version_id} (state: {versions[0]['attributes'].get('appStoreState')})")

# Step 3: Get localization
print("\n=== Step 3: Setting up localization ===")
loc_result = api("GET", f"appStoreVersions/{version_id}/appStoreVersionLocalizations")
localizations = loc_result.get("data", [])

ja_loc_id = None
for loc in localizations:
    if loc["attributes"]["locale"] == "ja":
        ja_loc_id = loc["id"]
        break

description = """天然石占い - あなたに響くパワーストーンを見つけよう

200種類以上の天然石データベースから、あなたにぴったりのパワーストーンを占います。

【主な機能】
● パワーストーン占い
生年月日とお悩みカテゴリから、あなたに最適な天然石TOP3を占います。恋愛、仕事、健康、金運など8つのカテゴリに対応。

● 毎日のおみくじ
毎日1回、今日の運勢と守護石を占います。大吉から末吉まで5段階の運勢と、ラッキーカラー・ラッキーナンバーも。結果はSNSでシェアできます。

● 天然石図鑑
200種類の天然石を収録した本格図鑑。石の意味、効果、チャクラ、硬度、お手入れ方法まで詳しく解説。カテゴリ別フィルターと検索機能で簡単に探せます。

● Amazon連携
気になった天然石はAmazonで直接検索・購入可能。

【こんな方におすすめ】
・パワーストーンに興味がある方
・毎日の運勢を楽しみたい方
・天然石の知識を深めたい方
・自分に合った石を見つけたい方

神秘的な紫のデザインで、占いの世界に没入できます。"""

keywords = "天然石,パワーストーン,占い,おみくじ,運勢,水晶,アメジスト,ローズクォーツ,誕生石,スピリチュアル"

whats_new = "初回リリース"

promotional_text = "200種類の天然石からあなたにぴったりのパワーストーンを占おう！毎日のおみくじ機能付き。"

if ja_loc_id:
    print(f"Updating Japanese localization: {ja_loc_id}")
    api("PATCH", f"appStoreVersionLocalizations/{ja_loc_id}", {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": ja_loc_id,
            "attributes": {
                "description": description,
                "keywords": keywords,
                # whatsNew not editable for first version
                "promotionalText": promotional_text
            }
        }
    })
else:
    print("Creating Japanese localization...")
    api("POST", "appStoreVersionLocalizations", {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": "ja",
                "description": description,
                "keywords": keywords,
                # whatsNew not editable for first version
                "promotionalText": promotional_text
            },
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}
            }
        }
    })
print("Localization set!")

# Step 4: Set app info (category, privacy policy)
print("\n=== Step 4: Setting app info ===")

# Get app info
info_result = api("GET", f"apps/{app_id}/appInfos")
app_infos = info_result.get("data", [])
if app_infos:
    app_info_id = app_infos[0]["id"]
    # Set categories
    api("PATCH", f"appInfos/{app_info_id}", {
        "data": {
            "type": "appInfos",
            "id": app_info_id,
            "relationships": {
                "primaryCategory": {
                    "data": {"type": "appCategories", "id": "ENTERTAINMENT"}
                },
                "secondaryCategory": {
                    "data": {"type": "appCategories", "id": "LIFESTYLE"}
                }
            }
        }
    })
    print("Categories set: Entertainment + Lifestyle")

    # Set age rating / content rights etc via app info localizations
    info_loc_result = api("GET", f"appInfos/{app_info_id}/appInfoLocalizations")
    info_locs = info_loc_result.get("data", [])
    for il in info_locs:
        if il["attributes"]["locale"] == "ja":
            api("PATCH", f"appInfoLocalizations/{il['id']}", {
                "data": {
                    "type": "appInfoLocalizations",
                    "id": il["id"],
                    "attributes": {
                        "privacyPolicyUrl": "https://snarfnet.github.io/StoneFortuneAI/privacy.html"
                    }
                }
            })
            print("Privacy policy URL set!")
            break

# Step 5: Set up version info
print("\n=== Step 5: Setting version info ===")
api("PATCH", f"appStoreVersions/{version_id}", {
    "data": {
        "type": "appStoreVersions",
        "id": version_id,
        "attributes": {
            "copyright": "2026 satoshi amasaki",
            "releaseType": "MANUAL"
        }
    }
})
print("Copyright and release type set!")

# Step 6: Check for builds
print("\n=== Step 6: Checking builds ===")
builds_result = api("GET", f"builds?filter[app]={app_id}&sort=-uploadedDate&limit=5")
builds = builds_result.get("data", [])
if builds:
    build_id = builds[0]["id"]
    build_ver = builds[0]["attributes"].get("version", "?")
    build_state = builds[0]["attributes"].get("processingState", "?")
    print(f"Latest build: {build_id} (version: {build_ver}, state: {build_state})")

    if build_state == "VALID":
        # Assign build to version
        api("PATCH", f"appStoreVersions/{version_id}", {
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "relationships": {
                    "build": {"data": {"type": "builds", "id": build_id}}
                }
            }
        })
        print("Build assigned to version!")
    else:
        print(f"Build is still processing ({build_state}). Wait and run again to assign.")
else:
    print("No builds found yet. Wait for processing and run again.")

print("\n=== Done! ===")
print(f"App ID: {app_id}")
print(f"Version ID: {version_id}")
print("Next: Upload screenshots, then submit for review")
