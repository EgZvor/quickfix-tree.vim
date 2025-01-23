nnoremap <buffer> <cr> <cmd>exe 'll ' .. quickfix_tree#idx()<cr>
nnoremap <buffer> q <cmd>bdelete<cr>
nnoremap <buffer> <up> <cmd>call search($'^.*\<\d\+$', 'bWz')<cr>
nnoremap <buffer> <down> <cmd>call search($'^.*\<\d\+$', 'Wz')<cr>
