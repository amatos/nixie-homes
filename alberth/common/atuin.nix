# atuin — magical shell history.
# https://atuin.sh
#
# Shell integrations for bash, zsh, and fish are enabled automatically.
# --disable-up-arrow is passed to `atuin init` so up-arrow uses native shell
# history; atuin search is accessible via Ctrl-R only.
# ai.enabled = false disables the `?`-at-empty-prompt keybind (Atuin AI /
# natural language mode) that atuin's shell integration binds by default.
_:

{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = true;
      search_mode = "fuzzy";
      sync_address = "https://api.atuin.sh";
      sync_frequency = "5m";
      filter_mode = "global";
      style = "compact";
      ai.enabled = false;
    };
  };
}
