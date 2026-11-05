-- ~/.config/dcli/hosts/xyprvs-pc.lua
-- Host configuration for xyprvs-pc
-- DotDeDotz

return {
  host = "xyprvs-pc",
  description = "DotDeDotz",

  -- Enabled modules processing tree mapping layout
  enabled_modules = {
    "base",
    "wm/mango",
    "applications/appimages",
    "sync/syncthing",
  },

  module_processing = "sequential",

  -- Host-specific system package arrays
  packages = {
    "thunar",
    "vlc",
  },

  exclude = {},

  -- Default system tool application definitions
  default_apps = {
    scope = "user",
    -- browser = "app.zen_browser.zen",
    -- text_editor = "neovim",
    file_manager = "thunar",
    terminal = "foot",
    video_player = "vlc"
  },

  -- Engine configuration fallback layers
  config_backups = {
    enabled = true,
    max_backups = 5
  },

  -- Automated Snapshot Generation
  system_backups = {
    enabled = true,
    backup_on_sync = true,
    backup_on_update = true,
    tool = "snapper",
    snapper_config = "root",
    max_backups = 5
  },

  flatpak_scope = "system",
  auto_prune = false,
  aur_helper = "yay"
}
