#!/usr/bin/env bash
# Run the existing Godot desktop project in Replit's desktop preview.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/blink-arcana"
binary="$cache/Godot_v4.6-stable_linux.x86_64"
archive_url="https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_linux.x86_64.zip"
archive_sha256="6bcc59dfd1d670e918c77eae06e82b9dc5699de13d353dc3a4b3b6b307b6dc06"

if [[ ! -x "$binary" ]]; then
  mkdir -p "$cache"
  archive="$(mktemp "$cache/godot.XXXXXX.zip")"
  trap 'rm -f "$archive"' EXIT
  curl -fL --retry 3 "$archive_url" -o "$archive"
  echo "$archive_sha256  $archive" | sha256sum --check --status
  unzip -oq "$archive" -d "$cache"
  chmod +x "$binary"
  rm -f "$archive"
  trap - EXIT
fi

exec "$binary" --path "$root/godot" --rendering-method gl_compatibility --windowed --resolution 1280x720