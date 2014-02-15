redir => g:StartupErr

fun! CenterLine()
	let line=matchstr(getline('.'),'^\s*\zs.*\S\ze\s*$')
	call setline(line('.'),g:Pad[:(&columns-strdisplaywidth(line))/2].line)
endfun

fun! Permanent(name)
	let g:PermanentD[a:name]=toupper(a:name)
endfun
fun! DeletePerm(name)
	exe 'unlet g:'.toupper(a:name)
	exe 'unlet g:'.a:name
	unlet g:PermanentD[a:name]
endfun

fun! PrintTime(s,...) "%e crashes Windows!
	retu strftime('%b%d %I:%M ',a:0>0? (a:1) : localtime())
	\.(a:s>86399? (a:s/86400.'d'):'')
	\.(a:s%86400>3599? (a:s%86400/3600.'h'):'')
	\.(a:s%3600/60.'m ')
endfun

fun! GetCompletion()
	let c=col('.')
	if c>1 && getline(".")[c-2]=~'\S' | return "\<C-X>\<C-P>"
	el| return "\<Tab>" |en
endfun
inoremap <expr> <Tab> GetCompletion()

fun! New(class,...)
	let newclass={'cons':function('Init'.a:class)}
	exe 'call newclass.cons('.join(map(range(a:0),'"a:".(1+v:val)'),',').')'
	return newclass
endfun

nnoremap q: <nop>
nnoremap [15 q:
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

fun! GetVar(str)
	let varname=input('Store as:','','var') | if varnamei!=''
		exe 'let g:'.varname
	\.'=Ec(map(split(a:str,"\n"),''v:val=~"^\\[.*]$"? eval(v:val):(v:val)''))'
	en
endfun

fun! PrevHeading(indent)
	let i=line('.')
	let line=getline(i)
	if strdisplaywidth(matchstr(line,'^\s*'))==a:indent
		if i>0 | let i-=1 | end
		while i>0
			let line=getline(i)
			if strdisplaywidth(matchstr(line,'^\s*'))==a:indent && line!~'^\s*$'
				let i-=1
			el|brea|en
		endwhile
	en
	if i>0 | let i-=1 | end
	while i>0
		let line=getline(i)
		if strdisplaywidth(matchstr(line,'^\s*'))!=a:indent || line=~'^\s*$'
			let i-=1
		el|brea|en
	endwhile
	return i
endfun
fun! NextHeading(indent)
	let i=line('.')
	let end=line('$')
	let line=getline(i)
	if strdisplaywidth(matchstr(line,'^\s*'))==a:indent
		if i<end | let i+=1 | end
		while i<end
			let line=getline(i)
			if strdisplaywidth(matchstr(line,'^\s*'))==a:indent && line!~'^\s*$'
				let i+=1
			el|brea|en
		endwhile
	en
	if i<end | let i+=1 | end
	while i<end
		let line=getline(i)
		if strdisplaywidth(matchstr(line,'^\s*'))!=a:indent || line=~'^\s*$'
			let i+=1
		el|brea|en
	endwhile
	return i
endfun
nn <expr> + "\<Esc>".NextHeading(&ts*v:count).'Gzz'
nn <expr> - "\<Esc>".PrevHeading(&ts*v:count).'Gzz'
vn <expr> + '^'.NextHeading(&ts*v:count).'Gzz'
vn <expr> - '^'.PrevHeading(&ts*v:count).'Gzz'

let EcList=[]
fun! Ec(...)
	echoh Directory
	if a:0>1 && a:000[a:0-1]=~'00m$'
		redr| echom join(map(copy(a:000[:-2]),'string(v:val)'),'; ')
		exe 'sleep '.a:000[a:0-1]
	el| redr| echom join(map(copy(a:000),'string(v:val)'),'; ') |en
	echoh None
	return a:1
endfun

let HLb=split('1234567890abcdefghijklmnopqrstuvwxyz
\ABCDEFGHIJKLMNOPQRSTUVWXYZ','\zs')
let Asc2HLb=repeat([-1],256) | for i in range(len(HLb))
	let Asc2HLb[char2nr(HLb[i])]=i
endfor
let maxW=15
fun! GetLbl(file)
	let name=matchstr(a:file,"[[:alnum:]][^/\\\\]*$")
	return len(name)+3>g:maxW ? name[0:g:maxW-8]."~".name[-3:] : name
endfun
fun! InitHist()
	let g:histLb=map(copy(g:histL),'GetLbl(v:val[0])')
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
	return remove(g:histL,a:ix)[1]
endfun
fun! InsHist(name,lnum,cnum,w0)
	if a:name=='' || a:name=~escape($VIMRUNTIME,'\') |retu|en
	call insert(g:histL,[a:name,a:lnum,a:cnum,a:w0])
	if len(g:histL)>=len(g:HLb)-8
		let g:histL=g:histL[:len(g:HLb)-16] | call InitHist()
	retu|en
	let name=GetLbl(g:histL[0][0])
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
	if len(a:list)==0 | retu ''
	elseif len(a:list)==1 | retu a:list[0] | en
	let tabW=a:0==0? 0 : a:1 | let padN=[0]+(tabW==0 ? [] : range(tabW-1,1,-1))
	let ecstr=a:list[0] | let endX=len(ecstr)
	for e in a:list[1:]
		if endX+padN[endX%tabW]+len(e)>=&columns-1	
			let ecstr.="\n".e | let endX=len(e)
		else
			let ecstr.=g:Pad[1:padN[endX%tabW]].e
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
fun! OnWinEnter()
	let file=expand('%')
	for i in range(len(g:histL))
		if g:histL[i][0]==#file
			let j=g:histL[i][1]-g:histL[i][3]
			exe "norm! ".g:histL[i][3]."z\<CR>".(j>0? j.'j':'').g:histL[i][2].'|'
			call RmHist(i)
			break|en
	endfor
endfun
fun! OnNewBuf()
	if g:FORMAT_NEW_FILES
  		call setline(1,localtime()." vim: set nowrap ts=4 tw=78 fo=aw: "
   		\.strftime('%H:%M %m/%d/%y'))
   		setlocal nowrap ts=4 tw=62 fo=aw
  		call CheckFormatted()
	en
endfun

fun! CheckFormatted()
	if getline(1)!~'fo=aw' | retu|en
	setl noai
   	call InitCap()
   	iab <buffer> i I
   	iab <buffer> Id I'd
   	iab <buffer> id I'd
   	iab <buffer> im I'm
   	iab <buffer> Im I'm
   	nn <buffer> <silent> { :if !search('\S\n\s*.\\|\n\s*\n\s*.','Wbe')\|exe'norm!gg^'\|en<CR>
   	nn <buffer> <silent> } :if !search('\S\n\\|\s\n\s*\n','W')\|exe'norm!G$'\|en<CR>
   	nm <buffer> A }a
   	nm <buffer> I {i
   	nn <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
   	nn <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
	redr|ec 'Formatting Options Loaded: '.expand('%')
endfun
nn gf :e <cword><CR>

fun! TMenu(cmd,...)
	let ec=a:0==0? eval(a:cmd.msg) : a:cmd[a:1]
	if 1+len(ec)/&columns >= &cmdheight
		let save=&cmdheight | exe 'se cmdheight='.(1+len(ec)/&columns)
			ec ec | let key=getchar() | redr!
		exe 'se cmdheight='.save
	el| ec ec
		let key=getchar()|redr! | en
	retu has_key(a:cmd,key)? a:cmd[key] : TMenu(a:cmd,'help')
endfun!
nno <expr> ` TMenu(g:normD)
ino <expr> ` TMenu(g:insD)
vno <expr> ` TMenu(g:visD)

cnorea <expr> we ((getcmdtype()==':' && getcmdpos()<4)? 'w\|e' :'we')
cnorea <expr> ws ((getcmdtype()==':' && getcmdpos()<4)? 'w\|so%':'ws')
cnorea <expr> wd ((getcmdtype()==':' && getcmdpos()<4)? 'w\|bd':'wd')
cnorea <expr> wsd ((getcmdtype()==':' && getcmdpos()<5)? 'w\|so%\|bd':'wsd')

fun! CapWait(prev)
	redr | let next=nr2char(getchar())
	if next=~'[.?!\r\n[:blank:]]'
		exe 'norm! i' . next . "\<Right>"
		return CapWait(next)
	elseif next=='' || next==g:K_ESC
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

let g:Dashes=repeat('-',200)|let g:Pad=repeat(' ',200)
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
	exe 'norm! '.(s:cP[2]>s:pP[2]? (s:cP[2]-s:pP[2])."zh" : s:pP[2]>s:cP[2]? (s:pP[2]-s:cP[2])."zl" : '').(s:cP[1]>s:pP[1]? (s:cP[1]-s:pP[1])."\<C-Y>" : s:pP[1]>s:cP[1]? (s:pP[1]-s:cP[1])."\<C-E>" : 'g')
	let s:pP=s:cP
endfun
fun! OnVisual()
	let cdiff=virtcol("'v")-wincol()
	let rdiff=line("'v")-line(".")
	echo rdiff.(g:Pad[1:(cdiff>0? wincol():virtcol("'v"))]
	\.g:Dashes[1:abs(cdiff)])[len(rdiff):]
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
fun! OnRelease() " Must move before release
	if g:OnTouch=='OnVisual'
		norm! v`v
		let g:OnTouch='IniScroll'
	elseif g:OnTouch!='Paint'
		exe 'se ve='.s:vesave
		let g:OnTouch='IniScroll'
	endif
endfun

fun! SetOpt(...)
	let g:INPUT_METH=a:0? a:1 : 'thumb'
	if g:INPUT_METH==?"THUMB"
		let op=["@",64,1]
	el| let op=["\e",27,0] | en
	let [g:K_ESC,g:N_ESC]=op[:1]
	if exists(g:K_ESC)
		exe 'unm '.g:K_ESC
		exe 'unm! '.g:K_ESC
		exe 'cu '.g:K_ESC | en
	if g:K_ESC!=?"\e"
		exe 'no <F2> '.g:K_ESC
		exe 'no '.g:K_ESC.' <Esc>'
   		exe 'no! '.g:K_ESC.' <Esc>'
   		exe 'cno '.g:K_ESC.' <C-C>' | en
	try|exe (op[2]? 'nn <silent> <leftmouse> <leftmouse>:call {OnTouch}()<CR>'
			\:'nun <leftmouse>')
		exe (op[2]? 'nn <silent> <leftrelease> <leftmouse>:call OnRelease()<CR>'
			\:'nun <leftrelease>')
		exe (op[2]? "vn <silent> <leftmouse> <Esc>mv<leftmouse>
			\:let OnTouch='OnVisual'<CR>'":'vu <leftmouse>')
		exe (op[2]? 'map <C-J> <C-M>' : 'unm <C-J>')
		exe (op[2]? 'map! <C-J> <C-M>' : 'unm! <C-J>')
		exe (op[2]? 'no OQ @' :'unm OQ')
		exe (op[2]? 'no! OQ @' :'unm! OQ')
		exe (op[2]? 'no <F7> <PageDown>' : 'unm <F7>')
		exe (op[2]? 'no! <F7> <PageDown>' : 'unm! <F7>')
		exe (op[2]? 'no <F8> <PageUp>' : 'unm <F8>')
		exe (op[2]? 'no! <F8> <PageUp>' : 'unm! <F8>')
		exe (op[2]? 'ino <F9> <Home>' : 'iu <F9>')
		exe (op[2]? 'ino <F10> <End>' : 'iu <F10>')
		exe (op[2]? 'nn <F9> <C-O>' : 'nun <F9>')
		exe (op[2]? 'nn <F10> <C-I>' : 'nun <F10>')
	catch | endtry
	let g:normD={110:":noh\<CR>",(g:N_ESC):"\<Esc>",96:'`',122:":wa\<CR>",
	\114:":redi@t|sw|redi END\<CR>:!rm \<C-R>=escape(@t[1:],' ')\<CR>",
	\80:":call IniPaint()\<CR>",108:":call g:LogDic.show()\<CR>",
	\99:":call CenterLine()\<CR>",
	\103:"vawly:h \<C-R>=@\"[-1:-1]=='('? @\":@\"[:-2]\<CR>",
	\88:"vip:\<C-U>call Nexe()\<CR>",119:"\<C-W>\<C-W>",
	\115:":let qcx=HistMenu()|if qcx>=0|exe 'e '.g:histL[qcx][0]|en\<CR>",
	\49:":exe 'e '.g:histL[0][0]\<CR>",50:":exe 'e '.g:histL[1][0]\<CR>",
	\113:"\<Esc>",51:":exe 'e '.g:histL[2][0]\<CR>",
	\112:"i\<C-R>=eval(input('Put: ','','var'))\<CR>",109:":mes\<CR>",
	\42:":,$s/\<C-R>=expand('<cword>')\<CR>//gc|1,''-&&\<left>\<left>
	\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
	\35:":'<,'>s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>",
	\'help':'b[123] [g]:h [l]og [n]ohl [P]nt [r]mswp l[s] :[m]es [p]utvar
	\ C-[w]C-w e[X]e [z]:wa s/[*#]',
	\'msg':"expand('%:t').' '.join(map(g:histLb[:2],'v:val[2:]'),' ').' '
	\.line('.').'.'.col('.').'/'.line('$').' '
	\.PrintTime(localtime()-g:LastTime)"}
	let g:insD={103:"\<C-R>=getchar()\<CR>",(g:N_ESC):"\<Esc>a",96:'`',
	\115:"\<Esc>:let qcx=HistMenu()|if qcx>=0|exe 'e '.g:histL[qcx][0]|en\<CR>",
	\49:"\<Esc>:exe 'e '.g:histL[0][0]\<CR>",
	\50:"\<Esc>:exe 'e '.g:histL[1][0]\<CR>",
	\51:"\<Esc>:exe 'e '.g:histL[2][0]\<CR>",
	\102:"\<C-R>=escape(expand('%'),' ')\<CR>",119:"\<Esc>\<C-W>\<C-W>",
	\113:"\<Esc>a",'help':'b[123] [f]ilename [g]etchar l[s]:',
	\'msg':"expand('%:t').' '.join(map(g:histLb[:2],'v:val[2:]'),' ').' '
	\.line('.').'.'.col('.').'/'.line('$').' '
	\.PrintTime(localtime()-g:LastTime)"}
	let g:visD={(g:N_ESC):"",103:"y:call GetVar(@\")\<CR>",
	\120:"y:@\"\<CR>",99:"y:\<C-R>\"",'help':'[g]etvar e[x]e 2[c]md:',
	\'msg':"expand('%:t').' '.line('.').'.'.col('.').'/'.line('$').' '
	\.PrintTime(localtime()-g:LastTime)"}
endfun
fun! Write_Viminfo()
	if match(g:StartupErr,'\cerror')!=-1
		let in=input("Startup errors were encountered, write viminfo anyways?")
		if in!=?'y' && in!='ye' && in!='yes' |retu|en |en
	if exists('g:PermanentD')
		for i in keys(g:PermanentD)
			exe 'let g:'.g:PermanentD[i].'=string(g:'.i.')'
		endfor |en
	if has("gui_running")
		let g:S_GUIFONT=&guifont
		let g:WINPOS='se co='.&co.' lines='.&lines.
		\'|winp '.getwinposx().' '.getwinposy() |en
	se viminfo=!,'20,<1000,s10,/50,:50
	if g:VIMINFO_FILE==''| wviminfo
	el| if filereadable(g:VIMINFO_FILE.'.bak')
		silent exe '!rm '.g:VIMINFO_FILE.'.bak' |en
		silent exe '!mv '.g:VIMINFO_FILE.' '.g:VIMINFO_FILE.'.bak'
		silent exe 'wv! '.g:VIMINFO_FILE |en
	se viminfo=
endfun

if !exists('do_once') | let do_once=1 | el|finish|en
se viminfo=!,'20,<1000,s10,/50,:150
if !exists('VIMINFO_FILE')
	call Ec('VIMINFO_FILE not defined in .vimrc!')
	call Ec('...falling back to default')
	let VIMINFO_FILE=''
	if argc()==0
		rviminfo
	el| try | rv | catch | endtry |en
el| exe 'rv '.VIMINFO_FILE |en
se viminfo=
if !exists('WORKING_DIR') || !isdirectory(glob(WORKING_DIR))
	call Ec('WORKING_DIR invalid or not defined')
	if argc()==0| let WORKING_DIR=input('Working directory:',$HOME,'file')
	el| let WORKING_DIR=$HOME |en |en
if !exists('INPUT_METH')
	call Ec('INPUT_METH invalid or not defined!')
	if argc()==0| let INPUT_METH=input('Input method:','keyboard')
	el| let INPUT_METH='keyboard' |en |en
call SetOpt(g:INPUT_METH)
let sources=['abbrev','cmdnorm','pager']
for file in sources
	if filereadable(WORKING_DIR.'/'.file)| exe 'so '.WORKING_DIR.'/'.file
	el| call Ec(file.' unreadable')|en
endfor
if has("gui_running")
	colorscheme slate
	if exists("WINPOS") | exe WINPOS |en
	if !exists('S_GUIFONT')
		"se guifont=Envy\ Code\ R\ 10 
		se guifont=Envy_Code_R:h10 
		let S_GUIFONT=&guifont
	el| exe 'se guifont='.S_GUIFONT |en |en
if exists('PERMANENTD')
	let PermanentD=eval(PERMANENTD)
	for key in keys(PermanentD)
		exe 'let '.key.'='.eval(PermanentD[key])
	endfor
el| let PermanentD={} |en
if !exists('*InitLog')
	leg g:LastTime=localtime()
elseif !exists('LogDic')
	let LogDic=New('Log')
el| let g:LastTime=LogDic.L[-1][0] |en
if !exists('histL') | let histL=[] |en
call InitHist()
if !argc()
	let g:FORMAT_NEW_FILES=1
	if isdirectory(WORKING_DIR)
		exe 'cd '.WORKING_DIR |en
	if len(histL)>0
		silent exe 'e '.g:histL[0][0]
		call CheckFormatted() | call OnWinEnter() |en
el| let g:FORMAT_NEW_FILES=0 |en
if glob(g:WORKING_DIR)=='/home/q335/Desktop/Dropbox/q335writings'
\ && !has("gui_running")
	map OA <Up>
	map OB <Down>
	map OD <Left>
	map OC <Right>
	map! OA <Up>
	map! OB <Down>
	map! OD <Left>
	map! OC <Right>
en
call Permanent('histL')
call Permanent('LogDic')
call Permanent('PermanentD')

nohl
au BufWinEnter * call OnWinEnter()
au BufRead * call CheckFormatted()
au BufNewFile * call OnNewBuf()
au BufWinLeave * call InsHist(expand('%'),line('.'),col('.'),line('w0'))
au VimLeavePre * call Write_Viminfo()
hi ColorColumn guibg=#222222 ctermbg=237
hi Pmenu ctermbg=26 ctermfg=81
hi PmenuSel ctermbg=21 ctermfg=81
hi PmenuSbar ctermbg=23
hi PmenuThumb ctermfg=81
hi ErrorMsg ctermbg=9 ctermfg=15
hi Search ctermbg=21 ctermfg=81
hi MatchParen ctermfg=9 ctermbg=none
hi StatusLine cterm=underline ctermfg=244 ctermbg=236
hi StatusLineNC cterm=underline ctermfg=240 ctermbg=236
hi Vertsplit guifg=grey15 guibg=grey15 ctermfg=237 ctermbg=237
se noshowmode ai guioptions-=T
se nowrap linebreak sidescroll=1 ignorecase smartcase incsearch cc=81
se tabstop=4 history=150 mouse=a ttymouse=xterm hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
se whichwrap+=h,l wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
se stl=\ %l.%02c/%L\ %<%f%=\ %{PrintTime(localtime()-LastTime)}
redir END

"cmdmenu - echo prepend, long lines
"glob() for all history entries?
"log-cmdmenu interaction bug
"hi normal + highlight lines for quick scheme changes
"connectbot bug
	"restore position at end of OnReSize
