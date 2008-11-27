" File: scratch.vim
" Author:
" 	* Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" 	* Jonas Kramer (jkramer AT nex DOT scrapping DOT cc)
" Version: 1.1
" Last Modified: 2008-11-25
" Copyright: Copyright (C) 2003-2008 Yegappan Lakshmanan
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            scratch.vim is provided *as is* and comes with no warranty of any
"            kind, either expressed or implied. In no event will the copyright
"            holder be liable for any damages resulting from the use of this
"            software.
" 
" Changes/additions by Jonas Kramer:
" 	* Added toggle function and command.
" 	* Introduced option that lets you define the height of a scratch window.
" 	* Optionally saving buffer between sessions.
" 
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
"       :SplitScratch
"
" To toggle visibility of the scratch windoe, use:
"
" 		:ToggleScratch
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
" Settings
" --------
"
" Change the height of the scratch window in lines (default is 20).
"
" 	let g:scratch_height = 123
"
" Save the scratch buffers content between Vim sessions in some file.
"
" 	let g:scratch_file = ~/.vim/scratch
"
" ****************** Do not modify after this line ************************

if exists('loaded_scratch') || &cp
    finish
endif

let loaded_scratch = 1

" Default height of scratch window.
if !exists('g:scratch_height')
	let g:scratch_height = 20
endif

" Scratch buffer name
let ScratchBufferName = "__Scratch__"

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
            exe g:scratch_height . "new " . g:ScratchBufferName
        else
            exe "edit " . g:ScratchBufferName
        endif

		" If a scratch file is configured, load its content into the scratch
		" buffer.
		if exists("g:scratch_file")
			let s:globbed = glob(g:scratch_file)

			if filereadable(s:globbed)
				let content = readfile(s:globbed)
				call setline(1, content)
			endif
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
                exe g:scratch_height . "split +buffer" . scr_bufnum
            else
                exe "buffer " . scr_bufnum
            endif
        endif
    endif
endfunction

" Mark a buffer as scratch.
function! s:ScratchMarkBuffer()
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal buflisted
endfunction


" Scratch Toggling
function! s:ToggleScratch()
	if expand('%') == g:ScratchBufferName
		quit
	else
		SplitScratch
	endif
endfunction


" Save the scratch buffer to a file.
function! s:ScratchSave()
	let scr_bufnum = bufnr(g:ScratchBufferName)

	if scr_bufnum != -1
		let s:globbed = glob(g:scratch_file)
		let content = getbufline(g:ScratchBufferName, 1, '$')
		call writefile(content, s:globbed)
	endif
endf

autocmd BufNewFile __Scratch__ call s:ScratchMarkBuffer()
autocmd BufUnload,BufDelete __Scratch__ call s:ScratchSave()

" Command to edit the scratch buffer in the current window.
command! -nargs=0 Scratch call s:ScratchBufferOpen(0)

" Command to open the scratch buffer in a new split window.
command! -nargs=0 SplitScratch call s:ScratchBufferOpen(1)

" Command to toggle scratch buffer visibility on/off.
command! -nargs=0 ToggleScratch call s:ToggleScratch()
