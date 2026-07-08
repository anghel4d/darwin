# brew→nix migration: openjdk now comes from nix-darwin (pkgs.jdk in
# environment.systemPackages). Guarded so it self-disables once the brew keg
# is uninstalled by the declarative cleanup; delete after the first switch.
[ -d /opt/homebrew/opt/openjdk/bin ] && export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# ls bindings
alias ls='eza --icons --group-directories-first --time-style=long-iso'
alias ll='eza -l --icons --git --group-directories-first --time-style=long-iso --group --all'
alias la='eza -la --icons --git --group-directories-first --time-style=long-iso --group'
alias lt='eza --tree --icons --git-ignore'


autoload -Uz colors && colors
setopt prompt_subst

PROMPT='%F{blue}$(basename "$(dirname "$PWD")")%f %F{magenta}➤%f %F{green}$(basename "$PWD")%f %F{cyan}%#%f '


#PROMPT='
#%F{yellow}$(date "+%a %b %d, %H:%M:%S")%f
#%F{blue}$(basename "$(dirname "$PWD")")%f%F{magenta}➤%f%F{green}$(basename "$PWD")%f
#%F{cyan}%#%f '


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/matei3d/.opam/opam-init/init.zsh' ]] || source '/Users/matei3d/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

[ -f "/Users/matei3d/.ghcup/env" ] && . "/Users/matei3d/.ghcup/env" # ghcup-envexport PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# brew→nix migration: LLVM 22 (clang/clang++/lld/lldb) now comes from nix-darwin
# (llvmPackages_latest in environment.systemPackages), still ahead of Apple clang.
# Guarded so it self-disables once the brew keg is uninstalled by the declarative
# cleanup; delete after the first switch.
[ -d /opt/homebrew/opt/llvm/bin ] && export PATH="/opt/homebrew/opt/llvm/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/matei3d/.local/bin:$PATH"

# Vulkan SDK (LunarG): sets VULKAN_SDK + PATH (glslc), loader & layers.
# VULKAN_SDK is what CMake's find_package(Vulkan) keys off to locate glslc.
[ -f "$HOME/VulkanSDK/1.4.350.0/setup-env.sh" ] && source "$HOME/VulkanSDK/1.4.350.0/setup-env.sh" >/dev/null 2>&1

# Pin git (and only git) to UTC: all commit dates display in UTC, and new commits
# record a +0000 offset. The rest of the shell keeps the system local zone.
# Paired with `git config --global log.date iso-local` / `blame.date iso-local`.
git() {
  TZ=UTC command git "$@"
}

# Run Claude Code under two guarantees that last exactly as long as the session:
#   1. caffeinate -i holds a power assertion, so the Mac never idle-sleeps while
#      claude is running; the assertion is released the instant claude exits.
#   2. the process tree is reniced to -10 so claude (and every compile/test it
#      spawns, which inherit the nice value) outranks default-priority apps like
#      the browser. Negative nice needs root, so a detached one-shot uses
#      `sudo -n renice`; this requires the one-time grant in
#      /etc/sudoers.d/claude-priority. Without that grant sudo -n no-ops silently
#      and only the caffeinate half takes effect — nothing breaks.
# Add `-d` to caffeinate below if you also want the display kept awake.
claude() {
  emulate -L zsh
  local bin; bin=$(whence -p claude) || { print -ru2 -- "claude: not found in PATH"; return 127; }

  # Snapshot claude pids already running, so the watcher boosts only the session
  # we're about to start and never a pre-existing one. caffeinate exec's the real
  # binary, so the new claude process has argv[0] == "$bin" and is matched by
  # "^$bin" (caffeinate's and pgrep's own argv are excluded by the anchor).
  local before; before=" $(pgrep -f "^$bin" 2>/dev/null | tr '\n' ' ') "
  {
    local p i
    for i in {1..40}; do
      for p in $(pgrep -f "^$bin" 2>/dev/null); do
        if [[ "$before" != *" $p "* ]]; then
          sudo -n /usr/bin/renice -10 -p "$p" >/dev/null 2>&1
          break 2
        fi
      done
      sleep 0.2
    done
  } &!

  caffeinate -i "$bin" "$@"
}

# Nix
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
