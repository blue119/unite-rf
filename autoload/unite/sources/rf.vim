let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'rf',
      \ 'hooks': {},
      \ 'matchers' : 'matcher_regexp',
      \ }

function! s:unite_source.hooks.on_init(args, context)
  let s:rf_keywords = get(g:, 'rf_buf', 'default')
endfunction

function! s:unite_source.hooks.on_close(args, context)
  if s:rf_keywords== g:rf_buf
    return
  endif

  execute s:rf(s:rf_keywords)
endfunction

function! s:rf(x)
  return printf("%s %s",
        \ get(g:, 'unite_rf_command', 'rf'),
        \ a:x)
endfunction

function! s:_string_enc(s)
      return substitute(a:s, ' ', '@!@', 'g')
endfunction

function! s:_string_dec(s)
      return substitute(a:s, '@!@', ' ', 'g')
endfunction


let s:cndts_cache = []
function! s:unite_source.gather_candidates(args, context)

  if ! exists('g:cndts')
    let g:cndts = {}
    let s:cndts_list = []
    echo system('pwd')
    let tbls = split(system('python /home/blue119/.vim/bundle/unite-rf/list_rf_tbls.py /home/blue119/iLab/ci/robotframework/robotframework/src/RWTestRobot'), '\n')
    for tbl in tbls
        let l = split(tbl, '!\~!')
        let g:cndts[l[0]] = l[1:]
        call add(s:cndts_list, [l[0], s:_string_enc(l[0])])
    endfor
    let s:cndts_cache = copy(s:cndts_list)
  endif

  let s:cndts_list = copy(s:cndts_cache)
  return map(s:cndts_list, '{
         \ "word": v:val[0],
         \ "source": "rf",
         \ "kind": "command",
         \ "action__command": "UniteRfShow " . v:val[1],
         \ }')

endfunction

function! unite#sources#rf#define()
  return s:unite_source
endfunction

func! UniteRfShow(key) abort
    let l:pwd = getcwd()
    exec 'silent pedit ' . tempname()
    wincmd P

    call append(0, g:cndts[s:_string_dec(a:key)])
    " call append(0, g:cndts)

    setl buftype=nofile
    setl bufhidden=hide
    setl noswapfile
    setl nonu ro noma ignorecase

    call histdel(":", '^UniteRfShow')
    nnoremap <silent> <buffer> q :silent bd!<CR>
endf
command! -nargs=* UniteRfShow call UniteRfShow(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
