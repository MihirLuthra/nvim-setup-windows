vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

vim.cmd [[
  map <M-s> :tabnext<CR>
  map <M-a> :tabprev<CR>

  map <C-Right> w
  map <C-Left> b
  map <C-Up> 7<Up>
  map <C-Down> 7<Down>

  map <C-q> :NvimTreeToggle<CR>
  map <leader>fc :Telescope find_files search_dirs={"%:h"}<CR>

  map <C-d> :RustOpenDocs<CR>

  set iskeyword+=-
  " Using your mouse doesn't work inside vim
  " like it because I can use mouse to copy something
  " without changing my vim cursor.
  set mouse=
  " vim yank shouldn't copy to system clipboard
  set clipboard=

  " To copy to system clipboard in Visual Mode
  vnoremap cp :<C-u>call CopyVisualSelection()<CR>

  function! CopyVisualSelection()
      " Get the start and end positions of the visual selection
      let [line_start, column_start] = getpos("'<")[1:2]
      let [line_end, column_end] = getpos("'>")[1:2]
      let lines = getline(line_start, line_end)

      if len(lines) == 0
          return
      endif
      " Adjust the first and last lines based on the selection
      let lines[0] = lines[0][column_start - 1:]
      if line_start == line_end
          let lines[0] = lines[0][:column_end - column_start]
      else
          let lines[-1] = lines[-1][:column_end - 1]
      endif
      let text = join(lines, "###EOL###")
      let tempfile = tempname()
      " Write the selected text to the tempfile
      call writefile([text], tempfile, 'b')
      " Log the tempfile path and content for debugging
      echom 'Copied to clipboard'

      let replace_eol_with_newline = 'powershell -NoProfile -Command "(Get-Content -Path ''' . escape(tempfile, '\') . ''' ) -replace ''###EOL###'', \"`n\" | Set-Content ''' . escape(tempfile, '\') . '''"'
      call system(replace_eol_with_newline)
      " Use PowerShell to read the tempfile and set the clipboard
      let powershell_cmd = 'powershell -NoProfile -Command "Get-Content -Path ''' . shellescape(tempfile) . ''' | Set-Clipboard"'
      call system(powershell_cmd)
      " Comment out the next line to prevent deletion of the tempfile
      call delete(tempfile)
  endfunction

  " To copy to system clipboard in Normal Mode (copies from current cursor position to end of line)
  nnoremap cp$ :call system('clip', getline('.')[col('.') - 1:])<CR>

]]
