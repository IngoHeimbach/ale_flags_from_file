" Plugin based on https://github.com/amiorin/ctrlp-z

if exists('g:ale_flags_from_file') && g:ale_flags_from_file
  finish
endif
let g:ale_flags_from_file = 1

let s:flag_files = ['.color_coded']
let s:filetype_to_variables = {
    \   'c':   ['b:ale_c_clang_options'],
    \   'cpp': ['b:ale_cpp_clang_options']
    \ }

function! s:load_flags()
    if index(keys(s:filetype_to_variables), &ft) < 0 || exists(s:filetype_to_variables[&ft][0])
        return
    endif

    let l:flag_filepath = ''
    let l:flags = ''
    for flag_file in s:flag_files
        let l:flag_filepath = findfile(flag_file, '.;')
        if !empty(l:flag_filepath)
            let l:flags = join(readfile(l:flag_filepath), ' ')
            break
        endif
    endfor
    if empty(l:flags)
        return
    endif
    for var_name in s:filetype_to_variables[&ft]
        execute 'let ' . var_name . ' = "' . l:flags . '"'
    endfor

    ALELint
endfunction

augroup ale_flags_from_file
    autocmd!
    autocmd BufEnter * call s:load_flags()
augroup END
