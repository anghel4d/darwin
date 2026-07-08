eval "$(/opt/homebrew/bin/brew shellenv)"

# nix always wins over Homebrew. brew shellenv (above) prepends /opt/homebrew/bin
# to the front, ahead of the nix paths /etc/zshenv set up. Re-prepend the nix
# profile dirs and dedupe (typeset -U keeps the first occurrence), so any tool
# both managers provide resolves to nix. brew stays available, just behind nix.
path=(
  "$HOME/.nix-profile/bin"
  /run/current-system/sw/bin
  /nix/var/nix/profiles/default/bin
  $path
)
typeset -U path


# Added by Antigravity CLI installer
export PATH="/Users/matei3d/.local/bin:$PATH"
