let s:noswapfile = (2 == exists(':noswapfile')) ? 'noswapfile' : ''

function! quickfix_tree#idx() abort
    return matchstr(getline('.'), '\d\+$')
endfunction

function! quickfix_tree#quickfix() abort
    call s:list(function('getqflist'))
endfunction

function! quickfix_tree#loclist() abort
    function! Getloclist(what = v:null) abort
        return a:what == v:null ? getloclist(0) : getloclist(0, a:what)
    endfunction

    call s:list(funcref('Getloclist'))
endfunction

function! s:list(getlist) abort
    let entries = a:getlist()
    if empty(entries)
        call s:print_err("QuickfixTree: list is empty")
        return
    endif

    let paths = map(entries, {idx, entry -> fnamemodify(bufname(entry['bufnr']), ":p:.") .. ' ' .. (idx + 1)})
    execute 'silent' s:noswapfile 'keepalt edit quickfixtree://' .. fnameescape(a:getlist({'title': 0}).title)
    call s:init_buffer('quickfix_tree')
    silent keepmarks keepjumps %delete _
    let formatted = []
    for line in quickfix_tree#format#format_tree(paths)
        call add(formatted, substitute(
\            line,
\            '\(.*\s\+\)\(\d\+\)$',
\            {m -> m[1] .. '|| ' .. a:getlist()[m[2]-1]['text'] .. ' || ' .. m[2]},
\            ''
\         ))
    endfor
    silent keepmarks keepjumps call setline(1, formatted)
    call s:jump_to_idx(a:getlist({'idx' : 0}).idx)
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
