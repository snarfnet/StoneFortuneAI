import hashlib

def gen_uuid(seed):
    h = hashlib.md5(seed.encode()).hexdigest().upper()
    return h[:24]

pbx_path = "/Users/user/StoneFortuneAI/StoneFortuneAI.xcodeproj/project.pbxproj"

with open(pbx_path, "r") as f:
    content = f.read()

fr = gen_uuid("fileref_Components/BannerAdView.swift")
bf = gen_uuid("buildfile_Components/BannerAdView.swift")

print(f"FileRef UUID: {fr}")
print(f"BuildFile UUID: {bf}")

# 1. Add PBXBuildFile entry
old_bf = "/* End PBXBuildFile section */"
new_bf_entry = f'\t\t{bf} /* BannerAdView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {fr}; }};\n'
content = content.replace(old_bf, new_bf_entry + old_bf)

# 2. Add PBXFileReference entry
old_fr = "/* End PBXFileReference section */"
new_fr_entry = f'\t\t{fr} /* BannerAdView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "Components/BannerAdView.swift"; sourceTree = "<group>"; }};\n'
content = content.replace(old_fr, new_fr_entry + old_fr)

# 3. Add to source group children (before stones_json ref)
stones_ref = gen_uuid("stones_json_ref")
content = content.replace(
    f"\t\t\t\t{stones_ref},",
    f"\t\t\t\t{fr},\n\t\t\t\t{stones_ref},"
)

# 4. Add to sources build phase files list
# Find the last build file entry before the closing of sources phase
# We need to add bf to the files list in PBXSourcesBuildPhase
# Find the pattern: last entry before ); in sources phase
lines = content.split("\n")
new_lines = []
in_sources_phase = False
found_files = False
last_file_idx = -1

for i, line in enumerate(lines):
    if "PBXSourcesBuildPhase" in line and "Begin" in line:
        in_sources_phase = True
    if in_sources_phase and "files = (" in line:
        found_files = True
    if in_sources_phase and found_files and line.strip() == ");":
        # Insert our new build file before the closing paren
        new_lines.append(f"\t\t\t\t{bf},")
        found_files = False
        in_sources_phase = False
    new_lines.append(line)

content = "\n".join(new_lines)

with open(pbx_path, "w") as f:
    f.write(content)

print("pbxproj updated successfully with BannerAdView.swift")
