return {
  description = "Node via fnm, pnpm via corepack",

  packages = {
    "fnm",   -- in extra or the AUR depending on your setup; dcli will use your AUR helper
  },

  post_install_hook = "scripts/node-fnm.sh",
  hook_behavior = "once",
}
