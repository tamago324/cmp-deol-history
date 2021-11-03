local ns = vim.api.nvim_create_namespace("deol-suggestion-history")

local config = {
  hl_group = "Comment",
  filetypes = {
    "deoledit",
  },
}

local M = {}

-- buf と virttext の map
local buf_extmarks_virt_text = {}
-- 履歴のキャッシュ (毎回とってたら重くなりそうだから)
local cache_histories = {}

---@return boolean
local function is_insert_mode()
  return vim.tbl_contains({
    "i",
    "ic",
    "ix",
  }, vim.api.nvim_get_mode().mode) or vim.v.insertmode == "i"
end

local function is_enable()
  return vim.tbl_contains(config.filetypes, vim.bo.ft)
end

M.setup = function(opts)
  config = vim.tbl_extend("force", config, opts)

  vim.api.nvim_exec(
    [[
  augroup cmp-deol-history-suggestions
    autocmd!
    autocmd InsertEnter,CursorMovedI,TextChangedI,TextChangedP, * lua require('cmp_deol_history.suggestions').show()
    autocmd CompleteDone,InsertLeave * lua require('cmp_deol_history.suggestions').hide()
    autocmd InsertLeave * lua require('cmp_deol_history.suggestions').update_cache()
  augroup END
  ]],
    false
  )
end

M.show = function()
  -- とりあえずクリア
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  buf_extmarks_virt_text[vim.fn.bufnr()] = ""

  if not is_enable() then
    return
  end

  if not is_insert_mode() then
    return
  end

  if #vim.api.nvim_get_current_line() == 0 then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1
  local col = cursor[2]

  -- 末尾にカーソルがあるかどうかをチェック
  if col ~= #vim.api.nvim_get_current_line() then
    return
  end

  if #cache_histories == 0 then
    M.update_cache()
  end

  local before_cursor_text = vim.api.nvim_get_current_line():sub(0, col + 1)
  local text = ""
  for _, v in ipairs(cache_histories) do
    if vim.startswith(v, before_cursor_text) then
      text = v:sub(col + 1)
      goto setted
    end
  end
  ::setted::

  if #text > 0 then
    vim.api.nvim_buf_set_extmark(0, ns, lnum, col, {
      -- テキストが挿入されたときに ext_mark を左に移動？
      -- right_gravity = false,
      virt_text = { { text, config.hl_group } },
      -- 指定された col の上に表示する
      virt_text_pos = "overlay",
      -- テキストの背景色を virt_text のハイライトと組み合わせる
      hl_mode = "combine",
      -- -- nvim_set_decoration_provider で使用しているときに設定する
      -- ephemeral = true,
    })

    -- セットしておく
    buf_extmarks_virt_text[vim.api.nvim_get_current_buf()] = text
  end
end

M.hide = function()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

local reverse = function(t)
  local res = {}
  for i = #t, 1, -1 do
    table.insert(res, t[i])
  end
  return res
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

--- update cache
M.update_cache = function()
  -- 反転して、重複を削除
  cache_histories = unique_list(reverse(vim.fn["deol#_get_histories"]()))
end

M.get_current_virt_text = function()
  return buf_extmarks_virt_text[vim.api.nvim_get_current_buf()]
end

return M
