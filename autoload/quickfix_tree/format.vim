vim9script

export def FormatTree(paths: list<string>): list<string>
    var tree = {}
    for path in paths
        Insert(tree, path)
    endfor

    Collapse(tree)
    return FormatTree_(tree, '', '')
enddef

def Insert(tree: dict<any>, path: string)
    var cur = tree
    for path_item in path->SplitByChar('/')
        if !has_key(cur, path_item)
            cur[path_item] = {}
        endif
        cur = cur[path_item]
    endfor
enddef

def SplitByChar(line: string, sep: string): list<string>
    var result: list<string> = []
    var buf: string = ''

    for char in line
        if char == sep
            add(result, buf)
            buf = ''
            continue
        endif
        buf ..= char
    endfor

    if buf != ''
        add(result, buf)
    endif

    return result
enddef

def Collapse(root: dict<any>)
    for [path, child] in root->items()
        Collapse(child)
        # Replace a child with the only grandchild.
        if len(child) == 1
            for [subpath, grandchild] in child->items()
                root[$"{path}/{subpath}"] = grandchild
                remove(root, path)
            endfor
        endif
    endfor
enddef

def FormatTree_(tree: dict<any>, prefix: string, parent_path: string): list<string>
    var lines = []
    var normal_prefix = $'{prefix}│   '
    var last_prefix = $'{prefix}    '
    var current_path = ''

    for [idx, path] in tree->keys()->sort()->map((idx, path) => [idx, path])
        if parent_path != ''
            current_path = $'{parent_path}/{path}'
        else
            current_path = path
        endif
        var next = tree[path]

        var is_last = idx == tree->len() - 1
        if !is_last
            lines += [$'{prefix}├── {current_path}'] + FormatTree_(next, normal_prefix, current_path)
        else
            lines += [$'{prefix}└── {current_path}'] + FormatTree_(next, last_prefix, current_path)
        endif
    endfor

    return lines
enddef
