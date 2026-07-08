# nixie-homes — project directives

## Agent conventions

Any message prefixed with `question:` is a purely theoretical/discussion
request. Treat it as a request for information, reasoning, or discussion
only — **never** as an instruction to perform an action (no file edits,
commits, deployments, or other side effects), regardless of how the rest
of the phrasing reads.

See [ARCHITECTURE.md](./ARCHITECTURE.md) for how this repo fits alongside
[nixie](https://github.com/amatos/nixie) (still a placeholder until the
home-manager migration below lands).

## What this is

nixie-homes holds standalone [home-manager](https://github.com/nix-community/home-manager)
configuration for alberth (and, potentially, other users in the future) — usable two ways:

- **Standalone**, on any machine with Nix, independent of nixie: `home-manager switch
  --flake github:amatos/nixie-homes#<user>@<host>`. No NixOS or nix-darwin required.
- **Integrated**, consumed by nixie's own NixOS/darwin-managed home-manager as an
  external flake input, the same way nixie already consumes `nix-secrets` and
  `keytabs-matos-cc`.

**The dependency direction is one-way: nixie depends on nixie-homes, never the
reverse.** Unlike `nix-secrets`/`keytabs-matos-cc` (plain `flake = false` repos),
nixie-homes is a real flake with its own `nixpkgs`, `home-manager`, `nvf`, `qmd`,
`stylix`, and `nix-secrets` (`flake = false`) inputs — that's what makes standalone
use possible. It must never reach back into nixie: no relative-path imports crossing
the repo boundary (e.g. `../../users.nix`), no shared state. Where nixie's home
config previously imported nixie's `users.nix` directly for `email`/`gpgSigningKey`,
this repo keeps its own small, local copy instead — duplicated on purpose, since the
two `users.nix` files serve different concerns (nixie's drives system accounts/SSH
keys; this one only drives git/gpg identity).

**Status: scaffold only.** The actual home-manager configuration has not moved in
yet — currently just pre-commit tooling and placeholder docs. See "Layout" below for
the planned shape once the migration (moving `home/alberth` out of nixie, with git
history) happens.

---

## Layout

Current (scaffold):

```text
flake.nix / flake.lock   # pre-commit tooling only (nixpkgs, pre-commit-hooks);
                          # no home-manager modules or outputs wired in yet
.commitlintrc.yaml        # commitlint rules, copied from nixie
.markdownlint-cli2.yaml   # markdownlint rules, copied from nixie
.gitignore                # Nix dev tooling artifacts, matches nixie's
CLAUDE.md / README.md     # this file and usage docs
ARCHITECTURE.md           # still a placeholder — populate once wired into nixie
LICENSE.md                # BSD 2-Clause
CHANGELOG.md
```

Planned, once the migration lands (do not treat as current until it has):

```text
alberth/
  default.nix         # cross-platform home-manager base (shells, git, gpg,
                       # tools, theming) — was home/alberth/default.nix
  common/*.nix
  darwin/{default,ghostty}.nix
  nixos.nix            # NixOS-integration overlay (uses osConfig — only
                        # meaningful when home-manager runs as a NixOS module)
  nvf.nix
  codex.nix, darwintron.nix, gammu.nix, template-darwin.nix  # host overlays
  scripts/*.sh
users.nix               # local email/gpgSigningKey metadata — see "What this
                         # is" above; never import nixie's users.nix from here
```

Flake outputs will expose `homeModules.<name>` (importable building blocks — matches
[DeterminateSystems' flake-schemas](https://github.com/DeterminateSystems/flake-schemas)
convention and `qmd`/`stylix`'s naming, **not** `nvf`'s older `homeManagerModules`
name, which `stylix` itself has since deprecated in favor of `homeModules`) and
`homeConfigurations."<user>@<host>"` (ready-to-use standalone configs for real
machines).

---

## Conventions

- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `chore:`, etc.), matching nixie's style, enforced by the same
  commitlint/markdownlint-cli2/nixfmt pre-commit hooks as nixie (`flake.nix`,
  `.commitlintrc.yaml`) — run `nix develop` once to install them.
- Never add a relative-path import that reaches outside this repo into nixie (or any
  other repo) — see "What this is" above. If a home-manager module needs data that
  only nixie has, thread it through `extraSpecialArgs` from the *consuming* flake
  (nixie), not by reaching backward from here.
- Modules that use `osConfig` (e.g. the planned `nixos.nix`) only work when
  home-manager runs as a NixOS/darwin module — keep those clearly separate from
  portable modules meant to work standalone too.

## Formatting

`.nix` files are formatted automatically by a git pre-commit hook — do not run
`nix fmt` manually before committing.

## Releases

Releases use CalVer, matching nixie: `yy.mm.release` (e.g. `26.07.01`).

- The release counter resets to `01` at the start of each new month.
- Tags are GPG-signed: `git tag -s yy.mm.release -m "Release yy.mm.release"`.
- Before tagging, check the highest existing tag for the month:
  `git tag --list 'yy.mm.*' | sort`
- Combine all changes since the last release into a single `CHANGELOG.md`
  entry named after the tagged version.

**Never add a `Co-Authored-By` trailer** (or any other AI/tool attribution tag) to a
commit without explicitly asking the user first and receiving permission.

## Before making changes

1. Check "What this is" above before adding anything that imports from or otherwise
   depends on nixie — it isn't allowed; this repo must stand alone.
2. Check this file's "Layout" section before adding a new top-level directory — the
   planned shape (flattened `alberth/`, no redundant `home/` prefix) is intentional.
3. Propose structural/architectural changes before implementing — describe the
   approach and wait for confirmation, per nixie's own convention.
