-- return {
--     "rockerBOO/boo-colorscheme-nvim",
--     lazy = false,
--     priority = 1000,
--     as = "boo",
--     opts = {},
--     config = function()
--         vim.cmd('colorscheme boo')
--     end
--   }

return {
    -- add gruvbox
    { "ellisonleao/gruvbox.nvim" },
  
    -- Configure LazyVim to load gruvbox
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "habamax",
      },
    }
  }