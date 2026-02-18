" Folding-Komponente für AsciiDoc

" ---------------------------------------------------------
"  Folding
" ---------------------------------------------------------
setlocal foldexpr=getline(v:lnum)=~'^=\\+\\s'?'>'.len(matchstr(getline(v:lnum),'^=\\+')):'='
setlocal foldtext=<SID>AsciiDocFoldText()
setlocal foldlevel=1
setlocal foldlevelstart=1
setlocal foldenable

" Switch, calc and back to normal
function! s:AsciiDocUpdateFolds()
  if &filetype == 'asciidoc'
    let l:save_view = winsaveview()

    setlocal foldmethod=expr
    redraw
    setlocal foldmethod=manual

    call winrestview(l:save_view)
  endif
endfunction

" ---------------------------------------------------------
" Automatisation
" ---------------------------------------------------------
augroup AsciiDocFastFold
  autocmd! * <buffer>

  autocmd BufReadPost,BufWritePost <buffer> call s:AsciiDocUpdateFolds()

  " autocmd InsertLeave <buffer> call s:AsciiDocUpdateFolds()
augroup END

" ---------------------------------------------------------
" Beautify fold text
" ---------------------------------------------------------
function! s:AsciiDocFoldText()
    let l:line = getline(v:foldstart)

    let l:lines_count = v:foldend - v:foldstart + 1
    let l:info = ' (' . l:lines_count . ' Zeilen) '

    let l:window_width = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)

    let l:text_len = strdisplaywidth(l:line)
    let l:info_len = strdisplaywidth(l:info)

    let l:fill_len = l:window_width - l:text_len - l:info_len

    if l:fill_len < 0
        let l:fill_len = 0
    endif

    return l:line . repeat('·', l:fill_len) . l:info
endfunction

" ---------------------------------------------------------
" Initial call
" ---------------------------------------------------------
call s:AsciiDocUpdateFolds()

" ---------------------------------------------------------
" Mappings
" ---------------------------------------------------------
nnoremap <buffer> <silent> <LocalLeader>z :call <SID>AsciiDocUpdateFolds()<CR>

" Ergänzung zum Cleanup
let b:undo_ftplugin .= "| silent! nunmap <buffer> <LocalLeader>z | silent! autocmd! AsciiDocFastFold | setlocal foldmethod< foldexpr<"
