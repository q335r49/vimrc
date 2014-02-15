se nocompatible
redir => g:StartupErr

fun! InsHist(name,lnum,cnum,w0)
	if !empty(a:name) && a:name!~escape($VIMRUNTIME,'\') && !isdirectory(a:name)
		let g:MRUF[a:name]=[a:lnum,a:cnum,a:w0,localtime()]
	en
endfun
fun! LoadLastEdit(file)
	let pos=get(g:MRUF,a:file,[])
	if !empty(pos)
		exe "norm! ".pos[2]."z\<cr>".(pos[0]>pos[2]? (pos[0]-pos[2]).'j':'').pos[1].'|'
	en
endfun
fun! PruneHistory(num)
	if len(g:MRUF)<a:num+20
		return | en
	let keys=keys(g:MRUF)
	let cutoff=sort(map(copy(keys),"g:MRUF[v:val][3]"))[a:num]
	for i in keys
		if g:MRUF[i]>cutoff	
			unlet MRUF[i]
		en
	endfor
endfun

if !exists("firstrun") | let firstrun=1 | en

if !exists("g:EscChar") | let g:EscChar="\e" | let g:EscAsc=27
el | let g:EscAsc=char2nr(g:EscChar) |en
if g:EscChar!="\e"
	exe 'no <F2> '.g:EscChar
	exe 'no '.g:EscChar.' <Esc>'
   	exe 'no! '.g:EscChar.' <Esc>'
   	exe 'cno '.g:EscChar.' <C-C>'
en

nno <space> <c-e>
nno <backspace> <c-y>
nno <c-i> <c-y>

let opt_autocap=0
if !exists('opt_device')
	echom "Warning: opt_device is undefined, device specific settings will not be loaded."
	let opt_device=''
en
if opt_device=~?'cygwin'
	se timeout ttimeout timeoutlen=100 ttimeoutlen=100
	cno <c-h> <left>
	cno <c-j> <down>
	cno <c-k> <up>
	cno <c-l> <right>
	vno <c-c> "*y
	vno <c-v> "*p
	ino <c-_> <c-w>
	nno <c-_> db
	let opt_LongPressTimeout=[99999,99999]
	let opt_TmenuKey="`"
	let Viminfo_File='~/.viminfo'
	let Cyg_Working_Dir= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings'
	let Working_Dir= 'C:/Users/q335r49/Desktop/Dropbox/q335writings'
	let EscChar="\e"
en
if opt_device=~?'notepad'
	se noswapfile
	nno <c-s> :wa<cr>			
	nno <c-w> :wqa<cr>
	nno <c-v> "*p
	nno <c-q> <c-v> 
	let opt_colorscheme='notepad'
en
if opt_device=~?'droid4'
	let opt_autocap=1
	ino <c-b> <c-w>
	se timeout ttimeout timeoutlen=100 ttimeoutlen=100
	let opt_TmenuKey="_"
	let opt_LongPressTimeout=[0,500000]
	nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (Mscroll()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
	let opt_colorscheme='d4-default'
	nn R <c-r>
	nn <c-r> <nop>
en
if empty(opt_device)
	nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (Mscroll()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
	let opt_TmenuKey="`"
	let opt_LongPressTimeout=[0,500000]
en
let opt_TmenuAsc=char2nr(opt_TmenuKey)

if has('signs') "{{{
sign define scrollbox texthl=Visual text=[]
fun! ScrollbarGrab()
	if getchar()=="\<leftrelease>" || v:mouse_col!=1
		return|en
 	while getchar()!="\<leftrelease>"
		let pos=1+(v:mouse_lnum-line('w0'))*line('$')/winheight(0)
		call cursor(pos,1)
		sign unplace 789
		exe "sign place 789 line=".(pos*winheight(0)/line('$')+line('w0')).b:scrollexpr
	endwhile
endfun
fun! UpdateScrollbox()
	sign unplace 789
	exe "sign place 789 line=".(line('w0')*winheight(0)/line('$')+line('w0')).b:scrollexpr
endfun
fun! ToggleScrollbar()
	if exists('b:opt_scrollbar')
		unlet b:opt_scrollbar
		nun <buffer> <leftmouse>
		iun <buffer> <leftmouse>
		nun <buffer> <scrollwheelup>
		nun <buffer> <scrollwheeldown>
		iun <buffer> <scrollwheelup>
		iun <buffer> <scrollwheeldown>
		exe "sign unplace 789 file=" . expand("%:p")
		exe "sign unplace 788 file=" . expand("%:p")
	el
		let b:opt_scrollbar=1
		nno <silent> <buffer> <leftmouse> <leftmouse>:call ScrollbarGrab()<cr>
		ino <silent> <buffer> <leftmouse> <leftmouse><c-o>:call ScrollbarGrab()<cr>
		nno <buffer> <scrollwheelup> <scrollwheelup>:call UpdateScrollbox()<cr>
		nno <buffer> <scrollwheelup> <scrollwheelup>:call UpdateScrollbox()<cr>
		nno <buffer> <scrollwheeldown> <scrollwheeldown>:call UpdateScrollbox()<cr>
		ino <buffer> <scrollwheelup> <scrollwheelup><c-o>:call UpdateScrollbox()<cr>
		ino <buffer> <scrollwheeldown> <scrollwheeldown><c-o>: call UpdateScrollbox()<cr>
		let b:scrollexpr=" name=scrollbox file=".expand("%:p")
		exe "sign place 789 line=".(line('w0')*winheight(0)/line('$')+line('w0')).b:scrollexpr
		exe "sign place 788 line=1".b:scrollexpr
	en
endfun
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
en "}}}

function! SafeSearchCommand(line1, line2, theCommand)
  let search = @/
  execute a:line1 . "," . a:line2 . a:theCommand
  let @/ = search
endfunction
com! -range -nargs=+ SS call SafeSearchCommand(<line1>, <line2>, <q-args>)
com! -range -nargs=* S call SafeSearchCommand(<line1>, <line2>, 's' . <q-args>)

nn j gj
nn k gk
let gnmap=map(range(256),'"g".nr2char(v:val)')
let gvmap=copy(gnmap)
let gnmap[112]=":exe 'norm! `['.strpart(getregtype(), 0, 1).'`]'\<cr>"
let gnmap[106]='j'
let gnmap[107]='k'
let gnmap[36]="G:call search('^.*\\S.*$','Wcb')\<cr>"
let gnmap[65]="A"
let gnmap[123]="{"
let gnmap[125]="}"
let gvmap[85]=":S/\\<\\(\\w\\)\\(\\w*\\)\\>/\\u\\1\\L\\2/g\<cr>"
let gvmap[112]="\<esc>:call search('\\S\\n\\s*.\\|\\n\\s*\\n\\s*.\\|\\%^','Wbe')\<cr>m<:call search('\\S\\n\\|\\s\\n\\s*\\n\\|\\%$','W')\<cr>m>gv"
nn <expr> g gnmap[getchar()]
vn <expr> g gvmap[getchar()]

nno <MiddleMouse> <LeftMouse>:q<cr>

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

let lastft='f'
let lastftchar=32
fun! MLT(char)
	let g:lastftchar=a:char
    if search('\C\V'.nr2char(a:char),'bW')
        norm! l
    endif
	return 'T'
endfun
fun! MLF(char)
	let g:lastftchar=a:char
    call search('\C\V'.nr2char(a:char),'bW')
	return 'F'
endfun
fun! MLf(char)
	let g:lastftchar=a:char
    if search('\C\V'.nr2char(a:char),'W')
        norm! l
    endif
	return 'f'
endfun
fun! MLt(char)
	let g:lastftchar=a:char
    call search('\C\V'.nr2char(a:char),'W')
	return 't'
endfun
fun! MLnT(char)
	let g:lastftchar=a:char
    if search('\C\V'.nr2char(a:char),'bW')
        norm! l
    endif
	return 'T'
endfun
fun! MLnF(char)
	let g:lastftchar=a:char
    call search('\C\V'.nr2char(a:char),'bW')
	return 'F'
endfun
fun! MLnt(char)
	let g:lastftchar=a:char
    if search('\C\V'.nr2char(a:char),'W')
        norm! h
    endif
	return 't'
endfun
fun! MLnf(char)
	let g:lastftchar=a:char
    call search('\C\V'.nr2char(a:char),'W')
	return 'f'
endfun

nno <c-p> :call GotoPreviousFold()<cr>
nno <c-n> :call GotoNextFold()<cr>
fun! GotoPreviousFold()
	call search('{{{','bW')	
endfun
fun! GotoNextFold()
	call search('{{{','W')	
endfun

exe "ab /f {{{\<cr>\<cr>\<cr>\}}}\<esc>3k$a\<c-o>"

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

let CShst=[[0,7]]
let [CShix,SwchIx]=[0,0]
let CSgrp='Normal'
fun! CSLoad(...)
	if a:0!=0
		for k in keys(a:1)
			exe 'hi '.k.' ctermfg='.a:cs[k][0].' ctermbg='.a:1[k][1]
		endfor
		let g:SCHEMES.current=deepcopy(a:1)
	el
		for k in keys(g:SCHEMES.current)
			exe 'hi '.k.' ctermfg='.g:SCHEMES.current[k][0].' ctermbg='.g:SCHEMES.current[k][1]
		endfor
	en
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
		let [fg,bg]=get(g:SCHEMES.current,g:CSgrp,g:CShst[-1])
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
		exe get(g:CSChooserD,c,'let msg="[*]rand [fb]swatches [g]roup [hl]fg [i]nvert [jk]bg [np]history fgbg[rR]and [s]ave [S]avescheme [L]oadscheme"')
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

fun! WriteVars(...)
	sil exe "norm! :let g:\<c-a>'\<c-b>\<right>\<right>\<right>\<right>v='\<cr>"
	let list=[]
	for name in split(v)  
		if name[2:]==#toupper(name[2:])	
			let type=eval("type(".name.")")
			if type>1
				call add(list,substitute("let ".name."=".eval("string(".name.")"),"\n",'''."\\n".''',"g"))
				if type==4 && eval("has_key(".name.",'reinit')")
					call add(list,"call ".name.".reinit()")
				en
			en
		en
	endfor
	return map(copy(a:000),'writefile(list,escape(v:val," "))')
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

fun! Ec(...)
	echoh MatchParen
	if a:0>1 && a:000[-1][-2:]=='00'
		redr| echom join(map(copy(a:000[:-2]),'string(v:val)'),'; ')
		exe 'sleep '.a:000[-1].'m'
	el| redr| echom join(map(copy(a:000),'string(v:val)'),'; ') |en
	echoh None
	return a:1
endfun

let g:opt_defaultch=1
fun! JustEcho(str)
	let &ch=max([len(a:str)/&columns+1,&ch]) 
	redr!
	ec a:str
endfun!

fun! TMenu(cmd)
	exe a:cmd.msg
	let [c,&ch]=[getchar(),g:opt_defaultch]
	return get(a:cmd, c, a:cmd.default)
endfun!
exe "nno <expr> ".opt_TmenuKey." TMenu(g:normD)"
exe "ino <expr> ".opt_TmenuKey." TMenu(g:insD)"
exe "vno <expr> ".opt_TmenuKey." TMenu(g:visD)"

cnorea <expr> we ((getcmdtype()==':' && getcmdpos()<4)? 'w\|e' :'we')
cnorea <expr> ws ((getcmdtype()==':' && getcmdpos()<4)? 'w\|so%':'ws')
cnorea <expr> wd ((getcmdtype()==':' && getcmdpos()<4)? 'w\|bd':'wd')
cnorea <expr> wsd ((getcmdtype()==':' && getcmdpos()<5)? 'w\|so%\|bd':'wsd')

let ftfuncD={"f":function("MLf"),
\"t":function("MLt"),
\"F":function("MLF"),
\"T":function("MLT"),
\"nf":function("MLnf"),
\"nt":function("MLnt"),
\"nF":function("MLnF"),
\"nT":function("MLnT")}
let invftD={"f":"F",
\"F":"f",
\"t":"T",
\"T":"t",
\"nf":"nF",
\"nt":"nT",
\"nF":"nf",
\"nT":"nt"}
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
fun! CheckFormatted()
	let options=getline(1)
	if &fdm!='manual'
		nn <buffer>	<cr> za
	en
	if options=~?'prose'
		setl noai
		ino <buffer> <silent> <F6> <ESC>mt:call search("'",'b')<CR>x`ts
		if options=~#'Prose' && g:opt_autocap
			let b:CapStarters=".?!\<nl>\<cr>\<tab>\<space>"
			let b:CapSeparators="\<nl>\<cr>\<tab>\<space>"
			nm <buffer> <silent> O O^<Left><C-R>=CapWait("\r")<CR>
			nm <buffer> <silent> o o^<Left><C-R>=CapWait("\r")<CR>
			nm <buffer> <silent> cc cc^<Left><C-R>=CapHere()<CR>
			nm <buffer> <silent> C C^<Left><C-R>=CapHere()<CR>
			nm <buffer> <silent> I I^<Left><C-R>=CapHere()<CR>
			im <buffer> <silent> <CR> <CR>^<Left><C-R>=CapWait("\r")<CR>
			im <buffer> <silent> <NL> <NL>^<Left><C-R>=CapWait("\n")<CR>
		el| let b:CapStarters=".?!\<space>"
			let b:CapSeparators="\<space>" | en
		if g:opt_autocap
			im <buffer> <silent> . .^<Left><C-R>=CapHere()<CR>
			im <buffer> <silent> ? ?^<Left><C-R>=CapWait('?')<CR>
			im <buffer> <silent> ! !^<Left><C-R>=CapWait('!')<CR>
			nm <buffer> <silent> a a^<Left><C-R>=CapHere()<CR>
			nm <buffer> <silent> A $a^<Left><C-R>=CapHere()<CR>
			nm <buffer> <silent> i i^<Left><C-R>=CapHere()<CR>
			nm <buffer> <silent> s s^<Left><C-R>=CapHere()<CR>
			nm <buffer> <silent> cw cw^<Left><C-R>=CapHere()<CR>
			nm <buffer> <silent> C C^<Left><C-R>=CapHere()<CR>
		en
		iab <buffer> i I
		iab <buffer> Id I'd
		iab <buffer> id I'd
		iab <buffer> im I'm
		iab <buffer> Im I'm
		ono <buffer> <silent> F :let g:lastft=MLF(getchar())<cr>
		ono <buffer> <silent> T :let g:lastft=MLT(getchar())<cr>
		ono <buffer> <silent> f :let g:lastft=MLf(getchar())<cr>
		ono <buffer> <silent> t :let g:lastft=MLt(getchar())<cr>
		nn <buffer> <silent> F :let g:lastft=MLnF(getchar())<cr>
		nn <buffer> <silent> T :let g:lastft=MLnT(getchar())<cr>
		nn <buffer> <silent> f :let g:lastft=MLnf(getchar())<cr>
		nn <buffer> <silent> t :let g:lastft=MLnt(getchar())<cr>
		nn <buffer> <silent> ; :let g:lastft=g:ftfuncD["n".g:lastft](g:lastftchar)<cr>
		nn <buffer> <silent> , :let g:lastft=g:invftD[g:ftfuncD[g:invftD["n".g:lastft]](g:lastftchar)]<cr>
		ono <buffer> <silent> ; :let g:lastft=g:ftfuncD[g:lastft](g:lastftchar)<cr>
		ono <buffer> <silent> , :let g:lastft=g:invftD[g:ftfuncD[g:invftD[g:lastft]](g:lastftchar)]<cr>
	en
	if &fo=~#'a'
		nn <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
		nn <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
		if &fo=~#'w'	
			nn <buffer> <silent> { :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>
			nn <buffer> <silent> } :call search('\S\n\\|\s\n\s*\n\\|\%$','W')<CR>
			nn <buffer> <silent> I :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>i
			nn <buffer> <silent> A :call search('\S\n\\|\s\n\s*\n\\|\%$','W')<CR>a
		else
			nn <buffer> <silent> I :call search('^\s*\n\s*\S\\!\%^','Wbec')<CR>i
			nn <buffer> <silent> A :call search('\S\s*\n\s*\n\\|\%$','Wc')<CR>a
		en
	en
endfun

fun! WriteVimState()
	echoh ErrorMsg
	if g:StartupErr=~?'error' && input("Startup errors were encountered! "
	\.g:StartupErr."\nSave settings anyways?")!~?'^y'
		retu|en
	if g:opt_device=~?'cygwin'
		exe 'cd '.g:Cyg_Working_Dir
	el
		exe 'cd '.g:Working_Dir 
	en
	if filereadable('vars'.strftime("%y%m%d"))
		call WriteVars('vars')
	el
		call WriteVars('vars','vars'.strftime("%y%m%d"))
	en
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

if !firstrun
	finish|en
if !exists('Working_Dir') || !isdirectory(glob(Working_Dir))
	cal Ec('Error: g:Working_Dir='.Working_Dir.' invalid, using '.$HOME)
	let Working_Dir=$HOME |en
for file in ['abbrev','pager','vars']
	if filereadable(Working_Dir.'/'.file) | exe 'so '.Working_Dir.'/'.file
	el| call Ec('Error: '.Working_Dir.'/'.file.' unreadable')|en
endfor
if !argc() && isdirectory(Working_Dir)
	if opt_device=~?'cygwin'
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
	let MRUF={}
en
call PruneHistory(60)
if !exists('SWATCHES') | let SWATCHES={} |en
if !exists('SCHEMES') | let SCHEMES={'lastscheme':{}} | en
hi clear tabline
if exists('opt_colorscheme') && has_key(SCHEMES,opt_colorscheme)
	call CSLoad(SCHEMES[opt_colorscheme])
else
	call CSLoad()
en
au BufLeave * call InsHist(expand('<afile>'),line('.'),col('.'),line('w0'))
au BufWinEnter * call LoadLastEdit(expand('%')) 
au BufWinEnter * call CheckFormatted()
au VimLeavePre * call WriteVimState()
se nowrap linebreak sidescroll=1 ignorecase smartcase incsearch
se ai tabstop=4 history=1000 mouse=a ttymouse=xterm2 hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
se whichwrap+=b,s,h,l,<,>,~,[,] wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
se stl=\ %l.%02c/%L\ %<%f%=\ 

se fcs=vert:\  showbreak=.\  
se term=screen-256color
if opt_device=~?'cygwin'
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

let invertD={'msg':"call JustEcho((exists('b:bookmarks_shown')? '+' : ''). '[b]ookmarks '.(exists('b:opt_scrollbar')? '+':'').'Scroll[B]ar '.(&hls? '+':'').'[h]lsearch '.(&list? '+':'').'[l]ist '.(&number? '+':'').'[n]umber '.(&ls!=0? '+':'').'[s]tatusl '.(&spell? '+':'').'[S]pell '.(&stal? '+':'').'[t]abl '.(!empty(&ve)? '+':'').'[v]irtualedit '.(&wrap? '+':'').'[w]rap '.(winwidth(0)!=&columns? '+':'').'[W]riteroom')",
\'default':"call JustEcho('Undefined command.')",
\119:'se invwrap',
\104:'se invhls',
\108:'se invlist',
\116:'let &showtabline=!&showtabline',
\115:'let &ls=&ls>1? 0:2',
\110:'se invnumber',
\87:'if winwidth(0)==&columns | silent call Writeroom(exists(''g:OPT_WRITEROOMWIDTH'')? g:OPT_WRITEROOMWIDTH : 25) | else | only | en',
\118:'if empty(&ve) | se ve=all | el | se ve= | en',
\83:'se invspell'}
if has('signs')
	let invertD[66]='call ToggleScrollbar()'
	let invertD[99]='call ToggleBookmarks()'
en

let normD={'default':":ec '[123]tabs [c]olor [e]dit(^R^L^T^B) [g]ethelp [k]center [l]og [o]:punchin [r]mswp [m]sg [s]till [X]ecPara [z]:wa [*#]:sub'\<cr>",
\122:":wa\<cr>",32:":call TODO.show()\<cr>",
\82:"R",99:":call CSChooser()\<cr>",
\114:":redi@t|sw|redi END\<cr>:!rm \<c-r>=escape(@t[1:],' ')\<cr>\<bs>*",
\80:":call IniPaint()\<cr>",108:":cal g:LOGDIC.show()\<cr>",
\107:":s/{{{\\d*\\|$/\\=submatch(0)=~'{{{'?'':'{{{1'\<cr>:invhl\<cr>",103:"vawly:h \<c-r>=@\"[-1:-1]=='('? @\":@\"[:-2]\<cr>",
\101:":call EdMRU()\<cr>",
\72:":call New('RecentFiles').show()\<cr>",
\9:":exe TMenu(g:invertD)\<cr>",
\49:":tabn1\<cr>",
\50:":tabn2\<cr>",
\51:":tabn3\<cr>",
\52:":tabn4\<cr>",
\53:":tabn5\<cr>",
\54:":tabn6\<cr>",
\55:":tabn7\<cr>",
\56:":tabn8\<cr>",
\57:":tabn9\<cr>",
\"\<f1>":":tabp\<cr>",
\"\<f2>":":tabn\<cr>",
\42:":,$s/\\<\<c-r>=expand('<cword>')\<cr>\\>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\35:":'<,'>s/\<c-r>=expand('<cword>')\<cr>//gc\<left>\<left>\<left>",
\'msg':"call JustEcho(PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).line('.').'/'.line('$').' '.g:LOGDIC.L[-1][1])",
\111:":call LOGDIC.111(1)\<cr>",
\115:":call LOGDIC.115()|ec PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).g:LOGDIC.L[-1][1]\<cr>",
\88:"vipy: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>"}
let normD[EscAsc]="\<esc>"
let normD[opt_TmenuAsc]=opt_TmenuKey

let insD={9:"\<c-o>:exe TMenu(g:invertD)\<cr>",
\'default':"\<c-o>:ec '123:buff f/ilename g/etchar k:center w/indow:'\<cr>",
\97:"\<c-o>:call SoftCapsLock()\<cr>",
\103:"\<c-r>=getchar()\<cr>",
\113:"\<c-o>\<esc>",
\110:"\<c-o>:noh\<cr>",
\107:"\<esc>:s/{{{\\d*\\|$/\\=submatch(0)=~'{{{'?'':'{{{1'\<cr>:invnohl\<cr>",
\102:"\<c-r>=escape(expand('%'),' ')\<cr>",119:"\<c-o>\<c-w>\<c-w>",
\'msg':"call JustEcho(PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).line('.').'/'.line('$').' '.g:LOGDIC.L[-1][1])"}
let insD[EscAsc]="\<c-o>\<esc>"
let insD[opt_TmenuAsc]=opt_TmenuKey

let g:visD={42:"y:,$s/\\V\<c-r>=@\"\<cr>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\'default':":\<c-w>ec '*:sub c/enter e/dit g/et2cmd u/nformat x/ec'",
\120:"y: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>",
\103:"y:\<c-r>\"",
\101:"y:e \<c-r>\"\<cr>",117:":s/ \\n/ /\<cr>",
\67:"\"*y:let @*=substitute(@*,\" \\n\",' ','g')\<cr>",
\'msg':"call JustEcho(expand('%:t').' '.line('.').'/'.line('$').' '.(exists(\"g:LOGDIC\")? PrintTime(localtime()-g:LOGDIC.L[-1][0],localtime()).g:LOGDIC.L[-1][1] : \"\"))",
\99:":\<c-w>call ChangeCase()\<cr>"}
let visD[EscAsc]=""
let visD[opt_TmenuAsc]=opt_TmenuKey

let CSChooserD={113:"let continue=0 | if has_key(g:SCHEMES.current,g:CSgrp)
\|exe 'hi '.g:CSgrp.' ctermfg='.(g:SCHEMES.current[g:CSgrp][0]).' ctermbg='.(g:SCHEMES.current[g:CSgrp][1]) |en",
\(g:EscAsc):"let continue=0 | if has_key(g:SCHEMES.current,g:CSgrp)
\|exe 'hi '.g:CSgrp.' ctermfg='.(g:SCHEMES.current[g:CSgrp][0]).' ctermbg='.(g:SCHEMES.current[g:CSgrp][1]) |en",
\10: "let continue=0 | exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg
\|let g:SCHEMES.current[g:CSgrp]=[fg,bg]",
\13: "let continue=0 | exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg
\|let g:SCHEMES.current[g:CSgrp]=[fg,bg]",
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
\103:"let in=input('Group: ','','highlight')\n
\if has_key(g:SCHEMES.current,in)\n
\     let [fg,bg]=g:SCHEMES.current[in]\n
\en\n
\if has_key(g:SCHEMES.current,g:CSgrp)\n
\    exe 'hi '.g:CSgrp.' ctermfg='.(g:SCHEMES.current[g:CSgrp][0]).' ctermbg='.(g:SCHEMES.current[g:CSgrp][1])\n
\en\n
\let g:CSgrp=in\n
\let msg=g:CSgrp",
\115:'let name=input("Save swatch as: ","","customlist,CompleteSwatches") |
\if !empty(name) | let g:SWATCHES[name]=[fg,bg] |en',
\83:'let name=input("Save scheme as: ","","customlist,CompleteSchemes") | if !empty(name) | let g:SCHEMES[name]=deepcopy(g:SCHEMES.current) | en | let continue=0',
\76:"let in=get(g:SCHEMES,input('Load scheme: ','','customlist,CompleteSchemes'),{})\n
\if !empty(in)\n
\    call CSLoad(in)\n
\en\n
\let continue=0"}

let firstrun=0
