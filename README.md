# Recoll Homebrew Tap

**Homebrew tap for Recoll on macOS**

Two ways to install Recoll: pre-built binary (quick) or build from source (full features + .app bundle).

## Installation

### Option 1: Pre-built Binary (recommended)

```sh
brew tap nailuoGG/recoll
brew install --cask recoll
```

Quick install with official macOS binary, no compilation needed.

### Option 2: Build from Source

```sh
brew tap nailuoGG/recoll
brew install recoll
```

Compile from source with Qt6 GUI, Python module, fsevents, aspell, and more.
Also creates a `Recoll.app` bundle you can link to `/Applications`.

## Comparison

| Feature | Cask (`--cask recoll`) | Formula (`brew install recoll`) |
| --- | --- | --- |
| Source | Official pre-built DMG | Compiled from source |
| .app location | `/Applications/` | Cellar, link manually |
| CLI in PATH | No (inside .app) | Yes (bin/) |
| Python module | No | Yes |
| Build time | Instant | ~5-20 min |

## After Installing from Source

Add `Recoll.app` to `/Applications`:

```sh
ln -sf $(brew --prefix recoll)/Recoll.app /Applications/Recoll-from-source.app
```

CLI tools are automatically in your PATH:

```sh
recoll          # Start GUI
recollindex     # Index files
recollq         # Query index from command line
rclgrep         # Search without index
```

Configuration is stored in `~/.recoll/`.

## Details

- Cask uses official binaries from [Recoll macOS downloads](https://www.recoll.org/downloads/macos/)
- Formula builds via Meson with Qt6, Python, aspell, semantic search, webengine preview
- Packages are not digitally signed (same as official)
- Automated updates via GitHub Actions for both Cask and Formula

## Links

- [Official Recoll Site](https://www.recoll.org/)
- [This Repository](https://github.com/nailuoGG/homebrew-recoll)
