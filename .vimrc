"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Common option
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set visualbell
set nobackup
set noswapfile
set nowrap
set nocompatible
set backspace=indent,eol,start
set viminfo='20,\"1000
set history=50      
set ruler          
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set showcmd
set showmatch
set ignorecase
set smartcase
set scrolloff=1
set background=dark
set autowrite
set nrformats-=octal
set clipboard=autoselect
set hlsearch                                                                                                      
set nowrapscan
set tabline=%!MyTabLine()
syntax on
filetype on
colorscheme ron
set completeopt=
let loaded_matchparen = 1
set autoindent
autocmd FileType * set comments=
set t_ti= t_te=
"set list
"set cursorline
"set spell

set laststatus=2
set statusline=%F%m%r%h%w%=[%{&ff}]\ [%{has('multi_byte')&&\ &fileencoding!=''?&fileencoding:&encoding}][%04l,%03v][%3p%%]

"set tags+=tags;
"set tags+=./**/tags
set tag=tags

highlight TabLine     term=NONE cterm=NONE ctermfg=white ctermbg=blue guifg=white guibg=blue
highlight TabLineFill term=NONE cterm=NONE ctermfg=white ctermbg=blue guifg=white guibg=blue
highlight TabLineSel  term=NONE cterm=NONE ctermfg=black ctermbg=white guifg=black guibg=white
highlight StatusLine  term=NONE cterm=NONE ctermfg=black ctermbg=white guifg=black guibg=white

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if (v:progname ==? "vi")
    set encoding=japan
    set termencoding=cp932
    set fileencoding=cp932

    "set encoding=utf-8
    "set fileencoding=utf-8

    "set encoding=euc-jp
    "set fileencoding=euc-jp
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key bind
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map  <F5> :call CommentOutToggleSharp()<CR>
vmap <F5> :call CommentOutToggleSharp()<CR>
map  <F6> :call CommentOutToggleSlash()<CR>
vmap <F6> :call CommentOutToggleSlash()<CR>

"map  <F7> O<ESC>0i/*<ESC>j0i * <ESC>o<ESC>0i */<ESC>0
"vmap <F7> :call CommentOutToggleStar()<CR>
"map  <F7> 0i<!-- <ESC>A !--><ESC>0
"vmap <F7> :call CommentOutToggleML()<CR>
"map  <F8> 0i-- <ESC>0
"vmap <F8> :call CommentOutToggleSql()<CR>
"map  <F8> 0i<%-- <ESC>A --%><ESC>0
"vmap <F8> :call CommentOutToggleJSP()<CR>

map  <F7> :yank<CR>:put<CR>:.! ( echo 'obase=2;  ibase=16;'; cat ) \| d2u \| bc<CR>I= <ESC>
map  <F7> :yank<CR>:put<CR>:.! ( echo 'obase=16; ibase=16;'; cat ) \| d2u \| bc<CR>I= <ESC>
map  <F7> :yank<CR>:put<CR>:.! ( echo 'obase=10; ibase=10;'; cat ) \| d2u \| bc<CR>I= <ESC>

map  <F8> :call PutCurrentFile()<CR>
map  <F9> :call OpenGrepFile()<CR>
map  <F10> :call Open()<CR>
map  <F11> y$<CR>:call ClipBoard()<CR>
vmap <F11> :yank<CR>:call ClipBoard()<CR>
map  <F12> :tabnext<CR>

map  <C-\> :tab split<CR>:execute "tselect " . expand("<cword>")<CR>

cmap <C-F> <Right>
cmap <C-B> <Left>
cmap <C-D> <Del>
cmap <C-A> <Home>
cmap <C-E> <End>
map  <Space> <C-f>
map  b       <C-b>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function ClearUndo()
    :let old_undolevels = &undolevels
    :set undolevels=-1
    :exe "normal a \<BS>\<Esc>"
    :let &undolevels = old_undolevels
    :unlet old_undolevels
    :write
endfunction

function ClipBoard()
    call system("u2d | putclip", getreg())
endfunction

function Open()
    call system("explorer '" . getline(".") . "'")
endfunction

function OpenGrepFile()
    let s:line = getline(".")
    let s:input = split(s:line, ":")
    execute ":edit " . "+" . s:input[1] . " " . s:input[0]
endfunction

function PutCurrentFile()
    let s:line = expand("%:p") . ":" . line(".") . ":" . getline(".") . "\n"
    call setreg(v:register, s:line)
endfunction

function CommentOutToggleSharp()

    let s:line = getline(".")

    if ((strpart(s:line, 0, 1)) == "#")
        let s:rep = substitute(s:line, "^# ", "", "")
        call setline(".", s:rep)
    else
        let s:rep = substitute(s:line, ".*", "# &", "")
        call setline(".", s:rep)
    endif

    if (line(".") == a:lastline)
        
        unlet s:line
        unlet s:rep
    endif

endfunction

function CommentOutToggleSlash()

    let s:line = getline(".")

    if ((strpart(s:line, 0, 3)) == "// ")
        let s:rep = substitute(s:line, "^// ", "", "")
        call setline(".", s:rep)
    else
        let s:rep = substitute(s:line, ".*", "// &", "")
        call setline(".", s:rep)
    endif

    if (line(".") == a:lastline)
        
        unlet s:line
        unlet s:rep
    endif

endfunction

function CommentOutToggleStar()

    if (line(".") == a:firstline)

        let s:start = strpart(getline(a:firstline), 0, 2)
        let s:end   = strpart(getline(a:lastline), 0, 3)

        if (s:start == "/*" && s:end == " */")
            
            let s:num = a:firstline + 1
            while (s:num < a:lastline)

                let s:rep = substitute(getline(s:num), "^ \\* ", "", "")
                call setline(s:num, s:rep)
                let s:num = s:num + 1

            endwhile

            execute a:firstline . "delete"
            execute a:lastline - 1 . "delete"

        else

            let s:num = a:firstline
            while (s:num <= a:lastline)

                let s:rep = substitute(getline(s:num), ".*", " * &", "")
                call setline(s:num, s:rep)
                let s:num = s:num + 1

            endwhile

            call append(a:firstline - 1, "/*")
            call append(a:lastline + 1, " */")

        endif

        unlet s:start
        unlet s:end
        unlet s:num
        unlet s:rep

    endif

endfunction

function CommentOutToggleML()

    if (line(".") == a:firstline)

        let s:start = strpart(getline(a:firstline), 0, 4)
        let s:end   = strpart(getline(a:lastline), 0, 5)

        if (s:start == "<!--" && s:end == " !-->")
            
            let s:num = a:firstline + 1
            while (s:num < a:lastline)

                let s:rep = substitute(getline(s:num), "^ ! ", "", "")
                call setline(s:num, s:rep)
                let s:num = s:num + 1

            endwhile

            execute a:firstline . "delete"
            execute a:lastline - 1 . "delete"

        else

            let s:num = a:firstline
            while (s:num <= a:lastline)

                let s:rep = substitute(getline(s:num), ".*", " ! &", "")
                call setline(s:num, s:rep)
                let s:num = s:num + 1

            endwhile

            call append(a:firstline - 1, "<!--")
            call append(a:lastline + 1, " !-->")

        endif

        unlet s:start
        unlet s:end
        unlet s:num
        unlet s:rep

    endif

endfunction

function CommentOutToggleJSP()

    if (line(".") == a:firstline)

        let s:start = strpart(getline(a:firstline), 0, 5)
        let s:end   = strpart(getline(a:lastline), 0, 4)

        if (s:start == " <%--" && s:end == "--%>")
            
            let s:num = a:firstline + 1
            while (s:num < a:lastline)

                let s:rep = substitute(getline(s:num), "^  % ", "", "")
                call setline(s:num, s:rep)
                let s:num = s:num + 1

            endwhile

            execute a:firstline . "delete"
            execute a:lastline - 1 . "delete"

        else

            let s:num = a:firstline
            while (s:num <= a:lastline)

                let s:rep = substitute(getline(s:num), ".*", "  % &", "")
                call setline(s:num, s:rep)
                let s:num = s:num + 1

            endwhile

            call append(a:firstline - 1, " <%--")
            call append(a:lastline + 1,  "--%>")

        endif

        unlet s:start
        unlet s:end
        unlet s:num
        unlet s:rep

    endif

endfunction

function CommentOutToggleSql()

    let s:line = getline(".")

    if ((strpart(s:line, 0, 1)) == "-")
        let s:rep = substitute(s:line, "^-- ", "", "")
        call setline(".", s:rep)
    else
        let s:rep = substitute(s:line, ".*", "-- &", "")
        call setline(".", s:rep)
    endif

    if (line(".") == a:lastline)
        
        unlet s:line
        unlet s:rep
    endif

endfunction

function MoveCursor()

    let s:line = line("'\"")

    if  s:line > 0 && s:line <= line("$")
        call cursor(s:line, 0)
    endif

    unlet s:line

endfunction

function MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        " the label is made by MyTabLabel()
        let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'

    return s
endfunction

function MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let arr = split(bufname(buflist[winnr - 1]), '/')
    let win = winwidth(0)
    let tabs =  tabpagenr("$")
    let width = (win - (2 * tabs)) / tabs
    return strpart(arr[-1], 0, width)
endfunction

autocmd BufReadPost * :call MoveCursor()
