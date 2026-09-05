#!/bin/zsh

set -euo pipefail

project_dir=${0:A:h:h}
bundle_dir="$project_dir/dist/Calendar Widget.app"
contents_dir="$bundle_dir/Contents"
macos_dir="$contents_dir/MacOS"

if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

swift build --package-path "$project_dir" -c release
binary_dir=$(swift build --package-path "$project_dir" -c release --show-bin-path)

mkdir -p "$macos_dir"
install -m 755 "$binary_dir/CalendarWidget" "$macos_dir/CalendarWidget"
install -m 644 "$project_dir/App/Info.plist" "$contents_dir/Info.plist"
codesign --force --sign - "$bundle_dir"

echo "$bundle_dir"
