" File: scratch.vim
" Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" Version: 1.0
" Last Modified: June 3, 2003
"
" Overview
" --------
" You can use the scratch plugin to create a temporary scratch buffer to store
" and edit text that will be discarded when you quit/exit vim. The contents
" of the scratch buffer are not saved/stored in a file.
"
" Installation
" ------------
" 1. Copy the scratch.vim plugin to the $HOME/.vim/plugin directory. Refer to
"    the following Vim help topics for more information about Vim plugins:
"
"       :help add-plugin
"       :help add-global-plugin
"       :help runtimepath
"
" 2. Restart Vim.
"
" Usage
" -----
" You can use the following command to open/edit the scratch buffer:
"
"       :Scratch
"
" To open the scratch buffer in a new split window, use the following command:
"
"       :Sscratch
"
" When you close the scratch buffer window, the buffer will retain the
" contents. You can again edit the scratch buffer by openeing it using one of
" the above commands. There is no need to save the scatch buffer.
"
" When you quit/exit Vim, the contents of the scratch buffer will be lost.
" You will not be prompted to save the contents of the modified scratch
" buffer.
"
" You can have only one scratch buffer open in a single Vim instance. If the
" current buffer has unsaved modifications, then the scratch buffer will be
" opened in a new window
"
" ****************** Do not modify after this line ************************
if exists('loaded_scratch') || &cp
    finish
endif
let loaded_scratch=1

" Scratch buffer name
let ScratchBufferName = "__Scratch__"

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
        if split_win
            exe "new " . g:ScratchBufferName
        else
            exe "edit " . g:ScratchBufferName
        endif
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
            if split_win
                exe "split +buffer" . scr_bufnum
            else
                exe "buffer " . scr_bufnum
            endif
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

function! s:ScratchBufferToggle()
  let winnum = bufwinnr(g:ScratchBufferName)
  if winnum == -1
    call s:ScratchBufferOpen(1)
  else
    call s:ScratchBufferClose()
  endif
endfunction

" ScratchMarkBuffer
" Mark a buffer as scratch
function! s:ScratchMarkBuffer()
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal buflisted
endfunction

" ScratchLogMsg
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

" ScratchWarningMsg()
" Display a message using WarningMsg highlight group
function! s:ScratchWarningMsg(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

autocmd BufNewFile __Scratch__ call s:ScratchMarkBuffer()

" Command to edit the scratch buffer in the current window
command! -nargs=0 Scratch call s:ScratchBufferOpen(0)
" Command to open the scratch buffer in a new split window
command! -nargs=0 Sscratch call s:ScratchBufferOpen(1)
" Command to close the scratch buffer
command! -nargs=0 -bar ScratchClose call s:ScratchBufferClose()
" Command to toggle the scratch buffer in a new split window
command! -nargs=0 -bar ScratchToggle call s:ScratchBufferToggle()
