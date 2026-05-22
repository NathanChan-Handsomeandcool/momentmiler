#!/usr/bin/env bash
#
# add-photos.sh — process raw photos dropped into images/_inbox/<category>/
#
# For every file found, the script:
#   1. picks the next free number in that category (E26, AC12, ...)
#   2. runs `sips` to cap the long edge at 2000px and re-encode as JPEG (q=85)
#   3. writes the result to images/<PREFIX><N>.jpg
#   4. deletes the original file from _inbox
#   5. appends a new entry to the PHOTOS array in index.html
#   6. stages the changes (does NOT commit, does NOT push)
#
# Categories:
#   images/_inbox/europe/         → E<N>.jpg    cat: 'europe'
#   images/_inbox/arctic/         → AC<N>.jpg   cat: 'arctic'
#   images/_inbox/asia/           → A<N>.jpg    cat: 'asia'
#   images/_inbox/south-america/  → SA<N>.jpg   cat: 'south-america'
#   images/_inbox/south-africa/   → SAF<N>.jpg  cat: 'south-africa'

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

IMAGES_DIR="images"
INBOX_DIR="$IMAGES_DIR/_inbox"
INDEX_FILE="index.html"

if [[ ! -d "$INBOX_DIR" ]]; then
  echo "✗ Inbox directory not found: $INBOX_DIR" >&2
  exit 1
fi

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "✗ index.html not found in $REPO_ROOT" >&2
  exit 1
fi

# folder name → filename prefix (case is bash 3.2 compatible; macOS still ships 3.2)
folder_to_prefix() {
  case "$1" in
    europe)        echo "E"   ;;
    arctic)        echo "AC"  ;;
    asia)          echo "A"   ;;
    south-america) echo "SA"  ;;
    south-africa)  echo "SAF" ;;
    *)             echo ""    ;;
  esac
}

# Process folders in this fixed order so the run is deterministic
FOLDERS=(europe arctic asia south-america south-africa)

added_count=0
declare -a added_entries=()
declare -a renamed_log=()

for folder in "${FOLDERS[@]}"; do
  inbox_path="$INBOX_DIR/$folder"
  [[ -d "$inbox_path" ]] || continue

  prefix="$(folder_to_prefix "$folder")"

  # find the highest existing number for this prefix
  # regex must match exactly PREFIX + digits + .jpg to avoid SA matching SAF, A matching AC, etc.
  max_num=0
  if compgen -G "$IMAGES_DIR/${prefix}*.jpg" > /dev/null 2>&1; then
    while IFS= read -r n; do
      [[ -n "$n" ]] && (( n > max_num )) && max_num=$n
    done < <(ls "$IMAGES_DIR" 2>/dev/null | grep -E "^${prefix}[0-9]+\.jpg$" | sed -E "s/^${prefix}([0-9]+)\.jpg$/\1/")
  fi
  next_num=$((max_num + 1))

  shopt -s nullglob nocaseglob
  for src in "$inbox_path"/*.jpg "$inbox_path"/*.jpeg "$inbox_path"/*.heic "$inbox_path"/*.png; do
    [[ -f "$src" ]] || continue

    out_name="${prefix}${next_num}.jpg"
    out_path="$IMAGES_DIR/$out_name"

    src_base="$(basename "$src")"
    echo "→ ${folder}/${src_base}  →  ${out_name}"

    sips -Z 2000 -s format jpeg -s formatOptions 85 "$src" --out "$out_path" > /dev/null
    rm "$src"

    added_entries+=("  { src: 'images/${out_name}', title: '', loc: '', cat: '${folder}' },")
    renamed_log+=("${folder}/${src_base} → ${out_name}")
    added_count=$((added_count + 1))
    next_num=$((next_num + 1))
  done
  shopt -u nullglob nocaseglob
done

if [[ $added_count -eq 0 ]]; then
  echo "No new photos found in $INBOX_DIR/."
  echo "Drop .jpg / .jpeg / .heic / .png files into one of the category folders and run again."
  exit 0
fi

# Insert new entries before the FIRST '];' that closes the PHOTOS array.
# We write the insertion to a tmp file and have awk pull it in — BSD awk on macOS
# rejects literal newlines passed via -v, so we read from a file instead.
tmp_file="$(mktemp)"
insertion_file="$(mktemp)"
for entry in "${added_entries[@]}"; do
  printf '%s\n' "$entry" >> "$insertion_file"
done

awk -v insertion_file="$insertion_file" '
  BEGIN {
    insertion = ""
    while ((getline line < insertion_file) > 0) insertion = insertion line "\n"
    close(insertion_file)
    in_photos = 0; done = 0
  }
  /^const PHOTOS = \[/ { in_photos = 1; print; next }
  in_photos == 1 && done == 0 && /^\];/ {
    printf "%s", insertion
    print
    in_photos = 0
    done = 1
    next
  }
  { print }
' "$INDEX_FILE" > "$tmp_file"
rm -f "$insertion_file"

# Safety: tmp file must contain ALL the new entries we added
for entry in "${added_entries[@]}"; do
  if ! grep -qF "$entry" "$tmp_file"; then
    echo "✗ Insertion check failed — PHOTOS array marker not found. Aborting; index.html unchanged." >&2
    rm -f "$tmp_file"
    exit 1
  fi
done

mv "$tmp_file" "$INDEX_FILE"

echo ""
echo "✓ Added $added_count photo(s):"
for line in "${renamed_log[@]}"; do
  echo "    $line"
done

# Stage the changes (commit/push left to the operator)
git add "$IMAGES_DIR" "$INDEX_FILE" 2>/dev/null || true

echo ""
echo "✓ Staged. Review with:  git status && git diff --cached"
echo "  Then commit and push when ready."
