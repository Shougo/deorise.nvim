"=============================================================================
" FILE: deorise.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! deorise#initialize() abort
  return deorise#init#_initialize()
endfunction

function! deorise#start(paths, user_context) abort
  call deorise#initialize()
  let context = deorise#init#_context(a:user_context)
endfunction

function! deorise#do_action(action, ...) abort
  if &l:filetype !=# 'deorise'
    return ''
  endif

  let args = deorise#util#convert2list(get(a:000, 0, []))
endfunction
function! deorise#call_action(action, ...) abort
  if &l:filetype !=# 'deorise'
    return
  endif

  let context = deorise#init#_context({})
  let args = deorise#util#convert2list(get(a:000, 0, []))
endfunction
