# Cursor Profiles

This directory contains exportable Cursor profiles.

## How to Import a Profile

1. Open Cursor
2. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Linux)
3. Type **"Profiles: Import Profile..."**
4. Select the `.code-profile` file from `~/.config/cursor/profiles/`
5. Choose which settings to import

## How to Export a Profile

1. Open Cursor
2. Press `Cmd+Shift+P` / `Ctrl+Shift+P`
3. Type **"Profiles: Export Profile..."**
4. Save to `~/.local/share/chezmoi/dot_config/cursor/profiles/`
5. Run `chezmoi apply` to sync

## Available Profiles

| Profile | Description |
|---------|-------------|
| `default.code-profile` | Main development profile |

Add your own profiles as needed!
