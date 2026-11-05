local packages = {
    "mangowm",
    "dux-shell",
    "foot",

    -- Dux shell Dependencies
    "quickshell"
}
return {
  name = "Mango WM",
  description = "Mango Window Manager Ecosystem",
  packages = packages,
  dotfiles_sync = true
}
