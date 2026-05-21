#!/bin/bash
set -e

PROJECT_DIR=~/StoneFortuneAI
BUNDLE_ID="com.tokyonasu.StoneFortuneAI"
APP_NAME="StoneFortuneAI"

# Clean and create project directory
rm -rf "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/$APP_NAME"

# Copy source files
cp -r ~/StoneFortuneAI_tmp/StoneFortuneAI/* "$PROJECT_DIR/$APP_NAME/"

# Create Assets.xcassets
mkdir -p "$PROJECT_DIR/$APP_NAME/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$PROJECT_DIR/$APP_NAME/Assets.xcassets/AccentColor.colorset"

cat > "$PROJECT_DIR/$APP_NAME/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

cat > "$PROJECT_DIR/$APP_NAME/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

cat > "$PROJECT_DIR/$APP_NAME/Assets.xcassets/AccentColor.colorset/Contents.json" << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.216",
          "green" : "0.686",
          "red" : "0.831"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Info.plist
cat > "$PROJECT_DIR/$APP_NAME/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>ja</string>
    <key>CFBundleDisplayName</key>
    <string>天然石占い</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict>
        <key>UIColorName</key>
        <string>AccentColor</string>
    </dict>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
</dict>
</plist>
EOF

# Create Xcode project directory
mkdir -p "$PROJECT_DIR/$APP_NAME.xcodeproj"

# Collect all Swift files and generate pbxproj
python3 << 'PYEOF'
import os
import hashlib

PROJECT_DIR = os.path.expanduser("~/StoneFortuneAI")
APP_NAME = "StoneFortuneAI"
BUNDLE_ID = "com.tokyonasu.StoneFortuneAI"

def gen_uuid(seed):
    h = hashlib.md5(seed.encode()).hexdigest().upper()
    return h[:24]

# Collect Swift files
swift_files = []
src_dir = os.path.join(PROJECT_DIR, APP_NAME)
for root, dirs, files in os.walk(src_dir):
    for f in sorted(files):
        if f.endswith(".swift"):
            full = os.path.join(root, f)
            rel = os.path.relpath(full, src_dir)
            swift_files.append((f, rel))

# Generate UUIDs
root_obj = gen_uuid("root_object")
main_group = gen_uuid("main_group")
product_group = gen_uuid("product_group")
app_target = gen_uuid("app_target")
bcl_proj = gen_uuid("bcl_proj")
bcl_target = gen_uuid("bcl_target")
debug_proj = gen_uuid("debug_proj")
release_proj = gen_uuid("release_proj")
debug_target = gen_uuid("debug_target")
release_target = gen_uuid("release_target")
product_ref = gen_uuid("product_ref")
sources_phase = gen_uuid("sources_phase")
resources_phase = gen_uuid("resources_phase")
frameworks_phase = gen_uuid("frameworks_phase")
source_group = gen_uuid("source_group")
stones_ref = gen_uuid("stones_json_ref")
stones_build = gen_uuid("stones_json_build")
assets_ref = gen_uuid("assets_ref")
assets_build = gen_uuid("assets_build")
info_ref = gen_uuid("info_plist_ref")

file_refs = []
build_files = []
for name, rel in swift_files:
    fr = gen_uuid(f"fileref_{rel}")
    bf = gen_uuid(f"buildfile_{rel}")
    file_refs.append((fr, bf, name, rel))

# Build pbxproj
lines = []
lines.append('// !$*UTF8*$!')
lines.append('{')
lines.append('\tarchiveVersion = 1;')
lines.append('\tclasses = {')
lines.append('\t};')
lines.append('\tobjectVersion = 56;')
lines.append('\tobjects = {')
lines.append('')

# PBXBuildFile
lines.append('/* Begin PBXBuildFile section */')
for fr, bf, name, rel in file_refs:
    lines.append(f'\t\t{bf} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr}; }};')
lines.append(f'\t\t{stones_build} /* stones.json in Resources */ = {{isa = PBXBuildFile; fileRef = {stones_ref}; }};')
lines.append(f'\t\t{assets_build} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_ref}; }};')
lines.append('/* End PBXBuildFile section */')
lines.append('')

# PBXFileReference
lines.append('/* Begin PBXFileReference section */')
for fr, bf, name, rel in file_refs:
    lines.append(f'\t\t{fr} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{rel}"; sourceTree = "<group>"; }};')
lines.append(f'\t\t{stones_ref} /* stones.json */ = {{isa = PBXFileReference; lastKnownFileType = text.json; path = "Data/stones.json"; sourceTree = "<group>"; }};')
lines.append(f'\t\t{assets_ref} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
lines.append(f'\t\t{info_ref} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
lines.append(f'\t\t{product_ref} /* {APP_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "{APP_NAME}.app"; sourceTree = BUILT_PRODUCTS_DIR; }};')
lines.append('/* End PBXFileReference section */')
lines.append('')

# PBXFrameworksBuildPhase
lines.append('/* Begin PBXFrameworksBuildPhase section */')
lines.append(f'\t\t{frameworks_phase} = {{')
lines.append('\t\t\tisa = PBXFrameworksBuildPhase;')
lines.append('\t\t\tbuildActionMask = 2147483647;')
lines.append('\t\t\tfiles = (')
lines.append('\t\t\t);')
lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
lines.append('\t\t};')
lines.append('/* End PBXFrameworksBuildPhase section */')
lines.append('')

# PBXGroup
lines.append('/* Begin PBXGroup section */')
lines.append(f'\t\t{main_group} = {{')
lines.append('\t\t\tisa = PBXGroup;')
lines.append('\t\t\tchildren = (')
lines.append(f'\t\t\t\t{source_group},')
lines.append(f'\t\t\t\t{product_group},')
lines.append('\t\t\t);')
lines.append('\t\t\tsourceTree = "<group>";')
lines.append('\t\t};')
lines.append(f'\t\t{product_group} = {{')
lines.append('\t\t\tisa = PBXGroup;')
lines.append('\t\t\tchildren = (')
lines.append(f'\t\t\t\t{product_ref},')
lines.append('\t\t\t);')
lines.append('\t\t\tname = Products;')
lines.append('\t\t\tsourceTree = "<group>";')
lines.append('\t\t};')
lines.append(f'\t\t{source_group} = {{')
lines.append('\t\t\tisa = PBXGroup;')
lines.append('\t\t\tchildren = (')
for fr, bf, name, rel in file_refs:
    lines.append(f'\t\t\t\t{fr},')
lines.append(f'\t\t\t\t{stones_ref},')
lines.append(f'\t\t\t\t{assets_ref},')
lines.append(f'\t\t\t\t{info_ref},')
lines.append('\t\t\t);')
lines.append(f'\t\t\tpath = "{APP_NAME}";')
lines.append('\t\t\tsourceTree = "<group>";')
lines.append('\t\t};')
lines.append('/* End PBXGroup section */')
lines.append('')

# PBXNativeTarget
lines.append('/* Begin PBXNativeTarget section */')
lines.append(f'\t\t{app_target} = {{')
lines.append('\t\t\tisa = PBXNativeTarget;')
lines.append(f'\t\t\tbuildConfigurationList = {bcl_target};')
lines.append('\t\t\tbuildPhases = (')
lines.append(f'\t\t\t\t{sources_phase},')
lines.append(f'\t\t\t\t{frameworks_phase},')
lines.append(f'\t\t\t\t{resources_phase},')
lines.append('\t\t\t);')
lines.append('\t\t\tbuildRules = ();')
lines.append('\t\t\tdependencies = ();')
lines.append(f'\t\t\tname = "{APP_NAME}";')
lines.append(f'\t\t\tproductName = "{APP_NAME}";')
lines.append(f'\t\t\tproductReference = {product_ref};')
lines.append('\t\t\tproductType = "com.apple.product-type.application";')
lines.append('\t\t};')
lines.append('/* End PBXNativeTarget section */')
lines.append('')

# PBXProject
lines.append('/* Begin PBXProject section */')
lines.append(f'\t\t{root_obj} = {{')
lines.append('\t\t\tisa = PBXProject;')
lines.append('\t\t\tattributes = {')
lines.append('\t\t\t\tBuildIndependentTargetsInParallel = 1;')
lines.append('\t\t\t\tLastSwiftUpdateCheck = 1620;')
lines.append('\t\t\t\tLastUpgradeCheck = 1620;')
lines.append('\t\t\t\tTargetAttributes = {')
lines.append(f'\t\t\t\t\t{app_target} = {{')
lines.append('\t\t\t\t\t\tCreatedOnToolsVersion = 16.2;')
lines.append('\t\t\t\t\t};')
lines.append('\t\t\t\t};')
lines.append('\t\t\t};')
lines.append(f'\t\t\tbuildConfigurationList = {bcl_proj};')
lines.append('\t\t\tcompatibilityVersion = "Xcode 14.0";')
lines.append('\t\t\tdevelopmentRegion = ja;')
lines.append('\t\t\thasScannedForEncodings = 0;')
lines.append('\t\t\tknownRegions = (')
lines.append('\t\t\t\tja,')
lines.append('\t\t\t\tBase,')
lines.append('\t\t\t);')
lines.append(f'\t\t\tmainGroup = {main_group};')
lines.append(f'\t\t\tproductRefGroup = {product_group};')
lines.append('\t\t\tprojectDirPath = "";')
lines.append('\t\t\tprojectRoot = "";')
lines.append('\t\t\ttargets = (')
lines.append(f'\t\t\t\t{app_target},')
lines.append('\t\t\t);')
lines.append('\t\t};')
lines.append('/* End PBXProject section */')
lines.append('')

# PBXResourcesBuildPhase
lines.append('/* Begin PBXResourcesBuildPhase section */')
lines.append(f'\t\t{resources_phase} = {{')
lines.append('\t\t\tisa = PBXResourcesBuildPhase;')
lines.append('\t\t\tbuildActionMask = 2147483647;')
lines.append('\t\t\tfiles = (')
lines.append(f'\t\t\t\t{assets_build},')
lines.append(f'\t\t\t\t{stones_build},')
lines.append('\t\t\t);')
lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
lines.append('\t\t};')
lines.append('/* End PBXResourcesBuildPhase section */')
lines.append('')

# PBXSourcesBuildPhase
lines.append('/* Begin PBXSourcesBuildPhase section */')
lines.append(f'\t\t{sources_phase} = {{')
lines.append('\t\t\tisa = PBXSourcesBuildPhase;')
lines.append('\t\t\tbuildActionMask = 2147483647;')
lines.append('\t\t\tfiles = (')
for fr, bf, name, rel in file_refs:
    lines.append(f'\t\t\t\t{bf},')
lines.append('\t\t\t);')
lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
lines.append('\t\t};')
lines.append('/* End PBXSourcesBuildPhase section */')
lines.append('')

# XCBuildConfiguration
lines.append('/* Begin XCBuildConfiguration section */')
# Debug - Project
lines.append(f'\t\t{debug_proj} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
lines.append('\t\t\t\tASSTCALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;')
lines.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
lines.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
lines.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
lines.append('\t\t\t\tENABLE_TESTABILITY = YES;')
lines.append('\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
lines.append('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (')
lines.append('\t\t\t\t\t"DEBUG=1",')
lines.append('\t\t\t\t\t"$(inherited)",')
lines.append('\t\t\t\t);')
lines.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
lines.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
lines.append('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
lines.append('\t\t\t\tSDKROOT = iphoneos;')
lines.append('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";')
lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Debug;')
lines.append('\t\t};')
# Release - Project
lines.append(f'\t\t{release_proj} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
lines.append('\t\t\t\tASSTCALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;')
lines.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
lines.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
lines.append('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
lines.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;')
lines.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
lines.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
lines.append('\t\t\t\tSDKROOT = iphoneos;')
lines.append('\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
lines.append('\t\t\t\tVALIDATE_PRODUCT = YES;')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Release;')
lines.append('\t\t};')
# Debug - Target
lines.append(f'\t\t{debug_target} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
lines.append('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
lines.append('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
lines.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
lines.append('\t\t\t\tDEVELOPMENT_TEAM = "";')
lines.append('\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
lines.append(f'\t\t\t\tINFOPLIST_FILE = "{APP_NAME}/Info.plist";')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;')
lines.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
lines.append('\t\t\t\t\t"$(inherited)",')
lines.append('\t\t\t\t\t"@executable_path/Frameworks",')
lines.append('\t\t\t\t);')
lines.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
lines.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}";')
lines.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
lines.append('\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
lines.append('\t\t\t\tSUPPORTS_MACCATALYST = NO;')
lines.append('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
lines.append('\t\t\t\tSWIFT_VERSION = 5.0;')
lines.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1";')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Debug;')
lines.append('\t\t};')
# Release - Target
lines.append(f'\t\t{release_target} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
lines.append('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
lines.append('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
lines.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
lines.append('\t\t\t\tDEVELOPMENT_TEAM = "";')
lines.append('\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
lines.append(f'\t\t\t\tINFOPLIST_FILE = "{APP_NAME}/Info.plist";')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;')
lines.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
lines.append('\t\t\t\t\t"$(inherited)",')
lines.append('\t\t\t\t\t"@executable_path/Frameworks",')
lines.append('\t\t\t\t);')
lines.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
lines.append(f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}";')
lines.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
lines.append('\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
lines.append('\t\t\t\tSUPPORTS_MACCATALYST = NO;')
lines.append('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
lines.append('\t\t\t\tSWIFT_VERSION = 5.0;')
lines.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1";')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Release;')
lines.append('\t\t};')
lines.append('/* End XCBuildConfiguration section */')
lines.append('')

# XCConfigurationList
lines.append('/* Begin XCConfigurationList section */')
lines.append(f'\t\t{bcl_proj} = {{')
lines.append('\t\t\tisa = XCConfigurationList;')
lines.append('\t\t\tbuildConfigurations = (')
lines.append(f'\t\t\t\t{debug_proj},')
lines.append(f'\t\t\t\t{release_proj},')
lines.append('\t\t\t);')
lines.append('\t\t\tdefaultConfigurationIsVisible = 0;')
lines.append('\t\t\tdefaultConfigurationName = Release;')
lines.append('\t\t};')
lines.append(f'\t\t{bcl_target} = {{')
lines.append('\t\t\tisa = XCConfigurationList;')
lines.append('\t\t\tbuildConfigurations = (')
lines.append(f'\t\t\t\t{debug_target},')
lines.append(f'\t\t\t\t{release_target},')
lines.append('\t\t\t);')
lines.append('\t\t\tdefaultConfigurationIsVisible = 0;')
lines.append('\t\t\tdefaultConfigurationName = Release;')
lines.append('\t\t};')
lines.append('/* End XCConfigurationList section */')
lines.append('')


lines.append('\t};')
lines.append(f'\trootObject = {root_obj};')
lines.append('}')

pbxproj_path = os.path.join(PROJECT_DIR, f"{APP_NAME}.xcodeproj", "project.pbxproj")
with open(pbxproj_path, "w") as f:
    f.write("\n".join(lines) + "\n")

print(f"pbxproj created with {len(swift_files)} Swift files")
PYEOF

echo "Xcode project created at $PROJECT_DIR"
ls -la "$PROJECT_DIR/$APP_NAME.xcodeproj/"
echo "Swift files: $(find "$PROJECT_DIR/$APP_NAME" -name '*.swift' | wc -l)"
echo "Done!"
