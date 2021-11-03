# cmp-deol-history

deol.nvim completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

## Configuration


### Display the suggestion as virtual text

```lua
require'cmp_deol_history.suggestions'.setup({
  hl_group = 'Comment',
  filetypes = {
    'deoledit'
  }
})
```


### Configuration to enable zsh and deol_history when filetype is deoledit

```
require'cmp_deol_history.suggestions'.setup({
  hl_group = 'Comment',
  filetypes = {
    'deoledit'
  }
})


local ft_sources = {
  deoledit = {
    'zsh', 'deol_history'
  }
}

function _G.setup_buf_cmp_source(ft)
  local sources = ft_sources[ft]
  if sources == nil then
    return
  end

  local list = {}
  for _, name in ipairs(sources) do
    table.insert(list, { name = name })
  end

  local setup_tbl = {
    sources = list
  }

  if ft == 'deoledit' then
    setup_tbl.mapping = {
      -- <CR> to close the popup and send
      ['<CR>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.close()
        end
        fallback()
      end, {'i', 's'}),

      -- Insert a suggestion
      ['<C-e>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.close()
        end

        local virt_text = deol_suggestion_text.get_current_virt_text()
        if virt_text and #virt_text > 0 then
          vim.api.nvim_put({virt_text}, 'c', true, true)
        else
          fallback()
        end
      end, {'i', 's'}),
    }
  end

  cmp.setup.buffer(setup_tbl)
end

function setup_autocmd()
  vim.api.nvim_exec([[
  augroup MyCmpSetup
    autocmd!
    autocmd FileType * lua setup_buf_cmp_source(vim.fn.expand('<amatch>'))
  augroup END
  ]], false)
end

setup_autocmd()
```

## License

MIT
