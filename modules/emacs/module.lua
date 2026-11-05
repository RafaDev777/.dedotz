return {
  description = "Doom Emacs with its CLI dependencies",

  packages = {
    -- core
    "emacs",                    -- use "emacs-wayland" instead if you want pgtk
    "git",
    "ripgrep",
    "fd",

    -- doom modules that shell out to these
    "editorconfig-core-c",
    "shellcheck",
    "aspell",
    "aspell-en",

    -- icons (nerd-icons looks for "Symbols Nerd Font Mono")
    "ttf-nerd-fonts-symbols",

  },

  post_install_hook = "scripts/emacs-doom.sh",
  hook_behavior = "once",
}
