# Extreme Curation 2026 — Workshop Website

Source for the website of the **First Annual IEEE Workshop on Curation and
Contextualization of Extreme Datasets (Extreme Curation 2026)**, co-located
with IEEE BigData 2026 (Phoenix, AZ, December 14–17 2026).

Built with [Jekyll](https://jekyllrb.com/) using the
[Feeling Responsive](https://github.com/Phlow/feeling-responsive) theme
(pulled in via `remote_theme`, not vendored locally) and deployed to
GitHub Pages.

## Prerequisites

- **Ruby** 3.0+ (GitHub Actions builds with 3.1 — see
  `.github/workflows/`). If you're stuck on Ruby 2.6 and see `ffi`
  version errors, see the note at the bottom of `Gemfile`.
- **Bundler** (`gem install bundler` if you don't already have it)

## Setup

```bash
git clone <repo-url>
cd ExtremeDataCurationWorkshop.github.io
bundle install
```

This installs a standalone Jekyll (not the `github-pages` gem) with
`jekyll-sass-converter` pinned to 1.x — required because the Feeling
Responsive theme's Foundation grid Sass breaks under Sass 2.x. See the
comments in `Gemfile` for details.

## Local preview

```bash
bundle exec jekyll serve
```

Then open `http://localhost:4000`.

**⚠️ SSL note:** `jekyll-remote-theme` fetches the Feeling Responsive
theme from GitHub over HTTPS at build time. If your machine's SSL/CA
setup isn't cooperating (common on corporate networks/VPNs), the build
will fail to download the theme. See `_config_local.yml` for two
workarounds:

- **Fix SSL** (recommended): add your CA cert to the system trust
  store, then `bundle exec jekyll serve` as above.
- **Skip local preview**: push your branch and preview via GitHub
  Pages instead (see Deployment below). The theme has no gem-based
  fallback, so this is the only option if SSL can't be fixed locally.

## Build only (no server)

```bash
bundle exec jekyll build
```

Output goes to `_site/` (git-ignored).

## Deployment

GitHub Pages deployment is automated via
`.github/workflows/` using GitHub Actions: pushes to `main` trigger a
build (Ruby 3.1, `bundle exec jekyll build`) and publish to Pages.
Active development currently happens on the `feeling-responsive`
branch; merge to `main` (or push and preview on a Pages-enabled branch
per `_config_local.yml`) to publish.

## Repo structure notes

- `_config.yml` — site config, nav, footer credits, theme settings
- `_data/` — navigation and author data used by the theme
- `_layouts/page.html` — local override of the theme's `page` layout
  (widens the content column)
- `_includes/_footer.html` — local override of the theme's footer
  (removes a duplicate "back to top" caret the theme would otherwise
  render twice)
- `_plugins/fix_foundation_grid.rb` — Jekyll generator that patches the
  theme's Sass at build time to fix `calc()`-related arithmetic bugs
  under Sass 2.x — needed for the grid to render correctly; don't
  remove without re-checking the grid layout
- `assets/img/banner.jpg` — homepage/page banner image (credited in
  the footer)
- `cfp.md`, `organizers.md`, `schedule.md`, `speakers.md`,
  `logistics.md`, `index.md` — page content; several still contain
  placeholder text pending finalized details
