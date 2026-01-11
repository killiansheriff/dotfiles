# 🏠 Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Works on **macOS** and **Linux** with automatic OS-specific configuration.

---

## 📦 What's Included

| File | Description |
|------|-------------|
| `.zshrc` | Zsh configuration (minimal, no framework) |
| `.bashrc` | Bash configuration |
| `.zprofile` | Login shell config (macOS) |
| `.gitconfig` | Git configuration with aliases |
| `.gitignore_global` | Global gitignore patterns |
| `.ssh/config` | SSH configuration with multiplexing |
| `.config/shell/aliases.sh` | Shell aliases (git, navigation, Slurm, etc.) |
| `.config/shell/exports.sh` | Environment variables, PATH, FZF/Nord themes |
| `.config/shell/functions.sh` | Utility functions (`texclean`, `extract`, `mkcd`, etc.) |
| `.config/shell/local.sh` | Machine-specific config (not tracked) |
| `.config/dircolors/nord.dircolors` | Nord theme colors for ls/tree |
| `.config/cursor/profiles/` | Cursor importable profiles (includes extensions) |

### 🚀 Auto-Bootstrap

On first run, chezmoi automatically:
- Installs Homebrew (macOS) or apt packages (Linux)
- Installs CLI tools: `eza`, `bat`, `fzf`, `zoxide`, `fd`, `ripgrep`
- Clones zsh plugins (autosuggestions, syntax-highlighting)
- Creates SSH directories with correct permissions

---

## 🚀 Quick Start

### 1. Install chezmoi

**macOS:**
```bash
brew install chezmoi
```

**Linux (Debian/Ubuntu):**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

```

### 2. Clone & Initialize

```bash
# Clone the dotfiles repo
chezmoi init https://github.com/killiansheriff/dotfiles.git

# You'll be prompted for:
#   - Email address
#   - Full name
#   - GitHub username
```

### 3. Preview Changes

```bash
chezmoi diff          # See what will change (press q to exit)
```

### 4. Apply

```bash
chezmoi apply -v      # Apply with verbose output
```

This will automatically:
- Install Homebrew (macOS) or apt packages (Linux)
- Install CLI tools: eza, bat, fzf, zoxide, fd, ripgrep
- Clone zsh plugins (autosuggestions, syntax-highlighting)
- Create all dotfiles

### 5. Reload Shell

```bash
reload    # Works for both zsh and bash
# Or just open a new terminal
```

---

## 🔄 Updating on Existing Machine

If you've made changes to the source and want to re-apply:

```bash
chezmoi apply -v
```

If you added new config prompts (like github_username):

```bash
chezmoi init          # Re-prompts for all values
chezmoi apply -v
```

---

## 🛠️ Required & Recommended Tools

### Required

| Tool | Purpose | macOS | Linux (Debian/Ubuntu) |
|------|---------|-------|----------------------|
| [chezmoi](https://www.chezmoi.io/) | Dotfile manager | `brew install chezmoi` | [See install guide](https://www.chezmoi.io/install/) |

### Recommended CLI Tools

These tools enhance your shell experience. The aliases/config auto-detect if they're installed:

| Tool | Purpose | macOS | Linux |
|------|---------|-------|-------|
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement | `brew install eza` | `cargo install eza` or [deb](https://github.com/eza-community/eza/releases) |
| [bat](https://github.com/sharkdp/bat) | Better `cat` with syntax highlighting | `brew install bat` | `sudo apt install bat` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `brew install fzf` | `sudo apt install fzf` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` | `brew install zoxide` | `cargo install zoxide` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep | `brew install ripgrep` | `sudo apt install ripgrep` |
| [fd](https://github.com/sharkdp/fd) | Fast find | `brew install fd` | `sudo apt install fd-find` |

### Zsh Plugins (optional)

Install these for better autocompletion and syntax highlighting:

```bash
# Create plugin directory
mkdir -p ~/.zsh

# Autosuggestions (gray suggestions as you type)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# Syntax highlighting (colorize commands as you type)
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
```

---

## 📝 Daily Workflow

### Quick Commands

```bash
cze ~/.zshrc       # Edit a dotfile (opens source, applies after save)
czd                # Preview pending changes
cza                # Apply changes
czcd               # cd to chezmoi source directory
```

### Making Changes

1. **Edit the source file** (not the target):
   ```bash
   chezmoi edit ~/.zshrc
   # Or directly edit files in ~/.local/share/chezmoi/
   ```

2. **Preview changes**:
   ```bash
   chezmoi diff
   ```

3. **Apply changes**:
   ```bash
   chezmoi apply -v
   ```

4. **Commit and push** (if using git):
   ```bash
   cd ~/.local/share/chezmoi
   git add -A && git commit -m "Update dotfiles"
   git push
   ```

### Pulling Updates on Another Machine

```bash
chezmoi update -v
```

---

## 🔧 Machine-Specific Configuration (Secrets & Private Aliases)

For settings that shouldn't be version controlled (API keys, SSH aliases, work shortcuts), use:

```bash
~/.config/shell/local.sh
```

### How It Works

1. **On first `chezmoi apply`**: A starter template is created at `~/.config/shell/local.sh`
2. **You edit it manually**: Add your real secrets, SSH aliases, etc.
3. **Chezmoi never overwrites it**: The `create_` prefix ensures your edits are preserved

### Example `local.sh`

```bash
# SSH Connections
alias cexp="ssh user@login.expanse.sdsc.edu"
alias myserver="ssh user@server.example.com"

# API Keys (private)
export MY_API_KEY="your_secret_key"
export ANOTHER_TOKEN="your_token"

# Custom Aliases
alias pj='uv run pj'
```

### Why Not Store Secrets in Git?

Secrets should **never** be committed to git, even in a private repo. On each new machine:
1. Run `chezmoi apply` → creates the template
2. Edit `~/.config/shell/local.sh` → add your secrets
3. Your secrets stay local to that machine

> **Tip**: For synced secrets across machines, consider [1Password CLI](https://developer.1password.com/docs/cli/) or similar.

---

## 📁 Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl          # Chezmoi config with OS detection
├── .chezmoiignore              # Files to ignore per OS
├── dot_config/
│   ├── shell/
│   │   ├── aliases.sh.tmpl     # All aliases
│   │   ├── exports.sh.tmpl     # Environment variables
│   │   ├── functions.sh        # Shell functions
│   │   └── create_private_local.sh  # Template (created once, never overwritten)
│   └── cursor/
│       ├── profiles/           # Importable .code-profile files
│       │   └── default.code-profile
│       ├── extensions.txt      # Extension list
│       └── install-extensions.sh
├── dot_zshrc.tmpl              # Main zsh config
├── dot_bashrc.tmpl             # Main bash config
└── dot_zprofile.tmpl           # Login shell (macOS)
```

### Chezmoi Naming Conventions

| Prefix | Meaning |
|--------|---------|
| `dot_` | File starts with `.` (e.g., `dot_zshrc` → `.zshrc`) |
| `.tmpl` | Template file (uses Go templating) |
| `private_` | Private file (600 permissions) |
| `create_` | Create file once, never overwrite (for secrets/local config) |
| `empty_` | Ensure file exists but don't manage contents |

---

## 🔄 Syncing Across Machines

### Push changes (from machine A):
```bash
cd ~/.local/share/chezmoi
git add -A && git commit -m "Update config"
git push
```

### Pull changes (on machine B):
```bash
chezmoi update -v
# Or: chezmoi git pull && chezmoi apply
```

---

## 🎨 VS Code / Cursor Setup

This repo includes VS Code profiles and extensions that work for both **VS Code** and **Cursor**.

### Import a Profile

1. Open Cursor
2. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Linux)
3. Type **"Profiles: Import Profile..."**
4. Navigate to `~/.config/cursor/profiles/`
5. Select `default.code-profile`
6. Choose settings + extensions to import (Cursor will prompt to install extensions)

### Export Your Current Profile

1. Press `Cmd+Shift+P` / `Ctrl+Shift+P`
2. Type **"Profiles: Export Profile..."**
3. Save to `~/.local/share/chezmoi/dot_config/cursor/profiles/`
4. Run `chezmoi apply` then commit & push

Add your own profiles (e.g., `python.code-profile`, `minimal.code-profile`) as needed!

---

## ❓ Troubleshooting

### See what chezmoi will do
```bash
chezmoi status        # Show managed files and their status
chezmoi managed       # List all managed files
chezmoi data          # Show template data (OS, name, etc.)
```

### Force re-apply a file
```bash
chezmoi apply --force ~/.zshrc
```

### Debug templates
```bash
chezmoi execute-template '{{ .chezmoi.os }}'
chezmoi cat ~/.zshrc  # Show what would be written
```

---

## 📜 License

MIT
