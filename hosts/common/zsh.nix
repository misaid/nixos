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
      cfetch = "fastfetch -c paleofetch -l ~/.config/background --logo-height 20";
      nc = "nordvpn connect";
      nd = "nordvpn disconnect";
      sdn = "shutdown now";
      open = "xdg-open";
      clock = "tty-clock -c -s -t -C 4";
      c = "clear";
      show = "kitty +kitten icat";
      srn = "sudo reboot now";
      vi = "nvim";
      sz = "source ~/.zshrc";
      fu = "flatpak upgrade";
      setdarkmode = ''while [ 1 -eq 1 ]; do echo "Press 1 for light theme, 2 for dark theme and hit enter"; read userInput; userInput=$(echo "$userInput" | xargs); if [ "$userInput" -eq "1" ]; then theme="Adwaita"; elif [ "$userInput" -eq "2" ]; then theme="Adwaita-dark"; else clear; echo "Invalid input, try again"; continue; fi; sudo flatpak override --env=GTK_THEME=$theme; sudo flatpak override --env=QT_STYLE_OVERRIDE=$theme; clear; echo "Operation Complete"; done;'';
      flatsearch = "flatpak list | grep";
      asearch = "alias | grep";
      editalias = "nvim ~/.zsh_aliases";
      editz = "nvim ~/.zshrc";
      leet = "nvim leetcode.nvim";
      ncspot = "flatpak run io.github.hrkfdn.ncspot/x86_64/stable";
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

      copyout() {
        cat "$1" | wl-copy
      }
    '';
  };

  environment.etc."powerlevel10k/p10k.zsh".source = ./p10k/.p10k.zsh;
  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ]; # https://wiki.nixos.org/wiki/Zsh#GDM_does_not_show_user_when_zsh_is_the_default_shell
  environment.loginShellInit = ''
    # equivalent to .profile
    # https://search.nixos.org/options?show=environment.loginShellInit
  '';
}
