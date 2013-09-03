tslime.vim
==========

This is a simple vim script to send portion of text from a vim buffer to a
running tmux session.

It is based on slime.vim http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/,
but use tmux instead of screen. However, compared to tmux, screen doesn't
have the notion of panes. So, the script was adapted to take panes into
account.

**Note:** If you use version of tmux ealier than 1.3, you should use the stable
branch. The version available in that branch isn't aware of panes so it
will paste to pane 0 of the window.

Default bindings
-------------------

``` vim
gt<motion> " Send to pane
gtt " Send line to pane
```


Setting Keybindings
-------------------

Reset your tmux session, windows and panel mapping

```
ResetTmuxVars
```

More info about the `<Plug>` and other mapping syntax can be found
[here](http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_3\) ).
