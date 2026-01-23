" Copyright (c) 2025 Andreas Rudolf <ardev@gmx.de>
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" ---------------------------------------------------------
" Support asciidoc file references for gf (Open file)
" ---------------------------------------------------------
setlocal isfname+=:,#,[
" gf to open xref:file.ext#anchor[], xref:file.exit[], include::file.ext[] and link:file.ext[] files
setlocal includeexpr=substitute(v:fname,'\\(link:\\\|include::\\\|xref:\\)\\(.\\{-}\\)\\([#\\[].*\\)','\\2','g')

" ---------------------------------------------------------
" Helperfunction for gx (Open Link )
" ---------------------------------------------------------
function! s:OpenAsciiDocLink()
    let l:raw_word = expand('<cWORD>')
    let l:url = split(l:raw_word, '\[' )[0]
    let l:url = substitute(l:url, '^link:', '', '')

    if l:url =~# '^\(http\|https\|file\|ftp\)://'
        call job_start([expand(g:asciibox_browser), l:url])
    else
        echomsg "Found no valid URL" . l:url
    endif
endfunction

" ---------------------------------------------------------
" OS Platform-independent call of browser
" ---------------------------------------------------------
if get(g:, 'asciibox_browser', '') == ''
    if has('mac')
        let g:asciibox_browser = "open"
    elseif has('win32')
        let g:asciibox_browser = "rundll32 url.dll,FileProtocolHandler"
    else
        " Fallback for Linux 
        let g:asciibox_browser = "xdg-open"
    endif
endif

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

" --- 3. Automatisierung (Autocmds) ---
augroup AsciiDocFastFold
  autocmd! * <buffer>

  autocmd BufReadPost,BufWritePost <buffer> call s:AsciiDocUpdateFolds()

  " autocmd InsertLeave <buffer> call s:AsciiDocUpdateFolds()
augroup END

" Foldtext
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

" Initial call
call s:AsciiDocUpdateFolds()

" ---------------------------------------------------------
" Mappings
" ---------------------------------------------------------
nnoremap <silent><buffer> gp :call job_start([expand(g:asciibox_browser), expand('%')])<CR>
nnoremap <silent><buffer> gx :call <SID>OpenAsciiDocLink()<CR>
nnoremap <buffer> <silent> <LocalLeader>z :call <SID>AsciiDocUpdateFolds()<CR>

if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = ''
endif

" ---------------------------------------------------------
" Cleanup
" ---------------------------------------------------------
let b:undo_ftplugin .= "| nunmap <buffer> gp"
let b:undo_ftplugin .= "| nunmap <buffer> gx"
let b:undo_ftplugin .= "| nunmap <buffer> <LocalLeader>z | autocmd! AsciiDocFastFold * <buffer>"
let b:undo_ftplugin .= "| setlocal isfname< includeexpr< foldmethod< foldexpr< foldlevel<"
