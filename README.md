# darwin — Matei3dMac platform configs

A submodule of [dots](https://github.com/anghel4d/dots), mounted at `darwin/`:
the dots root holds **pylon**'s (NixOS-WSL) home files; everything mac-specific
lives here, mirrored $HOME-relative. Being a submodule, it clones and pins
independently of dots.

The shell, terminal and askpass configs are now home-manager-managed from
`../nixos-config` (`home.nix` + the `home/` sources); a `darwin-rebuild switch`
deploys them. What remains here is the mac home state home-manager can't own —
files a daemon or app rewrites, where a read-only /nix/store symlink would lose:

- `.claude/` — a **copy** of the mac's Claude Code config (settings + user
  skills). The root-level `.claude/` is pylon's; the two are intentionally
  separate. Copies flow **from** `~/.claude` **into** here — never deploy this
  directory back over a live `~/.claude`.
- `Library/Preferences/com.apple.Terminal.plist` — Terminal.app profiles,
  stored as XML (`plutil -convert xml1`); restore with
  `plutil -convert binary1 -o ~/Library/Preferences/com.apple.Terminal.plist <file>`.

The mac's system configuration itself (packages, brew remnant, defaults) is
declarative in `../nixos-config/darwin.nix`.
