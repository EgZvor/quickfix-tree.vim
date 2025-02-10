vim9script

import autoload '../autoload/quickfix_tree.vim'

nnoremap <buffer> <Plug>(quickfix_tree_select) <scriptcmd>exe 'll ' .. quickfix_tree.Idx()<cr>
