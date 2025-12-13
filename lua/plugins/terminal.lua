require("toggleterm").setup({
open_mapping = [[<A-t>]],     -- Alt + t works everywhere
  start_in_insert = true,       -- cursor ready to type immediately
  insert_mappings = true,       -- Alt + t works in Insert mode
  terminal_mappings = true,     -- Alt + t works inside the terminal too
  direction = "horizontal",     -- options: horizontal, vertical, float, tab
  size = 10,                    -- height for horizontal (width for vertical)
  float_opts = { border = "curved" }
})
