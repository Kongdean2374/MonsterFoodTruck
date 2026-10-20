#!/bin/bash
set -euo pipefail
# Normalize the selected icon to Apple's required 1024px; preserve its RGB master.
# sips is an Apple-provided macOS asset utility, not an added build dependency.
mkdir -p build
sips -z 1024 1024 ArtSource/Masters/app-icon.png --out MonsterFoodTruck/Assets.xcassets/AppIcon.appiconset/Icon.png > build/icon-normalization.txt
python3 Scripts/validate_content.py
