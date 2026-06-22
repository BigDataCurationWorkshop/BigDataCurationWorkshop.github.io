# Extreme Curation 2026 — Workshop Website

Source for the website of the **First Annual IEEE Workshop on Curation and
Contextualization of Extreme Datasets (Extreme Curation 2026)**, co-located
with IEEE BigData 2026 (Phoenix, AZ, December 14–17 2026).

Built with [Jekyll](https://jekyllrb.com/) using the
[Feeling Responsive](https://github.com/Phlow/feeling-responsive) theme
(pulled in via `remote_theme`, not vendored locally) and deployed to
GitHub Pages.

## Prerequisites

This site is built with [Jekyll](https://jekyllrb.com/), which is a
**Ruby** program. You don't need to know Ruby or Jekyll to build the
site — you just need Ruby itself installed, plus a Ruby package
manager called **Bundler**. The steps below assume you have never
installed Ruby before and walk through it from scratch.

GitHub Actions (the thing that builds the live site) uses **Ruby
3.1**. Match that version if you can, to minimize "works on GitHub but
not on my machine" surprises.

### Step 1: Check whether you already have Ruby

Open a terminal and run:

```bash
ruby -v
```

- If you see something like `ruby 3.1.x ...` or higher, skip to
  **Step 3**.
- If you see `ruby 2.x` (e.g. macOS's built-in system Ruby is often
  2.6), don't use it — it's old enough to cause gem version errors.
  Continue to Step 2 to install a newer one.
- If you see `command not found`, continue to Step 2.

### Step 2: Install Ruby

Don't install Ruby system-wide if you can avoid it (it usually
requires `sudo` and makes upgrading painful later). Instead, install a
**Ruby version manager**, which installs Ruby into your home
directory and lets you switch versions per-project. This repo uses
[`rbenv`](https://github.com/rbenv/rbenv) as an example below, but
[`rvm`](https://rvm.io/) or [`asdf`](https://asdf-vm.com/) work
similarly.

**macOS** (using [Homebrew](https://brew.sh/) — install Homebrew first
if you don't have it, via the command on that site):

```bash
brew install rbenv ruby-build
rbenv init
# Follow the printed instructions to add rbenv to your shell startup
# file (e.g. ~/.zshrc), then restart your terminal or run:
exec $SHELL

rbenv install 3.1.0
cd /path/to/ExtremeDataCurationWorkshop.github.io
rbenv local 3.1.0
```

**Linux (Debian/Ubuntu)**:

```bash
sudo apt update
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev \
  autoconf bison build-essential libyaml-dev libreadline-dev \
  libncurses5-dev libffi-dev libgdbm-dev

curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
# Follow the printed instructions to add rbenv to your shell startup
# file (e.g. ~/.bashrc), then restart your terminal or run:
exec $SHELL

rbenv install 3.1.0
cd /path/to/ExtremeDataCurationWorkshop.github.io
rbenv local 3.1.0
```

**Windows**: the simplest path is to install
[WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install)
first, then follow the Linux instructions above inside your WSL
terminal. (Native Windows Ruby via
[RubyInstaller](https://rubyinstaller.org/) also works, but the
Feeling Responsive theme and Jekyll tooling are most predictably
behaved on Linux/macOS.)

After installing, confirm it worked:

```bash
ruby -v
# should now print 3.1.x (or whatever version you installed)
```

If it still shows an old version or "command not found," your shell
likely needs to be restarted, or rbenv wasn't added to your shell
startup file correctly — re-check the "Follow the printed
instructions" step above.

### Step 3: Install Bundler

Bundler is Ruby's equivalent of `npm`/`pip` — it reads the `Gemfile`
in this repo and installs exactly the gem (Ruby package) versions
listed in `Gemfile.lock`.

```bash
gem install bundler
bundle -v
```

This should print a Bundler version with no errors. If you get a
permissions error here, it almost always means Ruby is still pointing
at a system install rather than the rbenv one from Step 2 — re-check
that step rather than re-running this with `sudo`.

## Setup

```bash
git clone <repo-url>
cd ExtremeDataCurationWorkshop.github.io
bundle install
```

`bundle install` reads `Gemfile`/`Gemfile.lock` and downloads/installs
every Ruby package this site needs (Jekyll itself, the Sass
processor, a few Jekyll plugins) into a project-local location — it
does not touch anything outside this folder.

This installs a standalone Jekyll (not the `github-pages` gem) with
`jekyll-sass-converter` pinned to 1.x — required because the Feeling
Responsive theme's Foundation grid Sass breaks under Sass 2.x. See the
comments in `Gemfile` for details. You don't need to understand why;
just don't delete that pin.

If `bundle install` fails with something mentioning the `ffi` gem and
a version number, your Ruby is too old (see Step 2 above) — upgrading
Ruby is the real fix; the `ffi` pin already in `Gemfile` is only a
fallback for people stuck on old Ruby.

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
