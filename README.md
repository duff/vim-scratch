Scratch
=======

You can use the scratch plugin to create a temporary scratch buffer to store
and edit text that will be discarded when you quit/exit vim. The contents
of the scratch buffer are not saved/stored in a file.

Installation
------------
1. Copy the scratch.vim plugin to the $HOME/.vim/plugin directory. Refer to
   the following Vim help topics for more information about Vim plugins:

      :help add-plugin
      :help add-global-plugin
      :help runtimepath

    If you are using Vundle then

        BundleInstall 'molok/vim-scratch'

    and place

        Bundle 'molok/vim-scratch'

    in your vimrc

    If you're prefer using pathogen, place this directory inside ~/.vim/bundle/

2. Restart Vim.

Usage
-----
You can use the following command to open/edit the scratch buffer:

      :Scratch

To open the scratch buffer in a new split window, use the following command:

      :Sscratch

You can toggle the Scratch window using

      :ScratchToggle

Similar command using vertical split instead of horizontal are available:

      :Vscratch
      :VscratchToggle

To open the scratch buffer in a new tab, use the following command:

      :Tscratch

When you close the scratch buffer window, the buffer will retain the
contents. You can again edit the scratch buffer by openeing it using one of
the above commands. There is no need to save the scatch buffer.

When you quit/exit Vim, the contents of the scratch buffer will be lost.
You will not be prompted to save the contents of the modified scratch
buffer.

You can have only one scratch buffer open in a single Vim instance. If the
current buffer has unsaved modifications, then the scratch buffer will be
opened in a new window

User Options
------------
The default is to set the scratch buffer as hidden when closed. If you open
the scratch buffer again before you close vim, the contents of the buffer will
still be there. If you like the buffer to be deleted upon closing it, add the
following to your .vimrc :

    let g:scratch_persistent = 0

If you want the scratch buffer to be preserved between sessions:

    let g:scratch_persistent = 2

By default, the name of the scratch file is "__Scratch__".  You may set your
own scratch file name by adding the following to your .vimrc :

    let g:scratch_filename = "~/.vim/scratch_file"

this filename is also the one used to save information between sessions.

You can set the height and the width for Sscratch/Vscratch with:

    let g:scratch_height = 20
    let g:scratch_width = 100


