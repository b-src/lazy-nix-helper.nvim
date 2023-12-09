M = {}

local function repo_path()
  local file_path = debug.getinfo(1, "S").source:sub(2)
  local full_file_path = vim.fn.fnamemodify(file_path, ":p")
  local lazy_nix_helper_absolute_path = string.match(full_file_path, "(.*).tests/init%.lua") .. "/"
  return lazy_nix_helper_absolute_path
end

local function install_deps()
  local repo_root = repo_path()
  local dependency_root = repo_root .. "test_dependencies/"
  local plenary_path = dependency_root .. "plenary/"

  vim.fn.mkdir(dependency_root, "p")
  vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/nvim-lua/plenary.nvim.git", plenary_path })

  vim.opt.rtp:prepend(plenary_path)
end

function M.setup_test_env()
  vim.opt.rtp:prepend(repo_path())

  install_deps()

  local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  require("lazy-nix-helper").setup({ lazypath = non_nix_lazypath })
end

M.setup_test_env()

