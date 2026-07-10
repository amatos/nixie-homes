{ config, ... }:

# Zed settings are hand-edited via the app itself (command palette:
# "zed: open settings"), not authored as Nix. Rather than a `text =` block
# (which would make ~/.config/zed/settings.json a read-only store symlink,
# breaking that workflow), symlink straight to the real file living in this
# repo's working copy — edits made through Zed land directly on a
# repo-tracked file, to be committed here whenever you want to snapshot them.
#
# Requires nix-home-alberth checked out at ~/Projects/nix-home-alberth on any
# machine consuming this module; a plain string (not a Nix path literal) is
# used so it isn't resolved against the flake's store-copied source when
# nix-home-alberth is consumed as a locked flake input.
{
  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/nix-home-alberth/alberth/common/zed/settings.json";
}
