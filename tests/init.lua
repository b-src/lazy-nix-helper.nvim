M = {}

function M.setup_test_env()
  local file_path = debug.getinfo(1, "S").source:sub(2)
  local lazy_nix_helper_absolute_path = string.match(file_path, "(.*).tests/init%.lua")

  vim.opt.rtp:prepend(lazy_nix_helper_absolute_path)

  local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  require("lazy-nix-helper").setup({ lazypath = non_nix_lazypath })


  local plenary_path = require("lazy-nix-helper").get_plugin_path("plenary.nvim")
  -- TODO: can't assume plenary will be available here or at all
  if plenary_path == nil then
    plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
  end
  vim.opt.rtp:prepend(plenary_path)
end

M.setup_test_env()

