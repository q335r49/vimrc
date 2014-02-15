let HLb=split('1234567890abcdefghijklmnopqrstuvwxyz
\ABCDEFGHIJKLMNOPQRSTUVWXYZ','\zs')
let Asc2HLb=repeat([-1],256) | for i in range(len(HLb))
	let Asc2HLb[char2nr(HLb[i])]=i
endfor
let maxW=15
fun! GetLbl(file)
	let name=matchstr(a:file,"[[:alnum:]][^/\\\\]*\\$")[:-2]	
	return len(name)+3>g:maxW ? name[0:g:maxW-8]."~".name[-3:] : name
endfu4
fun! InitHist()
	let g:histLb=map(copy(g:histL),'GetLbl(v:val)')
	let g:HLb2fIx=repeat([-1],len(g:HLb)+1) "invar: g:HLb2fIx[-1]=-1
	let unassigned=range(len(g:histLb))
	for i in unassigned
		let lbl=g:Asc2HLb[char2nr(tolower(g:histLb[i][0]))]
		if lbl==-1 | let unassigned[i]=-1
		elseif g:HLb2fIx[lbl]==-1
			let g:histLb[i]=g:HLb[lbl].')'.g:histLb[i]
			let g:HLb2fIx[lbl]=i
		else | let lbl=g:Asc2HLb[char2nr(toupper(g:histLb[i][0]))]
			if g:HLb2fIx[lbl]==-1
				let g:histLb[i]=g:HLb[lbl].')'.g:histLb[i]
				let g:HLb2fIx[lbl]=i
			el |let unassigned[i]=-1 |en
		en
	endfor
	let firstopenslot=0
	for i in range(len(g:histLb))
		if unassigned[i]==-1
			let lbl=match(g:HLb2fIx,-1,firstopenslot)
			let g:histLb[i]=g:HLb[lbl].')'.g:histLb[i]
			let g:HLb2fIx[lbl]=i
			let firstopenslot+=1
		en
	endfor
endfun
fun! RmHist(ix)
	if (a:ix>=len(g:histL) || a:ix<0) | retu 0|en
	if g:histLb[a:ix][0]==?g:histLb[a:ix][2]
		for i in range(a:ix+1,len(g:histLb)-1)
		if g:histLb[i][2]==?g:histLb[a:ix][0] && g:histLb[i][2]!=?g:histLb[i][0]
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
fun! InsHist(name,lnum,cnum)
	if a:name==''|retu|en
	call RmHist(match(g:histL,'\V'.a:name.'$'))
	call insert(g:histL,a:name.'$'.a:lnum.'|'.a:cnum)
	if len(g:histL)>=len(g:HLb)-8
		let g:histL=g:histL[:len(g:HLb)-16] | call InitHist()
	retu|en
	let name=GetLbl(g:histL[0])
	let lbll=g:Asc2HLb[char2nr(tolower(name[0]))]
	let lblu=g:Asc2HLb[char2nr(toupper(name[0]))]
	let collisionl=g:HLb2fIx[lbll]
	let collisionu=g:HLb2fIx[lblu]
	if collisionl==-1
		let lbl=lbll | let collision=collisionl
	el |let lbl=lblu | let collision=collisionu |en
	call map(g:HLb2fIx,'v:val==-1 ? -1 : v:val+1')
	if lbl==-1
		let newIx=match(g:HLb2fIx,-1)	
		let g:HLb2fIx[newIx]=0
		call insert(g:histLb,g:HLb[newIx].')'.name)
	elseif collision!=-1
		let newIx=match(g:HLb2fIx,-1)	
		let g:HLb2fIx[newIx]=collision+1
		let g:HLb2fIx[lbl]=0
		let g:histLb[collision]=g:HLb[newIx].g:histLb[collision][1:]
		call insert(g:histLb,toupper(name[0]).')'.name)
	else
		let g:HLb2fIx[lbl]=0	
		call insert(g:histLb,g:HLb[lbl].')'.name)
	en
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
	ec FmtList(g:histLb,g:maxW).':' | let sel=getchar()
	while sel=="\<BS>"
		redr|ec FmtList(g:histLb+["[DELETE]:"],g:maxW) | let sel2=getchar()
		if sel2=="\<BS>" | redr|retu HistMenu()
		elseif RmHist(g:HLb2fIx[g:Asc2HLb[sel2]])=='0' | redr|retu -1 | en|endw
	redr|retu g:HLb2fIx[g:Asc2HLb[sel]]
endfun
fun! Edit(file)
	let file=split(a:file,'\$')
	if file[0]=='' | retu|en
	if !bufloaded(file[0])
		exe 'e '.escape(file[0],' ')
		if !filereadable(file[0])
			call setline(1,localtime()." vim: set nowrap ts=4 tw=62 fo=aw: "
			\.strftime('%H:%M %m/%d/%y'))
			setlocal nowrap ts=4 tw=62 fo=aw |en
		if getline(1)=~'tw='
			call InitCap()
			iab <buffer> i I
			iab <buffer> Id I'd
			iab <buffer> id I'd
			iab <buffer> im I'm
			iab <buffer> Im I'm
			nmap <buffer> A }b$a
			nmap <buffer> I {w0i
			nno <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
			nno <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
			redr|ec 'Editing as text: '.file[0] |en
	el| exe 'e '.escape(file[0],' ') | en
	if len(file)>1 | call cursor(split(file[1],'|'))
	el| let ix=match(g:histL,'\V'.file[0].'$')
		call cursor(ix>=0? split(split(g:histL[ix],'\$')[1],'|') : [1,1]) |en
endfun
command! -nargs=1 -complete=file Edit call Edit('<args>')
nno gf :call Edit(expand('<cWORD>'))<CR>

fun! PrintTime(s,...)
	return strftime('%b %d %I:%M [',a:0>0? (a:1) : localtime())
	\.(a:s>3600? (a:s/3600.(a:s%3600<600? ':0' : ':')) : '').(a:s%3600/60).'] '
endfun
fun! PrintLogMsg()
	let tspan=localtime()-g:tlog[0][0]
	retu (tspan>86399? (tspan/86400).'d':'')
	\.(tspan%86400>3599? (tspan%86400)/3600.'h ':'').len(g:tlog)."e:"
endfun
fun! Log()
	let g:logmsg=''|for i in range(len(g:tlog)>5? len(g:tlog)-5:0,len(g:tlog)-1)
		let g:logmsg.=PrintTime(g:tlog[i][0]-(i>0? g:tlog[i-1][0] : 0),
		\g:tlog[i][0]).g:tlog[i][1]."\n" | endfor
	let g:cmdMode='g:tlogD'
		redr | let ent=input(g:logmsg.PrintTime(localtime()-g:tlog[-1][0]))
	let g:cmdMode='g:cmdD'
	if ent[0:1]==?'R:'
		if len(ent)>2 | let g:tlog[-1][1]=ent[2:] | en
	elseif ent[0:1]==?'S:'
		let g:tlog[-1]=[localtime(),len(ent)>2? ent[2:] : g:tlog[-1][1]]
	elseif ent==?'X'
		call remove(g:tlog,-1)
	elseif ent!=?'Q' && ent!=''
		call extend(g:tlog,[[localtime(),ent]])
	else | retu|en | call Log()
endfun

fun! TMenu(cmd,...)
	if a:0==0 | ec eval(a:cmd.msg) | el | ec a:cmd[a:1] | en
	let key=getchar()|redr!
	return has_key(a:cmd,key)? a:cmd[key] : TMenu(a:cmd,'help')
endfun!
nno <expr> ` TMenu(g:normD)
ino <expr> ` TMenu(g:insD)
cno <expr> ` eval('TMenu('.g:cmdMode.')')

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
fun! InitCap()
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
endfun

let s:Dashes=repeat('-',200)|let s:Pad=repeat(' ',200)
let g:OnTouch='IniScroll'
se wiw=1
fun! IniScroll()
let s:vesave=&ve
se ve=all
let s:pP=[winnr(),winline(),0]
call getchar()
let s:pP[2]=v:mouse_col
let g:OnTouch='ScrollR'
endfun
fun! ScrollR()
let s:cP=[winnr(),winline(),wincol()]
if s:cP[0]!=s:pP[0]
let g:OnTouch='OnResize'
call OnResize()
retu
en
if s:cP[2]-s:pP[2]>5 || s:pP[2]-s:cP[2]>5
let g:OnTouch='ScrollRC'
retu
en
exe 'norm! '.(s:cP[1]>s:pP[1]? (s:cP[1]-s:pP[1])."\<C-Y>" : s:pP[1]>s:cP[1]? (s:pP[1]-s:cP[1])."\<C-E>" : 'z')
let s:pP=s:cP
endfun
fun! ScrollRC()
let s:cP=[winnr(),winline(),wincol()]
if s:cP[0]!=s:pP[0]
let g:OnTouch='OnResize'
call OnResize()
retu
en
exe 'norm! '.(s:cP[2]>s:pP[2]? (s:cP[2]-s:pP[2])."zh" : s:pP[2]>s:cP[2]? (s:pP[2]-s:cP[2])."zl" : '').(s:cP[1]>s:pP[1]? (s:cP[1]-s:pP[1])."\<C-Y>" : s:pP[1]>s:cP[1]? (s:pP[1]-s:cP[1])."\<C-E>" : '')
let s:pP=s:cP
endfun
fun! OnVisual()
	let cdiff=virtcol("'v")-wincol()
	let rdiff=line("'v")-line(".")
	echo rdiff.(s:Pad[1:(cdiff>0? wincol():virtcol("'v"))]
	\.s:Dashes[1:abs(cdiff)])[len(rdiff):]
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
fun! Paint()
	exe 'norm! R'.g:brush
endfun
fun! IniPaint()
	ec ' Brush? (Backspace to turn off)' | let g:brush=getchar()
	if g:brush!="\<BS>"
		let g:brush=nr2char(g:brush)
		let s:vesave=&ve | se ve=all
		let g:OnTouch='Paint'
		redr|ec g:brush
	el| redr|ec ' Brush Off'
		exe 'se ve='.s:vesave
       	let g:OnTouch='IniScroll' |en
endfun
fun! OnRelease()
	if g:OnTouch=='OnVisual'
		norm! v`v
		let g:OnTouch='IniScroll'
	elseif g:OnTouch!='Paint'
		exe 'se ve='.s:vesave
		let g:OnTouch='IniScroll'
	endif
endfun

fun! Write_Viminfo()
	let g:TLOG=join(map(g:tlog,'v:val[0]."|".v:val[1]'),"\n")
	let g:LAST_FILE=expand('%')
	let g:HISTL=join(g:histL,"\n")
	se viminfo=!,'20,<1000,s10,/50,:50
	if exists('g:viminfo_file_invalid')
		wv
	elseif !exists('g:USE_WV_WORKAROUND')
		try
			wv $VIMINFO_FILE
		catch
			let g:USE_WV_WORKAROUND=1
			wv ~/.viminfo
			!cp ~/.viminfo $VIMINFO_FILE
		endtry
	el| let g:USE_WV_WORKAROUND=1
		wv ~/.viminfo
		!cp ~/.viminfo $VIMINFO_FILE
	en | se viminfo=
endfun

if !exists('do_once') | let do_once=1
se viminfo=!,'20,<1000,s10,/50,:50
	if filereadable($VIMINFO_FILE)
		rv $VIMINFO_FILE
	el| let g:viminfo_file_invalid=1
		rv
	en
se viminfo=
au VimLeavePre * call Write_Viminfo()

se nowrap linebreak sidescroll=1 ignorecase smartcase incsearch cc=81
se tabstop=4 history=150 mouse=a ttymouse=xterm hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256
se whichwrap+=h,l wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
se stl=\ %l.%02c/%L\ %<%f%=\ %{PrintTime(localtime()-tlog[-1][0])}
se guifont=Envy\ Code\ R:h12:cANSI guioptions-=T
if has("gui_running") | colorscheme slate | el | syntax off | en
hi ColorColumn guibg=#222222 ctermbg=237
hi ErrorMsg ctermbg=9 ctermfg=15
hi Search ctermfg=9 ctermbg=none
hi MatchParen ctermfg=9 ctermbg=none
hi StatusLine cterm=underline ctermfg=244 ctermbg=236
hi StatusLineNC cterm=underline ctermfg=240 ctermbg=236
hi Vertsplit guifg=grey15 guibg=grey15 ctermfg=237 ctermbg=237
if !exists('MAIN_DIRECTORY') || !isdirectory(MAIN_DIRECTORY)
	echoerr 'Set MAIN_DIRECTORY!'
el| exe 'so '.MAIN_DIRECTORY.'/abbrev'
	if !argc() | exe 'cd '.MAIN_DIRECTORY
		au VimEnter * call Edit(LAST_FILE)
en|en
if exists('OPT_THUMBOARD')
	let K_ESC='@'|let N_ESC=64
	exe 'no '.K_ESC.' <Esc>'
	exe 'no! '.K_ESC.' <Esc>'
	exe 'cno '.K_ESC.' <C-C>'
	nn <silent> <leftmouse> <leftmouse>:call {OnTouch}()<CR>
	nn <silent> <leftrelease> <leftmouse>:call OnRelease()<CR>
	vn <silent> <leftmouse> <Esc>mv<leftmouse>:let OnTouch='OnVisual'<CR>
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
el | let K_ESC="\<Esc>" | let N_ESC=27 | en
let cmdMode='cmdD'
if !exists('TLOG') | let tlog=[[localtime(),'0000']]
el | let tlog=map(split(TLOG,"\n"),"split(v:val,'|')") | en
let histL=exists('HISTL') ? split(HISTL,"\n") : [] | call InitHist()
au BufWinLeave * call InsHist(expand('%'),line('.'),col('.'))

	let g:tlogD={108:"\<C-R>=input(g:logmsg)\<CR>\<CR>",
\114:"\<C-R>='R:'.((inputsave()? '':'').input(g:logmsg.'RENAME:')
\.(inputrestore()? '':''))\<CR>\<CR>",120:"\<C-U>X\<CR>",
\115:"\<C-R>='S:'.((inputsave()? '':'').input(g:logmsg.'STILL:')
\.(inputrestore()? '':''))\<CR>\<CR>",'help':'[L]og [R]ename [S]till [X]Del:',
\(g:N_ESC):"\<C-R>=input(g:logmsg)\<CR>\<CR>",'msg':'PrintLogMsg()'}
	let normD={110:":noh\<CR>",(g:N_ESC):"\<Esc>",96:'`',119:":wa\<CR>",
\114:":redi@t|sw|redi END\<CR>:!rm \<C-R>=escape(@t[1:],' ')\<CR>",
\112:":call IniPaint()\<CR>",108:":call Log()\<CR>",
\101:":call Edit(expand('<cWORD>'))\<CR>",
\103:"vawly:h \<C-R>=@\"[-1:-1]=='('? @\":@\"[:-2]\<CR>",88:"^y$:\<C-R>\"\<CR>",
\115:":let qcx=HistMenu()|if qcx>=0|call Edit(g:histL[qcx])|en\<CR>",
\49:":call Edit(g:histL[0])\<CR>",
\50:":call Edit(g:histL[2])\<CR>",51:":call Edit(g:histL[3])\<CR>",
\42:":%s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>",
\35:":'<,'>s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>",
\'help':'b[12] [e]d [g]:h [l]og [n]ohl [p]nt l[s] [r]mswp [w]a e[X]e s/[*#]',
\'msg':"line('.').'.'.col('.').'/'.line('$').' '
\.PrintTime(localtime()-g:tlog[-1][0]).expand('%:t').':'"}
	let insD={103:"\<C-R>=getchar()\<CR>",(g:N_ESC):"\<Esc>a",96:'`',
\115:"\<Esc>:let qcx=HistMenu()|if qcx>=0|call Edit(g:histL[qcx])|en\<CR>",
\49:"\<Esc>:call Edit(g:histL[0])\<CR>",
\50:"\<Esc>:call Edit(g:histL[2])\<CR>",51:"\<Esc>:call Edit(g:histL[3])\<CR>",
\102:"\<C-R>=escape(expand('%'),' ')\<CR>",'help':'[f]ilename [g]etchar l[s]:',
\'msg':"line('.').'.'.col('.').'/'.line('$').' '
\.PrintTime(localtime()-g:tlog[-1][0]).expand('%:t').':'"}
	let cmdD={103:"\<C-R>=getchar()\<CR>",(g:N_ESC):" \<BS>",96:" \<BS>`",
\115:"\<C-R>=eval(join(repeat([HistMenu()],2),'==-1 ? \"\" : 
\escape(split(histL[').'],\"\\\\\\$\")[0],\" \")')\<CR>",
\102:"\<C-R>=escape(expand('%'),' ')\<CR>",
\108:"\<C-R>=matchstr(getline('.'),'[[:graph:]].*[[:graph:]]')\<CR>",
\119:"\<C-R>=expand('<cword>')\<CR>",87:"\<C-R>=expand('<cWORD>')\<CR>",
\'help':'[12]bn [f]ilename [g]etchar [l]ine l[s] [wW]ord:',
\'msg':"line('.').'.'.col('.').'/'.line('$').' '
\.PrintTime(localtime()-g:tlog[-1][0]).expand('%:t').':'"}

endif
