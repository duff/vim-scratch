" File: scratch.vim
" Version: 1.9.1
" Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" Modified By: Duff OMelia
" Modified By: Mark Bennett
" Modified By: Doug Avery
" Modified By: Dennis Burke (dennisburke AT prodigy DOT net)
" Modified By: Alessio Bolognino (alessio.bolognino AT gmail DOT com)
" Last Modified: 15 August 2012

if exists('loaded_scratch') || &cp
    finish
endif

let loaded_scratch = 1


" Default height of scratch window.
if !exists('g:scratch_height')
    let g:scratch_height = 20
endif

" Default width of scratch window.
if !exists('g:scratch_width')
    let g:scratch_width = 100
endif

if !exists('g:scratch_persistent')
    " 0 => closing the buffer deletes it
    " 1 => deleted at the end of the session
    " 2 => persistent between sessions
    let g:scratch_persistent = 1
endif

" Scratch buffer name
if !exists('g:scratch_filename')
    let ScratchBufferName = "__Scratch__"
else
    let ScratchBufferName = escape(g:scratch_filename, ' ')
endif

" Open the scratch buffer
function! s:ScratchBufferOpen(new_win, vert)
    let split_win = a:new_win
    let vert_split = a:vert

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
            if vert_split
                exe g:scratch_width . "vnew " . g:ScratchBufferName
            else
                exe g:scratch_height . "new " . g:ScratchBufferName
            endif
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
                if vert_split
                    exe g:scratch_width . "vsplit +buffer" . scr_bufnum
                else
                    exe g:scratch_height . "split +buffer" . scr_bufnum
                endif
            elseif split_win == 2
                exe "tab drop " . escape(s:scr_fullpath, ' ')
            else
                exe "buffer " . scr_bufnum
            endif
        endif
    endif
    setfiletype scratch

    " If a scratch file is configured, load its content into the scratch
    " buffer.
    if g:scratch_persistent == 2
        let s:filename_expanded = expand(g:scratch_filename)

        if filereadable(s:filename_expanded)
            let content = readfile(s:filename_expanded)
            call setline(1, content)
        endif
    endif
endfunction

function! s:ScratchBufferClose()
    let winnum = bufwinnr(g:ScratchBufferName)
    if winnum == -1
        call s:ScratchWarningMsg('Error: Scratch window is not open')
        return
    endif

    if winnr() == winnum
        " Already in the scratch window. Close it and return
        if winbufnr(2) != -1
            " If a window other than the scratch window is open,
            " then only close the taglist window.
            close
        endif
    else
        " Goto the scratch window, close it and then come back to the
        " original window
        let curbufnr = bufnr('%')
        exe winnum . 'wincmd w'
        close
        " Need to jump back to the original window only if we are not
        " already in that window
        let winnum = bufwinnr(curbufnr)
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
    endif
endfunction

function! s:ScratchBufferToggle(vert)
    let vert_split = a:vert
    let winnum = bufwinnr(g:ScratchBufferName)
    if winnum == -1
        if vert_split
            call s:ScratchBufferOpen(1, 1)
        else
            call s:ScratchBufferOpen(1, 0)
        endif
    else
        call s:ScratchBufferClose()
    endif
endfunction

" ScratchMarkBuffer
" Mark a buffer as scratch
function! s:ScratchMarkBuffer()
    setlocal buftype=nofile
    if g:scratch_persistent == 1
        setlocal bufhidden=hide
    elseif g:scratch_persistent == 0
        setlocal bufhidden=delete
    endif
    setlocal noswapfile
    setlocal buflisted
endfunction

" Save the scratch buffer to a file.
function! s:ScratchSave()
    if g:scratch_persistent == 2
        let scr_bufnum = bufnr(g:ScratchBufferName)

        if scr_bufnum != -1
            let s:filename_expanded = expand(g:scratch_filename)
            let content = getbufline(g:ScratchBufferName, 1, '$')
            call writefile(content, s:filename_expanded)
        endif
    endif
endf

" Log the supplied debug message along with the time
let s:scratch_msg = ''
let s:scratch_debug = 1
let s:scratch_debug_file = ''
function! s:ScratchLogMsg(msg)
    if s:scratch_debug
        if s:scratch_debug_file != ''
            exe 'redir >> ' . s:scratch_debug_file
            silent echon strftime('%H:%M:%S') . ': ' . a:msg . "\n"
            redir END
        else
            " Log the message into a variable
            " Retain only the last 3000 characters
            let len = strlen(s:scratch_msg)
            if len > 3000
                let s:scratch_msg = strpart(s:scratch_msg, len - 3000)
            endif
            let s:scratch_msg = s:scratch_msg . strftime('%H:%M:%S') . ': ' .
                        \ a:msg . "\n"
        endif
    endif
endfunction

" Display a message using WarningMsg highlight group
function! s:ScratchWarningMsg(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

autocmd FileType scratch call s:ScratchMarkBuffer()
autocmd BufUnload,BufDelete,BufHidden,BufWinLeave,BufLeave * if &ft ==# 'scratch' | call s:ScratchSave() | endif

" Command to edit the scratch buffer in the current window
command! -nargs=0 Scratch call s:ScratchBufferOpen(0, 0)

" Command to open the scratch buffer in a new split window
command! -nargs=0 Sscratch call s:ScratchBufferOpen(1, 0)

" Command to open the scratch buffer in a new vertical split window
command! -nargs=0 Vscratch call s:ScratchBufferOpen(1, 1)

" Command to close the scratch buffer
command! -nargs=0 -bar ScratchClose call s:ScratchBufferClose()

" Command to toggle the scratch buffer in a new split window
command! -nargs=0 -bar ScratchToggle call s:ScratchBufferToggle(0)

" Command to toggle the scratch buffer in a new vertical split window
command! -nargs=0 -bar VscratchToggle call s:ScratchBufferToggle(1)

" Command to open the scratch buffer in a new tab
command! -nargs=0 Tscratch call s:ScratchBufferOpen(2, 0)
