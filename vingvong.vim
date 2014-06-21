" also take care of edge cases : requirements are satisfied or not
" like we need a non-blinkable cursor
" ▇

if exists("g:vingvong")
  finish
endif
let g:vingvong = 1


"""""""""""""""""
" Game Statuses "
"""""""""""""""""

" game objects
let s:signal = "▇"
let s:paddle = "▇▇▇▇▇▇▇▇▇▇"

" being played or paused
let s:gamestate = 0

" variable to help in timer
let s:lasttime = 0

" velocity vector for 'signal' motion at a time
let s:x = 0
let s:y = 0

" line and column number for 'signal' at a time
let s:line = 0
let s:col = (winwidth(0)/2)

" line and column for just previous instance of 'signal'
let s:lastline = 0
let s:lastcol = s:col


"""""""""""""""""""""""
" Game Configurations "
"""""""""""""""""""""""

" a new user defined command to start game
command Vingvong :call StartGame()

" no line numbers in gamefile
autocmd BufRead,BufNewFile *vingvong.txt* set nonumber

" 
autocmd BufRead,BufNewFile *vingvong.txt* nnoremap <buffer> w :call TimeMac()<cr>

" stop cursor blinking
autocmd BufRead,BufNewFile *vingvong.txt* set gcr=n:blinkwait0

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

" returns locatime in seconds
function! Now()
  return localtime()
endfunc

" function that acts as a pseudo timer
" with help of fake key-press events
function! TimeMac()
  let now = 0
  while (Now() < s:lasttime + 1)
    let now = Now()
  endwhile

  let s:lasttime = now
endfunc


" manage space for game and place required objects at right places
function! GamePlot()
  let i = 1
  while i < winheight(0)
    call setline(i, repeat(" ", winwidth(0)))
    let i = i + 1
  endwhile
  call setline(i, repeat(" ", winwidth(0)))

  " now lines in buffer have increased
  let s:line = line("$") - 1
  let s:lastline = s:line

  call AddPaddle()
  call InitState()
  call InitVector()
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
    call setline("$", repeat(" ", lfs).(s:paddle).repeat(" ", rgs))
  endif
endfunc

" play and pause the game
function! PlayPause()
  let s:gamestate = !(s:gamestate)

  if (s:gamestate == 1)
    call MoveCursor()
  endif
endfunc

" place cursor in center : initial state when game is not started
function! InitState()
  call PlaceSignal(s:line, s:col)
endfunc

" decide where 'signal' will move initially
function! InitVector()
  if (localtime()%2 == 1)
    let s:x = 1
    let s:y = -1
  else
    let s:x = -1
    let s:y = -1
  endif
endfunc

" paddle movement
function! MovePaddle(direction)
  let strt = stridx(getline("$"), s:signal)
  if a:direction == "L"
    if strt > 0
      call setline("$", substitute(getline("$"), " ".s:paddle, s:paddle." ", ""))
    endif
  elseif a:direction == "R"
    if strt < (winwidth(0) - 10)
      call setline("$", substitute(getline("$"), s:paddle." ", " ".s:paddle, ""))
    endif
  endif
endfunc

" Time is under my control
function! Delay(ms)
  let time = a:ms." m"
  execute "sleep".time
endfunc

" changes the 'signal' velocity vector
function! Change(dir)
  if a:dir == 1
    return -1
  elseif a:dir == -1
    return 1
  endif
endfunc

" function that returns next line and col number
" according to collision and velocity vector
function! NextPosition()
  " proposed values of next position
  let l = s:line + s:y
  let c = s:col + s:x

  " vertical border collision
  if ((c == (winwidth(0))) || (c == 0))
    let s:x = Change(s:x)
  endif

  " horizontal border collision
  if ((l == (winheight(0))) || (l == 0))
    let s:y = Change(s:y)
  endif

  " last position of 'signal'
  let s:lastline = s:line
  let s:lastcol = s:col

  " updated value of next position
  let s:line = s:line + s:y
  let s:col = s:col + s:x

  let result = [s:line, s:col]
  return result
endfunc

" place 'signal' object at 'where it should'
function! PlaceSignal(line, col)
  " remove 'signal' object from its precious place
  call setline(s:lastline, repeat(" ", winwidth(0)))

  " place 'signal' object at new place
  call setline(a:line, repeat(" ", a:col - 1).(s:signal).repeat(" ", winwidth(0) - a:col))
endfunc

function! Continue()
  call MoveCursor()
endfunc

" cursor movement
function! MoveCursor()
  " only when game is not paused
  if (s:gamestate == 1)
    let next = NextPosition()
    call PlaceSignal(next[0], next[1])
    call feedkeys("w")
  endif

  if (s:gamestate == 1)
    call Continue()
  endif
endfunc

" executed by user command ':Vingvong' : starts the game
function! StartGame()
  edit vingvong.txt
  call GamePlot()
endfunc
