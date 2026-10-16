# Maintained Omarchy Spotify fork

This fork preserves the local compatibility fixes for PixelShober's Omarchy installation. The original project and MIT license remain intact.

- Maintained repository: https://github.com/PixelShober/Omarchy-Spotify
- Stable branch: `main` (also the fork's default branch)
- Upstream: https://github.com/stappmus/Omarchy-Spotify
- Plugin ID: `quickshell.spotify`, preserving settings, login and shortcuts

## Included fixes

- Resolve the plugin directory when the host removes private manifest metadata.
- Read the scoped shell's `barConfig` and keep settings current, so the personal Spotify client ID survives restarts.
- Clear stale login errors after successful session restoration.
- Use Spotify's current limit of 10 albums per artist-page request, retaining pagination.
- Expose token-free playback/API diagnostics through `omarchy shell quickshell.spotify.player debugStatus`.
- `omarchy shell quickshell.spotify.player playPlaylist <uri-or-link> <name>` plays a playlist from its first track with shuffle off and opens the full player on the queue (Spotify's Web API returns 404 for its personalized playlists such as Discover Weekly, so the queue is the visible track list).

Personal client IDs, credentials and machine configuration remain outside this repository. The upstream backend release verification is preserved; these changes do not change the Rust backend inputs.

## Updates

The installed plugin's `origin` must point to this fork. `upstream` remains a separate remote for the original project. Omarchy's updater fetches `origin HEAD` and performs a fast-forward merge; it therefore follows our stable branch instead of replacing these fixes with upstream code.

To review original updates in the development checkout:

```bash
git fetch upstream
git log --oneline HEAD..upstream/main
git diff HEAD...upstream/main
```

Merge upstream deliberately on `main`, resolve conflicts, run the checks below, and commit before pushing. Do not use GitHub's force-sync/discard-changes option on the stable branch. After publishing:

```bash
omarchy plugin update quickshell.spotify --yes
```

The current Omarchy shell retains service instances during plugin rescans. Apply changes to `Service.qml` or `SpotifyApi.qml` with `omarchy restart shell`, then verify the personal client and search in the running player.

## Checks

```bash
omarchy plugin validate .
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -input tests/tst_spotify_api.qml
OMARCHY_SPOTIFY_TEST_PLUGIN_DIR="$PWD" timeout 10s quickshell -p tests/integration/ServicePath.qml --no-color
```

For the scoped-settings regression, isolate the temporary configuration/state:

```bash
check_dir=$(mktemp -d)
OMARCHY_SPOTIFY_TEST_PLUGIN_DIR="$PWD" XDG_CONFIG_HOME="$check_dir/config" XDG_STATE_HOME="$check_dir/state" XDG_CACHE_HOME="$check_dir/cache" \
  timeout 10s quickshell -p tests/integration/ScopedSettings.qml --no-color
```

The QML checks must print `SERVICE_PATH_PASS` and `SCOPED_SETTINGS_PASS`. They disable automatic playback-backend installation.

Live validation on 2026-10-14: personal identity survives shell restart; global Kraftklub artist search returns 10 results in 597 ms; the artist page loads 10 albums and 10 songs without cooldown or error. Complete audio playback has not been tested.
