-- ~/.config/dcli/modules/app_images/module.lua
local packages = {
  "flatpak:it.mijorus.gearlever"
  -- { name = "it.mijorus.gearlever", type = "flatpak" }
}


return {
  name = "AppImage Installer",
  description = "AppImage downloaded automatically",
  packages = packages,

  -- Flattened hooks structure for the AppImage module
  hook_behavior = "once",
  post_install_hook = "scripts/install_appimages.sh"
}
