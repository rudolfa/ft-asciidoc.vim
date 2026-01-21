# asciibox-vft-asciidoc-plugin
Overwrites ft asciidoc system plugin

## Prerequisite

At least vim 8 or younger

## 🚀 Features 

- **Follow links**
 - **gf** goto file. Support for include and xref macro.
 - **gp** preview file. Open as textfile. Use [Asciidoctor.js](https://docs.asciidoctor.org/asciidoctor.js/latest/extend/extensions/) to render it.
 - **gx** open link. Support http,https,link, ftp macros.

## 📦 Installation

Use your prefered Plugin-Manager.
Maybe 
 [vim-plug](https://github.com/junegunn/vim-plug) or [vim-packager](https://github.com/kristijanhusak/vim-packager)
 
I use [vim-packager](https://github.com/kristijanhusak/vim-packager)

### Packer Initialisation Prefix block
```vim
"  PLUGINS ---------------------------------------------------------------- {{{
" Packager had to be installes first
" git clone https://github.com/kristijanhusak/vim-packager ~/.vim/pack/packager/opt/vim-packager
" Load packager only when you need it
function! PackagerInit() abort
    packadd vim-packager
    call packager#init()
    call packager#add('kristijanhusak/vim-packager', { 'type': 'opt' })
```    
    
### Add this to your PackerInit() function
```vim
    call packager#add('rudolfa/asciibox-vft-asciidoc-plugin')
```

### Packer Installation Suffix block
```vim
endfunction
" These commands are automatically added when using `packager#setup()`
command! -nargs=* -bar PackagerInstall call PackagerInit() | call packager#install(<args>)
command! -nargs=* -bar PackagerUpdate call PackagerInit() | call packager#update(<args>)
command! -bar PackagerClean call PackagerInit() | call packager#clean()
command! -bar PackagerStatus call PackagerInit() | call packager#status()
}}}
```

## Usage
See
```vim
:h asciibox-ft-asciidoc
```

## License
MIT
