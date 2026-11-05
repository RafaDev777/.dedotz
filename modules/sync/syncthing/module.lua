--- ~/.config/dcli/modules/sync/syncthing/module.lua
local packages = {
  "syncthing"
}

return {
  name = "Syncthing Note Synchronization",
  description = "Sync note with Syncthing",
  packages = packages,

  -- Root-level DCLI keys matching your framework rules
  hook_behaviour = "once",
  post_install_hook = "scripts/syncthing_init.sh"
}
