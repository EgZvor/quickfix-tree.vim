function! quickfix_tree#format#format_tree(paths) abort
    let tree = {}
    for path in a:paths
        call s:insert(tree, path)
    endfor

    call s:collapse(tree)
    return s:format_tree(tree, '', '')
endfunction

function! s:insert(tree, path) abort
    let cur = a:tree
    for path_item in a:path->split('/')
        if !has_key(cur, path_item)
            let cur[path_item] = {}
        endif
        let cur = cur[path_item]
    endfor
endfunction


" TODO: improve performance?
function! s:collapse(root) abort
    for [path, child] in a:root->items()
        call s:collapse(child)
        " Replace a child with the only grandchild.
        if len(child) == 1
            for [subpath, grandchild] in child->items()
                let a:root[$"{path}/{subpath}"] = grandchild
                call remove(a:root, path)
            endfor
        endif
    endfor
endfunction

function! s:format_tree(tree, prefix, parent_path) abort
    let lines = []
    let normal_prefix = $'{a:prefix}│   '
    let last_prefix = $'{a:prefix}    '

    for [idx, path] in a:tree->keys()->sort()->map({idx, path -> [idx, path]})
        if a:parent_path != ''
            let current_path = $'{a:parent_path}/{path}'
        else
            let current_path = path
        endif
        let next = a:tree[path]

        let is_last = idx == a:tree->len() - 1
        if !is_last
            let lines += [$'{a:prefix}├── {current_path}'] + s:format_tree(next, normal_prefix, current_path)
        else
            let lines += [$'{a:prefix}└── {current_path}'] + s:format_tree(next, last_prefix, current_path)
        endif
    endfor

    return lines
endfunction
