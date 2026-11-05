-- ~/.config/dcli/base.lua
-- Base packages installed on all systems
-- These packages are included regardless of host or modules

local packages = {
  -- Essential base system
  "base",
  "base-devel",

  -- Kernel (uncomment the one you use)
  "linux",   -- Standard kernel
  -- "linux-zen",          -- Zen kernel (optimized for desktop)
  -- "linux-lts",          -- Long-term support kernel
  -- "linux-hardened",     -- Security-focused kernel

  -- Firmware (usually needed)
  "linux-firmware",

  -- Basic tools (uncomment as needed)
  "git",
  "vim",
  "neovim",
  "btop",

  -- dcli dependencies
  "yay",      -- AUR helper (required for AUR package management)
  "fzf",      -- Fuzzy finder (required for dcli search/module/backup TUI)
  "snapper"   -- System backup tool (required for dcli backup commands)
}

return {
  description = "Base system packages for all machine",
  packages = packages
}
