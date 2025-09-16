-- File: lua/plugins/clangd.lua
-- Purpose: Use *system* clangd (installed via apt or manual binary) for C/C++ LSP without Mason
-- Why: Mason clangd install failed (unzip issue). This spec skips Mason entirely.
-- Tip: Ensure `clangd` is on PATH (e.g., `sudo apt install -y clangd` on Ubuntu/WSL)

return {
  "neovim/nvim-lspconfig", -- core LSP client configs
  ft = { "c", "cpp", "objc", "objcpp", "cuda" }, -- lazy-load on C-family files
  dependencies = {
    -- Optional but recommended: better completion via nvim-cmp
    { "hrsh7th/cmp-nvim-lsp", optional = true },
  },
  config = function()
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if not lspconfig_ok then
      vim.notify("lspconfig not found", vim.log.levels.ERROR)
      return
    end

    -- Capabilities: integrate with nvim-cmp if available
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_ok and cmp_lsp then
      capabilities = cmp_lsp.default_capabilities(capabilities)
    end

    -- on_attach: keymaps only when LSP is active in the current buffer
    local function on_attach(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      map("n", "K", vim.lsp.buf.hover, "LSP Hover")
      map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
      map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
      map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
      map("n", "gr", vim.lsp.buf.references, "List References")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    end

    -- Prefer system clangd; warn if missing
    if vim.fn.executable("clangd") ~= 1 then
      vim.notify(
        "System 'clangd' not found on PATH. Install via 'sudo apt install -y clangd' or put your binary in /usr/local/bin.",
        vim.log.levels.WARN
      )
      return
    end

    -- Recommended flags; adjust as you like
    local cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--fallback-style=llvm", -- format style when no .clang-format present
    }

    lspconfig.clangd.setup({
      cmd = cmd,
      capabilities = capabilities,
      on_attach = on_attach,
      -- You may also set root_dir = lspconfig.util.root_pattern('compile_commands.json', '.git')
    })
  end,
}

