
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    

    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh ={
    enable = true;

    plugins = [
      "git"
      "sudo"
      "tmux"
      "docker"
      "pipenv"
      "python"
      "archlinux"
      "dotnet"
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
      pacsearch = "pacman -Q | grep";
      flatsearch = "flatpak list | grep";
      asearch = "alias | grep";
      ocon = "~/Scripts/ocon.zsh";
      leet = "nvim leetcode.nvim";
      ncspot = "flatpak run io.github.hrkfdn.ncspot/x86_64/stable";
      srtw = "~/Scripts/reboot-to-windows.zsh";
      cherish = "~/Projects/learnrust/cherish/target/debug/cherish";
    };

    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source /etc/powerlevel10k/p10k.zsh
    '';

    interactiveShellInit = ''
      setopt NO_BEEP

      export EDITOR="nvim"
      export HISTORY="$HOME/.zsh_history"
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

environment.etc."powerlevel10k/p10k.zsh".source =
  ../p10k/.p10k.zsh;
  environment.systemPackages = with pkgs; [
    zsh
    zsh-powerlevel10k
    fastfetch
  ];

  users.defaultUserShell = pkgs.zsh;
}
