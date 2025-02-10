vim9script

import autoload '../autoload/quickfix_tree.vim'

nnoremap <buffer> <Plug>(quickfix_tree_select) <scriptcmd>exe 'cc ' .. quickfix_tree.Idx()<cr>
nnoremap <buffer> <Plug>(quickfix_tree_up) <up><Plug>(_quickfix_tree_up)
nnoremap <buffer> <Plug>(quickfix_tree_down) <down><Plug>(_quickfix_tree_down)
nmap <buffer> <expr> <Plug>(_quickfix_tree_up) StopAtLine() ? '' : '<up><Plug>(_quickfix_tree_up)'
nmap <buffer> <expr> <Plug>(_quickfix_tree_down) StopAtLine() ? '' : '<down><Plug>(_quickfix_tree_down)'

if !exists('g:quickfix_tree_disable_mappings')
    nnoremap <buffer> q <cmd>bdelete<cr>
    nnoremap <buffer> <cr> <Plug>(quickfix_tree_select)

    nnoremap <buffer> <up> <Plug>(quickfix_tree_up)
    nnoremap <buffer> <down> <Plug>(quickfix_tree_down)
    nnoremap <buffer> k <Plug>(quickfix_tree_up)
    nnoremap <buffer> j <Plug>(quickfix_tree_down)
endif

def StopAtLine(): bool
    return foldclosed(line('.')) != -1 || match(getline('.'), '^.*\<\d\+$') >= 0
enddef

def FoldLevel(): any
    var prev = g:LineToLevel(v:lnum)
    var cur = g:LineToLevel(v:lnum)
    var next = g:LineToLevel(v:lnum + 1)
    if cur < next
        # cur is a directory containing some items
        return '>' .. next
    elseif cur < prev
        # exited a directory, now a new fold should start
        return '>' .. cur
    else
        return cur
    endif
enddef

def g:LineToLevel(lnum: number): number
    return lnum
        ->getline()
        ->matchstr('\v^[[:space:]─└├│]+')
        ->strchars() / 4 - 1
enddef

set foldmethod=expr
set foldexpr=s:FoldLevel()
&foldtext = "getline(v:foldstart) .. $'/ {(v:foldend - v:foldstart + 1)} lines '"
