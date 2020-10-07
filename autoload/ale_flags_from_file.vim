let s:flag_files = {
    \   'standard': ['.compile_flags'],
    \   'unix': ['.unix_compile_flags'],
    \   'windows': ['.windows_compile_flags']
    \ }
let s:filetype_to_variables = {
    \   'standard': {
        \   'c': ['ale_c_cc_options', 'ale_c_clangtidy_options', 'ale_c_cppcheck_options', 'ale_c_oclint_compileflags', 'ale_c_mingw_options'],
        \   'cpp': ['ale_cpp_cc_options', 'ale_cpp_clangtidy_options', 'ale_cpp_cppcheck_options', 'ale_cpp_oclint_compileflags', 'ale_cpp_mingw_options'],
        \   'fortran': ['ale_fortran_ifort_options']
        \ },
    \   'unix': {
        \   'c': ['ale_c_clangunix_options'],
        \   'cpp': ['ale_cpp_clangunix_options']
        \ },
    \   'windows': {
        \   'c': ['ale_c_clangwin_options'],
        \   'cpp': ['ale_cpp_clangwin_options']
        \ }
    \ }
let s:option_blacklist = {
    \   'ale_c_oclint_compileflags': ['-std'],
    \   'ale_cpp_oclint_compileflags': ['-std']
    \ }
let s:option_whitelist = {
    \   'ale_c_cppcheck_options': ['-D', '-I'],
    \   'ale_cpp_cppcheck_options': ['-D', '-I']
    \ }

function! s:c_clangunix_enable()
    let b:ale_c_clangunix_enable = 1
endfunction

function! s:c_clangwin_enable()
    let b:ale_c_clangwin_enable = 1
endfunction

function! s:cpp_clangunix_enable()
    let b:ale_cpp_clangunix_enable = 1
endfunction

function! s:cpp_clangwin_enable()
    let b:ale_cpp_clangwin_enable = 1
endfunction

let s:variable_to_action = {
    \   'ale_c_clangunix_options': function('s:c_clangunix_enable'),
    \   'ale_c_clangwin_options': function('s:c_clangwin_enable'),
    \   'ale_cpp_clangunix_options': function('s:cpp_clangunix_enable'),
    \   'ale_cpp_clangwin_options': function('s:cpp_clangwin_enable')
    \ }


function! s:read_flag_file(flag_files)
    let l:flag_list = []
    for l:flag_file in a:flag_files
        let l:flag_filepath = findfile(l:flag_file, '.;')
        if !empty(l:flag_filepath)
            let l:flag_list = readfile(l:flag_filepath)
            break
        endif
    endfor
    return l:flag_list
endfunction


function! s:set_flags(flag_list, variables)
    for l:var_name in a:variables
        let l:current_flag_list = []
        if has_key(s:option_whitelist, l:var_name)
            let l:current_flag_list = []
            for l:flag in a:flag_list
                for l:option in s:option_whitelist[l:var_name]
                    if l:flag =~# ('^' . l:option)
                        call add(l:current_flag_list, l:flag)
                        break
                    endif
                endfor
            endfor
        elseif has_key(s:option_blacklist, l:var_name)
            let l:current_flag_list = []
            for l:flag in a:flag_list
                for l:option in s:option_blacklist[l:var_name]
                    if l:flag !~# ('^' . l:option)
                        call add(l:current_flag_list, l:flag)
                        break
                    endif
                endfor
            endfor
        else
            let l:current_flag_list = a:flag_list
        endif
        if exists('g:' . l:var_name)
            execute 'let b:' . l:var_name . ' = g:' . l:var_name
        else
            execute 'let b:' . l:var_name . ' = ""'
        endif
        execute 'let l:is_var_empty = empty(b:' . l:var_name . ')'
        if !l:is_var_empty
            execute 'let b:' . l:var_name . ' .= " "'
        endif
        execute 'let b:' . l:var_name . ' .= "' . join(l:current_flag_list, ' ') . '"'
        if has_key(s:variable_to_action, l:var_name)
            call s:variable_to_action[l:var_name]()
        endif
    endfor
endfunction


function! ale_flags_from_file#load_flags()
    let l:linter_types = keys(s:flag_files)
    for l:linter_type in l:linter_types
        let l:flag_files = s:flag_files[l:linter_type]
        let l:filetype_to_variables = s:filetype_to_variables[l:linter_type]
        if index(keys(l:filetype_to_variables), &filetype) >= 0 && !exists('b:' . l:filetype_to_variables[&filetype][0])
            let l:flag_list = s:read_flag_file(l:flag_files)
            if !empty(l:flag_list)
                call s:set_flags(l:flag_list, l:filetype_to_variables[&filetype])
            endif
        endif
    endfor
    ALELint
endfunction
