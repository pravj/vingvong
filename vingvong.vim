" also take care of edge cases : requirements are satisfied or not
" like we need a blinkable cursor : I have but check for users

if exists("b:vingvong")
  finish
endif
let b:vingvong = 1

""""""""""""""""""""""""
" Game Configurations "
""""""""""""""""""""""""

" a new user defined command to start game
command Vingvong :call StartGame()

" no line numbers in gamefile
autocmd BufRead,BufNewFile *vingvong.txt* set nonumber

" override default navigation to game motion
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

" paddle movement
function! MovePaddle(direction)
  let strt = stridx(getline("$"), "▇")
  echo strt
  if a:direction == "L"
    if strt > 1
      call setline("$", substitute(getline("$"), " ▇▇▇▇▇▇▇▇▇▇", "▇▇▇▇▇▇▇▇▇▇ ", ""))
    endif
  elseif a:direction == "R"
    if strt < (winwidth(0) - 10)
      call setline("$", substitute(getline("$"), "▇▇▇▇▇▇▇▇▇▇ ", " ▇▇▇▇▇▇▇▇▇▇", ""))
    endif
  endif
endfunc

" executed by user command ':Vingvong' : starts the game
function! StartGame()
  edit vingvong.txt
  call GamePlot()
endfunc
