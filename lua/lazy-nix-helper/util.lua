local M = {}

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "lazy-nix-helper" })
end

return M
