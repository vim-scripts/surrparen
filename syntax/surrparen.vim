" surrparen.vim - Hilights a pair of parens/braces that surround the cursor 
" Last Modified : 2007-01-04
" Maintainer    : AOYAMA Shotaro <jod@r9.dion.ne.jp>
"
" The surrparen plugin hilights a pair of parens/braces that surround
" the cursor position automatically. Unlike the matchparen.vim, it works 
" even when the cursor is not just on a paren/brace.
" It's useful especially for lisp sources etc.
"
" Install:
" Just put it in your .vim/plugin directory.
"
" Commands:
"     NoSurrParen   inactivates hilighting of parens
"     DoSurrParen   activates hilighting of parens
"     NoSurrBrace   inactivates hilighting of braces
"     DoSurrBrace   activates hilighting of braces
"     NoSurrAll     inactivates all hilighting
"     DoSurrAll     activates all hilighting

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
" - the "CursorMoved" autocmd event is not availble.
if exists("g:loaded_surrparen") || &cp || !exists("##CursorMoved")
  finish
endif
let g:loaded_surrparen = 1

let cpo_save = &cpo
set cpo&vim

" Define commands that will disable and enable the plugin.
command! NoSurrParen 2match none | let g:surr_enable_flags[0] = 0
command! DoSurrParen let g:surr_enable_flags[0] = 1
command! NoSurrBrace 2match none | let g:surr_enable_flags[1] = 0
command! DoSurrBrace let g:surr_enable_flags[1] = 1
command! NoSurrAll 2match none | unlet! g:loaded_surrparen | au! surrparen
command! DoSurrAll runtime plugin/surrparen.vim | doau CursorMoved

augroup surrparen
  autocmd! CursorMoved * call s:Highlight_Surrounding_Pair()
  "autocmd! CursorMoved,CursorMovedI * call s:Highlight_Surrounding_Pair()
augroup END

let g:surr_enable_flags = [1, 1]
let s:openchars = ["(", "{"]

function! s:Highlight_Surrounding_Pair()
  let g:view_save = winsaveview()

  if pumvisible()
    return
  endif

  2match none

  let c_lnum = line('.')
  let c_col = col('.')

  let c = getline(c_lnum)[c_col - 1]
  let i = 0
  let done = 0
  while i < 2
    if g:surr_enable_flags[i] && !done
      if c == s:openchars[i]
        " now the cursor is no a opening paren
        let onopen = 1
      else
        exe "normal! [" . s:openchars[i]
        let onopen = 0
      endif
      let openlnum = line(".")
      let opencol = col(".")
      " if the cursor is on a paren or found an unmatched paren
      if onopen || openlnum != c_lnum || opencol != c_col
        normal! %
        let closelnum = line(".")
        let closecol = col(".")
        if openlnum != closelnum || opencol != closecol
          exe '2match MatchParen /\(\%' . openlnum . 'l\%' . opencol . 'c\)\|\(\%' . closelnum . 'l\%' . closecol . 'c\)/'
        else
          exe '2match Error /\%' . openlnum . 'l\%' . opencol . 'c/'
        endif
        let done = 1
      end
    endif
    call cursor(c_lnum, c_col)
    let i = i + 1
  endwhile

  call cursor(c_lnum, c_col)
  call winrestview(g:view_save)
endfunction 

let &cpo = cpo_save
