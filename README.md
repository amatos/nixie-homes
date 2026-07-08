# nixie-homes

Standalone [home-manager](https://github.com/nix-community/home-manager) configurations,
usable with or without [nixie](https://github.com/amatos/nixie). This repo is currently a
scaffold — the actual home-manager configuration has not moved in yet.

---

## Development shell

A devShell is provided for this repo's own tooling (`nixfmt`, plus the pre-commit hooks below):

```bash
cd /path/to/nixie-homes
nix develop
```

This installs `nixfmt`/`markdownlint-cli2`/`commitlint` pre-commit hooks into `.git/hooks`,
matching nixie's own hook set (`flake.nix`, `.commitlintrc.yaml`, `.markdownlint-cli2.yaml`).
