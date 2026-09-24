{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;

      # Powerlevel10k loads as the omz theme so exactly one prompt framework
      # is active. (Previously omz fell back to robbyrussell, which loaded
      # alongside p10k from promptInit below and fought it.)
      theme = "powerlevel10k";
      custom = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";

      plugins = [
        "git"
        "sudo"
        "tmux"
        "docker"
        "pipenv"
        "python"
        "dotnet"
        "zoxide"
      ];
    };

    shellAliases = {
      fzc = "fzf | wl-copy";
      sdn = "shutdown now";
      open = "xdg-open";
      clock = "tty-clock -c -s -t -C 4";
      c = "clear";
      show = "kitty +kitten icat";
      srn = "sudo reboot now";
      vi = "nvim";
      fu = "flatpak upgrade";
      fix_bluetooth = "~/Scripts/fix_bt_1.sh";
      flatsearch = "flatpak list | grep";
      asearch = "alias | grep";
      ocon = "~/Scripts/ocon.zsh";
      leet = "nvim leetcode.nvim";
      ncspot = "flatpak run io.github.hrkfdn.ncspot/x86_64/stable";
      srtw = "~/Scripts/reboot-to-windows.zsh";
      cherish = "~/Projects/learnrust/cherish/target/debug/cherish";
    };

    # Only the p10k *user config* is sourced here — the theme itself loads
    # via ohMyZsh above. promptInit runs last in /etc/zshrc, which is the
    # correct p10k ordering (theme first, user config after).
    # NOTE: the omz module wipes promptInit with mkDefault, but an explicit
    # value like this one still wins, so this survives.
    promptInit = ''
      source /etc/powerlevel10k/p10k.zsh
    '';

    interactiveShellInit = ''
      setopt NO_BEEP

      export EDITOR="nvim"
      export HISTFILE="$HOME/.zsh_history"
      export OPENAI_API_KEY=""

      HISTSIZE=10000
      SAVEHIST=10000
      export ANDROID_HOME="$HOME/Android/Sdk"
      export ANDROID_SDK_ROOT="$ANDROID_HOME"
      export _JAVA_AWT_WM_NONREPARENTING=1

      export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
      export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    '';
  };

  environment.etc."powerlevel10k/p10k.zsh".source = ../p10k/.p10k.zsh;
  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  users.defaultUserShell = pkgs.zsh;
}
