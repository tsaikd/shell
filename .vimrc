syntax on
set nocin
set noai
set nobackup
set tabstop=4
set shiftwidth=4
" autocmd FileType c,cpp set nocindent

" 自動補全命令時, 使用菜單式匹配列表
set wildmenu

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,big5,gbk,euc-jp,euc-kr,utf-bom,iso8859-1
set termencoding=utf-8

" 切換視窗 ( or C-w C-w )
map <F9> :wincmd p<CR>
" 重新調整縮排
map <F11> gg=G<CR>
" 轉換檔案編碼
map <F12> :set tenc=utf-8<CR>:set fenc=utf-8<CR>

" TagList
nnoremap <silent> <F8> :Tlist<CR>:wincmd p<CR>

if has("cscope")
	set csprg=/usr/bin/cscope
	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
	" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set csverb
	nmap <C-[>s :cs find s <C-R>=expand("<cword>")<CR><CR>
endif

