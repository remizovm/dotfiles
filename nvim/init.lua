vim.pack.add{
  'https://github.com/nvim-mini/mini.nvim',
  'https://codeberg.org/mfussenegger/nvim-dap.git',
  'https://github.com/leoluz/nvim-dap-go.git', 'https://github.com/igorlfs/nvim-dap-view',
  'https://codeberg.org/mfussenegger/nvim-lint.git'
}

-- Инициализация модулей mini.nvim
require('mini.pairs').setup()
require('mini.statusline').setup()
require('mini.icons').setup()
require('mini.indentscope').setup()
require('mini.starter').setup()
require('mini.files').setup()
local pick = require('mini.pick')
pick.setup()

-- Базовые опции Neovim
local opt = vim.opt
opt.tabstop = 2         -- Ширина таба равна 2 пробелам
opt.shiftwidth = 2      -- Размер автоматического отступа равен 2 пробелам
opt.softtabstop = 2     -- Нажатие Tab вставляет 2 пробела
opt.expandtab = true    -- ПРЕВРАЩАТЬ ВСЕ ТАБЫ В ПРОБЕЛЫ
opt.smarttab = true
opt.scrolloff = 8
opt.incsearch, opt.hlsearch, opt.ignorecase, opt.smartcase = true, true, true, true
opt.number, opt.relativenumber, opt.gdefault = true, true, true
opt.list = true
opt.listchars = { tab = '⁞ ', eol = '¬', trail = '·' }
opt.wildmode, opt.wildmenu = 'longest,list', true
opt.cursorline = true
opt.mouse = ""
opt.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
opt.updatetime = 100
opt.signcolumn = "number"
opt.colorcolumn = "80"

-- Горячие клавиши для поиска и диагностики
vim.keymap.set('n', '<C-p>', function() pick.builtin.files() end)
vim.keymap.set('n', '<leader>fg', function() pick.builtin.grep_live() end)
vim.keymap.set('n', '<leader>fb', function() pick.builtin.buffers() end)
vim.keymap.set('n', '<leader>fh', function() pick.builtin.help() end)
vim.keymap.set('n', 'gl', vim.diagnostic.open_float)

-- Навигация по коду (LSP + Нативный стек переходов)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP: Go to Definition' })
vim.keymap.set('n', 'gb', '<C-t>', { desc = 'LSP: Go Back' }) -- Возврат назад по стек-тегу

-- Настройки поведения встроенной диагностики
vim.diagnostic.config({
  virtual_text = false, -- Отключаем текст в конце строки, чтобы не загромождать экран
  signs = true,         -- Оставляем значки на панели номеров строк
  underline = true,     -- Подчеркиваем код с ошибкой
  update_in_insert = false,
  severity_sort = true,
})

-- Автокоманда: Автоматически открывать окно диагностики при остановке курсора
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    -- Открываем окно только если мы в обычном режиме и нет открытого всплывающего окна (например, подсказки)
    if vim.api.nvim_get_mode().mode == 'n' and vim.fn.pumvisible() == 0 then
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded", -- Красивая скругленная рамка для окна ошибки
        source = "always",  -- Показывать, откуда ошибка (gopls или golangci-lint)
        prefix = " ",
        scope = "cursor",
      })
    end
  end,
})

-- Глобальные настройки нативного автодополнения
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- 1. ДЕКЛАРАЦИЯ СЕРВЕРА (Встроенный в ядро Neovim 0.11+)
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  settings = {
    gopls = {
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
    },
  },
})

vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
})

vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--mode', 'stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
})

vim.lsp.config('vtsls', {
  cmd = { 'vtsls', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', '.git' },
})

vim.lsp.enable('gopls', 'clangd', 'pyright', 'vtsls')

-- 3. ПРИВЯЗКА СОБЫТИЙ (Автодополнение и форматирование)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client_id = args.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)

    -- Включаем асинхронный автотриггер для подсказок
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
    end

    -- Настраиваем автоформатирование при сохранении силами gopls
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})

-- Логика управления всплывающим окном (Нажатия Enter, Tab и Shift+Tab)
vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.fn.complete_info().selected == -1 and '<C-n><C-y>' or '<C-y>'
  else
    return '<CR>'
  end
end, { expr = true, replace_keycodes = true })

vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  else
    return '<Tab>'
  end
end, { expr = true, replace_keycodes = true })

vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  else
    return '<S-Tab>'
  end
end, { expr = true, replace_keycodes = true })

vim.lsp.log.set_level('off')

-- Настройка Linter (nvim-lint) — Возвращена рабочая конфигурация
local lint = require('lint')
lint.linters_by_ft = { go = { 'golangcilint' } }
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  callback = function() lint.try_lint() end,
})

-- Нативный встроенный Treesitter
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'markdown', 'go', 'c', 'cpp', 'python', 'javascript' },
  callback = function() vim.treesitter.start() end,
})

-- Настройка отладки (DAP)
require('dap-go').setup()
local dap_view = require("dap-view")
dap_view.setup({ windows = { terminal = { hide = false } }, virtual_text = { enabled = true } })

local dap = require("dap")
dap.listeners.before.attach.dap_view_config = function() dap_view.open() end
dap.listeners.before.launch.dap_view_config = function() dap_view.open() end
dap.listeners.before.event_terminated.dap_view_config = function() dap_view.close() end
dap.listeners.before.event_exited.dap_view_config = function() dap_view.close() end

vim.keymap.set('n', '<F5>', function() dap.continue() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<leader>ui', function() dap_view.toggle() end)

-- Встроенная тема оформления
vim.cmd[[colorscheme sorbet]]

-- АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ ПЛАГИНОВ (Нативный Lua-скрипт)
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniStarterOpened", -- Триггер срабатывает при открытии стартового экрана
  callback = function()
    local pack_dir = vim.fn.stdpath("data") .. "/site/pack"
    
    -- Проверяем, существует ли папка с плагинами, чтобы избежать системных ошибок
    if vim.fn.isdirectory(pack_dir) == 1 then
      -- Асинхронно запускаем однострочник find + git pull
      vim.system({
        "find", pack_dir, "-maxdepth", "3", "-type", "d", "-name", ".git", 
        "-exec", "sh", "-c", "cd {}/.. && git pull --quiet", ";"
      }, {}, function(obj)
        -- Если обновление прошло успешно (код выхода 0), выводим тихое уведомление в статус-бар
        if obj.code == 0 then
          vim.schedule(function()
            vim.api.nvim_echo({{"[Autoupdate] Плагины успешно обновлены в фоне.", "Comment"}}, false, {})
          end)
        end
      end)
    end
  end,
})

vim.keymap.set('n', '-', function() require('mini.files').open() end, { desc = 'Open mini.files' })

vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#2e2e2e' })   -- Мягкий темно-серый фон для текущей строки
vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#3a3a3a' })  -- Тонкий приглушенный оттенок для 80-й колонки
