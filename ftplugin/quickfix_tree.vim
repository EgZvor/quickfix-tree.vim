vim9script

import autoload '../autoload/quickfix_tree.vim'

nnoremap <buffer> <cr> <scriptcmd>exe 'cc ' .. quickfix_tree.Idx()<cr>
nnoremap <buffer> q <cmd>bdelete<cr>

nmap <buffer> <expr> <Plug>(quickfix_tree_up) StopAtLine() ? '' : '<up><Plug>(quickfix_tree_up)'
nnoremap <buffer> <up> <up><Plug>(quickfix_tree_up)
nmap <buffer> <expr> <Plug>(quickfix_tree_down) StopAtLine() ? '' : '<down><Plug>(quickfix_tree_down)'
nnoremap <buffer> <down> <down><Plug>(quickfix_tree_down)

def QuickfixTreeFoldLevel(): any
    return v:lnum
        ->getline()
        ->matchstr('\v^[[:space:]─└├│]+')
        ->strchars() / 4
enddef

set foldmethod=expr
set foldexpr=s:QuickfixTreeFoldLevel()
&foldtext = "getline(v:foldstart) .. $'/ {(v:foldend - v:foldstart + 1)} lines '"
