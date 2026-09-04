---@diagnostic disable-next-line: undefined-global
local vim = vim

-- =========================================================
-- Quickshell / QML LSP (qmlls) — v0.3.1 style
-- Docs: https://quickshell.org/docs/v0.3.1/guide/install-setup/
-- =========================================================
-- v0.3.1 uses managed `.qmlls.ini` (created empty next to
-- shell.qml, Quickshell fills it). No `-E` flag needed,
-- unlike v0.1.0 guide which used `cmd = { "qmlls", "-E" }`.
--
-- Caveats (upstream):
--  - needs correctly closed braces for completions/lints
--  - no docs for Quickshell types, PanelWindow won't resolve
--  - keep file structured while editing
-- =========================================================

-- ---------- binary resolution (Arch: qmlls6) ----------
local function resolve_qmlls()
  if vim.fn.executable("qmlls") == 1 then
    return "qmlls"
  end
  if vim.fn.executable("qmlls6") == 1 then
    return "qmlls6"
  end
  local fallback = "/usr/lib/qt6/bin/qmlls"
  if vim.fn.executable(fallback) == 1 then
    return fallback
  end
  return nil
end

local qmlls_bin = resolve_qmlls()

if not qmlls_bin then
  vim.notify(
    "[quickshell] qmlls not found (tried qmlls, qmlls6, /usr/lib/qt6/bin/qmlls). Install qt6-declarative.",
    vim.log.levels.WARN
  )
  return
end

-- ---------- capabilities (blink, same as lsp.lua) ----------
local capabilities = nil
pcall(function()
  capabilities = require("blink.cmp").get_lsp_capabilities()
end)

-- ---------- LSP config (new vim.lsp API, Neovim 0.11+) ----------
-- lspconfig default is cmd={qmlls}, filetypes={qml,qmljs},
-- root_markers={.git} — we extend root for quickshell layouts.
vim.lsp.config("qmlls", {
  cmd = { qmlls_bin },
  filetypes = { "qml", "qmljs" },
  root_markers = { ".qmlls.ini", "shell.qml", ".git" },
  capabilities = capabilities,
})
vim.lsp.enable("qmlls")

-- ---------- filetype: ensure .qml / .qmljs / qmldir ----------
vim.filetype.add({
  extension = {
    qml = "qml",
    qmljs = "qmljs",
  },
  filename = {
    [".qmlls.ini"] = "ini",
  },
})

-- ---------- treesitter: ensure qmljs + qmldir ----------
-- main-branch API: require("nvim-treesitter").install({langs})
-- :TSInstall qmljs still works interactively.
pcall(function()
  local ts = require("nvim-treesitter")
  if type(ts.install) == "function" then
    ts.install({ "qmljs", "qmldir" })
  end
end)

-- ---------- commands ----------
-- :QuickshellInit — create empty .qmlls.ini next to shell.qml
-- Quickshell replaces it with managed config on next run.
vim.api.nvim_create_user_command("QuickshellInit", function(opts)
  local dir = opts.args ~= "" and opts.args or vim.fn.getcwd()
  local path = dir .. "/.qmlls.ini"
  if vim.fn.filereadable(path) == 1 then
    vim.notify("[quickshell] .qmlls.ini already exists: " .. path, vim.log.levels.INFO)
    return
  end
  vim.fn.writefile({ "" }, path)
  vim.notify("[quickshell] created empty .qmlls.ini — run quickshell once to populate.", vim.log.levels.INFO)
end, {
  nargs = "?",
  complete = "dir",
  desc = "Create empty .qmlls.ini for qmlls managed config",
})

-- :QuickshellRun — quickshell -c <name> or current dir
vim.api.nvim_create_user_command("QuickshellRun", function(opts)
  local target = opts.args ~= "" and opts.args or vim.fn.getcwd()
  vim.cmd("split | terminal quickshell -c " .. vim.fn.shellescape(target))
end, {
  nargs = "?",
  complete = "dir",
  desc = "Run quickshell in a split terminal",
})

-- :QuickshellCheck — qmllint on current file if available
vim.api.nvim_create_user_command("QuickshellCheck", function()
  local lint = vim.fn.executable("qmllint") == 1 and "qmllint"
    or vim.fn.executable("qmllint6") == 1 and "qmllint6"
    or nil
  if not lint then
    vim.notify("[quickshell] qmllint not found", vim.log.levels.WARN)
    return
  end
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("[quickshell] no file to lint", vim.log.levels.WARN)
    return
  end
  vim.cmd("split | terminal " .. lint .. " " .. vim.fn.shellescape(file))
end, { desc = "Lint current QML file with qmllint" })

-- ---------- QML buffer options ----------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qml", "qmljs" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end,
  desc = "Quickshell QML indent defaults",
})
