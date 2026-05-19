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
images/             # 57 gallery photos (p01–p31 portrait, l01–l26 landscape)
```
