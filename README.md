# darwin — Matei3dMac platform configs

A submodule of [dots](https://github.com/anghel4d/dots), mounted at `darwin/`:
the dots root holds **pylon**'s (NixOS-WSL) home files; everything mac-specific
lives here, mirrored $HOME-relative so a future home-manager migration is a
mechanical move. Being a submodule, it clones and pins independently of dots.

- `.zshrc`, `.zprofile` — the mac shell (claude wrapper, prompt, brew→nix
  PATH guards).
- `.config/ghostty/config` — Ghostty (now installed via nix-darwin's
  `ghostty-bin`, config unchanged).
- `.local/bin/sudo-askpass` — GUI password prompt for `sudo -A`; exported
  as `SUDO_ASKPASS` from `.zshrc` so sudo works from no-TTY contexts.
- `.claude/` — a **copy** of the mac's Claude Code config (settings + user
  skills). The root-level `.claude/` is pylon's; the two are intentionally
  separate. Copies flow **from** `~/.claude` **into** here — never deploy this
  directory back over a live `~/.claude`.
- `Library/Preferences/com.apple.Terminal.plist` — Terminal.app profiles,
  stored as XML (`plutil -convert xml1`); restore with
  `plutil -convert binary1 -o ~/Library/Preferences/com.apple.Terminal.plist <file>`.

The mac's system configuration itself (packages, brew remnant, defaults) is
declarative in `../nixos-config/darwin.nix`.
