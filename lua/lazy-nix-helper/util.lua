local M = {}

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "lazy-nix-helper" })
end

function M.table_contains(table, key)
  return table[key] ~= nil
end

-- TODO: should this be checking nix-store is installed instead?
-- alternatively, should "in a nix environment" and "nix-store is installed" be separate ideas?
function M.in_a_nix_environment()
  return vim.fn.executable("nix")
end

return M
