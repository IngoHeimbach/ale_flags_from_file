if exists('g:ale_flags_from_file_loaded') && g:ale_flags_from_file_loaded
  finish
endif
let g:ale_flags_from_file_loaded = 1

augroup ale_flags_from_file
    autocmd!
    autocmd BufEnter * call ale_flags_from_file#load_flags()
    autocmd Filetype * call ale_flags_from_file#load_flags()
augroup END
