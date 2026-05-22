# MomentMiler — Onboarding

> A personal landscape photography portfolio. Live at **<https://momentmiler.com>**.
> This file exists so any new collaborator (human or AI agent in any IDE) can
> orient themselves in under five minutes.

---

## Project intent

A personal gallery — not a commercial site, not a SaaS. The audience is friends,
family, social followers, and the occasional photographer who lands here from a
shared link. Priorities, in order:

1. **First-impression polish** when someone opens a shared link
2. **Mobile experience** — most visitors are on phones
3. **Loading speed** — especially first paint
4. **Storytelling** — the editorial, quiet voice that runs through the copy

Things this site is *not* trying to do: SEO ranking, lead generation, e-commerce,
heavy analytics.

---

## Tech stack (intentionally tiny)

- **Plain HTML/CSS/JS** — no build step, no framework, no package.json
- All CSS lives inline in `<style>` inside each HTML file
- All JS lives inline in `<script>` at the bottom of each HTML file
- **Leaflet → replaced by a 3D globe** in the Journey section (see `index.html`)
- **Inter** font from Google Fonts
- **Hosting**: GitHub Pages (auto-deploy on push to `main`, ~30–60s)
- **Domain**: `momentmiler.com` bought through Railway (registered at Name.com).
  DNS records (`ANAME @`, `CNAME www` → `nathanchan-handsomeandcool.github.io`)
  are still managed from the Railway dashboard — **don't delete that domain
  entry** or the site will go dark.

---

## File layout

```
.
├── index.html          # ~2,400 lines — the entire main site (nav/hero/intro/gallery/
│                       #                 strip/about/journey/footer) + inline CSS + JS
├── gear.html           # ~640 lines  — My Gear sub-page (cameras / lenses / accessories)
├── CNAME               # contains: momentmiler.com  (for GitHub Pages custom domain)
├── README.md           # short stack/run notes
├── ONBOARDING.md       # this file
├── serve.ps1           # Windows-only PowerShell server (older; we use python now)
└── images/
    ├── hero-1..5.jpg           # hero crossfade
    ├── E*.jpg     (22 files)   # Europe
    ├── AC*.jpg    (11 files)   # Arctic Circle
    ├── A*.jpg     (20 files)   # Asia
    ├── SA*.jpg    (26 files)   # South America
    ├── SAF*.jpg   (9 files)    # South Africa (SAF — not SA!)
    ├── favicon/                # multi-size favicons (light/dark variants)
    └── gear/                   # 10 SVG line-art illustrations of cameras/lenses/etc.
```

Gallery photos are listed in the `PHOTOS` array near the top of `index.html`'s
`<script>` block. The array also encodes the **`cat`** for filtering:

| Prefix | `cat` value      | Filter tab label |
| ------ | ---------------- | ---------------- |
| `E`    | `europe`         | Europe           |
| `AC`   | `arctic`         | Arctic Circle    |
| `A`    | `asia`           | Asia             |
| `SA`   | `south-america`  | South America    |
| `SAF`  | `south-africa`   | South Africa     |

---

## Local development

```bash
git clone git@github.com:NathanChan-Handsomeandcool/momentmiler.git
cd momentmiler
python3 -m http.server 8080      # or: npx serve .
open http://localhost:8080/
```

No build. No install. Edit a file, refresh the browser.

---

## Deploy

```bash
git push origin main
```

GitHub Pages picks up `main` automatically. The site at `momentmiler.com` updates
in roughly 30–60 seconds. There is no staging environment — `main` is production.

If a deploy doesn't appear, check **GitHub → repo → Actions** tab for the
`pages-build-deployment` workflow.

---

## Common tasks

### Adding new photos

```bash
# 1. find next free number in the category
ls images | grep -E "^E[0-9]" | sort -V | tail -1   # e.g. E25.jpg → next is E26

# 2. resize + re-encode (works on .jpg AND .heic input)
sips -Z 2000 -s format jpeg -s formatOptions 85 ~/Desktop/source.JPG \
  --out images/E26.jpg

# 3. add one line to the PHOTOS array in index.html
#    { src: 'images/E26.jpg', title: '', loc: '', cat: 'europe' },

# 4. commit + push
git add images/E26.jpg index.html
git commit -m "Gallery: add Europe photo"
git push origin main
```

`-Z 2000` caps the long edge at 2000px (lightbox still looks sharp).
Originals frequently come in at 15–25 MB; the resized JPEGs end up around
0.5–1.5 MB.

### Editing copy (about, hero, footer, etc.)

Search for the literal string inside `index.html` and edit in place. There is no
content management layer.

### Changing the theme accent or token colors

Edit the `:root` block (light theme) and `[data-theme="dark"]` block at the top
of the `<style>` in `index.html`. **Mirror the same change in `gear.html`** —
the CSS is duplicated between the two pages (see "Known gotchas" below).

---

## Code style / aesthetic preferences

- **Editorial minimalist** — lots of whitespace, low-weight Inter type, single
  terracotta accent (`#B7472A` light / `#D86A4B` dark)
- **Italic emphasis** on the last 1–2 words of every section heading:
  *"Miles fade, Moments **remain**"*, *"The **Gallery**"*, *"Journey **so far**"*,
  *"A Collector of **Moments**"*
- **Dark mode is the default** — light mode is reachable through the
  sun/moon toggle, but most copy and imagery is tuned for dark
- **Signature**: "— Netiwat C." (right-aligned in About, used as well in Intro)

---

## Known gotchas

- **CSS is duplicated between `index.html` and `gear.html`.** A change to nav,
  footer, theme tokens, or buttons needs to be made in both files. Extracting
  to a shared `styles.css` is on the improvement list but not done yet.
- **DNS is at Railway, not Cloudflare.** Railway-managed Name.com nameservers
  hold the `ANAME @` and `CNAME www` records that point at GitHub Pages.
  Do not remove the `momentmiler.com` entry from the Railway dashboard.
- **A Cloudflare `cloudflare/workers-autoconfig` branch keeps being pushed** by
  the Cloudflare Workers bot whenever the dormant `momentmiler` Workers
  project in Cloudflare syncs the repo. Either delete the Workers project in
  Cloudflare (recommended — the site doesn't use it), or just keep pruning
  the branch with `git push origin --delete cloudflare/workers-autoconfig`.
- **`index.html` still contains two inline base64 JPEGs** (strip section and the
  about portrait, around line 1268 + 1282). They bloat the HTML to ~500 KB.
  Extracting them to real files is on the improvement list.
- **PHOTOS title/loc are empty strings** for every photo right now, so the
  lightbox caption and image `alt` text fall back to the generic word
  "Photograph". Filling in `loc` (e.g. `"Lofoten, Norway"`) is the cheapest
  way to add storytelling + accessibility.

---

## Open improvements (rough priority)

Pulled from a recent analysis. Pick whatever interests you — none of these
are blocking.

**High impact**
1. Open Graph + Twitter Card meta tags — preview image when the link is shared
2. Hero lazy-load + extract inline base64 images — faster first paint
3. Lightbox prev/next navigation (←/→ + swipe)
4. Custom `404.html`

**Polish**
5. Extract shared CSS to `styles.css`
6. Fill in `loc` for some photos
7. Mobile hero: stronger gradient so text doesn't fight the subject
8. Skeleton/shimmer while the gallery preloads image dimensions

**Nice to have**
9. EXIF readout in the lightbox (body / lens / focal / shutter)
10. Animated hometown → trip arc on the globe
11. PWA manifest + service worker for offline cache
12. Micro-blog notes under Journey (one paragraph per trip)

---

## Working across multiple IDEs / AI agents

The repo is the single source of truth. Switching between Antigravity, Claude
Code, Cursor, or just `vim` is fine — just follow:

```
git pull origin main      # before you start
… edit …
git add … && git commit -m "…"
git push origin main      # before you stop
```

Don't leave uncommitted work in one IDE and then start editing the same files
in another — that's the only way to create conflicts.
