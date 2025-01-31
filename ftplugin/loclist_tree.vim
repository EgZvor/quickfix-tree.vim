vim9script

import autoload '../autoload/quickfix_tree.vim'

nnoremap <buffer> <cr> <scriptcmd>exe 'll ' .. quickfix_tree.Idx()<cr>
