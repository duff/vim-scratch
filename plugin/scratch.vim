" File: scratch.vim
" Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" Modified By: Dennis Burke (dennisburke AT prodigy DOT net)
" Version: 1.1
" Last Modified: January 11, 2012
"
" User Options:
" =============
"
" By default, the name of the scratch file is "__Scratch__".  You may set your
" own scratch file name by adding the following to your .vimrc :
" let g:scratch_filename = "my scratch file name.txt"
"
" Also, the default is to set the scratch buffer as hidden when closed.  If
" you open the scratch buffer again before you close vim, the contents of the
" buffer will still be there.  If you like the buffer to be deleted upon
" closing it, add the following to your .vimrc :
" let g:scratch_bufclose = 2
"
" TODO:
" - Add an option to create another scratch buffer if one is already open.
"
if exists('loaded_scratch') || &cp
    finish
endif
let loaded_scratch=1

" Scratch buffer name
if !exists('g:scratch_filename')
	let ScratchBufferName = "__Scratch__"
else
	let ScratchBufferName = escape(g:scratch_filename, ' ')
endif

" When the buffer is closed, what should happen to the buffer?
" 1 - set it to be hidden (default)
" 2 - delete the buffer
if !exists('g:scratch_bufclose')
    let g:scratch_bufclose = 1
endif

" ScratchBufferOpen
" Open the scratch buffer
function! s:ScratchBufferOpen(new_win)
    let split_win = a:new_win

    " If the current buffer is modified then open the scratch buffer in a new
    " window
    if !split_win && &modified
        let split_win = 1
    endif

    " Check whether the scratch buffer is already created
    let scr_bufnum = bufnr(g:ScratchBufferName)
    if scr_bufnum == -1
        " open a new scratch buffer
        if split_win == 1
            exe "new " . g:ScratchBufferName
        elseif split_win == 2
            exe "tabnew " . g:ScratchBufferName
        else
            exe "edit " . g:ScratchBufferName
        endif
        let s:scr_fullpath = expand("%:p")
    else
        " Scratch buffer is already created. Check whether it is open
        " in one of the windows
        let scr_winnum = bufwinnr(scr_bufnum)
        if scr_winnum != -1
            " Jump to the window which has the scratch buffer if we are not
            " already in that window
            if winnr() != scr_winnum
                exe scr_winnum . "wincmd w"
            endif
        else
            " Create a new scratch buffer
            if split_win == 1
                exe "split +buffer" . scr_bufnum
            elseif split_win == 2
                exe "tab drop " . escape(s:scr_fullpath, ' ')
            else
                exe "buffer " . scr_bufnum
            endif
        endif
    endif
    setfiletype scratch
endfunction

" ScratchMarkBuffer
" Mark a buffer as scratch
function! s:ScratchMarkBuffer()
    setlocal buftype=nofile
    if g:scratch_bufclose == 1
        setlocal bufhidden=hide
    elseif g:scratch_bufclose == 2
        setlocal bufhidden=delete
    endif
    setlocal noswapfile
    setlocal buflisted
endfunction

autocmd FileType scratch call s:ScratchMarkBuffer()

" Command to edit the scratch buffer in the current window
command! -nargs=0 Scratch call s:ScratchBufferOpen(0)
" Command to open the scratch buffer in a new split window
command! -nargs=0 Sscratch call s:ScratchBufferOpen(1)
" Command to open the scratch buffer in a new tab
command! -nargs=0 Tscratch call s:ScratchBufferOpen(2)
