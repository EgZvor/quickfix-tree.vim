vim9script

import autoload '../autoload/quickfix_tree.vim'

command! QuickfixTree call quickfix_tree.Quickfix()
command! LoclistTree call quickfix_tree.Loclist()
