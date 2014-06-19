" also take care of edge cases : requirements are satisfied or not
" like we need a blinkable cursor : I have but check for users

if exists("b:vingvong")
  finish
endif
let b:vingvong = 1

" new user defined command to start game
command Vingvong :call StartGame()

"""""""""""""""""""
" local variables "

" no line numbers in gamefile
autocmd BufRead,BufNewFile vingvong.txt* set nonumber

" manage required space in window for game
function! GameSpace()
  let i = 1
  while i < winheight(0)
    call setline(i, repeat(" ", winwidth(0)))
    let i = i + 1
  endwhile
  call setline(i, repeat(" ", winwidth(0)))
endfunc

" function that display game errors
function GameError(error)
  echo "> VingVong : Error"
  echo "> ".a:error
endfunc

function! AddPaddle()
  if winwidth(0) < 15
    call GameError("Not enough window width to play")
  else
    let lf = (winwidth(0) - 10)/2
    let rg = winwidth(0) - 10 - lf
    call setline("$", repeat(" ", lf).repeat("▇", 10).repeat(" ", rg))
  endif
endfunc

" executed by user command ':Vingvong'
function! StartGame()
  edit vingvong.txt
  call GameSpace()
  call AddPaddle()
endfunc
