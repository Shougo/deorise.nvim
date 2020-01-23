deorise.nvim
============

Warning: This is the vaporware!  It is not implemented yet.

Deorise is the abbreviation of "dark powered neo-analyser".  It
provides the hexa decimal editing feature.


## Installation

**Note:** deorise requires Neovim 0.3.0+ or Vim8.1+ with Python3.6.1+.  See
[requirements](#requirements) if you aren't sure whether you have this.

1. Extract the files and put them in your Neovim directory
   (usually `$XDG_CONFIG_HOME/nvim/`).
2. Execute the `:UpdateRemotePlugins` and restart Neovim.


For vim-plug

```viml
Plug 'Shougo/deorise.nvim', { 'do': ':UpdateRemotePlugins' }
```

For dein.vim

```viml
call dein#add('Shougo/deorise.nvim')
```


## Requirements

deoppet requires Neovim with if\_python3.
If `:echo has("python3")` returns `1`, then you're done; otherwise, see below.

You can enable Python3 interface with pip:

    pip3 install --user pynvim

If you want to read the pynvim/python3 interface install documentation,
you should read `:help provider-python` and the Wiki.


## Note: Python3 must be enabled before updating remote plugins
If Deorise was installed prior to Python support being added to Neovim,
`:UpdateRemotePlugins` should be executed manually.


## Screenshots


## Configuration Examples

```vim
```
