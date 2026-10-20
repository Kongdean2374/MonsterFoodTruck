#!/bin/bash
set -euo pipefail
# Normalize the selected icon to Apple's required 1024px; preserve its RGB master.
# sips is an Apple-provided macOS asset utility, not an added build dependency.
mkdir -p build
sips -z 1024 1024 ArtSource/Masters/app-icon.png --out MonsterFoodTruck/Assets.xcassets/AppIcon.appiconset/Icon.png > build/icon-normalization.txt
mkdir -p MonsterFoodTruck/Assets.xcassets/LaunchMark.imageset
for MARK_SCALE in 1 2 3; do
  MARK_DIM=$((MARK_SCALE*100))
  sips -z "$MARK_DIM" "$MARK_DIM" ArtSource/Masters/app-icon.png --out "MonsterFoodTruck/Assets.xcassets/LaunchMark.imageset/Mark-${MARK_SCALE}x.png" >> build/icon-normalization.txt
done
python3 Scripts/validate_content.py
