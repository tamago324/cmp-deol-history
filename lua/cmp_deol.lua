local cmp = require'cmp'

local M = {}

M.new = function()
  local self = setmetatable({}, { __index = M })
  return self
end

M.get_keyword_pattern = function()
  return [[.*]]
end

M.complete = function(self, request, callback)
  local q = request.context.cursor_before_line
  local histories = vim.fn["deol#_get_histories"]()
  local words = {}
  for _, val in ipairs(histories) do
    if vim.startswith(val, q) then
      table.insert(words, {
        label = val
      })
    end
  end

  callback(words)
end

return M
