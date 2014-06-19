" also take care of edge cases : requirements are satisfied or not
" like we need a blinkable cursor : I have but check for users

if exists("g:vingvong")
  finish
endif
let g:vingvong = 1


"""""""""""""""""
" Game Statuses "
"""""""""""""""""

" being played or paused
let s:gamestate = 0

" velocity vector for cursor motion at a time
let s:x = 1
let s:y = 0


"""""""""""""""""""""""
" Game Configurations "
"""""""""""""""""""""""

" a new user defined command to start game
command Vingvong :call StartGame()

" no line numbers in gamefile
autocmd BufRead,BufNewFile *vingvong.txt* set nonumber

" overwrite default navigation to game motion
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> <space> :call PlayPause()<cr>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> h :call MovePaddle("L")<cr>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> l :call MovePaddle("R")<cr>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> <left> :call MovePaddle("L")<cr>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> <right> :call MovePaddle("R")<cr>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> j <nop>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> k <nop>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> <up> <nop>
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> <down> <nop>


""""""""""""""""""
" Game Functions "
""""""""""""""""""

" manage space for game and place required objects at right places
function! GamePlot()
  let i = 1
  while i < winheight(0)
    call setline(i, repeat(" ", winwidth(0)))
    let i = i + 1
  endwhile
  call setline(i, repeat(" ", winwidth(0)))

  call AddPaddle()
  call InitState()
endfunc

" function that display game errors
function GameError(error)
  echo "> VingVong : Error"
  echo "> ".a:error
endfunc

" add a paddle at bottom of game view
function! AddPaddle()
  if winwidth(0) < 15
    call GameError("Not enough window width to play")
  else
    " initial arrangement of paddle : left/right space
    let lfs = (winwidth(0) - 10)/2
    let rgs = winwidth(0) - 10 - lfs
    call setline("$", repeat(" ", lfs).repeat("▇", 10).repeat(" ", rgs))
  endif
endfunc

" play and pause the game
function! PlayPause()
  if s:gamestate == 0
    let s:gamestate = 1
  elseif s:gamestate == 1
    let s:gamestate = 0
  endif

  call MoveCursor(s:gamestate)
endfunc

" place cursor in center : initial state when game is not started
function! InitState()
  let s:lines = line("$")
  call cursor((s:lines - 1), (winwidth(0)/2))
endfunc

" paddle movement
function! MovePaddle(direction)
  let strt = stridx(getline("$"), "▇")
  if a:direction == "L"
    if strt > 0
      call setline("$", substitute(getline("$"), " ▇▇▇▇▇▇▇▇▇▇", "▇▇▇▇▇▇▇▇▇▇ ", ""))
    endif
  elseif a:direction == "R"
    if strt < (winwidth(0) - 10)
      call setline("$", substitute(getline("$"), "▇▇▇▇▇▇▇▇▇▇ ", " ▇▇▇▇▇▇▇▇▇▇", ""))
    endif
  endif
endfunc

" cursor movement
function MoveCursor(flag)
  if flag == 1
    "
  endif
"python << EOF
"  import time
"  time.sleep(0.5)
"EOF
endfunc

" executed by user command ':Vingvong' : starts the game
function! StartGame()
  edit vingvong.txt
  call GamePlot()
endfunc
