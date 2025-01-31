vim9script

import autoload './quickfix_tree/format.vim'

var noswapfile = (2 == exists(':noswapfile')) ? 'noswapfile' : ''

export def Idx(): string
    var idx = matchstr(getline('.'), '\d\+$')
    if idx == ''
        echoerr 'no index on the current line'
    endif

    return idx
enddef

export def Quickfix()
    List(function('getqflist'), 'quickfix_tree')
enddef

export def Loclist()
    List(function('getloclist', [0]), 'quickfix_tree.loclist_tree')
enddef

def List(GetList: any, filetype: string)
    var entries = GetList()
    if empty(entries)
        PrintErr("QuickfixTree: list is empty")
        return
    endif

    var paths: list<string> = mapnew(entries, (idx: number, entry: dict<any>): string =>
        fnamemodify(bufname(entry['bufnr']), ":p:.") .. ' ' .. string(idx + 1)
    )
    :execute $'silent {noswapfile} keepalt edit quickfixtree://' .. fnameescape(GetList({'title': 0}).title)
    InitBuffer(filetype)
    :silent keepmarks keepjumps :%delete _
    var formatted = []
    for line in format.FormatTree(paths)
        add(formatted, substitute(
             line,
             '\v(.*\s+)(\d+)$',
             (m) => m[1] .. '|| ' .. entries[str2nr(m[2]) - 1]['text'] .. ' || ' .. m[2],
             ''
          ))
    endfor
    :silent keepmarks keepjumps call setline(1, formatted)
    JumpToIdx(GetList({'idx': 0}).idx)
enddef

def PrintErr(msg: string)
    echohl ErrorMsg
    echo msg
    echohl None
enddef

def InitBuffer(filetype: string)
    setlocal nomodeline
    exe 'setfiletype ' .. filetype
    setlocal nowrap
    setlocal cursorline
    setlocal nobuflisted
    setlocal buftype=nofile noswapfile
enddef

def JumpToIdx(idx: number)
    search($'\<{idx}$')
    normal! ^
enddef
