-- ~/.config/dcli/modules/app_images/module.lua
local packages = {
  "flatpak:it.mijorus.gearlever"
  -- { name = "it.mijorus.gearlever", type = "flatpak" }
}

local apps = {
  { repo = "storytold/vectorcraft", name = "vectorcraft" },
  { repo = "storytold/photocraft",  name = "photocraft" },
  { repo = "storytold/pdfcraft",    name = "pdfcraft" },
  { repo = "storytold/effectcraft", name = "effectcraft" },
  { repo = "storytold/designcraft", name = "designcraft" }
}

return {
  name = "AppImage Installer",
  description = "AppImage downloaded automatically",
  packages = packages,

  -- Flattened hooks structure for the AppImage module
  hook_behavior = "once",
  post_install_hook = function()
    print("==> Processing AppImage provisioning...")

    local logname = "root"
    local handle = io.popen("logname")
    if handle then
      logname = handle:read("*a"):gsub("%s+", "")
      handle:close()
    end
    local home_dir = (logname == "root") and "/root" or ("/home/" .. logname)
    local bin_dir = home_dir .. "/Applications"

    print("Checking and creating Applications folder: " .. bin_dir)
    os.execute("mkdir -p " .. bin_dir)

    local function file_exists(path)
      local f = io.open(path, "r")
      if f then
        f:close()
        return true
      end
      return false
    end

    for _, app in ipairs(apps) do
      local target_path = bin_dir .. "/" .. app.name .. ".AppImage"
      local alternate_path = bin_dir .. "/" .. app.name .. ".appimage"

      if file_exists(target_path) or file_exists(alternate_path) then
        print("Skipping " .. app.name .. ": AppImage already exists in folder.")
      else
        print("Checking latest release for " .. app.repo .. "...")

        local api_url = string.format("https://github.com", app.repo)
        local curl_cmd = string.format('curl -s "%s"', api_url)
        local api_handle = io.popen(curl_cmd)
        local download_url = nil

        if api_handle then
          local json_response = api_handle:read("*a")
          api_handle:close()

          download_url = json_response:match('"(https://[^\"]+/releases/download/[^\"]+/linux%-x86_64%.AppImage)"')
          if not download_url then
            download_url = json_response:match(
            '"(https://[^\"]+/releases/download/[^\"]+/[^\"]%.[aA][pP][pP][iI][mM][aA][gG][eE])"')
          end
        end

        if not download_url or download_url == "" then
          print("⚠️ Warning: Could not find a valid .AppImage release for " .. app.repo .. ". Skipping.")
        else
          print("Downloading latest version of " .. app.name .. "...")
          local dl_cmd = string.format('curl -L -o "%s" "%s"', target_path, download_url)
          local dl_success = os.execute(dl_cmd)

          if dl_success then
            os.execute('chmod +x "' .. target_path .. '"')
            print("Successfully downloaded " .. app.name .. " to " .. target_path)

            local fp_check = os.execute("flatpak info it.mijorus.gearlever >/dev/null 2>&1")
            if fp_check then
              print("Integrating " .. app.name .. " with Gear Lever (Flatpak)...")
              os.execute(string.format('flatpak run it.mijorus.gearlever "%s" >/dev/null 2>&1', target_path))
            else
              local bin_check = os.execute("command -v gearlever >/dev/null 2>&1")
              if bin_check then
                print("Integrating " .. app.name .. " with Gear Lever (Native)...")
                os.execute(string.format('gearlever "%s" >/dev/null 2>&1', target_path))
              end
            end
          else
            print("❌ Error: Failed downloading application asset for " .. app.name)
          end
        end
      end
    end
    print("All AppImages processed.")
  end
}
