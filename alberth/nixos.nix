# Shared home-manager settings for all NixOS hosts.
#
# Auto-imports home/alberth/<hostname>.nix when it exists, so host-specific
# divergences can live in a predictably-named file without requiring a manual
# import in the host's system config.
{
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  hostName = osConfig.networking.hostName;
  hostFile = ./. + "/${hostName}.nix";
in
{
  imports = lib.optional (builtins.pathExists hostFile) hostFile;

  home.packages = with pkgs; [
    _1password-gui # 1Password desktop app
    _1password-cli # 1Password CLI (op)
    # SSH client with GSSAPI support for Kerberos authentication.
    # pkgs.openssh does not include GSSAPI; this shadows it in the user PATH.
    openssh_gssapi
    # krb5 provides kinit/klist/kdestroy for the MATOS.CC realm. Previously
    # excluded on porkchop (its system packages included krb5WithLdap, the
    # LDAP-backend build, and home packages shadow system packages in the
    # user PATH — adding the plain build here would have shadowed
    # kadmin.local's LDAP-enabled binary). No longer applicable: porkchop's
    # Kerberos+LDAP server role was decommissioned in nixie's
    # ARCHITECTURE.md §10 Stage 4, so it's a plain krb5 client like every
    # other NixOS host now.
    krb5
  ];

  home.shellAliases = {
    open = "xdg-open";
  };

  # Mask the syncthing user unit shipped by the syncthing package.
  # services.syncthing on NixOS runs syncthing as a system service; the package
  # also installs a user unit (WantedBy=default.target) which conflicts with it.
  home.activation.maskSyncthingUserService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/systemd/user"
    ln -sf /dev/null "$HOME/.config/systemd/user/syncthing.service"
  '';

  # GPG agent — use plain-text pinentry suitable for TTY / SSH sessions.
  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-tty}/bin/pinentry-tty
    '';
  };
}
