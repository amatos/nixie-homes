# Local user identity metadata for home-manager modules (git/gpg signing).
# Deliberately separate from nixie's own users.nix (system accounts, SSH
# keys, uids) — this repo must never import across the repo boundary. See
# CLAUDE.md "What this is". Duplicated on purpose: the two files serve
# different concerns and happen to share values today.
{
  primaryUser = "alberth";

  alberth = {
    description = "Alberth Matos";
    email = "alberth@matos.cc";
    gpgSigningKey = "F41BDBF6171A3BB4";
  };
}
