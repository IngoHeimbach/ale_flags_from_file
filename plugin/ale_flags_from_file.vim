if exists('g:ale_flags_from_file_loaded') && g:ale_flags_from_file_loaded
  finish
endif
let g:ale_flags_from_file_loaded = 1

let s:flag_files = ['.compile_flags']
let s:filetype_to_variables = {
    \   'c':   ['ale_c_clang_options', 'ale_c_clangtidy_options', 'ale_c_cppcheck_options'],
    \   'cpp': ['ale_cpp_clang_options', 'ale_cpp_clangtidy_options', 'ale_cpp_cppcheck_options']
    \ }
let s:option_filter = {
    \   'ale_c_cppcheck_options':   ['-D', '-I'],
    \   'ale_cpp_cppcheck_options': ['-D', '-I']
    \ }

function! s:load_flags()
    if index(keys(s:filetype_to_variables), &filetype) < 0 || exists('b:' . s:filetype_to_variables[&filetype][0])
        return
    endif

    let l:flag_list = []
    for l:flag_file in s:flag_files
        let l:flag_filepath = findfile(l:flag_file, '.;')
        if !empty(l:flag_filepath)
            let l:flag_list = readfile(l:flag_filepath)
            break
        endif
    endfor
    if empty(l:flag_list)
        return
    endif
    for l:var_name in s:filetype_to_variables[&filetype]
        let l:current_flag_list = []
        if has_key(s:option_filter, l:var_name)
            let l:current_flag_list = []
            for l:flag in l:flag_list
                for l:option in s:option_filter[l:var_name]
                    if l:flag =~# ('^' . l:option)
                        call add(l:current_flag_list, l:flag)
                        break
                    endif
                endfor
            endfor
        else
            let l:current_flag_list = l:flag_list
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
    endfor

    ALELint
endfunction

augroup ale_flags_from_file
    autocmd!
    autocmd BufEnter * call s:load_flags()
    autocmd Filetype * call s:load_flags()
augroup END
