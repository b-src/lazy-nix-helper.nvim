local M = {}

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "lazy-nix-helper" })
end

function M.table_contains(table, key)
  return table[key] ~= nil
end

function M.xor(a, b)
  return (a or b) and not (a and b)
end

-- use the presence of `nixos-rebuild` as a proxy for this being a nixOS system
function M.in_a_nix_environment()
  return vim.fn.executable("nixos-rebuild") == 1
end

function M.nix_store_installed()
  return vim.fn.executable("nix-store") == 1
end

function M.print_environment_info()
  print(
    "In a nixOS environment: "
      .. tostring(M.in_a_nix_environment())
      .. ". nix-store installed: "
      .. tostring(M.nix_store_installed())
  )
end

return M
