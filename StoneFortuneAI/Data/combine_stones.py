import json, os

base = "C:/Users/Windows/StoneFortuneAI/StoneFortuneAI/Data"

all_stones = []
for part in ["stones_p1.json", "stones_p2.json", "stones_p3.json"]:
    path = os.path.join(base, part)
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    all_stones.extend(data)
    print(f"Loaded {part}: {len(data)} stones")

# Check for duplicate ids
ids = [s["id"] for s in all_stones]
dupes = [id for id in ids if ids.count(id) > 1]
if dupes:
    print(f"WARNING duplicates: {set(dupes)}")

print(f"Total stones: {len(all_stones)}")

if len(all_stones) >= 200:
    all_stones = all_stones[:200]

out = os.path.join(base, "stones.json")
with open(out, "w", encoding="utf-8") as f:
    json.dump(all_stones, f, ensure_ascii=False, indent=2)
print(f"Written stones.json with {len(all_stones)} entries")
