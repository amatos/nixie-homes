{ config, ... }:

let
  userDefs = import ../../users.nix;
  user = userDefs.${userDefs.primaryUser};
in
{
  programs.git = {
    enable = true;
    signing = {
      key = user.gpgSigningKey;
      signByDefault = true;
    };
    lfs.enable = true;

    # core.excludesFile/attributesFile default to these exact XDG paths when
    # unset, so these two options are enough — no explicit path setting
    # needed. (The previous hand-placed ~/.config/git/{gitignore,gitattributes}
    # were misnamed relative to git's real defaults — "ignore"/"attributes",
    # not "gitignore"/"gitattributes" — so they were silently never read.)
    ignores = [
      "*.swp"

      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "Icon[]"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdiskre"

      # Linux
      "*~"
      ".fuse_hidden*"
      ".directory"
      ".Trash-*"
      ".nfs*"
      "nohup.out"

      # Windows
      "Thumbs.db"
      "Thumbs.db:encryptable"
      "ehthumbs.db"
      "ehthumbs_vista.db"
      "*.stackdump"
      "[Dd]esktop.ini"
      "$RECYCLE.BIN/"
      "*.cab"
      "*.msi"
      "*.msix"
      "*.msm"
      "*.msp"
      "*.lnk"

      # mise (https://mise.jdx.dev/configuration.html)
      ".mise.*.local.toml"
      ".mise.local.toml"
      "mise.*.local.toml"
      "mise.local.toml"
      ".mise/*.local.toml"
      "mise/*.local.toml"

      # VSCode
      ".vscode/*"
      "!.vscode/settings.json"
      "!.vscode/tasks.json"
      "!.vscode/launch.json"
      "!.vscode/extensions.json"
      "!.vscode/*.code-snippets"
      "!*.code-workspace"
      "*.vsix"

      "**/.claude/settings.local.json"
    ];

    attributes = [
      "* text=auto" # Automatically normalize line endings

      "*.png  binary"
      "*.jpg  binary"
      "*.jpeg binary"
      "*.bmp  binary"
    ];

    settings = {
      user = {
        name = user.description;
        inherit (user) email;
      };
      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab"; # Highlight whitespace issues
        hooksPath = "${config.home.homeDirectory}/.config/git/template/hooks"; # Global hooks for ALL repos
      };
      init = {
        defaultBranch = "main";
        templateDir = "${config.home.homeDirectory}/.config/git/template/repo";
      };
      commit = {
        gpgSign = true;
        template = "${config.home.homeDirectory}/.config/git/gitmessage";
      };
      tag.gpgSign = true;
      pull.rebase = true;
      rebase.autoStash = true;
      push.autoSetupRemote = true;
      maintenance.auto = true;
      maintenance.strategy = "incremental";
      # Fetch behavior
      fetch = {
        prune = true; # Auto-remove deleted remote branches
        pruneTags = true; # Auto-remove deleted remote tags
      };
      diff = {
        algorithm = "histogram"; # Better diff algorithm than default
        colorMoved = "default"; # Highlight moved lines in different color
        mnemonicPrefix = true; # Use i/w/c/o instead of a/b in diffs
      };

      # Dracula color theme (github.com/dracula/git), plain git coloring —
      # not delta: delta isn't installed/enabled anywhere in the fleet, so
      # the old ~/.config/git/config.delta-themes (a vendored copy of
      # delta's own community themes.gitconfig, no "dracula" theme among
      # them) was dead weight and was not ported. If delta gets enabled
      # later, source its theme from draculatheme.com/delta directly,
      # matching this project's other Dracula theming (see theming.nix).
      url."https://github.com/dracula/".insteadOf = "dracula://";
      color.ui = "auto";
      color.branch = {
        current = "cyan bold reverse";
        local = "white";
        plain = "";
        remote = "cyan";
      };
      color.diff = {
        commit = "";
        func = "cyan";
        plain = "";
        whitespace = "magenta reverse";
        meta = "white";
        frag = "cyan bold reverse";
        old = "red";
        new = "green";
      };
      color.grep = {
        context = "";
        filename = "";
        function = "";
        linenumber = "white";
        match = "";
        selected = "";
        separator = "";
      };
      color.interactive = {
        error = "";
        header = "";
        help = "";
        prompt = "";
      };
      color.status = {
        added = "green";
        changed = "yellow";
        header = "";
        localBranch = "";
        nobranch = "";
        remoteBranch = "cyan bold";
        unmerged = "magenta bold reverse";
        untracked = "red";
        updated = "green bold";
      };

      alias = {
        # Staging
        a = "add";
        aa = "add --all";
        apa = "add --patch"; # Interactively stage parts of a file.

        da = "diff";
        das = "diff --staged";
        daw = "diff --word-diff"; # show diff by word
        dasw = "diff --staged --word-diff";

        d = ''!f() { git diff                      "$@" ':(exclude)package-lock.json' ':(exclude)*.lock'; }; f'';
        ds = ''!f() { git diff --staged             "$@" ':(exclude)package-lock.json' ':(exclude)*.lock'; }; f'';
        dw = ''!f() { git diff          --word-diff "$@" ':(exclude)package-lock.json' ':(exclude)*.lock'; }; f'';
        dsw = ''!f() { git diff --staged --word-diff "$@" ':(exclude)package-lock.json' ':(exclude)*.lock'; }; f'';

        st = "status --short --branch";
        stu = "status --short --branch -u";
        stl = "status";

        # Committing
        c = "commit";
        ce = "commit --amend";
        cen = "commit --amend --no-edit --no-verify";
        ca = "!git add --all && git commit";
        cae = "!git add --all && git commit --amend";
        caen = "!git add --all && git commit --amend --no-edit --no-verify";
        cfu = "commit --fixup";

        rev = "revert";

        # Working dir & index manipulation
        co = "checkout";

        rt = "reset"; # rt <commit> -- [<path>] - undo <commit> but keep changes in working dir.
        rts = "reset --soft"; # undo commits and stage their changes

        rs = "restore --worktree"; # revert local changes
        rst = "restore --staged"; # unstage things
        rsa = "restore --worktree --staged";

        rss = "restore --worktree --source"; # specify a commit to revert to
        rsts = "restore --staged --source";
        rsas = "restore --worktree --staged --source";

        rmc = "rm --cached"; # leave worktree copy alone

        sta = "stash push";
        stam = "stash push --message";
        staa = "stash push --include-untracked";
        staam = "stash push --include-untracked --message";

        stap = "stash pop";
        stal = "stash list";
        stas = "stash show --text";

        cl = "clean -f"; # remove untracked & unignored files
        cldr = "clean --dry-run";

        # Branches
        b = "branch";
        cb = "checkout -b";
        cm = "!git checkout $(git_main_branch)";
        cd = "!git checkout $(git_develop_branch)";

        m = "merge";
        mtl = "mergetool --no-prompt";
        ma = "merge --abort";

        cp = "cherry-pick";
        cpa = "cherry-pick --abort";
        cpc = "cherry-pick --continue";
        cpq = "cherry-pick --quit";

        # Remotes
        p = "push";
        pv = "push -v";
        pdr = "push --dry-run";
        pf = "push --force-with-lease --force-if-includes";
        pfv = "push -v --force-with-lease --force-if-includes";
        pff = "push --force";
        pffv = "push -v --force";

        f = "fetch";
        fa = "fetch --all --prune";

        pl = "pull";
        plr = "pull --rebase";

        sub = "submodule";
        subu = "submodule update --init --recursive";

        # Logs (current branch)
        l = "log --pretty=lc --graph";
        lo = "log --pretty=lo --graph --date=human";
        lf = "log --pretty=lf --graph";
        ld = "log --pretty=lf --graph --cc --stat";
        lp = "log --pretty=lf --graph --cc --patch";

        # Logs, last 5 commits only
        #
        # NOTE: the original dotfiles-era config.aliases defined `ls`/`las`
        # a second time here, shadowing an earlier `ls`/`las` defined next to
        # `l`/`la` (with --simplify-by-decoration). Git's ini parser silently
        # let the later definition win, so those earlier `ls`/`las` were
        # already dead in practice; only the definitions below were ever
        # reachable, and are the only ones ported here.
        ls = "log -5 --pretty=lc --graph";
        los = "log -5 --pretty=lo --graph --date=human";
        lss = "log -5 --pretty=lo --graph --date=human --simplify-by-decoration";
        lfs = "log -5 --pretty=lf --graph";
        lds = "log -5 --pretty=lf --graph --cc --stat";
        lps = "log -5 --pretty=lf --graph --cc --patch";

        # Logs, all branches on all remotes
        la = "log --pretty=lc --graph --all";
        lao = "log --pretty=lo --graph --all --date=human";
        laf = "log --pretty=lf --graph --all";
        lad = "log --pretty=lf --graph --all --cc --stat";
        lap = "log --pretty=lf --graph --all --cc --patch";

        # Logs, all branches on all remotes, last 5 commits only
        las = "log -5 --pretty=lc --graph --all";
        laos = "log -5 --pretty=lo --graph --all --date=human";
        lass = "log -5 --pretty=lo --graph --all --date=human --simplify-by-decoration";
        lafs = "log -5 --pretty=lf --graph --all";
        lads = "log -5 --pretty=lf --graph --all --cc --stat";
        laps = "log -5 --pretty=lf --graph --all --cc --patch";

        # Shortcuts
        nevermind = "!git reset --hard HEAD && git clean -df";
        open = "!fish -c git_open";
        chash = "!git log --oneline | gum filter --height 10 | cut -d' ' -f1 | copyq copy - &>/dev/null";
      };
    };
  };

  xdg.configFile."git/gitmessage".text = ''
    [Type](Scope): <Short summary in imperative mood, max 50 chars>

    # ─── Type of change ───
    # feat: A new feature for the user.
    # fix: A bug fix.
    # docs: Documentation-only changes.
    # style: Formatting, missing semicolons, etc. (no production code changes).
    # refactor: Production code changes that neither fix a bug nor add a feature.
    # test: Adding missing tests or correcting existing tests.
    # chore: Updating build tasks, package manager configs, etc.

    # ─── Why is this change required? ───
    # - Explain the context or problem being solved.
    # - Do not explain "how" (the code shows how).

    # ─── What was changed? ───
    # - Bullet points summarizing the structural shifts.
    # - Keep lines wrapped under 72 characters.

    # ─── References / Trackers ───
    # Resolve: #JIRA-123
    # See also: #456
  '';

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "zed";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      pager = "bat";
      aliases = {
        co = "pr checkout";
      };
      color_labels = "enabled";
      accessible_colors = "disabled";
      accessible_prompter = "disabled";
      spinner = "enabled";
    };
  };
}
