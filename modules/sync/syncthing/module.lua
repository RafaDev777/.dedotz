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
  post_install_hook = function()
    print("==> Provisioning Syncthing module...")

    -- Resolve the true calling user's home directory safely
    local logname = "root"
    local handle = io.popen("logname")
    if handle then
      logname = handle:read("*a"):gsub("%s+", "")
      handle:close()
    end
    local home_dir = (logname == "root") and "/root" or ("/home/" .. logname)

    -- Deploy the .stignore system layout file if missing
    local stignore_path = home_dir .. "/org/.stignore"
    local f = io.open(stignore_path, "r")
    if not f then
      os.execute("mkdir -p " .. home_dir .. "/org")
      local out = io.open(stignore_path, "w")
      if out then
        out:write("// Ignore Emacs auto-save and lock files\n.#*\n#*#\n*~\n")
        out:close()
        print(" -> Created " .. stignore_path)
      end
    else
      f:close()
    end

    -- Safely map and invoke the systemd user daemon instance
    print(" -> Enabling and starting Syncthing user service...")
    local sudo_user = os.getenv("SUDO_USER")

    if sudo_user and sudo_user ~= "" then
      -- Pull the target user's UID to safely populate XDG_RUNTIME_DIR
      local uid = nil
      local id_handle = io.popen("id -u " .. sudo_user)
      if id_handle then
        uid = id_handle:read("*a"):gsub("%s+", "")
        id_handle:close()
      end

      if uid and uid ~= "" then
        os.execute(string.format(
          'sudo -u %s XDG_RUNTIME_DIR="/run/user/%s" systemctl --user enable --now syncthing.service',
          sudo_user, uid
        ))
      else
        print(" ⚠️ Could not resolve UID for SUDO_USER. Falling back to default systemctl.")
        os.execute("systemctl --user enable --now syncthing.service")
      end
    else
      os.execute("systemctl --user enable --now syncthing.service")
    end

    print("==> Syncthing setup complete!")
  end
}
