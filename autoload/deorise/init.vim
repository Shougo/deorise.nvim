"=============================================================================
" FILE: init.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! deorise#init#_initialize() abort
  if exists('g:deorise#_channel_id')
    return
  endif

  call deorise#init#_channel()

  augroup deorise
    autocmd!
  augroup END
endfunction
function! deorise#init#_channel() abort
  if !has('python3')
    call deorise#util#print_error(
          \ 'deorise requires Python3 support("+python3").')
    return v:true
  endif
  if has('nvim') && !has('nvim-0.3.0')
    call deorise#util#print_error('deorise requires nvim 0.3.0+.')
    return v:true
  endif
  if !has('nvim') && v:version < 801
    call deorise#util#print_error('deorise requires Vim 8.1+.')
    return v:true
  endif

  try
    if deorise#util#has_yarp()
      let g:deorise#_yarp = yarp#py3('deorise')
      call g:deorise#_yarp.request('_deorise_init')
      let g:deorise#_channel_id = 1
    else
      " rplugin.vim may not be loaded on VimEnter
      if !exists('g:loaded_remote_plugins')
        runtime! plugin/rplugin.vim
      endif

      call _deorise_init()
    endif
  catch
    call deorise#util#print_error(v:exception)
    call deorise#util#print_error(v:throwpoint)

    let python_version_check = deorise#init#_python_version_check()
    if python_version_check
      call deorise#util#print_error(
            \ 'deorise requires Python 3.6.1+.')
    endif

    if deorise#util#has_yarp()
      if !has('nvim') && !exists('*neovim_rpc#serveraddr')
        call deorise#util#print_error(
              \ 'deorise requires vim-hug-neovim-rpc plugin in Vim.')
      endif

      if !exists('*yarp#py3')
        call deorise#util#print_error(
              \ 'deorise requires nvim-yarp plugin.')
      endif
    else
      call deorise#util#print_error(
          \ 'deorise failed to load. '
          \ .'Try the :UpdateRemotePlugins command and restart Neovim. '
          \ .'See also :checkhealth.')
    endif

    return v:true
  endtry
endfunction
function! deorise#init#_check_channel() abort
  return exists('g:deorise#_channel_id')
endfunction

function! deorise#init#_python_version_check() abort
  python3 << EOF
import vim
import sys
vim.vars['deorise#_python_version_check'] = (
    sys.version_info.major,
    sys.version_info.minor,
    sys.version_info.micro) < (3, 6, 1)
EOF
  return g:deorise#_python_version_check
endfunction
function! deorise#init#_user_options() abort
  return {
        \ }
endfunction
function! s:internal_options() abort
  return {
        \ }
endfunction
function! deorise#init#_context(user_context) abort
  let buffer_name = get(a:user_context, 'buffer_name', 'default')
  let context = s:internal_options()
  call extend(context, deorise#init#_user_options())
  let custom = deorise#custom#_get()
  if has_key(custom.option, '_')
    call extend(context, custom.option['_'])
  endif
  if has_key(custom.option, buffer_name)
    call extend(context, custom.option[buffer_name])
  endif
  call extend(context, a:user_context)
  return context
endfunction
