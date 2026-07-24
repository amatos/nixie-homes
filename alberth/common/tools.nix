{ pkgs, ... }:

{
  # Nushell isn't used — but every program module's enableNushellIntegration
  # (fzf, zoxide, etc.) defaults to true via home.shell.enableShellIntegration
  # regardless of whether programs.nushell.enable is set, so disabling it
  # here (once, globally) is the only way to actually turn it off rather
  # than hunting down each program's own option. Needed concretely because
  # home-manager's fzf module asserts fzf >= 0.73.0 whenever its
  # enableNushellIntegration resolves true, which the fzf package in
  # nixpkgs-stable doesn't meet (see nixie's CLAUDE.md "Nixpkgs channels").
  home.shell.enableNushellIntegration = false;

  # eza (modern ls replacement)
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [ "--header" ];
  };

  # fzf with shell integrations
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  # bat — cat clone with syntax highlighting; Dracula theme via stylix.
  programs.bat = {
    enable = true;
    config.italic-text = "always";
  };

  # btop — resource monitor
  programs.btop.enable = true;

  # tealdeer (tldr client) with auto-update
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  # zoxide — smarter cd, aliased to cd across all shells
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  # direnv with nix-direnv — shell hook integration is handled by
  # direnv-instant below instead, so disabled here to avoid double-hooking.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  # direnv-instant — non-blocking shell hook (runs direnv in a background
  # daemon so the prompt returns immediately); replaces programs.direnv's
  # own hook integration above. Defaults enable bash/zsh/fish hooks.
  programs.direnv-instant.enable = true;

  # tmux
  programs.tmux = {
    enable = true;
    mouse = true;
    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      dracula
    ];
    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"
    '';
  };
}
