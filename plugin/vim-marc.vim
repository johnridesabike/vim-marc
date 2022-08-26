if empty($MARCEDIT_PATH)
  echo "Warning: Vim could not detect a MarcEdit installation."
  finish
endif

if exists('g:marc_plugin_loaded')
  finish
endif

function! Mrc21()
  let tmp_input = tempname()
  let tmp_output = tempname()
  call writefile(getline(0, '$'), tmp_input, "a")
  silent execute "!\"" . $MARCEDIT_PATH .
        \"\\cmarcedit.exe\" -s " . fnameescape(tmp_input) .
        \" -make -d " . fnameescape(tmp_output)
  let new_buf = readfile(tmp_output)
  call deletebufline(bufnr(), len(new_buf), '$')
  call setline(1, new_buf)
  set filetype=mrc
  call delete(tmp_input)
  call delete(tmp_output)
endfunction
command! -nargs=0 Mrc21 call Mrc21()

function! MrcMrk()
  let tmp_input = tempname()
  let tmp_output = tempname()
  call writefile(getline(0, '$'), tmp_input, "a")
  silent execute "!\"" . $MARCEDIT_PATH .
        \"\\cmarcedit.exe\" -s " . fnameescape(tmp_input) .
        \" -break -d " . fnameescape(tmp_output)
  let new_buf = readfile(tmp_output)
  call deletebufline(bufnr(), len(new_buf), '$')
  call setline(1, new_buf)
  set filetype=mrk
  call delete(tmp_input)
  call delete(tmp_output)
endfunction
command! -nargs=0 MrcMrk call MrcMrk()

let g:marc_plugin_loaded = 1

finish " Everything below this doesn't work.

"Tutorial Used
"candidtim.github.io/vim/2017/08/11/write-vim-plugin-in-python.html
if !has("python3")
    echo "VIM has to be compiled with +python3 for vim-marc to work"
    finish
endif

let s:plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

python3 << EOF
import sys
from os.path import normpath, join
import vim
plugin_root_dir = vim.eval('s:plugin_root_dir')
python_root_dir = normpath(join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)
import mmmarc
EOF

function! Mrc21()
    py3 mmmarc.vim_mrc21()
    set filetype=mrc
endfunction
command! -nargs=0 Mrc21 call Mrc21()

function! MrcMrk()
    py3 mmmarc.vim_mrk()
    set filetype=mrk
endfunction
command! -nargs=0 MrcMrk call MrcMrk()

function! MrcXML()
    py3 mmmarc.vim_xml()
    set filetype=xml
endfunction
command! -nargs=0 MrcXML call MrcXML()

function! MrcCycle()
    py3 mmmarc.vim_marc_carousel()
endfunction
command! -nargs=0 MrcCycle call MrcCycle()

function! MrcAddMrkLdr()
    py3 mmmarc.mrk_add_ldr()
endfunction
command! -nargs=0 MrcAddMrkLdr call MrcAddMrkLdr()

