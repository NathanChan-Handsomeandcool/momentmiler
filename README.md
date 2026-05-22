# MomentMiler — Journey Stock

A personal landscape photography portfolio capturing journeys around the world.

> "Some things are only temporary — this is my way of remembering them forever."

## Stack

- Single-file static site: `index.html` (HTML + CSS + JS inline)
- Leaflet for the interactive world map (CartoDB Positron tiles)
- Inter font (Google Fonts)
- 57 photographs from Asia, Europe, Arctic Circle, South America, South Africa

## Sections

- **Home** — Hero with 4-image crossfade slideshow (8s interval), dot selector
- **Intro** — Photographer's message card
- **Gallery** — Masonry grid with region filters and 2 randomized sets
- **About** — Bio with portrait and travel stats
- **Journey** — World map with pinned trips + horizontal timeline

## Run locally

```powershell
powershell -ExecutionPolicy Bypass -File serve.ps1
```

Then open <http://localhost:8080/>

## Deploy

The whole site is static. Drop the folder into any static host:

- [Netlify Drop](https://app.netlify.com/drop) — drag the folder, get a URL
- GitHub Pages — enable in repo Settings → Pages
- Vercel — drag & drop or connect repo
- Cloudflare Pages — connect repo

## Project layout

```
index.html          # everything: markup + styles + scripts
serve.ps1           # local dev server (PowerShell HttpListener)
scripts/
  add-photos.sh     # processes raw photos dropped into images/_inbox/
images/
  _inbox/           # raw photo drop zone (gitignored, .gitkeep tracks folders)
    europe/         # drop new Europe photos here          → renamed E<N>.jpg
    arctic/         # drop new Arctic photos here          → renamed AC<N>.jpg
    asia/           # drop new Asia photos here            → renamed A<N>.jpg
    south-america/  # drop new South America photos here   → renamed SA<N>.jpg
    south-africa/   # drop new South Africa photos here    → renamed SAF<N>.jpg
  E*.jpg AC*.jpg A*.jpg SA*.jpg SAF*.jpg   # processed gallery photos
```

## Adding new photos (the easy flow)

The hard parts (finding the next free number, resizing, editing `index.html`) are
automated. The flow is:

1. **Drag raw photos** from your computer into the matching category folder under
   `images/_inbox/`. Accepts `.jpg`, `.jpeg`, `.heic`, `.png`.
   Example: drop two photos into `images/_inbox/europe/`.
2. **Tell the assistant: "check new pictures"** (or run it yourself):

   ```bash
   ./scripts/add-photos.sh
   ```

   The script will:
   - find the next free number per category (e.g. `E26`, `E27`)
   - run `sips -Z 2000 -s format jpeg -s formatOptions 85` on each file
   - save the result as `images/E26.jpg`, `images/E27.jpg`, ...
   - delete the originals from `_inbox/`
   - append new entries to the `PHOTOS` array in `index.html`
   - `git add` the new images and `index.html`
3. **Review the diff:**

   ```bash
   git status
   git diff --cached
   ```
4. **Commit, then push when you're ready:**

   ```bash
   git commit -m "Gallery: add <region> photos"
   git push origin main
   ```

The `_inbox/` folders are gitignored, so raw drops won't bloat the repo.
`title` and `loc` are left empty (the original convention) — fill them in
later if you want lightbox captions.

Manual variant of the same flow (no script) is in `ONBOARDING.md` →
"Common tasks → Adding new photos".
