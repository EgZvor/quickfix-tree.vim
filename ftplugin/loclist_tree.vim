vim9script

import autoload '../autoload/quickfix_tree.vim'

nnoremap <buffer> <cr> <scriptcmd>exe 'll ' .. quickfix_tree.Idx()<cr>
nnoremap <buffer> q <cmd>bdelete<cr>
nnoremap <buffer> <up> <cmd>call search($'^.*\<\d\+$', 'bWz')<cr>
nnoremap <buffer> <down> <cmd>call search($'^.*\<\d\+$', 'Wz')<cr>
