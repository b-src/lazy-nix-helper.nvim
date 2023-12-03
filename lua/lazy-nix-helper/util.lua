local M = {}

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "lazy-nix-helper" })
end

function M.table_contains(table, key)
  return table[key] ~= nil
end

return M
