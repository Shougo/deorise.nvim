"=============================================================================
" FILE: util.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

let s:is_windows = has('win32') || has('win64')
let s:is_mac = !s:is_windows && !has('win32unix')
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!isdirectory('/proc') && executable('sw_vers')))

function! deorise#util#print_error(string) abort
  echohl Error | echomsg '[deorise] '
        \ . deorise#util#string(a:string) | echohl None
endfunction
function! deorise#util#print_warning(string) abort
  echohl WarningMsg | echomsg '[deorise] '
        \ . deorise#util#string(a:string) | echohl None
endfunction
function! deorise#util#print_debug(string) abort
  echomsg '[deorise] ' . deorise#util#string(a:string)
endfunction
function! deorise#util#print_message(string) abort
  echo '[deorise] ' . deorise#util#string(a:string)
endfunction
function! deorise#util#is_windows() abort
  return s:is_windows
endfunction

function! deorise#util#convert2list(expr) abort
  return type(a:expr) ==# type([]) ? a:expr : [a:expr]
endfunction
function! deorise#util#string(expr) abort
  return type(a:expr) ==# type('') ? a:expr : string(a:expr)
endfunction
function! deorise#util#split(string) abort
  return split(a:string, '\s*,\s*')
endfunction

function! deorise#util#has_yarp() abort
  return !has('nvim') || get(g:, 'deorise#enable_yarp', 0)
endfunction

function! deorise#util#execute_path(command, path) abort
  try
    execute a:command fnameescape(s:expand(a:path))
  catch /^Vim\%((\a\+)\)\=:E325/
    " Ignore swap file error
  catch
    call deorise#util#print_error(v:throwpoint)
    call deorise#util#print_error(v:exception)
  endtry
endfunction
function! s:expand(path) abort
  return s:substitute_path_separator(
        \ (a:path =~# '^\~') ? fnamemodify(a:path, ':p') :
        \ a:path)
endfunction
function! s:expand_complete(path) abort
  return s:substitute_path_separator(
        \ (a:path =~# '^\~') ? fnamemodify(a:path, ':p') :
        \ (a:path =~# '^\$\h\w*') ? substitute(a:path,
        \             '^\$\h\w*', '\=eval(submatch(0))', '') :
        \ a:path)
endfunction
function! s:substitute_path_separator(path) abort
  return s:is_windows ? substitute(a:path, '\\', '/', 'g') : a:path
endfunction

function! deorise#util#call_deorise(command, args) abort
  let [paths, context] = deorise#util#_parse_options_args(a:args)
  call deorise#start(paths, context)
endfunction

function! deorise#util#input(prompt, ...) abort
  let text = get(a:000, 0, '')
  let completion = get(a:000, 1, '')
  try
    if completion !=# ''
      return input(a:prompt, text, completion)
    else
      return input(a:prompt, text)
    endif
  catch
    " ignore the errors
    return ''
  endtry
endfunction
function! deorise#util#confirm(msg, choices, default) abort
  try
    return confirm(a:msg, a:choices, a:default)
  catch
    " ignore the errors
  endtry

  return a:default
endfunction

function! deorise#util#_parse_options_args(cmdline) abort
  return s:parse_options(a:cmdline)
endfunction
function! s:re_unquoted_match(match) abort
  " Don't match a:match if it is located in-between unescaped single or double
  " quotes
  return a:match . '\v\ze([^"' . "'" . '\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"|'
        \ . "'" . '([^' . "'" . '\\]*\\.)*[^' . "'" . '\\]*' . "'" . '))*[^"'
        \ . "'" . ']*$'
endfunction
function! s:remove_quote_pairs(s) abort
  " remove leading/ending quote pairs
  let s = a:s
  if s[0] ==# '"' && s[len(s) - 1] ==# '"'
    let s = s[1: len(s) - 2]
  elseif s[0] ==# "'" && s[len(s) - 1] ==# "'"
    let s = s[1: len(s) - 2]
  else
    let s = substitute(a:s, '\\\(.\)', "\\1", 'g')
  endif
  return s
endfunction
function! s:parse_options(cmdline) abort
  let args = []
  let options = {}

  " Eval
  let cmdline = (a:cmdline =~# '\\\@<!`.*\\\@<!`') ?
        \ s:eval_cmdline(a:cmdline) : a:cmdline

  for s in split(cmdline, s:re_unquoted_match('\%(\\\@<!\s\)\+'))
    let arg = substitute(s, '\\\( \)', '\1', 'g')
    let arg_key = substitute(arg, '=\zs.*$', '', '')

    let name = substitute(tr(arg_key, '-', '_'), '=$', '', '')[1:]
    if name =~# '^no_'
      let name = name[3:]
      let value = v:false
    else
      let value = (arg_key =~# '=$') ?
            \ s:remove_quote_pairs(arg[len(arg_key) :]) : v:true
    endif

    if index(keys(deorise#init#_user_options()), name) >= 0
      let options[name] = value
    else
      call add(args, arg)
    endif
  endfor

  return [args, options]
endfunction
function! s:eval_cmdline(cmdline) abort
  let cmdline = ''
  let prev_match = 0
  let eval_pos = match(a:cmdline, '\\\@<!`.\{-}\\\@<!`')
  while eval_pos >= 0
    if eval_pos - prev_match > 0
      let cmdline .= a:cmdline[prev_match : eval_pos - 1]
    endif
    let prev_match = matchend(a:cmdline,
          \ '\\\@<!`.\{-}\\\@<!`', eval_pos)
    let cmdline .= escape(eval(a:cmdline[eval_pos+1 : prev_match - 2]), '\ ')

    let eval_pos = match(a:cmdline, '\\\@<!`.\{-}\\\@<!`', prev_match)
  endwhile
  if prev_match >= 0
    let cmdline .= a:cmdline[prev_match :]
  endif

  return cmdline
endfunction

function! deorise#util#complete(arglead, cmdline, cursorpos) abort
  let _ = []

  if a:arglead =~# '^-'
    " Option names completion.
    let bool_options = keys(filter(copy(deorise#init#_user_options()),
          \ 'type(v:val) == type(v:true) || type(v:val) == type(v:false)'))
    let _ += map(copy(bool_options), "'-' . tr(v:val, '_', '-')")
    let string_options = keys(filter(copy(deorise#init#_user_options()),
          \ 'type(v:val) != type(v:true) && type(v:val) != type(v:false)'))
    let _ += map(copy(string_options), "'-' . tr(v:val, '_', '-') . '='")

    " Add "-no-" option names completion.
    let _ += map(copy(bool_options), "'-no-' . tr(v:val, '_', '-')")
  else
    let arglead = s:expand_complete(a:arglead)
    " Path names completion.
    let files = filter(map(glob(a:arglead . '*', v:true, v:true),
          \                's:substitute_path_separator(v:val)'),
          \            'stridx(tolower(v:val), tolower(arglead)) == 0')
    let files = map(filter(files, 'isdirectory(v:val)'),
          \ 's:expand_complete(v:val)')
    if a:arglead =~# '^\~'
      let home_pattern = '^'. s:expand_complete('~')
      call map(files, "substitute(v:val, home_pattern, '~/', '')")
    endif
    call map(files, "escape(v:val.'/', ' \\')")
    let _ += files
  endif

  return uniq(sort(filter(_, 'stridx(v:val, a:arglead) == 0')))
endfunction

function! deorise#util#has_yarp() abort
  return !has('nvim')
endfunction
function! deorise#util#rpcrequest(method, args, is_async) abort
  if !deorise#init#_check_channel()
    return -1
  endif

  if deorise#util#has_yarp()
    if g:deorise#_yarp.job_is_dead
      return -1
    endif
    if a:is_async
      return g:deorise#_yarp.notify(a:method, a:args)
    else
      return g:deorise#_yarp.request(a:method, a:args)
    endif
  else
    if a:is_async
      return rpcnotify(g:deorise#_channel_id, a:method, a:args)
    else
      return rpcrequest(g:deorise#_channel_id, a:method, a:args)
    endif
  endif
endfunction
