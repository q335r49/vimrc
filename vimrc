se nocompatible

redir => g:StartupErr

map k <up>
map j <down>
map h <left>
map l <right>
map! k <up>
map! j <down>
map! h <left>
map! l <right>

for mark in map(range(97,122)+range(65,90),'nr2char(v:val)')
	exe 'sign define bkmrk'.mark.' texthl=Visual text='.mark.'-'
endfor
fun! UpdateBookmark()
	let mark=getchar()
	if (65<=mark && mark<=90) || (97<=mark && mark<=122)
		exe "sign unplace ".mark 
		exe "sign place ".mark." line=".line('.')." name=bkmrk".nr2char(mark)." file=" . expand("%:p")
	en
	return "m".nr2char(mark)
endfun
fun! ToggleBookmarks()
	if exists("b:bookmarks_shown")
		unlet b:bookmarks_shown
		exe 'sign unplace * buffer='.bufnr("%")
		nunmap m
		return
	en
	let b:bookmarks_shown=1
	nnoremap <expr> m UpdateBookmark()
	let curbn=bufnr("%")
	for mark in map(range(65,90),'nr2char(v:val)')
		let pos=getpos("'".mark)
		if pos[0]==curbn 
			exe "sign place ".char2nr(mark)." line=".pos[1]." name=bkmrk".mark." file=" . expand("%:p")
		en
	endfor
	for mark in map(range(97,122),'nr2char(v:val)')
		let pos=getpos("'".mark)
		if pos[1]!=0
			exe "sign place ".char2nr(mark)." line=".pos[1]." name=bkmrk".mark." file=" . expand("%:p")
		en
	endfor
endfun

nno <space> 10jzz
nno <bs> 10kzz

nno <MiddleMouse> <LeftMouse>:q<cr>

hi clear tabline

if !exists('Cur_Device')
	echom "Warning: Cur_Device is undefined, device specific settings may not be loaded."
	let Cur_Device=''
en
if !exists('Cur_RunAs')
	let Cur_RunAs=''
en
if Cur_Device=='cygwin'
	se timeoutlen=1
	vno <c-c> "*y
	vno <c-v> "*p
	ino <c-_> <c-w>
	nno <c-_> db
	let opt_DisableAutocap=1
	let opt_LongPressTimeout=[99999,99999]
	let opt_TmenuKey="`"
	let Viminfo_File='~/.viminfo'
	let Cyg_Working_Dir= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings'
	let Working_Dir= 'C:/Users/q335r49/Desktop/Dropbox/q335writings'
	let EscChar="\e"
	if Cur_RunAs=='notepad'
		se noswapfile
		nno <c-s> :wa<cr>			
		nno <c-w> :wqa<cr>
		nno <c-v> "*p
		nno <c-q> <c-v> 
		let opt_colorscheme='notepad'
	en
elseif Cur_Device=='droid4'
	let opt_TmenuKey="_"
	let opt_LongPressTimeout=[0,500000]
	nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (Mscroll()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
el
	nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (Mscroll()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
	let opt_TmenuKey="`"
	let opt_LongPressTimeout=[0,500000]
en
let opt_TmenuAsc=char2nr(opt_TmenuKey)

fun! SoftCapsLock()
	let key=getchar()
	while key!=g:EscAsc
		if key=="\<backspace>"
			norm! x
		el| exe "norm! a".toupper(nr2char(key)) |en
		redraw!
		let key=getchar()
	endwhile
endfun

fun! MLT()
    if search('\C\V'.nr2char(getchar()),'bW')
        norm! l
    endif
endfun
fun! MLF()
    call search('\C\V'.nr2char(getchar()),'bW')
endfun
fun! MLf()
    if search('\C\V'.nr2char(getchar()),'W')
        norm! l
    endif
endfun
fun! MLt()
    call search('\C\V'.nr2char(getchar()),'W')
endfun
fun! MLnT()
    if search('\C\V'.nr2char(getchar()),'bW')
        norm! l
    endif
endfun
fun! MLnF()
    call search('\C\V'.nr2char(getchar()),'bW')
endfun
fun! MLnt()
    if search('\C\V'.nr2char(getchar()),'W')
        norm! h
    endif
endfun
fun! MLnf()
    call search('\C\V'.nr2char(getchar()),'W')
endfun

fun! InvertSetting(choice)
	if a:choice==119
		se invwrap
	elseif a:choice==104
		se invhls
	elseif a:choice==108
		se invlist
	elseif a:choice==116
		let &showtabline=!&showtabline
	elseif a:choice==115
		let &ls=&ls>1? 0:2
	elseif a:choice==110
		se invnumber
	elseif a:choice==87
		if winwidth(0)==&columns	
			silent call Writeroom(exists('OPT_WRITEROOMWIDTH')? OPT_WRITEROOMWIDTH : 25)
		else | only | en
	elseif a:choice==98
		call ToggleBookmarks()
	en
endfun

if !exists('Cur_Device')
	echom "Warning: Cur_Device is undefined, device specific settings may not be loaded."
	let Cur_Device=''
en
if !exists('Cur_RunAs')
	let Cur_RunAs=''
en
let opt_LongPressTimeout=[0,500000]
if Cur_Device=='cygwin'
	vno <c-c> "*y
	vno <c-v> "*p
	ino <c-_> <c-w>
	nno <c-_> db
	let opt_DisableAutocap=1
	let opt_LongPressTimeout=[99999,99999]
	let Viminfo_File='~/.viminfo'
	let Cyg_Working_Dir= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings'
	let Working_Dir= 'C:/Users/q335r49/Desktop/Dropbox/q335writings'
	let EscChar="\e"
	if Cur_RunAs=='notepad'
		se noswapfile
		nno <c-s> :wa<cr>			
		nno <c-w> :wqa<cr>
		nno <c-v> "*p
		nno <c-q> <c-v> 
		let opt_colorscheme='notepad'
	en
el
	nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (Mscroll()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
en

nno <c-p> :call GotoPreviousFold()<cr>
nno <c-n> :call GotoNextFold()<cr>
fun! GotoPreviousFold()
	call search('{{{','bW')	
endfun
fun! GotoNextFold()
	call search('{{{','W')	
endfun

ab /f {{{}}}2k$a

if Cur_Device=="Droid4"
	nn R <c-r>
	nn <c-r> <nop>
en

nn j gj
nn k gk
nn gj j
nn gk k
ino <c-z> <Space>
nn <expr> gp '`['.getregtype().'`]'

com! -nargs=+ -complete=var Editlist call New('NestedList',<args>).show()
com! DiffOrig belowright vert new|se bt=nofile|r #|0d_|diffthis|winc p|diffthis

fun! Writeroom(margin)
	echom a:margin
	wa
	only
	exe 'botright '.(a:margin*&columns/100).' vsp blankR'
	exe 'topleft '.(a:margin*&columns/100).' vsp blank'
	wincmd l
endfun

let Pad=repeat(' ',200)
fun! FoldText()
	let l=getline(v:foldstart)
	return g:Pad[v:foldlevel].'('.l[:stridx(l,'{{{')-1].')'
endfun

fun! ReltimeLT(t1,t2)
	return a:t1[0]<a:t2[0] || a:t1[0]==a:t2[0] && a:t1[1]<a:t2[1]
endfun
fun! Getcharuntil(t)
	let [g:gcwait,t0,c]=[[0,0],reltime(),getchar(0)]
	while c==#'0' && (g:gcwait[0]<a:t[0] || g:gcwait[0]==a:t[0] && g:gcwait[1]<a:t[1])
		let [c,g:gcwait]=[getchar(0),reltime(t0)]
	endw
	return c
endfun

let g:prevglide=0
fun! Mscroll()
	exe v:mouse_win.'wincmd w'
	if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1)
	\ || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) 
	\ || v:mouse_lnum==line('$')
		if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
		return 1 |en	
	exe 'keepj norm! '.v:mouse_lnum.'G'.v:mouse_col.'|'
	if !&wrap && v:mouse_lnum>=line('w$')-(winheight(0)>19)-(winheight(0)>35)
		let pos=v:mouse_col
		while getchar()=="\<leftdrag>"
			let diff=v:mouse_col-pos
			let pos+=diff
			if diff && -9<diff && diff<9
				exe 'keepj norm! '.(diff>0? "zh" :"zl")
				redr|en
		endw
	el| let pos=winline()
		if pos==1 | exe "keepj norm! \<c-y>" |en
		while 1 "continue scrolling if no fold or jumps are detected
	  	let [timeL,diffL]=[[],[]]
		while Getcharuntil(g:opt_LongPressTimeout) is "\<leftdrag>"
			exe 'keepj norm! '.v:mouse_lnum.'G'
			let diff=winline()+(v:mouse_col-1)/&columns-pos
			call add(timeL,g:gcwait)
			call add(diffL,diff)
			if diff
				let pos+=diff
				exe 'keepj norm! '.(diff>0? diff."\<c-y>":-diff."\<c-e>")
				redr|ec line('w0') '/' line('$')|en
		endwhile
		let action_executed=1
		if ReltimeLT(g:opt_LongPressTimeout,g:gcwait)
			try | keepj norm! za
			catch *
				try | exe "keepj norm! \<c-]>"
				catch *
					let action_executed=0
				endtry
			endtry
		elseif ReltimeLT(g:gcwait,[0,100000])
			let s=len(diffL)>4? -4 : 0
			let [max,min,elaps]=[max(diffL[s :]),min(diffL[s :]),
			\ eval(join(map(timeL[s :],'v:val[0].("00000".v:val[1])[-6:]'),'+').'+0')]
			if elaps<160000 && len(diffL)>1 && max*min>=0 && (max || min)
				if abs(max)>abs(min)
					let glide=max+(g:prevglide>0)*g:prevglide
					let cmd="keepj norm! \<C-Y>"
				el| let glide=min+(g:prevglide<0)*g:prevglide
					let cmd="keepj norm! \<C-E>" |en
				let delay=1080/glide/glide
				let counter=delay
				while !getchar(1) && delay<2000
					let counter-=1
					if !counter
						let delay=delay*11/10
						let counter=delay
						exe cmd
						redr|ec line('w0') '/' line('$')
					endif
				endwhile
				let g:prevglide=(2200-delay)*glide/4200
			el| let g:prevglide=0 |en
		en
		if action_executed
			break
		en
		endwhile
	en
endfun

let maxQselsize=&lines*&columns-2
fun! QSel(list,msg)
	let [inp,c]=['','']
	while c!=g:EscAsc && (c==0 || c>30)
		let inp=c=="\<bs>"? inp[:-2] : inp.nr2char(c)
		let [lenmatch,qual,qual1,qual2,qual3,qual4,qual5]=[len(a:msg)+2,0,'','','','','']
		for e in range(len(a:list))
			let pos=match(a:list[e],'\c'.inp)
			let thisqual=pos>-1? pos==0? inp==#a:list[e][:len(inp)-1]? inp==?a:list[e]? inp==#a:list[e]? 5 : 4 : 3 : 2 : 1 : 0
			if !thisqual | continue | en
			if thisqual>qual
				if qual | let qual{qual}.=a:list[match].' ' |en
				let [match,matchpos,qual]=[e,pos,thisqual]
			el| let qual{thisqual}.=a:list[e].' ' |en
			let lenmatch+=len(a:list[e])+1
			if lenmatch>g:maxQselsize | break|en
		endfor
		redr!
		if qual==1
			echon a:msg '(' a:list[match][:matchpos-1] ')' inp len(a:list[match])>matchpos+len(inp)
			\?'('.a:list[match][matchpos+len(inp):].') | ':' | ' qual1
		elseif qual==2
			echon a:msg inp len(a:list[match])>len(inp)?'('.a:list[match][len(inp):].') | '
			\: ' | ' qual2 qual1
		elseif qual==3
			echon a:msg inp len(a:list[match])>len(inp)?'('.a:list[match][len(inp):].') | '
			\: ' | ' qual3 qual2 qual1
		elseif qual==4
			echon a:msg inp ' | ' qual4 qual3 qual2 qual1
		elseif qual==5
			echon a:msg inp ' | ' qual5 qual4 qual3 qual2 qual1
		el| echon a:msg inp ' (No match)' |en
		let c=getchar()
	endwhile
	ec '' |redr
	let g:Qselenter=inp
	return [qual!=0? match : -1,c]
endfun

let CShst=[[0,7]]
let [CShix,SwchIx]=[0,0]
let CSgrp='Normal'
fun! CSLoad(cs)
	for k in keys(a:cs)
		exe 'hi '.k.' ctermfg='.a:cs[k][0].' ctermbg='.a:cs[k][1]
	endfor
	let g:cs_current=a:cs
endfun
fun! CompleteSwatches(Arglead,CmdLine,CurPos)
	return filter(keys(g:SWATCHES),'v:val=~a:Arglead')
endfun
fun! CompleteSchemes(Arglead,CmdLine,CurPos)
	return filter(keys(g:SCHEMES),'v:val=~a:Arglead')
endfun
fun! CSChooser(...)
	sil exe "norm! :hi \<c-a>')\<c-b>let \<right>\<right>=split('\<del>\<cr>"
	if a:0==0
		let [fg,bg]=has_key(g:cs_current,g:CSgrp)? (g:cs_current[g:CSgrp]) : g:CShst[-1]
	elseif a:0==2
		let [fg,bg]=[a:1,a:2]
		call add(g:CShst,[fg,bg])
	elseif a:0==1 && type(a:1)==1 && has_key(g:SWATCHES,a:1)
		let [fg,bg]=g:SWATCHES[a:1]
		call add(gName:CShst,[fg,bg])
	el|retu|en
	let swatchlist=keys(g:SWATCHES)
	exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg | redr
	let msg=g:CSgrp
	exe "echoh ".g:CSgrp
	ec msg fg bg
	let c=getchar()
	let continue=1
	while 1
		if has_key(g:CSChooserD,c)
			exe g:CSChooserD[c]
		el| let msg="[*]rand [fb]swatches [g]roup [hl]fg [i]nvert [jk]bg
			\ [np]history fgbg[rR]and [s]ave [S]avescheme [L]oadscheme" |en
		if continue
			if g:CShix<=len(g:CShst)-1
				let g:CShst[g:CShix]=[fg,bg]
			el| call add(g:CShst,[fg,bg])
				let g:CShix=len(g:CShst)-1 |en
			exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg |redr
			exe "echoh ".g:CSgrp
			ec msg fg bg
			let msg=g:CSgrp
			let c=getchar()
		el| if len(g:CShst)>100
				let CShst=g:CShix<25? (g:CShst[:50]) : g:CShix>75? (g:CShst[50:])
				\: g:CShst[g:CShix-25:g:CShix+25] |en
			echoh None
			return g:CShst[g:CShix] | en
	endwhile
endfun

fun! WriteVars(file)
	sil exe "norm! :let g:\<c-a>'\<c-b>\<right>\<right>\<right>\<right>v='\<cr>"
	let list=[]
	for name in split(v)  
		if name[2:]==#toupper(name[2:])	
			let type=eval("type(".name.")")
			if type>1
				call add(list,substitute("let ".name."="
				\.eval("string(".name.")"),"\n",'''."\\n".''',"g"))
				if type==4 && eval("has_key(".name.",'reinit')")
					call add(list,"call ".name.".reinit()")
				en
			en
		en
	endfor
	return writefile(list,a:file)
endfun
fun! OpenLastBackup()
	if g:Cur_Device=='cygwin'
		exe 'cd '.g:Cyg_Working_Dir
	el
		exe 'cd '.g:Working_Dir 
	en
	let modtimeL=map(range(5),'getftime("varsave".v:val)')
	let mostrecent=max(modtimeL)
	exe 'e varsave'.index(modtimeL,mostrecent)
	ec 'Last backup '.strftime("%c",mostrecent)
endfun

let g:DoWk='SMTWRFA'
fun! PrintTime(e,t) "%e crashes Windows!
	retu eval(strftime('printf("%%d%%s%%d %%d:%M %%d:%%02d ",%m,g:DoWk[%w],%d,%I,a:e/3600,a:e/60%%60)',a:t))
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

let GHprevArg=[0,1]
fun! GoHeading(indent,dir)
	let indent=(a:indent==0 && a:dir==g:GHprevArg[1])? g:GHprevArg[0] : a:indent
	let g:GHprevArg=[indent,a:dir]
	let [i,end]=[line('.'),line('$')]
	let line=getline(i)
	while ((a:dir==1 && i<end) || (a:dir==-1 && i>1))
	\&& strdisplaywidth(matchstr(line,'^\s*'))==indent && line!~'^\s*$'
		let i+=a:dir
		let line=getline(i)
	endwhile
	while ((a:dir==1 && i<end) || (a:dir==-1 && i>1))
	\&& (strdisplaywidth(matchstr(line,'^\s*'))!=indent || line=~'^\s*$')
		let i+=a:dir
		let line=getline(i)
	endwhile
	return i
endfun
nn <expr> + "\<esc>".GoHeading(&ts*v:count,1).'Gzz'
nn <expr> - "\<esc>".GoHeading(&ts*v:count,-1).'Gzz'
vn <expr> + '^'.GoHeading(&ts*v:count,1).'Gzz'
vn <expr> - '^'.GoHeading(&ts*v:count,-1).'Gzz'

fun! Ec(...)
	echoh MatchParen
	if a:0>1 && a:000[-1][-2:]=='00'
		redr| echom join(map(copy(a:000[:-2]),'string(v:val)'),'; ')
		exe 'sleep '.a:000[-1].'m'
	el| redr| echom join(map(copy(a:000),'string(v:val)'),'; ') |en
	echoh None
	return a:1
endfun

fun! EdMRU()
	let [sel,cmd]=QSel(g:MRUF,'Open: ')
	if cmd==g:EscAsc
		return
	elseif sel==-1
		exe empty(g:Qselenter)? '': 'e '.g:Qselenter | retu|en
	if cmd==22 "<c-v>
		let ro=1
		ec 'Read Only, split which direction? (CR,^L,^R,^T,^B)'
		let cmd=getchar()
	el| let ro=0 |en
	while cmd!=g:EscAsc
		if cmd==18 "<c-r>
			exe 'botright vertical '.(ro? 'sv ':'sp ').escape(g:MRUF[sel],' ')
		elseif cmd==12 "<c-l>
			exe 'topleft vertical '.(ro? 'sv ':'sp ').escape(g:MRUF[sel],' ')
		elseif cmd==20 "<c-t>
			exe 'topleft '.(ro? 'sv ':'sp ').escape(g:MRUF[sel],' ')
		elseif cmd==2 "<c-b>
			exe 'botright '.(ro? 'sv ':'sp ').escape(g:MRUF[sel],' ')
		elseif cmd==10 || cmd==13
			exe (ro? 'view ':'e ').escape(g:MRUF[sel],' ')
		elseif cmd==5
			exe 'e '.g:Qselenter
		el| ec '^E:Edit ^L:vspleft ^R:vspright ^T:sptop ^B:spbot ^V:readonly CR:edit'
			let cmd=getchar()
			continue | en
		break
	endwhile
	redr
endfun

fun! GetLbl(file)
	let name=matchstr(a:file,"[[:alnum:]][^/\\\\]*$")
	return len(name)>12 ? name[0:7]."~".name[-3:] : name
endfun
fun! InsHist(name,lnum,cnum,w0)
	if g:NoMRUsav==1 
		let g:NoMRUsav=0
	elseif !empty(a:name) && a:name!~escape($VIMRUNTIME,'\') && !isdirectory(a:name)
		cal insert(g:MRUF,a:name)
		cal insert(g:MRUL,[a:lnum,a:cnum,a:w0])
	en
endfun

fun! RemHist(file)
	let i=match(g:MRUF,'^'.a:file.'$')
	if i!=-1
		exe "norm! ".g:MRUL[i][2]."z\<cr>".(g:MRUL[i][0]>g:MRUL[i][2]? 
		\ (g:MRUL[i][0]-g:MRUL[i][2]).'j':'').g:MRUL[i][1].'|'
		cal remove(g:MRUF,i)
		cal remove(g:MRUL,i)
	en
endfun

fun! TMenu(cmd,...)
	let ec=a:0==0? eval(a:cmd.msg) : a:cmd[a:1]
	if 1+len(ec)/&columns >= &cmdheight
		let save=&cmdheight | exe 'se cmdheight='.(1+len(ec)/&columns)
			ec ec | let key=getchar() | redr!
		let &cmdheight=save
	el| ec ec
		let key=getchar()|redr! | en
	retu has_key(a:cmd,key)? a:cmd[key] : TMenu(a:cmd,'help')
endfun!
exe "nno <expr> ".opt_TmenuKey." TMenu(g:normD)"
exe "ino <expr> ".opt_TmenuKey." TMenu(g:insD)"
exe "vno <expr> ".opt_TmenuKey." TMenu(g:visD)"

cnorea <expr> we ((getcmdtype()==':' && getcmdpos()<4)? 'w\|e' :'we')
cnorea <expr> ws ((getcmdtype()==':' && getcmdpos()<4)? 'w\|so%':'ws')
cnorea <expr> wd ((getcmdtype()==':' && getcmdpos()<4)? 'w\|bd':'wd')
cnorea <expr> wsd ((getcmdtype()==':' && getcmdpos()<5)? 'w\|so%\|bd':'wsd')
cnorea <expr> bd! ((getcmdtype()==':' && getcmdpos()<5)? 'let NoMRUsav=1\|bd!':'bd!')
cnorea <expr> wa ((getcmdtype()==':' && getcmdpos()<4)? "wa\|redr\|ec (WriteVars(Working_Dir.'/saveD')==0? 'vars saved' : 'ERROR!')" :'wa')

let g:charL=[]
fun! CapWait(prev)
	call add(g:charL,a:prev)
	redr | let next=nr2char(getchar())
	if next==g:EscChar || empty(next)
		let g:charL=[]
		return "\<del>".(next==g:EscChar? "\<esc>":"")
	elseif stridx(b:CapStarters,next)!=-1
		exe 'norm! i' . next . "\<right>"
		if len(g:charL)>0 && next=='.' && g:charL[-1]=='.'
			let g:charL=[]
			return "\<del>"
		el| return CapWait(next) |en
	elseif next=='`'
		return "\<del>".TMenu(g:insD)
	elseif stridx(b:CapSeparators,a:prev)!=-1
		let g:charL=[]
		return (next=~#'[A-Z]'? tolower(next) : toupper(next)). "\<del>"
	el| let g:charL=[] 
		return next."\<del>"
	endif
endfun
fun! CapHere()
	let trunc = getline(".")[:col(".")-2] 
	return col(".")==1 ? (b:CapSeparators!=' '? CapWait("\r") : "\<del>")
	\ : (trunc=~'[?!.]\s*$\|^\s*$' && trunc!~'\.\.\s*$') ? (CapWait(trunc[-1:-1])) : "\<del>"
endfun
fun! InitCap(capnl)
	if exists('g:opt_DisableAutocap') | retu|en
	ino <buffer> <silent> <F6> <ESC>mt:call search("'",'b')<CR>x`ts
	if a:capnl==1
		let b:CapStarters=".?!\<nl>\<cr>\<tab>\<space>"
		let b:CapSeparators="\<nl>\<cr>\<tab>\<space>"
		nm <buffer> <silent> O O^<Left><C-R>=CapWait("\r")<CR>
		nm <buffer> <silent> o o^<Left><C-R>=CapWait("\r")<CR>
		nm <buffer> <silent> cc cc^<Left><C-R>=CapHere()<CR>
		nm <buffer> <silent> I I^<Left><C-R>=CapHere()<CR>
		im <buffer> <silent> <CR> <CR>^<Left><C-R>=CapWait("\r")<CR>
		im <buffer> <silent> <NL> <NL>^<Left><C-R>=CapWait("\n")<CR>
	el| let b:CapStarters=".?!\<space>"
		let b:CapSeparators="\<space>" | en
	im <buffer> <silent> . .^<Left><C-R>=CapHere()<CR>
	im <buffer> <silent> ? ?^<Left><C-R>=CapWait('?')<CR>
	im <buffer> <silent> ! !^<Left><C-R>=CapWait('!')<CR>
	nm <buffer> <silent> a a^<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> A $a^<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> i i^<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> s s^<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> cw cw^<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> C C^<Left><C-R>=CapHere()<CR>
endfun

fun! CheckFormatted()
	let options=getline(1)
	if &fdm!='manual'
		nn <buffer>	<cr> za
	en
	if options=~?'prose'
		setl noai
		call InitCap(options=~#'Prose')
		iab <buffer> i I
		iab <buffer> Id I'd
		iab <buffer> id I'd
		iab <buffer> im I'm
		iab <buffer> Im I'm

		onoremap <silent> F :call MLF()<CR>
		onoremap <silent> T :call MLT()<CR>
		onoremap <silent> f :call MLf()<CR>
		onoremap <silent> t :call MLt()<CR>
		nnoremap <silent> F :call MLnF()<CR>
		nnoremap <silent> T :call MLnT()<CR>
		nnoremap <silent> f :call MLnf()<CR>
		nnoremap <silent> t :call MLnt()<CR>
	en
	if &fo=~'a'
		nn <buffer> <silent> { :if !search('\S\n\s*.\\|\n\s*\n\s*.','Wbe')\|exe'norm!gg^'\|en<CR>
		nn <buffer> <silent> } :if !search('\S\n\\|\s\n\s*\n','W')\|exe'norm!G$'\|en<CR>
		nm <buffer> A }a
		nm <buffer> I {i
		nn <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
		nn <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
	en
endfun
nn gf :e <cWORD><cr>

fun! WriteVimState()
	echoh ErrorMsg
	if g:StartupErr=~?'error' && input("Startup errors were encountered! "
	\.g:StartupErr."\nSave settings anyways?")!~?'^y'
		retu|en
	if g:Cur_Device=='cygwin'
		exe 'cd '.g:Cyg_Working_Dir
	el
		exe 'cd '.g:Working_Dir 
	en
	let modtimeL=map(range(5),'getftime("varsave".v:val)')
	if localtime()-max(modtimeL)>86400
		call WriteVars(g:Working_Dir.'/varsave'.index(modtimeL,min(modtimeL)))
	en
	call WriteVars('saveD')
	if has("gui_running")
		let g:S_GUIFONT=&guifont |en
	"curdir is necessary to retain relative path
	se sessionoptions=winpos,resize,winsize,tabpages,folds,curdir
	if argc()
		argd *
	el
		mksession! .lastsession
	en
	if exists('g:RemoveBeforeWriteViminfo')
		sil exe '!rm '.g:Viminfo_File |en
endfun

if !exists('do_once') | let do_once=1 | el|finish|en
if !exists("g:EscChar") | let g:EscChar="\e" | let g:EscAsc=27
el|let g:EscAsc=char2nr(g:EscChar) |en
if g:EscChar!="\e"
	exe 'no <F2> '.g:EscChar
	exe 'no '.g:EscChar.' <Esc>'
   	exe 'no! '.g:EscChar.' <Esc>'
   	exe 'cno '.g:EscChar.' <C-C>' | en
if !exists('Working_Dir') || !isdirectory(glob(Working_Dir))
	cal Ec('Error: g:Working_Dir='.Working_Dir.' invalid, using '.$HOME)
	let Working_Dir=$HOME |en
for file in ['abbrev','pager','saveD']
	if filereadable(Working_Dir.'/'.file) | exe 'so '.Working_Dir.'/'.file
	el| call Ec('Error: '.Working_Dir.'/'.file.' unreadable')|en
endfor
if !argc() && isdirectory(Working_Dir)
	if Cur_Device=='cygwin'
		exe 'cd '.Cyg_Working_Dir
	el
		exe 'cd '.Working_Dir
	en
en
se viminfo=!,'120,<100,s10,/50,:500,h
if !exists('g:Viminfo_File')
	cal Ec("Error: g:Viminfo_File undefined, falling back to default")
el| exe "se viminfo+=n".g:Viminfo_File |en
if has("gui_running")
	colorscheme slate
	hi ColorColumn guibg=#222222 
	hi Vertsplit guifg=grey15 guibg=grey15
 	se guioptions-=T
	if !exists('S_GUIFONT')
		"se guifont=Envy\ Code\ R\ 10 
		se guifont=Envy_Code_R:h10 
		let S_GUIFONT=&guifont
	el| exe 'se guifont='.S_GUIFONT |en |en
if !exists('LOGDIC') | let LOGDIC=New('Log') |en
if !exists('MRUF')
	let MRUF=[]
	let MRUL=[] |en
if len(MRUF)>60
	let MRUF=MRUF[:40]
	let MRUL=MRUL[:40] |en
let NoMRUsav=0
if !exists('SWATCHES') | let SWATCHES={} |en
if !exists('SCHEMES') | let SCHEMES={'lastscheme':''} | en
if exists('opt_colorscheme')
	call CSLoad(SCHEMES[opt_colorscheme])
elseif has_key(SCHEMES,SCHEMES.lastscheme)
	call CSLoad(SCHEMES[SCHEMES.lastscheme])
el
	call CSLoad({})
en
au BufWinEnter * call RemHist(expand('%'))
au BufWinEnter * call CheckFormatted()
au BufHidden * call InsHist(expand('<afile>'),line('.'),col('.'),line('w0'))
au VimLeavePre * call WriteVimState()
se wrap linebreak sidescroll=1 ignorecase smartcase incsearch
se ai tabstop=4 history=1000 mouse=a ttymouse=xterm2 hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
se whichwrap+=b,s,h,l,<,>,~,[,] wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
se stl=\ %l.%02c/%L\ %<%f%=\ 

se fcs=vert:\  showbreak=.\  
se term=screen-256color
se so=4
if Cur_Device=='cygwin'
	let &t_ti.="\e[2 q"
	let &t_SI.="\e[6 q"
	let &t_EI.="\e[2 q"
	let &t_te.="\e[0 q"
	se noshowmode
en
redir END

if !argc() && filereadable('.lastsession')
	so .lastsession
en

fun! AdjustFontSize(k)
	let cmd=a:k
	while cmd==60 || cmd==62
		silent exe "!echo -e \"\\e]7770;".(cmd==60? "-":"+")."1\\a\" &" | redraw!
		let cmd=getchar()
	endwhile
endfun

let normD={(EscAsc):"\<esc>",(opt_TmenuAsc):opt_TmenuKey}
let normD=extend(normD,{62:":silent call AdjustFontSize(62)\<cr>",
\60:":silent call AdjustFontSize(60)\<cr>",
\122:":wa\<cr>",32:":call TODO.show()\<cr>",
\82:"R",99:":call CSChooser()\<cr>",
\114:":redi@t|sw|redi END\<cr>:!rm \<c-r>=escape(@t[1:],' ')\<cr>\<bs>*",
\80:":call IniPaint()\<cr>",108:":cal g:LOGDIC.show()\<cr>",
\107:":s/{{{\\d*\\|$/\\=submatch(0)=~'{{{'?'':'{{{1'\<cr>:invhl\<cr>",103:"vawly:h \<c-r>=@\"[-1:-1]=='('? @\":@\"[:-2]\<cr>",
\101:":call EdMRU()\<cr>",
\116:":call InvertSetting(getchar())\<cr>",
\49:":tabn1\<cr>",
\50:":tabn2\<cr>",
\51:":tabn3\<cr>",
\52:":tabn4\<cr>",
\53:":tabn5\<cr>",
\54:":tabn6\<cr>",
\55:":tabn7\<cr>",
\56:":tabn8\<cr>",
\57:":tabn9\<cr>",
\112:":tabp\<cr>",
\110:":tabn\<cr>",
\42:":,$s/\\<\<c-r>=expand('<cword>')\<cr>\\>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\35:":'<,'>s/\<c-r>=expand('<cword>')\<cr>//gc\<left>\<left>\<left>",
\'help':'<>:Font 123:buff c/olor e/dit(^R^L^T^B) g/ethelp k:center l/og n/ohl o:punchin r/mswp m/sg p/utvar s/till t:nextwin w/rap z:wa *#:sub ^w/riteroom',
\'msg':"expand('%:t').' .'.g:MRUF[0].' :'.g:MRUF[1].' .:'.g:MRUF[2].' '.line('.').'/'.line('$').' '.PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).g:LOGDIC.L[-1][1]",
\111:":call LOGDIC.111(1)\<cr>",
\115:":call LOGDIC.115()|ec PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).g:LOGDIC.L[-1][1]\<cr>"})

let insD={(EscAsc):"\<c-o>\<esc>",(opt_TmenuAsc):opt_TmenuKey}
let insD=extend(insD,{105:":call InvertSetting(getchar())\<cr>",
\97:"\<c-o>:call SoftCapsLock()\<cr>",
\103:"\<c-r>=getchar()\<cr>",
\113:"\<c-o>\<esc>",111:"\<c-r>=input('`o','','customlist,CmpMRU')\<cr>",
\110:"\<c-o>:noh\<cr>",
\107:"\<esc>:s/{{{\\d*\\|$/\\=submatch(0)=~'{{{'?'':'{{{1'\<cr>:invnohl\<cr>",
\102:"\<c-r>=escape(expand('%'),' ')\<cr>",119:"\<c-o>\<c-w>\<c-w>",
\'help':'123:buff f/ilename g/etchar k:center o/pen w/indow:',
\'msg':"expand('%:t').' .'.g:MRUF[0].' :'.g:MRUF[1].' .:'.g:MRUF[2].' '
\.line('.').'/'.line('$').' '.PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).g:LOGDIC.L[-1][1]"})

let visD={(g:EscAsc):"",(g:opt_TmenuAsc):g:opt_TmenuKey}
let g:visD=extend(visD,{42:"y:,$s/\\V\<c-r>=@\"\<cr>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\99:":ce\<cr>",
\120:"y: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>",
\103:"y:\<c-r>\"",
\'help':'*:sub c/enter e/dit g/et2cmd u/nformat x/ec',
\101:"y:e \<c-r>\"\<cr>",117:":s/ \\n/ /\<cr>",
\67:"\"*y:let @*=substitute(@*,\" \\n\",' ','g')\<cr>",
\'msg':"expand('%:t').' '.line('.')
\.'/'.line('$').' '.(exists(\"g:LOGDIC\")? PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).g:LOGDIC.L[-1][1] : \"\")"})

let CSChooserD={113:"let continue=0 | if has_key(g:cs_current,g:CSgrp)
\|exe 'hi '.g:CSgrp.' ctermfg='.(g:cs_current[g:CSgrp][0]).' ctermbg='.(g:cs_current[g:CSgrp][1]) |en",
\(g:EscAsc):"let continue=0 | if has_key(g:cs_current,g:CSgrp)
\|exe 'hi '.g:CSgrp.' ctermfg='.(g:cs_current[g:CSgrp][0]).' ctermbg='.(g:cs_current[g:CSgrp][1]) |en",
\10: "let continue=0 | exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg
\|let g:cs_current[g:CSgrp]=[fg,bg]",
\13: "let continue=0 | exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg
\|let g:cs_current[g:CSgrp]=[fg,bg]",
\104:'let [fg,g:CShix]=fg>0?   [fg-1,g:CShix+1] : [fg,g:CShix]',
\108:'let [fg,g:CShix]=fg<255? [fg+1,g:CShix+1] : [fg,g:CShix]',
\106:'let [bg,g:CShix]=bg>0?   [bg-1,g:CShix+1] : [bg,g:CShix]',
\107:'let [bg,g:CShix]=bg<255? [bg+1,g:CShix+1] : [bg,g:CShix]',
\98: 'let g:CShix+=1 | let g:SwchIx=g:SwchIx>0? g:SwchIx-1 : len(swatchlist)-1 |
\let [fg,bg]=g:SWATCHES[swatchlist[g:SwchIx]] | let msg.=" ".swatchlist[g:SwchIx]',
\102:'let g:CShix+=1 | let g:SwchIx=g:SwchIx<len(swatchlist)-1? g:SwchIx+1 : 0 |
\let [fg,bg]=g:SWATCHES[swatchlist[g:SwchIx]] | let msg.=" ".swatchlist[g:SwchIx]',
\112:'if g:CShix > 0 | let g:CShix-=1 | let [fg,bg]=g:CShst[g:CShix] | en',
\110:'if g:CShix<len(g:CShst)-1|let g:CShix+=1|let [fg,bg]=g:CShst[g:CShix]|en',
\42: 'let [fg,bg,g:CShix]=[reltime()[1]%256,reltime()[1]%256,g:CShix+1]',
\114:'let [fg,g:CShix]=[reltime()[1]%256,g:CShix+1]',
\82: 'let [bg,g:CShix]=[reltime()[1]%256,g:CShix+1]',
\105:'let [fg,bg]=[bg,fg]',
\103:'let [in,cmd]=QSel(hi,"Group: ")|if in!=-1 && cmd!=g:EscAsc|
\if has_key(g:cs_current,hi[in]) | let [fg,bg]=g:cs_current[hi[in]]|en|
\if has_key(g:cs_current,g:CSgrp) | 
\exe "hi ".g:CSgrp." ctermfg=".(g:cs_current[g:CSgrp][0])." ctermbg=".(g:cs_current[g:CSgrp][1])
\| en | let g:CSgrp=hi[in] | let msg=g:CSgrp | en',
\115:'let name=input("Save swatch as: ","","customlist,CompleteSwatches") |
\if !empty(name) | let g:SWATCHES[name]=[fg,bg] |en',
\83:'let name=input("Save scheme as: ",g:SCHEMES.lastscheme,"customlist,CompleteSchemes") | if !empty(name) | let g:SCHEMES[name]=g:cs_current | let g:SCHEMES.lastscheme=name | en | let continue=0',
\76:'let schemek=keys(g:SCHEMES) | let [in,cmd]=QSel(schemek,"scheme: ")|if in!=-1 && cmd!=g:EscAsc | let g:cs_current=g:SCHEMES[schemek[in]] | call CSLoad(g:cs_current) | let g:SCHEMES.lastscheme=schemek[in] | en | let continue=0'}

"Added changelog
"Added shortcuts to log functions in normD command
"Fixed menu history bug in pager
"Added gliding touch scrolling
"Added y emulation to cmdnorm
"Changed cmdnorm to exit on Esc rather than Q
"Fixed scrolling in folded texts via winline()
"Removed Center function: already implemented as :ce
"Explore no longer interacts with history
"remap center as `k, add line feed
"fixed c-r / s-r confusion
"longpress to toggle fold
"seamless way to deal with end of document scrolling
"have logappend calculate offset (for normal mode appends)
"invisible horizontal scrollbar on bottom
"no autocap on elipse
"yank for nested
"reading mode: remember offset
"long press to go to link
"Reformat folding, remove reading mode autocommands
"longpresses are activated on timeout
"fixed wacky log time display
"fixed cmdnorm cursor sticking around
"single esc to get out of autocap, use uppercase to avoid transformation
"synergize autocap and tmenu
"no new line autocap if option not set
"change log visualizations to pagers
"add T/op function to all pagers
"pager constructor can now set cursor / offset
"add option to hide numbers on pager (default)
"changed folding to marker (from expr)
"fully swap g, gj, k, gk
"backspace / esc bug for autocap
"synergize mouse scrolling and statusline / split dragging
"changed fold to display line number
"editmru now edits input if no match was found
"log histogram accounts for current task
"combined histogram & printlog
"shownum, default statusline for pager
"separate histogram mode and chart mode
"shortcut for se invwrap
"included day of week in date display
"fixed viminfo bug (&vi was being reset to default)
"changed seach hl quick command to toggle
"changed foldtext to display custom marks
"cleared args before mksession to prevent unnecessary file loading
"curdevice for device specific settings
"changed tmenu trigger to _
"changed autocap cursor to ^
"added option to [S]ave and [L]oad color schemes
"last scheme name default entry for load color scheme
"change color chooser from C to c
"use /f to automcomplete {{{
"added () to distinguish folds, removed fold centering
"variable maxQselsize for Qsel list length
"added cygwin customizations (must define Cyg_Working_Dir... confusing as hell)
"Writeroom(margin) function for wide screens
"Mapped normal c-n c-p to search for folds
"opt_DisableAutocap added
"Changed Writeroom to take percentage
"Autoexit after saving a color scheme
"added ^W to activate writeroom in normD
"moved device-dependent settings to main vimrc file
"Cygwin: added ^C and ^V (clipboard) visual mode bindings
"added u/nformat to visD
"autoexit after loading a color scheme
"Cygwin: Cursor changes shape based on mode
"Cygwin: innoremap escape to escape-escape to prevent delay
"set nocompatible to avoid absurd errors
"notepad mode (set Cur_RunAs='notepad') with ^W ^S nmaps
"added option to set colorscheme (set opt_colorscheme), eliminated unnecessary persistent vars
"`il `iw for invlist, invwrap in normal / insert mode
"mutline fFtT for prose
"Eliminate longpress to expand folds for Cygwin by setting opt_LongPressTimeout
"Mouse now continues scrolling even for low timeouts if there is no fold or no jump under cursor
"mintty: `< anc `> to adjust font size
"no Mscroll for cygwin
"added `C to visD to copy and unwrap lines
"CheckFormatted: set wrap and autoformat options to execute after loading modelines, simplifying detection
"streamlined opt_TenuKey to change keymenu  
"cygwin: set timeoutlen=1 to avoid delay when exiting insert mode
"software caps lock for insert mode via `a
"TD: Command to jump to previous cursor position?
"Middle click to close split or tab
"added `it `is to toggle tab bar and status line
"updated visual `x to work on all lines
"added <space> and <bs> as pgdown / pgup
"`tb to tggle bookmark visibility
"remapped arrow keys to alt-hjkl
