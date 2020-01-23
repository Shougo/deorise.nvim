"=============================================================================
" FILE: deorise.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! s:check_required_python_for_deorise() abort
  if has('python3')
    call health#report_ok('has("python3") was successful')
  else
    call health#report_error('has("python3") was not successful')
  endif

  if deorise#init#_python_version_check()
    call health#report_error('Python 3.6.1+ was successful')
  else
    call health#report_ok('Python 3.6.1+ was successful')
  endif
endfunction

function! health#deorise#check() abort
  call health#report_start('deorise.nvim')

  call s:check_required_python_for_deorise()
endfunction
