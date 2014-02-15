fun! Nexe()
	let range=getline(line("'<"),line("'>"))
	let commented=1 | for line in range
		if line!~'^\s*"' | let commented=0 | break | en | endfor
	if commented
		for line in range
			exe 'norm! :'.Ec(substitute(line,'^\s*"','',''),200)
		endfor
	el| for line in range
			exe 'norm! :'.Ec(line,200)
		endfor|en
endfun

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

fun! Ec(x,...)
	redr|echoh Directory | echom (a:0>1? (a:2):'').string(a:x) |echoh None
	if a:0>0 | exe 'sleep '.a:1.'m' | en
	return a:x
endfun

let Qpairs={'(':')','{':'}','[':']','<':'>'}
let QpairsOpp={')':'(','}':'{',']':'[','>':'<'}
let Qx1=['h','l']
let Qx2=['xb"hPl','xe"iph']
let Qx3=['xbbhe"iph','xeelb"hPl']
let Qx4=['norm! lb"hPe"iphmq','norm! he"ipb"hPlmq']
fun! IniQuote(mark)
	if has_key(g:Qpairs,a:mark) | let @h=a:mark | let @i=(g:Qpairs[a:mark])
	elsei has_key(g:QpairsOpp,a:mark) | let @h=(g:QpairsOpp[a:mark]) |let @i=a:mark
	el| let @h=a:mark | let @i=a:mark | en
endfun
fun! Quote(sel,dr)
	if a:sel==0 | norm! mrhel"tylbh"uyl`r
		if @u=~"[\[{(\*'\"/]" | call IniQuote(@u)
		elsei @t=~"[\)}]\*'\"/]" | call IniQuote(@t) | en
	elseif a:sel==1 | ec "Quote mark:" | call IniQuote(nr2char(getchar())) | en
	let WORD=expand('<cWORD>')		
	norm! mrlBms`r
	let cur=col("'r")-col("'s'")
	let tLQ=match(WORD,@h) | let LQ=tLQ
	while tLQ>-1 && tLQ<cur
		let LQ=tLQ | let tLQ=match(WORD,@h,LQ+1) | endw
	if LQ>cur | let RQ=(@i==@h? LQ : match(WORD,@i,cur)) | let LQ=-1
	elsei LQ<cur | let RQ=match(WORD,@i,cur)
	elsei LQ==len(WORD)-1 | let RQ=LQ | let LQ=-1
	el| let RQ=match(WORD,@i,cur+1) | en
	if a:dr | let T=(RQ>-1? RQ-cur : -1) | let A=(LQ>-1? cur-LQ : -1)
	el| let A=(RQ>-1? RQ-cur : -1) | let T=(LQ>-1? cur-LQ : -1) | en
	if T>-1 && A>-1 && getpos("'q")!=getpos('.')
		retu 'norm! '.(T>0 ? T.g:Qx1[a:dr] : '').'x'
		\.(T+A-!a:dr>0? (T+A-!a:dr).g:Qx1[!a:dr] : '').'x' 
	elsei T!=-1 | retu 'norm! mq'.(T>0? T.g:Qx1[a:dr] :'').g:Qx2[a:dr]
	elsei A!=-1 | retu 'norm! mq'.(A>0? A.g:Qx1[!a:dr] :'').g:Qx3[a:dr]
	el|retu g:Qx4[a:dr] | en
endfun
fun! QuoteChange(mark)
	if a:sel==0 | norm! mrhel"tylbh"uyl`r
		if @u=~"[\[{(\*'\"/]" | call IniQuote(@u)
		elsei @t=~"[\)}]\*'\"/]" | call IniQuote(@t) | en
	let mark=has_key(g:QpairsOpp,a:mark)? g:QpairsOpp[a:mark] : a:mark
	if search(@h,'bc') | let @h=mark | norm! x"hPl
		if search(@i,'c')
			let @i=has_key(g:Qpairs,@h)? g:Qpairs[@h] : @h | norm! x"iPh
		el| let @i=has_key(g:Qpairs,@h)? g:Qpairs[@h] : @h | en
	endif
endfun
nn <silent> [ :<C-U>exe Quote(v:count,0)<CR>
nn <silent> ] :<C-U>exe Quote(v:count,1)<CR>
nn <C-F> :<C-U>let gg=Quote(v:count,0)<CR>:ec gg<CR>
nn <C-G> :<C-U>ec Quote(v:count,1)<CR>

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

fun! PrintTime(s,...) "%e crashes Windows!
	retu strftime('%b%d %I:%M ',a:0>0? (a:1) : localtime())
	\.(a:s>86399? (a:s/86400.'d'):'')
	\.(a:s%86400>3599? (a:s%86400/3600.'h'):'')
	\.(a:s%3600/60.'m ')
endfun

let PagerH=6
fun! Pager(list)
	let g:cmdsave=&cmdheight
	exe "se ch=".(g:PagerH+1)
	let logmode=1
	let offset=len(a:list)-g:PagerH+(!logmode)
	let cursor=len(a:list)-logmode
	let ent=''
	while ent!=g:N_ESC || logmode==0
		let logmsg=''
		for i in range(offset,offset+g:PagerH-1)
			if i<0
				let logmsg.="\n"
			elseif i<len(a:list)
				let logmsg.=g:Pad[1:4-len(i)].i.(cursor==i? '>':' ')
				\.a:list[i][0:&columns-7]."\n"
			elseif i>len(a:list)
				let logmsg.="\n" | en	
		endfor
		if logmode==0
			if ent==105
				redr!|let ent=input(logmsg.'INS >')
				call insert(a:list,ent,cursor)
			elseif ent==97
				redr!|let ent=input(logmsg.'APP >')
				call insert(a:list,ent,cursor+1)
				let cursor+=1
				let offset+=1
			else
				redr!|let ent=input(logmsg.'CHG >'
				\,a:list[cursor])
				let a:list[cursor]=ent
			en
			let logmode=1
		el| redr!|ec logmsg
			let ent=getchar()
			if ent==120 "x
				if len(a:list)>0 | call remove(a:list,cursor) | en
				if cursor==len(a:list) | let cursor=len(a:list)-1 | en
			elseif ent==107 "k
				if cursor>0
					let cursor-=1
					if cursor<offset
						let offset-=1 | en
				en
			elseif ent==106 "j
				if cursor<len(a:list)-1
					let cursor+=1
					if cursor>=offset+g:PagerH
						let offset+=1 | en
				en
			elseif ent==99 || ent==105 || ent==97 "cia
				let logmode=0	
			elseif ent==71 "G
				let cursor=len(a:list)-1
				let offset=len(a:list)-g:PagerH	
			elseif ent==65 "A
				let cursor=len(a:list)
				let offset=len(a:list)-g:PagerH+1
				let logmode=0
			elseif ent==113 "q
				let ent=g:N_ESC
			en
		en
	endwhile
	exe 'se ch='.g:cmdsave
endfun
fun! Log()
	let g:cmdsave=&cmdheight
	exe "se ch=".(g:PagerH+1)
	let logmode=1
	let offset=len(g:tlog)-g:PagerH+(!logmode)
	let cursor=len(g:tlog)-logmode
	let ent=''
	while ent!=g:N_ESC || logmode==0
		let g:logmsg=''
		for i in range(offset,offset+g:PagerH-1)
			if i<0
				let g:logmsg.="\n"
			elseif i<len(g:tlog)
				let g:logmsg.=((cursor==i? '>':' ')
				\.PrintTime(g:tlog[i][0]-(i>0? g:tlog[i-1][0] : 0),
				\g:tlog[i][0]).g:tlog[i][1]."\n")[0:&columns-1]
			elseif i>len(g:tlog)
				let g:logmsg.="\n" | en	
		endfor
		if logmode==0
			if offset==len(g:tlog)-g:PagerH+1
				redr!|let ent=input(g:logmsg.'>'.PrintTime(localtime()-g:tlog[-1][0]))
			else
				redr!|let ent=input(g:logmsg.'Edit:',g:tlog[cursor][1]) | en
			if ent[0:1]==?'S:'
				let g:tlog[-1]=[localtime(),len(ent)>2? ent[2:] : g:tlog[-1][1]]
			elseif ent==''
				let logmode=1
				if offset==len(g:tlog)-g:PagerH+1
					let offset-=1
					let cursor-=1
				en
			else
				if ent[0:1]==?'b:'
					let ent=ent[2:].' @'.expand('%').'?'.line('.')	
				en
				if offset==len(g:tlog)-g:PagerH+1
					call extend(g:tlog,[[localtime(),ent]])
					let offset+=1
					let cursor+=1
				else
					let g:tlog[cursor][1]=ent
					let logmode=1
				en
			en
		else
			redr!|ec g:logmsg
			let ent=getchar()
			if ent==120 "x
				if len(g:tlog)>1 | call remove(g:tlog,cursor) | en
				if cursor==len(g:tlog) | let cursor=len(g:tlog)-1 | en
			elseif ent==107 "k
				if cursor>0
					let cursor-=1
					if cursor<offset
						let offset-=1 | en
				en
			elseif ent==106 "j
				if cursor<len(g:tlog)-1
					let cursor+=1
					if cursor>=offset+g:PagerH
						let offset+=1 | en
				en
			elseif ent==99 "c
				let logmode=0	
			elseif ent==71 "G
				let cursor=len(g:tlog)-1
				let offset=len(g:tlog)-g:PagerH	
			elseif ent==65 "A
				let cursor=len(g:tlog)
				let offset=len(g:tlog)-g:PagerH+1
				let logmode=0
			elseif ent==103 "g
				let atpos=stridx(g:tlog[cursor][1],'@')
				if atpos!=-1
					let file=split(g:tlog[cursor][1][atpos+1:],'?')
					if glob(file[0])!=#glob('%') | exe 'e '.file[0] | en
					exe 'norm! '.file[1].'G'
					let ent=g:N_ESC
				en
			en
		en
	endwhile
	exe 'se ch='.g:cmdsave
endfun

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
cno <expr> ` eval('TMenu('.g:cmdMode.')')

cnorea <expr> we ((getcmdtype()==':' && getcmdpos()<4)? 'w\|e' :'we')
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
let g:Tabs=repeat("\t",50)
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

fun! Write_Viminfo()
	let g:TLOG=join(map(g:tlog,'v:val[0]."|".v:val[1]'),"\n")
	let g:HISTL=join(map(g:histL,'join(v:val,"$")'),"\n")
	if has("gui_running")
		let g:S_GUIFONT=&guifont
		let g:WINPOS='se co='.&co.' lines='.&lines.
		\'|winp '.getwinposx().' '.getwinposy() | en
	se viminfo=!,'20,<1000,s10,/50,:50
	if !filereadable($VIMINFO_FILE) | wv
	elseif !exists('g:USE_WV_WORKAROUND') || g:USE_WV_WORKAROUND!=$VIMINFO
		try
			wv $VIMINFO_FILE
		catch
			let g:USE_WV_WORKAROUND=$VIMINFO_FILE
			wv ~/.viminfo
			!cp ~/.viminfo $VIMINFO_FILE
		endtry
	el| let g:USE_WV_WORKAROUND=$VIMINFO_FILE
		wv ~/.viminfo
		!cp ~/.viminfo $VIMINFO_FILE
	en | se viminfo=
endfun
fun! SetOpt(...)
	let g:INPUT_METH=a:0? a:1 : 'thumb'
	if g:INPUT_METH==?"THUMB"
		let op=["@",64,1]
	el| let op=["NONE",27,0] | en
	if exists(g:K_ESC)
		exe 'unm '.g:K_ESC
		exe 'unm! '.g:K_ESC
		exe 'cu '.g:K_ESC | en
	let g:K_ESC=op[0] | let g:N_ESC=op[1]
	if g:K_ESC!=?"NONE"
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
	let g:tlogD={108:"\<C-R>=input(g:logmsg)\<CR>\<CR>",
\114:"\<C-R>='R:'.((inputsave()? '':'').input(g:logmsg.'RENAME:')
\.(inputrestore()? '':''))\<CR>\<CR>",120:"\<C-U>X\<CR>",
\115:"\<C-R>='S:'.((inputsave()? '':'').input(g:logmsg.'STILL:')
\.(inputrestore()? '':''))\<CR>\<CR>",'help':'[L]og [R]ename [S]till [X]Del:',
\(g:N_ESC):"\<C-R>=input(g:logmsg)\<CR>\<CR>",
\113:"\<C-R>=input(g:logmsg)\<CR>\<CR>",
\'msg':"PrintTime(localtime()-g:tlog[0][0],g:tlog[0][0]).len(g:tlog).'L:'"}
	let g:normD={110:":noh\<CR>",(g:N_ESC):"\<Esc>",96:'`',122:":wa\<CR>",
\114:":redi@t|sw|redi END\<CR>:!rm \<C-R>=escape(@t[1:],' ')\<CR>",
\80:":call IniPaint()\<CR>",108:":call Log()\<CR>",
\103:"vawly:h \<C-R>=@\"[-1:-1]=='('? @\":@\"[:-2]\<CR>",
\88:"vip:\<C-U>call Nexe()\<CR>",
\115:":let qcx=HistMenu()|if qcx>=0|exe 'e '.g:histL[qcx][0]|en\<CR>",
\113:"\<Esc>",99:":call QuoteChange(nr2char(getchar()))\<CR>",
\49:":exe 'e '.g:histL[0][0]\<CR>",50:":exe 'e '.g:histL[1][0]\<CR>",
\51:":exe 'e '.g:histL[2][0]\<CR>",
\112:"i\<C-R>=eval(input('Put: ','','var'))\<CR>",
\42:":%s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>",
\35:":'<,'>s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>",
\'help':'b[123] [c]hg" [g]:h [l]og [n]ohl [P]nt [r]mswp l[s] [p]utvar e[X]e [z]:wa s/[*#]',
\'msg':"expand('%:t').' '.join(map(g:histLb[:2],'v:val[2:]'),' ').' '.line('.').'.'.col('.').'/'.line('$').' '.PrintTime(localtime()-g:tlog[-1][0])"}
	let g:insD={103:"\<C-R>=getchar()\<CR>",(g:N_ESC):"\<Esc>a",96:'`',
\115:"\<Esc>:let qcx=HistMenu()|if qcx>=0|exe 'e '.g:histL[qcx][0]|en\<CR>",
\49:"\<Esc>:exe 'e '.g:histL[0][0]\<CR>",
\50:"\<Esc>:exe 'e '.g:histL[1][0]\<CR>",
\51:"\<Esc>:exe 'e '.g:histL[2][0]\<CR>",
\102:"\<C-R>=escape(expand('%'),' ')\<CR>",
\113:"\<Esc>a",'help':'b[123] [f]ilename [g]etchar l[s]:',
\'msg':"expand('%:t').' '.join(map(g:histLb[:2],'v:val[2:]'),' ').' '.line('.').'.'.col('.').'/'.line('$').' '.PrintTime(localtime()-g:tlog[-1][0])"}
	let g:visD={(g:N_ESC):"\<Esc>", 113:"\<Esc>",
\103:"y:call GetVar(@\")\<CR>",
\120:"y:@\"\<CR>",99:"y:\<C-R>\"",'help':'[g]etvar e[x]e 2[c]md:',
\'msg':"expand('%:t').' '.join(map(g:histLb[:2],'v:val[2:]'),' ').' '.line('.').'.'.col('.').'/'.line('$').' '.PrintTime(localtime()-g:tlog[-1][0])"}
	let g:cmdD={103:"\<C-R>=getchar()\<CR>",(g:N_ESC):" \<BS>",96:" \<BS>`",
\115:"\<C-R>=eval(join(repeat([HistMenu()],2),'==-1 ? \"\" : 
\escape(split(histL[').'],\"\\\\\\$\")[0],\" \")')\<CR>",
\102:"\<C-R>=escape(expand('%'),' ')\<CR>",
\108:"\<C-R>=matchstr(getline('.'),'[[:graph:]].*[[:graph:]]')\<CR>",
\113:" \<BS>",
\119:"\<C-R>=expand('<cword>')\<CR>",87:"\<C-R>=expand('<cWORD>')\<CR>",
\'help':'[f]ilename [g]etchar [l]ine l[s] [wW]ord:',
\'msg':"expand('%:t').' '.line('.').'.'.col('.').'/'.line('$').' '
\.PrintTime(localtime()-g:tlog[-1][0])"}
endfun
fun! WelcomeMsg()
	if has('win16') || has('win32') || has('win64') | let os='WIN'
	elseif exists('$VIMINFO_FILE') | let os='AND'
	el| let os='UX' | en
	let g:WORKING_DIR=input("Files are relative to WORKING_DIR:",
		\exists('g:DEFWD_'.os)? eval('g:DEFWD_'.os):expand('$HOME'),'file')
	exe 'let g:DEFWD_'.os.'=g:WORKING_DIR'
	let g:INPUT_METH=input("INPUT_METH? (thumb/keyboard):",
		\exists('g:DEFIM_'.os)? eval('g:DEFIM_'.os):'thumb','file')
	exe 'let g:DEFIM_'.os.'=g:INPUT_METH'
endfun
fun! OnVimEnter()
	if !exists('g:WORKING_DIR') || !isdirectory(glob(g:WORKING_DIR))
		call WelcomeMsg() | en
	call SetOpt(g:INPUT_METH)
	if !argc()
		let g:FORMAT_NEW_FILES=1
		exe 'cd '.g:WORKING_DIR
		so cmdnorm.vim
		so abbrev
		if len(g:histL)>0
			exe 'e '.g:histL[0][0] | call CheckFormatted() | call OnWinEnter()
		en
	el| let g:FORMAT_NEW_FILES=0 | en
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
endfun
if !exists('do_once') | let do_once=1
	se viminfo=!,'20,<1000,s10,/50,:150
		if filereadable($VIMINFO_FILE) | rv $VIMINFO_FILE
		el| let g:viminfo_file_invalid=1 | rv | en
	se viminfo=
	au VimEnter * call OnVimEnter()
	au BufWinEnter * call OnWinEnter()
	au BufRead * call CheckFormatted()
	au BufNewFile * call OnNewBuf()
	au BufWinLeave * call InsHist(expand('%'),line('.'),col('.'),line('w0'))
	au VimLeavePre * call Write_Viminfo()
	se noshowmode ai
	se nowrap linebreak sidescroll=1 ignorecase smartcase incsearch cc=81
	se tabstop=4 history=150 mouse=a ttymouse=xterm hidden backspace=2
	se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
	se whichwrap+=h,l wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
	se stl=\ %l.%02c/%L\ %<%f%=\ %{PrintTime(localtime()-tlog[-1][0])}
	se guioptions-=T
	hi ColorColumn guibg=#222222 ctermbg=237
	hi Pmenu ctermbg=26 ctermfg=81
	hi PmenuSel ctermbg=21 ctermfg=81
	hi PmenuSbar ctermbg=23
	hi PmenuThumb ctermfg=81
	hi ErrorMsg ctermbg=9 ctermfg=15
	hi Search ctermfg=9 ctermbg=none
	hi MatchParen ctermfg=9 ctermbg=none
	hi StatusLine cterm=underline ctermfg=244 ctermbg=236
	hi StatusLineNC cterm=underline ctermfg=240 ctermbg=236
	hi Vertsplit guifg=grey15 guibg=grey15 ctermfg=237 ctermbg=237
	let cmdMode='cmdD'
	if has("gui_running")
		colorscheme slate
		if exists("WINPOS") | exe WINPOS | en
		if !exists('S_GUIFONT')
			"se guifont=Envy\ Code\ R\ 10 
			se guifont=Envy_Code_R:h10 
			let S_GUIFONT='Envy_Code_R:h10' 
		el| exe 'se guifont='.S_GUIFONT | en
	el | syntax off | en
	if !exists('TLOG') | let tlog=[[localtime(),'0000']]
	el | let tlog=map(split(TLOG,"\n"),"split(v:val,'|')") | en
	if !exists("HISTL") | let g:HISTL="" | en
	let g:histL=map(split(g:HISTL,"\n"),'split((v:val),"\\$")')
	call InitHist()
	call IniQuote("*")
	nohl
en

"visual +/- (use &ts)
	"don't count blank lines as 0 indent
	"use count!!!
"Pager
	"2d arrays
	"Undo
	"Copy Paste
	"Memory
	"Readonly
	"Increase/decrease height (+/-)
	"Special functions
		"merge with Log
		"return values with position
		"shopping list quick check!
		"TOC
		"On Noexist create a list (Command)
		"User Menus
	"better help msg based on LogPager ('more')
	"l\Log menus, for going straight to normal
	"bookmark jumps maintain log?? or, remember place after jump?!
	"Open files (eg, shopping) as list
		"longer arrays in viminfo, daily? viminfo backups
"palette, generalized color scheme, pastel palette though! 'relational' colors!
	"complement, eg! balance customizability & uniformity
	"Use higlight line and normal to change it for *most* cases
	"have a *base scheme*: black and white??????
	"redraw at end of scroll!
"vsp bug -- redo onrelease, by storing last remembered position? speed?
	"ve bug
	"Use getchar()?!!
"make recently used files lowercase
"`t: trim spaces from end of lines
"#t_ bug
"out-of-box: viminfo prompt
"Set message for cmdnormal
"Colorful echos
"Centering, left, right justify
