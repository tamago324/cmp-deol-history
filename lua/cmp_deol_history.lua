local cmp = require("cmp")

local M = {}

M.new = function()
  local self = setmetatable({}, { __index = M })
  return self
end

M.get_keyword_pattern = function()
  return [[.*]]
end

local unique_list = function(list)
  local res = {}
  -- table にしておく
  local added_histories = {}
  for _, v in ipairs(list) do
    if added_histories[v] == nil then
      -- 追加されていなければ、追加する
      table.insert(res, v)
      added_histories[v] = true
    end
  end

  return res
end

M.complete = function(self, request, callback)
  local q = request.context.cursor_before_line
  local histories = unique_list(vim.fn["deol#_get_histories"]())
  local words = {}
  for _, val in ipairs(histories) do
    if vim.startswith(val, q) then
      table.insert(words, {
        label = val,
      })
    end
  end

  callback(words)
end

-- XXX: 必要かどうかわからない...
-- M.resolve = function(self, completion_item, callback)
--   callback(completion_item)
-- end

return M
