" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

" Main function.
" Use it in your script if you want to send text to a tmux session.
function! Send_to_Tmux(text)
  if !exists("g:tslime")
    call <SID>Tmux_Vars()
  end

  let oldbuffer = system(shellescape("tmux show-buffer"))
  call <SID>set_tmux_buffer(a:text."\n")
  call system("tmux paste-buffer -t " . s:tmux_target())
  call <SID>set_tmux_buffer(oldbuffer)
endfunction

function! s:tmux_target()
  return '"' . g:tslime['session'] . '":' . g:tslime['window'] . "." . g:tslime['pane']
endfunction

function! s:set_tmux_buffer(text)
  call system("tmux set-buffer '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
endfunction

function! SendToTmux(text)
  call Send_to_Tmux(a:text)
endfunction

" Session completion
function! Tmux_Session_Names(A,L,P)
  return <SID>TmuxSessions()
endfunction

" Window completion
function! Tmux_Window_Names(A,L,P)
  return <SID>TmuxWindows()
endfunction

" Pane completion
function! Tmux_Pane_Numbers(A,L,P)
  return <SID>TmuxPanes()
endfunction

function! s:TmuxPanes()
  return system('tmux list-panes -t "' . g:tslime['session'] . '":' . g:tslime['window'] . " | sed -e 's/:.*$//'")
endfunction

" set tslime.vim variables
function! s:Tmux_Vars()
  let g:tslime = {}

  let g:tslime['session'] = split(system("tmux display-message -p '#S'") , '\n')[0]
  let g:tslime['window'] = split(system("tmux display-message -p '#I'") , '\n')[0]


  let panes = split(s:TmuxPanes(), "\n")
  if len(panes) == 1
    let g:tslime['pane'] = panes[0]
  else
    let g:tslime['pane'] = input("pane number: ", "", "custom,Tmux_Pane_Numbers")
    if g:tslime['pane'] == ''
      let g:tslime['pane'] = panes[0]
    endif
  endif
endfunction

function! ResetTmuxVars()
  call <SID>Tmux_Vars()
endfunction
command ResetTmuxVars call ResetTmuxVars()

function! Send_to_Tmux_Motion(type, ...)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@

  if a:0  " Invoked from Visual mode, use '< and '> marks.
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'
    silent exe "normal! '[V']y"
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]y"
  else
    silent exe "normal! `[v`]y"
  endif

  call Send_to_Tmux(@@)

  let &selection = sel_save
  let @@ = reg_save
endfunction

nmap <silent> gt :set opfunc=Send_to_Tmux_Motion<CR>g@
vmap <silent> gt :<C-U>call Send_to_Tmux_Motion(visualmode(), 1)<CR>
nmap <silent> gtt :set opfunc=Send_to_Tmux_Motion<CR>0g@$

vn <unique> <Plug>SendSelectionToTmux "Zy:call Send_to_Tmux(@Z)<CR>
nn <unique> <Plug>NormalModeSendToTmux "Zyip:call Send_to_Tmux(@Z)<CR>

nmap <unique> <Plug>SetTmuxVars :call <SID>Tmux_Vars()<CR>

command! -nargs=* Tx call Send_to_Tmux('<Args><CR>')
