vim.pack.add{
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/folke/tokyonight.nvim',
	'https://github.com/SmiteshP/nvim-navic',
	'https://github.com/sheerun/vim-polyglot',
	'https://github.com/hrsh7th/nvim-cmp',
	'https://github.com/hrsh7th/cmp-vsnip',
	'https://github.com/hrsh7th/vim-vsnip',
	'https://github.com/hrsh7th/cmp-nvim-lsp',
}

local on_lsp_attach = function(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		navic = require('nvim-navic')
		navic.attach(client, bufnr)
	end
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('gopls', {
	on_attach = on_lsp_attach,
  capabilities = capabilities,
  settings = {
    gopls = {
      -- Optional: enable advanced features
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
    },
  },
})

vim.lsp.enable({ 'gopls' })

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- Main LSP source for Go symbols
    { name = 'go_pkgs' },  -- If using cmp-go-pkgs
  }, {
    { name = 'buffer' },   -- Text from current buffer
  })
})


vim.keymap.set('n', 'gl', vim.diagnostic.open_float)

-- Basic indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.smarttab = true

vim.opt.scrolloff = 8

-- Search incrementally, highlight
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Show line numbers relatively
vim.opt.number = true
vim.opt.relativenumber = true

-- Replace all by-default
vim.opt.gdefault = true

-- Show unprintable

vim.opt.list = true
vim.opt.listchars = {tab = '⁞ ', eol = '¬', trail = '·'}

-- Autocompletion
vim.opt.wildmode = 'longest,list'
vim.opt.wildmenu = true
vim.opt.autocomplete = true

-- Also work under ru
vim.opt.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'

vim.opt.colorcolumn = "120"

vim.opt.mouse = ""

vim.lsp.log.set_level('off')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.cmd[[colorscheme tokyonight]]

vim.o.statusline = "%<%f:%l, %c%V %h%w%m%r %{%v:lua.require'nvim-navic'.get_location()%}%=%-14.(%) %P"
