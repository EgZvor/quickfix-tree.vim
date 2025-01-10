let s:noswapfile = (2 == exists(':noswapfile')) ? 'noswapfile' : ''

function! quickfix_tree#idx() abort
    return matchstr(getline('.'), '\d\+$')
endfunction

function! quickfix_tree#quickfix() abort
    let entries = getqflist()
    if empty(entries)
        call s:print_err("Quickfix list is empty")
        return
    endif

    let paths = map(entries, {idx, entry -> fnamemodify(bufname(entry['bufnr']), ":p:.") .. ' ' .. (idx + 1)})
    execute 'silent' s:noswapfile 'keepalt edit quickfixtree://' .. fnameescape(getqflist({'title': 0}).title)
    call s:init_buffer('quickfix_tree')
    silent keepmarks keepjumps %delete _
    let trie = {}
    for path in paths
        call s:insert(trie, path)
    endfor

    let formatted = []
    for line in trie->s:format_as_tree('', '')
        call add(formatted, substitute(
        \    line,
        \    '\(.*\s\+\)\(\d\+\)$',
        \    '\=submatch(1) .. "|| " .. getqflist()[submatch(2)-1]["text"] .. " || " .. submatch(2)',
        \    ''
        \ ))
    endfor
    silent keepmarks keepjumps call setline(1, formatted)
    call s:jump_to_idx(getqflist({'idx' : 0}).idx)
endfunction

function! s:print_err(msg)
    echohl ErrorMsg
    echo a:msg
    echohl None
endfunction

function! s:init_buffer(filetype)
    exe 'setfiletype ' .. a:filetype
    setlocal nowrap
    setlocal cursorline
    setlocal nobuflisted
    setlocal buftype=nofile noswapfile
endfunction

function! s:jump_to_idx(idx) abort
    call search($'\<{a:idx}$')
    normal! ^
endfunction

" Tree formatting

function! s:insert(trie, path) abort
    let cur = a:trie
    for path_item in a:path->split('/')
        if !has_key(cur, path_item)
            let cur[path_item] = {}
        endif
        let cur = cur[path_item]
    endfor
endfunction

function! s:format_as_tree(trie, prefix, parent_path) abort
    let lines = []
    let normal_prefix = $'{a:prefix}│   '
    let last_prefix = $'{a:prefix}    '

    for [idx, path] in a:trie->keys()->sort()->map({idx, path -> [idx, path]})
        if a:parent_path != ''
            let current_path = $'{a:parent_path}/{path}'
        else
            let current_path = path
        endif
        let next = a:trie[path]

        let is_last = idx == a:trie->len() - 1
        if !is_last
            let lines += [$'{a:prefix}├── {current_path}'] + s:format_as_tree(next, normal_prefix, current_path)
        else
            let lines += [$'{a:prefix}└── {current_path}'] + s:format_as_tree(next, last_prefix, current_path)
        endif
    endfor

    return lines
endfunction
