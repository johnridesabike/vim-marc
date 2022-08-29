if exists('g:marc_plugin_loaded')
  finish
endif

if !exists("g:marcedit_path") && exists("$MARCEDIT_PATH")
  let g:marcedit_path = $MARCEDIT_PATH . "\\cmarcedit.exe"
endif

function! s:MarcEdit(arg, ftype)
  if !exists("g:marcedit_path")
    echoerr "Error: Vim could not find a MarcEdit installation."
    return
  endif
  let tmp_input = tempname()
  let tmp_output = tempname()
  call writefile(getline(0, "$"), tmp_input, "a")
  silent execute "!" .
        \"\"" . g:marcedit_path . "\"" .
        \" -s " . fnameescape(tmp_input) .
        \" " . a:arg .
        \" -d " . fnameescape(tmp_output)
  call delete(tmp_input)
  if filereadable(tmp_output)
    let new_buf = readfile(tmp_output)
    silent call deletebufline(bufnr(), len(new_buf), "$")
    call setline(1, new_buf)
    call delete(tmp_output)
    execute "set filetype=" . a:ftype
  else
    echoerr "Error: MarcEdit could not process this buffer."
  endif
endfunction

command! -nargs=0 MarcMake      call s:MarcEdit("-make", "mrc")
command! -nargs=0 MarcBreak     call s:MarcEdit("-break", "mrk")
command! -nargs=0 MarcToXml     call s:MarcEdit("-marcxml", "xml")
command! -nargs=0 MarcFromXml   call s:MarcEdit("-xmlmarc", "mrc")
command! -nargs=0 MarcToJson    call s:MarcEdit("-marc2json", "json")
command! -nargs=0 MarcFromJson  call s:MarcEdit("-json2marc", "mrc")

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

