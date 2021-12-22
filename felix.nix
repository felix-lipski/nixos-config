{ lib, pkgs, config, inputs, ... }:
let
  spacelixVariant = "dark";
  # palette = config.ui.spacelix."${spacelixVariant}".withGrey;
  palette = import ./gruvbox.nix;
  font = "Terminus";
  utils = (import ./utils.nix) {lib=lib;};
  futhark-vim = pkgs.vimUtils.buildVimPlugin {
    name = "futhark-vim";
    src = inputs.futhark-vim;
  };
  wallpaper = (import ./wallpaper.nix) {inherit pkgs inputs palette;};

  # change to palette_felix for dark mode
  palette = palette_sara;
in
with palette; {
  console.colors = map (lib.strings.removePrefix "#") ([
    black red green yellow blue magenta cyan white
    grey red green yellow blue magenta cyan white
  ]);
  users.users.felix = {
    password = "n";
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ];
  };
  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      felix = {
        home.file = {
          ".xinitrc".text = "exec xmonad";
          ".xmobarrc".text =
          (utils.interpolateColors palette
            (builtins.readFile ./resources/xmobarrc.hs)
          );
          "wallpaper.png".source = ''${wallpaper}/wallpaper.png'';
          ".config/nvim/colors/xelex.vim".source = resources/xelex.vim;
          ".config/nvim/coc-settings.json".text = ''{"suggest.noselect": false}'';
          ".doom.d/themes/doom-spacelix-theme.el".text = 
            (utils.interpolateColors palette
              (builtins.readFile ./resources/doom-spacelix-theme.el)
            );
          ".agda".source = (import resources/agda-dir.nix) { inherit pkgs; };
        };
        home.sessionPath = [ "$HOME/.emacs.d/bin" ];
        xsession = {
          enable = true;
          windowManager.xmonad = {
          enable = true;
	      enableContribAndExtras = true;
            config = pkgs.writeText "xmonad.hs" 
              (utils.interpolateColors palette
                (builtins.readFile ./resources/xmonad.hs)
              );
	      };
	    };
        services.lorri.enable = true;
        services.picom = {
          enable = true;
          activeOpacity = "0.8";
          inactiveOpacity = "0.8";
          shadow = true;
          extraOptions = ''
            corner-radius = 10;
          '';
        };
	    home.packages = with pkgs; [
          haskellPackages.xmobar nitrogen
	      brave mpv
          gnumake gcc cmake direnv unzip
          tmux ripgrep coreutils
          dmenu lf sxiv vimv
          xcape
          yarn
          slack
          cabal2nix cabal-install
          (agda.withPackages [ agdaPackages.standard-library ])
          inputs.nix-boiler.defaultPackage."x86_64-linux"
	    ];
        programs = {
          alacritty = {
            enable = true;
            settings = {
              shell.program = "zsh";
              font = {
                size = 12;
                # size = 9;
                normal.family = font;
                bold.family   = font;
                italic.family = font;
              };
              cursor.style = "Beam";
              colors = rec {
                primary = {
                  background = black;
                  foreground = white;
                };
                normal = { inherit black red green yellow blue magenta cyan white; };
                dim    = normal;
                bright = normal // { black = grey; };
              };
              window.padding = {
                x = 4;
                y = 4;
              };
            };
          };
          zsh = {
            enable = true;
            dotDir = ".config/zsh";
            shellAliases = {
	          ls       = "ls --color";
              l        = "ls -la";
              v        = "nvim";
	          m        = "make";
              e        = "make edit";
	          c        = "cd";
	          g        = "git";
              x        = "exit";
              z        = "zathura";
              s        = "sxiv";
	          pgl      = "git log --pretty=oneline";
              nsh      = "nix develop --command zsh";
              nunfree  = "export NIXPKGS_ALLOW_UNFREE=1";
              xc       = "xcape -e 'Super_L=Escape'";
              gcroots  = "nix-store --gc --print-roots | grep home/"; 
              forkterm = "alacritty & disown";
            };
            localVariables = {
              PROMPT = "%B%F{blue}%n%f %F{green}%~%f%b ";
              EDITOR = "nvim";
              F = "https://github.com/felix-lipski/";
              # export PATH="$HOME/.npm-packages/bin:$PATH"
            };
            initExtra = lib.fileContents ./resources/zshrc;
          };
          neovim = {
            enable = true;
            plugins = with pkgs.vimPlugins; [ 
              # general
              gruvbox 
	          nvim-treesitter
              vim-commentary
	          vim-css-color
              goyo-vim
              # misc langs
              vim-glsl
              # functional langs
	          vim-nix
              vim-ocaml
              futhark-vim
              haskell-vim
              agda-vim
              conjure
              aniseed
              ats-vim
              # soydev langs
              vim-closetag
              coc-nvim
            # coc-tsserver
            # coc-eslint
            # coc-tslint
            # coc-snippets
              coc-prettier
            ];
            extraConfig = lib.fileContents ./resources/init.vim;
          };
          git = {
            enable = true;
            # userEmail = "felix.lipski7@gmail.com";
            # userName = "felix-lipski";
            extraConfig = ''
[user]
  email = "felix.lipski7@gmail.com";
  name = "felix-lipski";
[includeIf "gitdir:~/code/sara/"]
  path = ~/.gitconfig-sara
[includeIf "gitdir:~/code/work/"]
  path = ~/.gitconfig-work
[includeIf "gitdir:~/code/sara/"]
  path = ~/.gitconfig-sara
'';
          };
          zathura = {
            enable = true;
            options = { 
              default-bg = black; 
              default-fg = white; 
            };
            extraConfig = ''
              set recolor-lightcolor \${palette.black}
              set recolor-darkcolor \${palette.white}
              set recolor
            '';
          };
          qutebrowser = {
            enable = true;
            settings = {
              tabs.position = "left";
              colors = {
                tabs = {
                  even = {bg = black; fg = grey;};
                  odd = {bg = black; fg = grey;};
                  selected.even = {bg = white; fg = black;};
                  selected.odd = {bg = white; fg = black;};
                  bar.bg = black;
                  indicator = { stop = green; start = blue; error = red; };
                };
                downloads = {
                  bar.bg = black;
                  error.bg = red;
                  stop.bg = green;
                  start.bg = yellow;
                };
                statusbar = {
                  caret   = { fg = white; bg = cyan;  };
                  insert  = { fg = white; bg = green; };
                  normal  = { fg = white; bg = black; };
                  command = { fg = yellow; bg = black; };
                  url.success = { http.fg = blue; https.fg = green; };
                };
                completion = {
                  category = { bg = black; fg = white; border = { top = white; bottom = white; }; };
                  item.selected = { bg = white; fg = black; match.fg = green; border = { top = white; bottom = white; }; };
                  match.fg = green;
                  even.bg = black;
                  odd.bg = black;
                  fg = [white white blue];
                };
                webpage.darkmode.enabled = true;
                messages = {
                  error   = { fg = black;  bg = red;   border = red; };
                  info    = { fg = blue;   bg = black; border = blue; };
                  warning = { fg = yellow; bg = black; border = yellow; };
                };
              };
              fonts = let 
                bold = "bold 14px 'terminus'"; 
              in {
                tabs.selected = bold;
                tabs.unselected = bold;
                downloads = bold;
                statusbar = bold;
                completion.category = bold;
                completion.entry = bold;
                messages.info = bold;
                messages.error = bold;
                messages.warning = bold;
              };
            };
            searchEngines = {
              g = "https://github.com/felix-lipski/{}";
              y = "https://www.youtube.com/results?search_query={}";
              n = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
              w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
              aw = "https://wiki.archlinux.org/?search={}";
              nw = "https://nixos.wiki/index.php?search={}";
              google = "https://www.google.com/search?hl=en&q={}";
            };
          };
          vscode.enable = true;
        };
      };
    };
  };
}
