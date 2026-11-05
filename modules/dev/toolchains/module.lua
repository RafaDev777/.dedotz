return {
  description = "Language toolchains and LSP servers",
  packages = {
    -- C
    "clang", "gdb", "cmake", "bear",
    -- Lua
    "lua", "lua-language-server", "stylua",
    -- Zig
    "zig", "zls",
    -- Rust (rust-analyzer comes via rustup)
    "rustup",
  },
  post_install_hook = "scripts/rust-toolchains.sh",
  hook_behavior = "once"
}
