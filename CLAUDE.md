# nix-home-alberth — project directives

## Agent conventions

Any message prefixed with `question:` is a purely theoretical/discussion
request. Treat it as a request for information, reasoning, or discussion
only — **never** as an instruction to perform an action (no file edits,
commits, deployments, or other side effects), regardless of how the rest
of the phrasing reads.

See [ARCHITECTURE.md](./ARCHITECTURE.md) for how this repo fits alongside
[nixie](https://github.com/amatos/nixie) — nixie's own `ARCHITECTURE.md` has the
authoritative cross-repo picture; this repo's copy is a thinner, self-focused view.

## What this is

nix-home-alberth holds [home-manager](https://github.com/nix-community/home-manager)
configuration for alberth (and, potentially, other users in the future) — usable two ways:

- **Standalone**, on any machine with Nix, independent of nixie: `home-manager switch
  --flake github:amatos/nix-home-alberth#<user>@<host>`. No NixOS or nix-darwin required.
  Ready-to-use configs exist for `alberth@codex`, `alberth@darwintron`, and
  `alberth@gammu` (`homeConfigurations` in `flake.nix`).
- **Integrated**, consumed by nixie's own NixOS/darwin-managed home-manager via the
  `nix-home-alberth` flake input's `homeModules.<name>` outputs, the same way nixie already
  consumes `nix-secrets` and `nix-keytabs-matos-cc` for secrets — except this is a real
  flake input, not `flake = false`.

**The dependency direction is one-way: nixie depends on nix-home-alberth, never the
reverse.** Unlike `nix-secrets`/`nix-keytabs-matos-cc` (plain `flake = false` repos),
nix-home-alberth is a real flake with its own `nixpkgs`, `home-manager`, `nvf`, `qmd`,
`stylix`, and `nix-secrets` (`flake = false`) inputs (all `.follows`-pinned to
nixie's own, when consumed as its input) — that's what makes standalone use possible.
It must never reach back into nixie: no relative-path imports crossing the repo
boundary (e.g. `../../users.nix`), no shared state. `alberth/default.nix` and three
`alberth/common/*.nix` modules (`git.nix`, `gpg.nix`, `shells.nix`) import this repo's
own local `users.nix` (`email`/`gpgSigningKey`/`description`) instead of nixie's —
duplicated on purpose, since the two `users.nix` files serve different concerns
(nixie's drives system accounts/SSH keys; this one only drives git/gpg identity).

---

## Layout

```text
flake.nix / flake.lock   # nixpkgs, home-manager, nvf, qmd, stylix, nix-secrets
                          # (flake=false), pre-commit-hooks — homeModules and
                          # homeConfigurations outputs defined here
.commitlintrc.yaml        # commitlint rules, copied from nixie
.markdownlint-cli2.yaml   # markdownlint rules, copied from nixie
.gitignore                # Nix dev tooling artifacts, matches nixie's
CLAUDE.md / README.md     # this file and usage docs
ARCHITECTURE.md           # thinner, self-focused copy; nixie's is authoritative
LICENSE.md                # BSD 2-Clause
CHANGELOG.md
users.nix                 # local email/gpgSigningKey/description metadata —
                           # see "What this is" above; never import nixie's
alberth/
  default.nix         # cross-platform home-manager base (shells, git, gpg,
                       # tools, theming)
  common/*.nix
  darwin/{default,ghostty}.nix
  nixos.nix            # NixOS-integration overlay (uses osConfig — only
                        # meaningful when home-manager runs as a NixOS module,
                        # excluded from the standalone homeConfigurations below)
  nvf.nix
  codex.nix, darwintron.nix, gammu.nix, template-darwin.nix  # host overlays
  scripts/*.sh
```

Flake outputs expose `homeModules.<name>` (importable building blocks: `alberth`,
`alberth-darwin`, `alberth-nixos`, `alberth-nvf`, `alberth-codex`, `alberth-darwintron`,
`alberth-gammu` — matches
[DeterminateSystems' flake-schemas](https://github.com/DeterminateSystems/flake-schemas)
convention and `qmd`/`stylix`'s naming, **not** `nvf`'s older `homeManagerModules`
name, which `stylix` itself has since deprecated in favor of `homeModules`) and
`homeConfigurations."<user>@<host>"` (ready-to-use standalone configs — see "What
this is" above for which hosts).

Adding a new host overlay: create `alberth/<host>.nix`, add a `homeModules.alberth-<host>`
entry and (optionally) a `homeConfigurations."alberth@<host>"` entry in `flake.nix`,
commit and push. If nixie needs it, run `nix flake lock --update-input nix-home-alberth`
there afterward — it can't see an unpushed commit.

---

## Conventions

- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `chore:`, etc.), matching nixie's style, enforced by the same
  commitlint/markdownlint-cli2/nixfmt pre-commit hooks as nixie (`flake.nix`,
  `.commitlintrc.yaml`) — run `nix develop` once to install them.
- All commits must be GPG-signed (`git commit -S`), matching nixie's requirement.
  Enforced in CI by the `verify-signed-commits` job in `.github/workflows/ci.yml`.
- Never add a relative-path import that reaches outside this repo into nixie (or any
  other repo) — see "What this is" above. If a home-manager module needs data that
  only nixie has, thread it through `extraSpecialArgs` from the *consuming* flake
  (nixie), not by reaching backward from here.
- Modules that use `osConfig` (i.e. `nixos.nix`) only work when home-manager runs as a
  NixOS/darwin module — keep those clearly separate from portable modules meant to
  work standalone too, and never add them to `homeConfigurations` in `flake.nix`.

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
   flattened `alberth/` shape (no redundant `home/` prefix) is intentional.
3. Propose structural/architectural changes before implementing — describe the
   approach and wait for confirmation, per nixie's own convention.
