#!/bin/bash
set -euo pipefail
mkdir -p build
{
  echo "source_sha=$(git rev-parse HEAD)"
  echo "runner_image=${ImageOS:-unknown}/${ImageVersion:-unknown}"
  xcodebuild -version
  xcrun swift --version
  xcodebuild -showsdks
  xcrun simctl list runtimes
} > build/ENVIRONMENT.txt
cat build/ENVIRONMENT.txt
test -z "$(git status --porcelain --untracked-files=no)"
python3 Scripts/generate_project.py
git diff --exit-code -- MonsterFoodTruck.xcodeproj
python3 Scripts/test_verify_app.py
