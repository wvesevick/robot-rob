# Cartoon Clue Asset Pipeline

The app now uses image assets named `clue_<word>` for every puzzle word.

## Current Status
- Generated clue assets: `117`
- Asset location: `RobotRobApp/Resources/Assets.xcassets/clue_*.imageset`
- Generator script: `scripts/generate_clue_images.py`

## Re-generate After Editing Words
If you add/change words in `GameData.swift`, re-run:

```bash
cd "/Users/willvesevick/Documents/Robot/Robot Rob"
python3 -m venv .venv
source .venv/bin/activate
pip install pillow
python scripts/generate_clue_images.py
rm -rf .venv
```

Then open `RobotRob.xcodeproj` and build.
