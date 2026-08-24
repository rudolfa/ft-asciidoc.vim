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
"  Adjust file complete for asciidoc files
" --------------------------------------------------------
function! AsciidocFileComplete(findstart, base)
  if a:findstart
    " Pass 1: Determine the start position of the path
    let l:line = getline('.')
    let l:col = col('.') - 1
    let l:text_before = l:line[:l:col-1]
    
    " Check if we are right after a macro
    if l:text_before =~# '\v(link|xref|include|image)::?$'
      return match(l:text_before, '\v(link|xref|include|image)::?$') + matchend(l:text_before, '\v(link|xref|include|image)::?$')
    endif
    return -1
  else
    " Pass 2: Collect matches
    let l:line = getline('.')
    let l:col = col('.') - 1
    let l:text_before = l:line[:l:col-1]
    
    " Temporarily remove the colon from isfname
    let l:old_isfname = &isfname
    setlocal isfname-=:
    
    let l:matches = []
    
    " Read all files and store directories separately.
    " copy() prevents filter() from destroying the l:all_files list.
    let l:all_files = glob(a:base . '*', 0, 1)
    let l:dirs = filter(copy(l:all_files), 'isdirectory(v:val)')
    
    if l:text_before =~# '\vimage::?$'
      " Image files: Configurable via g:asciidoc_image_extensions
      let l:extensions = get(g:, 'asciidoc_image_extensions', ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp'])
      
      for l:ext in l:extensions
        call extend(l:matches, glob(a:base . '*.' . l:ext, 0, 1))
        call extend(l:matches, glob(a:base . '*.' . toupper(l:ext), 0, 1))
      endfor
      call extend(l:matches, l:dirs)
      
    elseif l:text_before =~# '\vinclude::?$'
      " Include: .adoc, .csv, and various source code formats (configurable)
      let l:include_exts = get(g:, 'asciidoc_include_extensions', ['adoc', 'csv', 'java', 'py', 'sh', 'vim', 'json', 'xml', 'html', 'css', 'js', 'ts', 'c', 'cpp', 'txt'])
      
      for l:ext in l:include_exts
        call extend(l:matches, glob(a:base . '*.' . l:ext, 0, 1))
        call extend(l:matches, glob(a:base . '*.' . toupper(l:ext), 0, 1))
      endfor
      call extend(l:matches, l:dirs)
      
    elseif l:text_before =~# '\vxref::?$'
      " Xref: Strictly allow only .adoc and directory navigation
      call extend(l:matches, glob(a:base . '*.adoc', 0, 1))
      call extend(l:matches, glob(a:base . '*.ADOC', 0, 1))
      call extend(l:matches, l:dirs)
      
    else
      " For link: (and as a fallback), show all files without restrictions
      let l:matches = l:all_files
    endif
    
    " Immediately restore isfname
    let &l:isfname = l:old_isfname
    
    " Clean up: Sort and remove duplicates
    return uniq(sort(l:matches))
  endif
endfunction


" ---------------------------------------------------------
" Support filename completion after specific asciidoc macros
" ---------------------------------------------------------
function! s:SetupAsciidocCompletion()
  " Register clean user defined autocomplete function 
  setlocal completefunc=AsciidocFileComplete

  " Check during insertmode if we are behind a macro
  inoremap <buffer> <expr> <C-x><C-f> getline('.')[:col('.')-2] =~# '\v(link<bar>xref<bar>include<bar>image)::?$' ? "\<C-x>\<C-u>" : "\<C-x>\<C-f>"

endfunction


" Execute when loading the ftplugins
call s:SetupAsciidocCompletion()


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
" Cleanup
" ---------------------------------------------------------
let b:undo_ftplugin = "setlocal isfname< includeexpr< | silent! nunmap <buffer> gp | silent! nunmap <buffer> gx"

" ---------------------------------------------------------
"  Folding activate by default
" ---------------------------------------------------------
if has("folding") && get(g:, 'asciidoc_folding', 0)
    runtime ftplugin/asciidoc/opt/folding.vim
endif

" ---------------------------------------------------------
" Mappings
" ---------------------------------------------------------
nnoremap <silent><buffer> gp :call job_start([expand(g:asciibox_browser), expand('%')])<CR>
nnoremap <silent><buffer> gx :call <SID>OpenAsciiDocLink()<CR>

