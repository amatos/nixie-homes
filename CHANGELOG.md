# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Repo scaffolded: `CLAUDE.md`, `ARCHITECTURE.md`, `README.md`,
  `LICENSE.md` (BSD 2-Clause), `CHANGELOG.md`
- `flake.nix`/`flake.lock` — pre-commit tooling only (`nixpkgs`,
  `pre-commit-hooks`), no system builds; same `nixfmt`/`markdownlint-cli2`/
  `commitlint` hook set as nixie, installed via `nix develop`
- `.commitlintrc.yaml`/`.markdownlint-cli2.yaml` — copied from nixie so the
  new hooks have rules to enforce
- `.gitignore` — `/.direnv`, `/result`, `/.pre-commit-config.yaml`,
  `/.claude`, matching nixie's

### Changed

- `CLAUDE.md` — populated (was empty): project directives adapted from
  nixie's own `CLAUDE.md` — standalone-vs-integrated usage, the one-way
  dependency rule (never reach back into nixie), current vs. planned
  `Layout`, `homeModules` output naming rationale, and commit/release
  conventions matching nixie
