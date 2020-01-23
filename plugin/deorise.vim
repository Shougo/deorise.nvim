"=============================================================================
" FILE: deorise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

if exists('g:loaded_deorise')
  finish
endif
let g:loaded_deorise = 1

command! -nargs=* -range -bar -complete=customlist,deorise#util#complete
      \ Deorise
      \ call deorise#util#call_deorise('Deorise', <q-args>)
