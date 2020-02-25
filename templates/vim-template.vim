
" block nerd config
" Plugin 'ryanoasis/vim-devicons' " allow Nerdfont Icons
" Plugin 'tiagofumo/vim-nerdtree-syntax-highlight' " Pretty Icons
" end nerd

" block CoC config Uncomment if CoC should be enabled
" Plugin 'neoclide/coc.nvim' " Language Completion Protocol
"
" let g:coc_global_extensions = [
" \ 'coc-snippets',
" \ 'coc-pairs',
" \ 'coc-python',
" \ 'coc-ccls',
" \ 'coc-json']
" set hidden
" set updatetime=300
"
" set shortmess+=c
"
" inoremap <silent><expr> <TAB>
" \ pumvisible() ? "\<C-n" :
" \ <SID>check_back_space() ? "\<TAB>" :
" \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"
" function! s:check_back_space() abort
" let col = col('.') - 1
" return !col || getline('.')[col - 1] =~# '\s'
" endfunction
"
" " Use <c-space> to trigger completion
" inoremap <silent><expr> <c-space> coc#refresh()
"
" " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" " Coc only does snippet and additional edit on confrim.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"
" set statusline=%h%m%r\ %<%{coc#status()}\ %=%f\ %=%l,%c%V\ \ %P
" " coc-cSpell
" nnoremap <leader>a :CocCommand cSpell.addWordToWorkspaceDictionary<CR>
" nnoremap <leader><S-a> :CocCommand cSpell.addWordToUserDictionary<CR>
" nnoremap <leader>i :CocCommand cSpell.addIgnoreWordToWorkspace<CR>
" nnoremap <leader><S-i> :CocCommand cSpell.addIgnoreWordToUser<CR>
" nnoremap <leader>se :CocCommand cSpell.enableForWorkspace<CR>
" nnoremap <leader>s<S-e> :CocCommand cSpell.enableCurrentLanguage<CR>
" nnoremap <leader>sd :CocCommand cSpell.disableForWorkspace<CR>
" nnoremap <leader>s<S-d> :CocCommand cSpell.disableCurrentLanguage<CR>
" nnoremap <leader>st :CocCommand cSpell.toggleEnableSpellChecker<CR>
" End CoC

" AutoGroup
augroup configgroup
  autocmd!
  autocmd VimEnter * highlight clear SignColumn
  autocmd BufWritePre * %s/\s\+$//e " Remove all Trailing whitespace when saving any file

  autocmd FileType python setlocal commentstring=#\ %s

  autocmd BufEnter *.zsh-theme setlocal filetype=zsh

  autocmd FileType Makefile setlocal noexpandtab
  autocmd FileType Makefile setlocal tabstop=4
  autocmd FileType Makefile setlocal softtabstop=4

  autocmd FileType c setlocal tabstop=3
  autocmd FileType c setlocal softtabstop=3
augroup END
