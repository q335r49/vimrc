se viminfo=!,'20,<1000,s10,/50,:50
se nowrap linebreak sidescroll=1 ignorecase smartcase incsearch
se tabstop=4 history=150 mouse=a ttymouse=xterm hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256
se whichwrap+=h,l wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
if has("gui_running")
	colorscheme slate
el | syntax off | en
se guifont=Envy\ Code\ R:h12:cANSI guioptions-=T
hi ColorColumn guibg=#222222 ctermbg=237
hi ErrorMsg ctermbg=9 ctermfg=15
hi Search ctermfg=9 ctermbg=none
hi MatchParen ctermfg=9 ctermbg=none
hi StatusLine cterm=underline ctermfg=240 ctermbg=236
hi StatusLineNC cterm=underline ctermfg=240 ctermbg=236
hi Vertsplit guifg=grey15 guibg=grey15 ctermfg=240 ctermbg=236
se stl=\ %l.%02c/%L\ %<%f%=\ 
se stl+=%{(localtime()-g:TLOG[0:9])/60.strftime('\ %H:%M\ %d')}\ 
if has("win16") || has("win32") || has("win64")
	let K_ESC="\<Esc>" | let N_ESC=27
else
	let K_ESC='@'|let N_ESC=64
	exe 'no '.K_ESC.' <Esc>'
	exe 'no! '.K_ESC.' <Esc>'
	exe 'cno '.K_ESC.' <C-C>'
	nn <silent> <leftmouse> <leftmouse>:call {g:OnTouch}()<CR>
	nn <silent> <leftrelease> <leftmouse>:call OnRelease()<CR>
	vn <silent> <leftmouse> <Esc>mv<leftmouse>:let g:OnTouch='OnVisual'<CR>
	map <C-J> <C-M>
	map! <C-J> <C-M>
	no   OQ @
	no!  OQ @
	no   <F7> <PageDown>
	no!  <F7> <PageDown>
	no   <F8> <PageUp>
	no!  <F8> <PageUp>
	ino  <F9> <Home>
	ino  <F10> <End>
	nn   <F9> <C-O>
	nn   <F10> <C-I>
en
if !exists('au_processed')
	let au_processed=1
	au VimEnter * call AfterViminfoLoaded()
	au BufRead *.txt call InitTextFile()
	au BufNewFile *.txt call InitTextFile() | exe "norm! i".localtime()." "
	\ .strftime('%y%m%d')." vim: set nowrap ts=4 tw=62 fo=aw:"
en
fun! AfterViminfoLoaded()
	if !exists('g:TLOG') | let g:TLOG=localtime().'[0] ---' | en
	if !exists('g:MAIN_DIRECTORY') || !isdirectory(g:MAIN_DIRECTORY)
		echoerr 'Set MAIN_DIRECTORY!'
	elseif !argc()
		exe 'cd '.g:MAIN_DIRECTORY
		so abbrev | e main.txt 
    en
	let g:histL=exists('g:FHIST') ? split(g:FHIST,"\n") : [] |cal InitHist()
	au BufWinEnter * let ix=match(g:histL,'\V'.expand('%').'$')
	\|call cursor((ix>=0? g:histL[ix][match(g:histL[ix],'\$')+1:] : 1),1)
	au BufWinLeave * call InsHist(expand('%'),line('.'))
	au VimLeavePre * let g:FHIST=join(g:histL,"\n")
endfun

fun! Quote(mark)
	norm! `< 
	let l=getline(".")
	if l=='' | exe 'norm! {}Wi'.a:mark
	elseif l[col('.')-1]=~'[[:blank:]]' | exe 'norm! Wi'.a:mark
	el | exe 'norm lbi'.a:mark | en
	norm! `>
	let l=getline(".") | let c=col('.')
	exe (c!=col('$') ? 'norm! l' : '')
	if l=='' | exe 'norm! {}BEa'.a:mark
 	elseif l[c-1]=~'[[:blank:]]' | exe 'norm! BEa'.a:mark
	el | exe 'norm! bea'.a:mark | en
endfun
let QuoteMark={97:"'",113:'"',115:'*',105:'/'}
vn <silent> q :call Quote(QuoteMark[getchar()])<CR>

fun! Log(...)
	let log=input(g:TLOG[:match(g:TLOG,'\n',0,6)]
	\."[".(localtime()-g:TLOG[0:9])/60
	\.(a:0==0? "] LOG > " : '] [R:]ename [S:]till [X]Delete [Q]uit > '))
	if log[0:1]==?'R:'
		let g:TLOG=g:TLOG[:match(g:TLOG,' ')].log[2:]
		\."\n".g:TLOG[match(g:TLOG,'\n')+1:] | redr | call Log()
	elseif log[0:1]==?'S:'
		let g:TLOG=g:TLOG[match(g:TLOG,'\n')+1:]
		let g:TLOG=localtime()."[".(localtime()-g:TLOG[0:9])/60
		\."] ".log[2:]."\n".g:TLOG | redr | call Log()
	elseif log==?'X'
		let g:TLOG=g:TLOG[match(g:TLOG,'\n')+1:] | redr | call Log()
	elseif log==?'?'
		redr | call Log(1)
	elseif log!='Q' && log!=''
		let g:TLOG=localtime()."[".(localtime()-g:TLOG[0:9])/60
		\."] ".log."\n".g:TLOG | redr | call Log()
	en
endfun

let QCD={110:":noh\<CR>",9:"\<Esc>",(g:N_ESC):"\<Esc>",
\114:":redi@t|sw|redi END\<CR>:!rm \<C-R>=escape(@t[1:],' ')
\\<CR>",112:":call Paint()\<CR>",108:":call Log()\<CR>",101:":e <cWORD>\<CR>",
\104:"vawly:h \<C-R>=@\"[-1:-1]=='('? @\":@\"[:-2]\<CR>",121:"^y$:\<C-R>\"",
\98:":let qcx=HistMenu()|exe qcx=='' ? '' : 'e '.qcx\<CR>",89:"^y$:\<C-R>\"",
\42:":%s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>",
\35:":'<,'>s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>"}
fun! QCF(msg)
	ec a:msg|let key=getchar()
	return has_key(g:QCD,key)? g:QCD[key] : QCF('[B]uffer [E]d [H]lp [L]og 
	\[N]ohls [P]aint [R]m swp [Y]ank [*\#]sub > ')
endfun!
nn <expr> <Tab> QCF(line('.').'.'.col('.').'/'.line('$').' - '.
\(localtime()-g:TLOG[0:9])/60.strftime('/%H:%M/%d - ').expand('%:t').' > ')

let HLb=split('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ','\zs')
let Asc2HLb=repeat([-1],256) | for i in range(len(HLb))
	let Asc2HLb[char2nr(tolower(HLb[i]))]=i
	let Asc2HLb[char2nr(toupper(HLb[i]))]=i
endfor
let g:maxW=15
fun! GetLbl(file)
	return matchstr(a:file,"[[:alnum:]][^/\\\\]*\\$")[:-2]	
endfun
fun! InitHist()
	let g:histLb=map(copy(g:histL),'GetLbl(v:val)')
	let g:HLb2fIx=repeat([-1],len(g:HLb)+1) "invar: g:HLb2fIx[-1]=-1
	let firstopenslot=0
	for i in range(len(g:histLb))
		let g:histLb[i]=len(g:histLb[i])+3>g:maxW ?
		\ g:histLb[i][0:g:maxW-8]."~".g:histLb[i][-3:] : g:histLb[i] 
		let lbl=g:Asc2HLb[char2nr(g:histLb[i][0])]
		if lbl==-1 || g:HLb2fIx[lbl]!=-1
			let lbl=match(g:HLb2fIx,-1,firstopenslot)
			let firstopenslot=lbl+1	
		en
		let g:histLb[i]=g:HLb[lbl].')'.g:histLb[i]
		let g:HLb2fIx[lbl]=i
	endfor
endfun
fun! InsHist(name,num)
	if a:name==''|retu|en
	call RmHist(match(g:histL,'\V'.a:name.'$'))
	call insert(g:histL,a:name.'$'.a:num)
	if len(g:histL)>=len(g:HLb)-8
		let g:histL=g:histL[:len(g:HLb)-16] | call InitHist()
	retu|en
	let name=GetLbl(g:histL[0])
	let name=len(name)+3>g:maxW ? name[0:g:maxW-8]."~".name[-3:] : name
	let lbl=g:Asc2HLb[char2nr(name[0])]
	let colIx=g:HLb2fIx[lbl]
	call map(g:HLb2fIx,'v:val==-1 ? -1 : v:val+1')
	if lbl==-1
		let newIx=match(g:HLb2fIx,-1)	
		let g:HLb2fIx[newIx]=0
		call insert(g:histLb,g:HLb[newIx].')'.name)
	elseif colIx!=-1
		let newIx=match(g:HLb2fIx,-1)	
		let g:HLb2fIx[newIx]=colIx+1
		let g:HLb2fIx[lbl]=0
		let g:histLb[colIx]=g:HLb[newIx].g:histLb[colIx][1:]
		call insert(g:histLb,toupper(name[0]).')'.name)
	else
		let g:HLb2fIx[lbl]=0	
		call insert(g:histLb,g:HLb[lbl].')'.name)
	en
endfun
fun! RmHist(ix)
	if (a:ix>=len(g:histL) || a:ix<0) | retu '0'|en
	if g:histLb[a:ix][0]==g:histLb[a:ix][2]
		for i in range(a:ix+1,len(g:histLb)-1)
			if g:histLb[i][2]==g:histLb[a:ix][0]
				let g:HLb2fIx[g:Asc2HLb[char2nr(g:histLb[i][0])]]=-1
				let g:HLb2fIx[g:Asc2HLb[char2nr(g:histLb[a:ix][0])]]=i
				let g:histLb[i]=g:histLb[a:ix][0].g:histLb[i][1:]
			break|en
		endfor
	en
	call remove(g:histLb,a:ix)
	call map(g:HLb2fIx,'v:val>a:ix ? v:val-1 : (v:val==a:ix ? -1 : v:val)')
	return split(remove(g:histL,a:ix),'\$')[1]
endfun
fun! FmtList(list, ...)
	let tabW=a:0==0? 0 : a:1 | let padN=[0]+(tabW==0 ? [] : range(tabW-1,1,-1))
	let ecstr=a:list[0] | let endX=len(ecstr)
	for e in a:list[1:]
		if endX+padN[endX%tabW]+len(e)>=&columns-1	
			let ecstr.="\n".e | let endX=len(e)
		else
			let ecstr.=s:Pad[1:padN[endX%tabW]].e
			let endX+=padN[endX%tabW]+len(e)
		en
	endfor
	return ecstr
endfun
fun! HistMenu()
	ec FmtList(g:histLb,g:maxW).' > ' | let sel=getchar()
	if sel==9 || sel==32
		redr|retu escape(g:histL[0][:match(g:histL[0],'\$')-1],' ')
	elseif sel=="\<BS>"
		while 1
			redr|ec FmtList(g:histLb+["[DELETE] >"],g:maxW)
			if RmHist(g:HLb2fIx[g:Asc2HLb[getchar()]])=='0' | redr | brea|en
		endwhile
	else
		redr | let ix=g:HLb2fIx[g:Asc2HLb[sel]]
		retu ix==-1 ? '' : escape(g:histL[ix][:match(g:histL[ix],'\$')-1],' ')
	en
endfun

nn <silent> <Space> :<C-U>exe 'norm! i'.nr2char(getchar())<CR>
cnorea <expr> we ((getcmdtype()==':' && getcmdpos()<4)? 'w\|e' :'we')
cnorea <expr> waq ((getcmdtype()==':' && getcmdpos()<5)? 'wa\|q':'waq')
cnorea <expr> ws ((getcmdtype()==':' && getcmdpos()<4)? 'w\|so%':'ws')
cnorea <expr> wd ((getcmdtype()==':' && getcmdpos()<4)? 'w\|bd':'wd')
cnorea <expr> wsd ((getcmdtype()==':' && getcmdpos()<5)? 'w\|so%\|bd':'wsd')

let g:PrevFT=[0,0]
fun! MultilineFT(command)
	if a:command==';'
		let com=g:PrevFT[0]
	elseif a:command==','		
		let ascii=char2nr(g:PrevFT[0])
		let com=nr2char((ascii>95)*(ascii-32)+(ascii<=95)*(ascii+32))
	else
		let key=getchar()|if key==g:N_ESC | retu|en
		let g:PrevFT=[a:command,nr2char(key)]
		let com=a:command
	endif
	if     com==#'F' | call search(g:PrevFT[1],'bW')
	elseif com==#'T' | exe (search(g:PrevFT[1],'bW')? 'norm! l' : '')
	elseif com==#'f' | exe (search(g:PrevFT[1],'W')? 'norm! l' : '')
	elseif com==#'t' | call search(g:PrevFT[1],'W')
	endif
endfun
fun! MultilinenFT(command)
	if a:command==';'
		let com=g:PrevFT[0]
	elseif a:command==','		
		let ascii=char2nr(g:PrevFT[0])
		let com=nr2char((ascii>95)*(ascii-32)+(ascii<=95)*(ascii+32))
	else
		let key=getchar()|if key==g:N_ESC | retu|en
		let g:PrevFT=[a:command,nr2char(key)]
		let com=a:command
	endif
	if com==#'F'
		call search(g:PrevFT[1],'bW')
	elseif com==#'T'
		norm! h
		call search(g:PrevFT[1],'bW')
		norm! l
	elseif com==#'t'
		norm! l
		call search(g:PrevFT[1],'W')
		norm! h
	elseif com==#'f'
		call search(g:PrevFT[1],'W')
	endif
endfun
nn <silent> F :call MultilinenFT('F')<CR>
nn <silent> T :call MultilinenFT('T')<CR>
nn <silent> f :call MultilinenFT('f')<CR>
nn <silent> t :call MultilinenFT('t')<CR>
nn <silent> ; :call MultilinenFT(';')<CR>
nn <silent> , :call MultilinenFT(',')<CR>
ono <silent> F :call MultilineFT('F')<CR>
ono <silent> T :call MultilineFT('T')<CR>
ono <silent> f :call MultilineFT('f')<CR>
ono <silent> t :call MultilineFT('t')<CR>
ono <silent> ; :call MultilinenFT(';')<CR>
ono <silent> , :call MultilinenFT(',')<CR>

fun! CapWait(prev)
	redr | let next=nr2char(getchar())
	if next=~'[.?!\r\n[:blank:]]'
		exe 'norm! i' . next . "\<Right>"
		return CapWait(next)
	elseif next==g:K_ESC
		return "\<del>"
	elseif a:prev=~'[\r\n[:blank:]]'
		return toupper(next) . "\<del>"
	else
		return next . "\<del>"
	endif
endfun
fun! CapHere()
	let trunc = getline(".")[:col(".")-2] 
	return col(".")==1 ? CapWait("\r")
	\ : trunc=~'[?!.]\s*$\|^\s*$' ? CapWait(trunc[-1:-1]) : "\<del>"
endfun
fun! InitTextFile()
	iab <buffer> i I
	iab <buffer> Id I'd
	iab <buffer> id I'd
	iab <buffer> im I'm
	iab <buffer> Im I'm
	ino <buffer> <silent> <F6> _<ESC>mt:call search("'",'b')<CR>x`ts
	im <buffer> <silent> . ._<Left><C-R>=CapWait('.')<CR>
	im <buffer> <silent> ? ?_<Left><C-R>=CapWait('?')<CR>
	im <buffer> <silent> ! !_<Left><C-R>=CapWait('!')<CR>
	im <buffer> <silent> <CR> <CR>_<Left><C-R>=CapWait("\r")<CR>
	im <buffer> <silent> <NL> <NL>_<Left><C-R>=CapWait("\n")<CR>
	nm <buffer> <silent> O O_<Left><C-R>=CapWait("\r")<CR>
	nm <buffer> <silent> o o_<Left><C-R>=CapWait("\r")<CR>
	nm <buffer> <silent> a a_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> A $a_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> i i_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> I I_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> s s_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> cc cc_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> cw cw_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> R R_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> C C_<Left><C-R>=CapHere()<CR>
	if getline(1)=~'tw='	
		nmap <buffer> A }b$a
		nmap <buffer> I {w0i
		nno <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
		nno <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
	endif
endfun

let s:Dashes=repeat('-',200)|let s:Pad=repeat(' ',200)
let s:Speed = range(1,25)
let g:OnTouch='InitScroll'
se wiw=1
fun! InitScroll()
	let s:vesave=&ve | se ve=all
	let s:pP=[winnr(),winline(),wincol()]
	let g:OnTouch='OnScroll'
	let s:initCol=s:pP[2]
endfun
fun! OnScroll()
	let s:cP=[winnr(),winline(),wincol()]
	if s:cP[0]==s:pP[0]
		if s:initCol
			let s:initCol=(abs(s:cP[2]-s:initCol)<10)*s:initCol
    		let difC=0
		else
    		let difC=s:cP[2]-s:pP[2]
		endif
		let difR=s:cP[1]-s:pP[1]
    	let s:pP=s:cP
		let cmd=(difC>0? difC."z\<left>":difC<0? (-difC)."z\<right>":'')
		\ .(difR>0? s:Speed[difR]."\<C-Y>":difR<0? s:Speed[-difR]."\<C-E>":'')
		if cmd
			exe 'norm! '.cmd
	    	redraw | echo s:Dashes[2:line('w0')*&columns/line('$')]
	    elseif line('.')==line('$')
	    	exe "norm! \<C-Y>"
	    endif
	else
		let g:OnTouch='OnResize'
		call OnResize()
	endif
endfun
fun! OnVisual()
	let cdiff=virtcol("'v")-wincol()
	let rdiff=line("'v")-line(".")
	echo rdiff.(s:Pad[1:(cdiff>0? wincol():virtcol("'v"))]
	\ .s:Dashes[1:abs(cdiff)])[len(rdiff):]
	if line('.')==line('w$')
		exe "norm! \<C-E>"
	elseif line('.')==line('w0')
		exe "norm! \<C-Y>"
	endif
endfun
let s:dirs=['k','j','l','h'] |let s:opp =['j','k','h','l']
fun! GetResDir()
	for i in (s:cP[0]>s:pP[0]? [1,2]:[0,3])
		exe s:cP[0].'winc w|winc '.s:opp[i]
		if winnr()==s:pP[0]
			return s:dirs[i]
		endif
	endfor
	return 'U'
endfun
fun! ResizeWinU(winnr,L)
endfun
fun! ResizeWinX(winnr,L)
endfun
fun! WinPushK(winnr,L)
	exe a:winnr.'winc w|winc k'
	let moved=0
	let iwin=a:winnr
	let todo=[]
	while iwin!=winnr() && a:L>moved
		let iwin=winnr()
		let curL=winheight(0)-1
		let moved+=insert(todo,[iwin,(curL>a:L-moved ? 
		\ a:L-moved : (curL>0)*curL)])[0][1]
		winc k
	endwhile
	let sum=0
	for i in todo
		let sum+=i[1]
		exe i[0].'winc w|res -'.sum
	endfor
endfun
fun! WinPullK(winnr,L)
	exe a:winnr.'winc w|winc k'
   	exe 'res +'.(winnr()!=a:winnr? min([winheight(a:winnr)-1,a:L]):0)
endfun
fun! WinPushH(winnr,L)
	exe a:winnr.'winc w|winc h'
	let moved=0
	let iwin=a:winnr
	let todo=[]
	while iwin!=winnr() && a:L>moved
		let iwin=winnr()
		let curL=winwidth(0)-1
		let moved+=insert(todo,[iwin,(curL>a:L-moved ?
		\ a:L-moved : (curL>0)*curL)])[0][1]
		winc h
	endwhile
	let sum=0
	for i in todo
		let sum+=i[1]
		exe i[0].'winc w|vert res -'.sum
	endfor
endfun
fun! WinPullH(winnr,L)
	exe a:winnr.'winc w|winc h'
   	exe 'vert res +'.(winnr()!=a:winnr? min([winwidth(a:winnr)-1,a:L]):0)
endfun
fun! WinPushJ(winnr,L)
	exe a:winnr.'winc w|winc j'
	let moved=0
	let curwin=a:winnr
	while moved<a:L && winnr()!=curwin
		let moved+=winheight(0)-1
		let curwin=winnr()
		winc j
	endwhile
	exe a:winnr.'winc w|res +'.min([a:L,moved])
endfun
fun! WinPullJ(winnr,L)
	exe a:winnr.'winc w|winc j'
   	if winnr()!=a:winnr
		exe a:winnr.'winc w|res -'.min([winheight(a:winnr)-1,a:L])
   	endif
endfun
fun! WinPushL(winnr,L)
	exe a:winnr.'winc w|winc l'
	let moved=0
	let curwin=a:winnr
	while moved<a:L && winnr()!=curwin
		let moved+=winwidth(0)-1
		let curwin=winnr()
		winc l
	endwhile
	exe a:winnr.'winc w|vert res +'.min([a:L,moved])
endfun
fun! WinPullL(winnr,L)
	exe a:winnr.'winc w|winc l'
   	if winnr()!=a:winnr
		exe a:winnr.'winc w|vert res -'.min([winwidth(a:winnr)-1,a:L])
   	endif
endfun
fun! OnResize()
	let s:cP=[winnr(),winline(),wincol()]
	if s:pP[0]!=s:cP[0]
		let s:dir=GetResDir()
		if s:dir=='k'
			call WinPushK(s:pP[0],winheight(s:cP[0])-s:cP[1]+1)
			let s:pP[1]=1
		elseif s:dir=='j'
			call WinPushJ(s:pP[0],s:cP[1])
			let s:pP[1]=winheight(s:pP[0])
		elseif s:dir=='h'
			call WinPushH(s:pP[0],winwidth(s:cP[0])-s:cP[2]+1)
			let s:pP[2]=1
		elseif s:dir=='l'
			call WinPushL(s:pP[0],s:cP[2])
			let s:pP[2]=winwidth(s:pP[0])
		endif
	elseif s:pP!=s:cP
		if s:dir=='j'
			call WinPullJ(s:pP[0],winheight(s:cP[0])-s:cP[1])
			let s:pP[1]=winheight(s:pP[0])
		elseif s:dir=='k'
			call WinPullK(s:pP[0],s:cP[1]-1)
			let s:pP[1]=1
		elseif s:dir=='l'
			call WinPullL(s:pP[0],winwidth(s:cP[0])-s:cP[2])
			let s:pP[2]=winwidth(s:pP[0])
		elseif s:dir=='h'
			call WinPullH(s:pP[0],s:cP[2]-1)
			let s:pP[2]=1
		endif
	endif
endfun
fun! OnRelease()
	if g:OnTouch=='OnVisual'
		norm! v`v
	else
		exe 'se ve='.s:vesave
	endif
	let g:OnTouch='InitScroll'
endfun
fun! Paint()
	ec ' Brush? (Backspace to turn off)' | let brush=getchar()
	if brush!="\<BS>"
		let brush=nr2char(brush)
		let s:vesave=&ve | se ve=all
		exe 'nn <silent> <leftmouse> <leftmouse>R'.(brush=='|'? '\|' : brush)
		exe 'ino <silent> <leftmouse> <leftmouse>'.(brush=='|'? '\|' : brush)
		ino <leftrelease> <Esc>
		redr|ec brush
	else
		redr|ec ' Brush Off'
		exe 'se ve='.s:vesave
		nn <silent> <leftmouse> <leftmouse>:call {g:OnTouch}()<CR>
		nn <silent> <leftrelease> <leftmouse>:call OnRelease()<CR>
		try
			iunmap <leftrelease>
			iunmap <leftmouse>
		catch | endtry
	endif
endfun                                                              
