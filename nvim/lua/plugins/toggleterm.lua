-- File: lua/plugins/toggleterm.lua
-- Purpose: Configure toggleterm.nvim with three terminal modes: floating, horizontal, and a dedicated lazygit instance
-- Plugin: https://github.com/akinsho/toggleterm.nvim

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "<leader>th", mode = { "n", "t" }, desc = "Toggle Terminal (Horizontal)" },
    { "<leader>tf", mode = { "n", "t" }, desc = "Toggle Terminal (Floating)" },
    { "<leader>tg", mode = { "n", "t" }, desc = "Toggle Lazygit (Floating)" },
    { [[<C-\>]], mode = { "n", "t" }, desc = "Toggle Lazygit (default)" },
    { "<C-Space>", mode = { "n", "t" }, desc = "Close current Terminal" },
  },

  config = function()
    require("toggleterm").setup({
      open_mapping = [[<C-\>]],
      direction = "horizontal",
      size = function(term)
        if term.direction == "horizontal" then
          return math.floor(vim.o.lines * 0.30)
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.40)
        else
          return 20
        end
      end,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      persist_mode = true,
      persist_size = true,
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "rounded",
        width = function() return math.floor(vim.o.columns * 0.90) end,
        height = function() return math.floor(vim.o.lines * 0.90) end,
        winblend = 0,
      },
    })

    local Terminal = require("toggleterm.terminal").Terminal

    -- Horizontal terminal
    local horiz_term = Terminal:new({
      direction = "horizontal",
    })

    -- Floating terminal
    local float_term = Terminal:new({
      direction = "float",
      float_opts = {
        border = "rounded",
      },
    })

    -- Lazygit terminal (always floating)
    local lazygit_term = Terminal:new({
      cmd = "lazygit", -- run lazygit command directly
      direction = "float",
      float_opts = {
        border = "rounded",
        width = function() return math.floor(vim.o.columns * 0.95) end,
        height = function() return math.floor(vim.o.lines * 0.95) end,
      },
      hidden = true,
    })

    -- Only keep minimal keymaps inside terminal
    local function set_terminal_keymaps()
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = 0, desc = "Terminal: exit to Normal" })
      vim.keymap.set("t", "<C-c>", [[<C-\><C-n>]], { buffer = 0, desc = "Terminal: exit to Normal (Ctrl-C)" })
      vim.keymap.set("t", "<C-Space>", [[<C-\><C-n>:q!<CR>]], { buffer = 0, desc = "Terminal: close" })
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = set_terminal_keymaps,
      desc = "toggleterm: per-terminal keymaps",
    })

    vim.keymap.set({ "n", "t" }, "<leader>th", function()
      horiz_term:toggle()
    end, { desc = "Toggle Terminal (Horizontal)" })

    vim.keymap.set({ "n", "t" }, "<leader>tf", function()
      float_term:toggle()
    end, { desc = "Toggle Terminal (Floating)" })

    vim.keymap.set({ "n", "t" }, "<leader>tg", function()
      lazygit_term:toggle()
    end, { desc = "Toggle Lazygit (Floating)" })

    -- Map Ctrl-\\ to always open the lazygit terminal by default
    vim.keymap.set({ "n", "t" }, [[<C-\>]], function()
      lazygit_term:toggle()
    end, { desc = "Toggle Lazygit (default)" })

    -- Map Ctrl-Space to close the current terminal window
    vim.keymap.set({ "n", "t" }, "<C-Space>", function()
      vim.cmd("quit!")
    end, { desc = "Close current Terminal" })
  end,
}
