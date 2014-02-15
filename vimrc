redir => g:StartupErr

fun! QSel(list,msg)
	let [inp,c]=['','']
	while c!=g:EscAsc && c!=10 && c!=13
		let inp=c=="\<bs>"? inp[:-2] : inp.nr2char(c)
		let [lenmatch,qual,qual1,qual2,qual3]=[len(a:msg)+2,0,'','','']
		for e in range(len(a:list))
			let pos=match(a:list[e],'\c'.inp)
			let thisqual=pos>-1? pos==0? inp==#a:list[e][:len(inp)-1]? 3 : 2 : 1 : 0
			if !thisqual | continue | en
			if thisqual>qual
				if qual
					let qual{qual}.=a:list[match].' '
				let [match,matchpos,qual]=[e,pos,thisqual]
			el| let qual{thisqual}.=a:list[e].' ' |en
			let lenmatch+=len(a:list[e])+1
			if lenmatch>2*&columns | break|en
		endfor
		redr!
		if qual==1
			echon a:msg '(' a:list[match][:matchpos-1] ')' inp len(a:list[match])>matchpos+len(inp)
			\?'('.a:list[match][matchpos+len(inp):].') _ ':' _ ' qual1[len(a:list[match])+1:]
		elseif qual==2
			echon a:msg inp len(a:list[match])>len(inp)?'('.a:list[match][len(inp):].') _ '
			\: ' _ ' qual2[len(a:list[match])+1:] qual1
		elseif qual==3
			echon a:msg inp len(a:list[match])>len(inp)?'('.a:list[match][len(inp):].') _ '
			\: ' _ ' qual3[len(a:list[match])+1:] qual2 qual1
		el| echon a:msg inp ' (No match)' |en
		let c=getchar()
	endwhile
	ec '' |redr
	return c==g:EscAsc? -1 : qual? match : -1
endfun

let CShst=[[0,7]]
let [CShix,SwchIx]=[0,0]
let CSgrp='Normal'
fun! CSLoad(cs)
	for k in keys(a:cs)
		exe 'hi '.k.' ctermfg='.a:cs[k][0].' ctermbg='.a:cs[k][1]
	endfor
endfun
fun! CompleteSwatches(Arglead,CmdLine,CurPos)
	return filter(keys(g:SWATCHES),'v:val=~a:Arglead')
endfun
fun! CSChooser(...)
	sil exe "norm! :hi \<c-a>')\<c-b>let \<right>\<right>=split('\<del>\<cr>"
	if a:0==0
		let [fg,bg]=has_key(g:CURCS,g:CSgrp)? (g:CURCS[g:CSgrp]) : g:CShst[-1]
	elseif a:0==2
		let [fg,bg]=[a:1,a:2]
		call add(g:CShst,[fg,bg])
	elseif a:0==1 && type(a:1)==1 && has_key(g:SWATCHES,a:1)
		let [fg,bg]=g:SWATCHES[a:1]
		call add(g:CShst,[fg,bg])
	el|retu|en
	let swatchlist=keys(g:SWATCHES)
	exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg | redr
	let msg=g:CSgrp
	exe "echoh ".g:CSgrp
	ec msg fg bg
	let c=getchar()
	while c!=g:EscAsc && c!=113 && c!=10 && c!=13
		if c==104 && fg > 0
			let fg-=1
			let g:CShix+=1
		elseif c==108 && fg < 255
			let fg+=1
			let g:CShix+=1
		elseif c==98
			let g:CShix+=1
			let g:SwchIx=g:SwchIx>0? g:SwchIx-1 : len(swatchlist)-1
			let [fg,bg]=g:SWATCHES[swatchlist[g:SwchIx]]
			let msg.=' '.swatchlist[g:SwchIx]
		elseif c==102
			let g:CShix+=1
			let g:SwchIx=g:SwchIx<len(swatchlist)-1? g:SwchIx+1 : 0
			let [fg,bg]=g:SWATCHES[swatchlist[g:SwchIx]]
			let msg.=' '.swatchlist[g:SwchIx]
		elseif c==106 && bg > 0
			let bg-=1
			let g:CShix+=1
		elseif c==107 && bg < 255
			let bg+=1
			let g:CShix+=1
		elseif c==112 && g:CShix > 0
			let g:CShix-=1
			let [fg,bg]=g:CShst[g:CShix]
		elseif c==110 && g:CShix < len(g:CShst)-1
			let g:CShix+=1
			let [fg,bg]=g:CShst[g:CShix]
		elseif c==42
			let g:CShix+=1
			let [fg,bg]=[reltime()[1]%256,reltime()[1]%256]
		elseif c==114
			let g:CShix+=1
			let fg=reltime()[1]%256
		elseif c==82
			let g:CShix+=1
			let bg=reltime()[1]%256
		elseif c==105
			let [fg,bg]=[bg,fg]
		elseif c==103
			let in=QSel(hi,"Group: ")
			if in!=-1
				if has_key(g:CURCS,hi[in])
					let [fg,bg]=g:CURCS[hi[in]] |en
				if has_key(g:CURCS,g:CSgrp)
					exe 'hi '.g:CSgrp.' ctermfg='.(g:CURCS[g:CSgrp][0])
					\.' ctermbg='.(g:CURCS[g:CSgrp][1])
				en
				let g:CSgrp=hi[in]
				let msg=g:CSgrp
			en
		elseif c==115
			let name=input("Save swatch as: ",'','customlist,CompleteSwatches')
			if !empty(name) | let g:SWATCHES[name]=[fg,bg] |en
		el| let msg="[*]rand [fb]swatches [g]roup [hl]fg [i]nvert [jk]bg
			\ [np]history fgbg[rR]and [s]ave" |en
		if g:CShix<=len(g:CShst)-1
			let g:CShst[g:CShix]=[fg,bg]
		el| call add(g:CShst,[fg,bg])
			let g:CShix=len(g:CShst)-1 |en
		exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg |redr
		exe "echoh ".g:CSgrp
		ec msg fg bg
		let msg=g:CSgrp
		let c=getchar()
	endwhile
	if (c==10 || c==13)
		exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg
		let g:CURCS[g:CSgrp]=[fg,bg]
	elseif has_key(g:CURCS,g:CSgrp)
		exe 'hi '.g:CSgrp.' ctermfg='.(g:CURCS[g:CSgrp][0]).' ctermbg='
		\.(g:CURCS[g:CSgrp][1]) |en
	if len(g:CShst)>100
		let CShst=g:CShix<25? (g:CShst[:50]) : g:CShix>75? (g:CShst[50:])
		\: g:CShst[g:CShix-25:g:CShix+25] |en
	echoh None
	return g:CShst[g:CShix]
endfun

let Pad=repeat(' ',200)

fun! CenterLine()
	let line=matchstr(getline('.'),'^\s*\zs\S.*\S\ze\s*$')
	if &tw==0
		call setline(line('.'),g:Pad[1:(&columns-strdisplaywidth(line))/2].line)
	elseif &tw > strdisplaywidth(line)
		call setline(line('.'),g:Pad[1:(&tw-strdisplaywidth(line))/2].line)
	en
endfun

fun! WriteVars(filename)
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
	call writefile(list,a:filename)
endfun

fun! PrintTime(s,...) "%e crashes Windows!
	retu strftime('%b%d %I:%M ',a:0>0? (a:1) : localtime())
	\.(a:s>86399? (a:s/86400.'d'):'')
	\.(a:s%86400>3599? (a:s%86400/3600.'h'):'').(a:s%3600/60.'m ')
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

nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

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

fun! GetMRU()
	let sel=QSel(g:MRUF,'e: ')
	if sel!=-1 | exe 'e '.g:MRUF[sel] |en
endfun
fun! GetLbl(file)
	let name=matchstr(a:file,"[[:alnum:]][^/\\\\]*$")
	return len(name)>12 ? name[0:7]."~".name[-3:] : name
endfun
fun! InsHist(name,lnum,cnum,w0)
	if g:NoMRUsav==1 || empty(a:name) || a:name=~escape($VIMRUNTIME,'\')
		let g:NoMRUsav=0 | retu|en
	cal insert(g:MRUF,a:name)
	cal insert(g:MRUL,[a:lnum,a:cnum,a:w0])
endfun
fun! RemHist()
	let i=match(g:MRUF,'^'.expand('%').'$')
	if i==-1 | retu|en
	exe "norm! ".g:MRUL[i][2]."z\<cr>".(g:MRUL[i][0]>g:MRUL[i][2]? 
	\ (g:MRUL[i][0]-g:MRUL[i][2]).'j':'').g:MRUL[i][1].'|'
	cal remove(g:MRUF,i)
	cal remove(g:MRUL,i)
endfun

fun! OnNewBuf()
	if !g:FmtNew | retu|en
	call setline(1,localtime()." vim: set nowrap ts=4 tw=78 fo=aw: "
	\.strftime('%H:%M %m/%d/%y'))
	setlocal nowrap ts=4 tw=78 fo=aw
	call CheckFormatted()
endfun
fun! CheckFormatted()
	if &wrap
		nno j gj
		nno k gk
	en
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
	redr|ec 'Formatting Options Loaded:' expand('%')
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
cnorea <expr> wg ((getcmdtype()==':' && getcmdpos()<4)? "cal WriteVars('saveD')":'wg')
cnorea <expr> bd! ((getcmdtype()==':' && getcmdpos()<5)? 'let NoMRUsav=1\|bd!':'bd!')

let g:CapStarters=".?!\<nl>\<cr>\<tab>\<space>"
let g:CapSeparators="\<nl>\<cr>\<tab>\<space>"
fun! CapWait(prev)
	redr | let next=nr2char(getchar())
	if empty(next) || next==g:EscChar
		return "\<del>"
	elseif stridx(g:CapStarters,next)!=-1
		exe 'norm! i' . next . "\<right>"
		return CapWait(next)
	elseif stridx(g:CapSeparators,a:prev)!=-1
		return toupper(next) . "\<del>"
	el| return next . "\<del>"
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

fun! WriteVimState()
	echoh ErrorMsg
	if g:StartupErr=~?'error' && input("Startup errors were encountered! "
	\.g:StartupErr."\nSave settings anyways?")!~?'^y'
		retu|en
	call WriteVars('saveD')
	if has("gui_running")
		let g:S_GUIFONT=&guifont
		let g:WINPOS='se co='.&co.' lines='.&lines.
		\'|winp '.getwinposx().' '.getwinposy() |en
	se viminfo=!,'20,<1000,s10,/50,:150
	if !exists("g:Viminfo_File") | wviminfo
	el| if exists('g:RemoveBeforeWriteViminfo')
			sil exe '!rm '.g:Viminfo_File |en
		sil exe 'wv! '.g:Viminfo_File |en
	se viminfo=
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
let sources=['abbrev','cmdnorm','pager','saveD']
for file in sources
	if filereadable(Working_Dir.'/'.file) | exe 'so '.Working_Dir.'/'.file
	el| call Ec('Error: '.Working_Dir.'/'.file.' unreadable')|en
endfor
if !argc()
	let g:FmtNew=1
	if isdirectory(Working_Dir)
		exe 'cd '.Working_Dir |en
el| let g:FmtNew=0 |en
se viminfo=!,'20,<1000,s10,/50,:150
if !exists('Viminfo_File')
	cal Ec("Error: g:Viminfo_File undefined, falling back to default")
	rviminfo
el| exe 'rv '.Viminfo_File |en
se viminfo=
if has("gui_running")
	colorscheme slate
	hi ColorColumn guibg=#222222 
	hi Vertsplit guifg=grey15 guibg=grey15
 	se guioptions-=T
	if exists("WINPOS") | exe WINPOS |en
	if !exists('S_GUIFONT')
		"se guifont=Envy\ Code\ R\ 10 
		se guifont=Envy_Code_R:h10 
		let S_GUIFONT=&guifont
	el| exe 'se guifont='.S_GUIFONT |en |en
if !exists('*InitLog') | let g:LastTime=localtime()
elseif !exists('LOGDIC') | let LOGDIC=New('Log')
el| let g:LastTime=LOGDIC.L[-1][0] |en
if !exists('MRUF')
	let MRUF=[]
	let MRUL=[] |en
if len(MRUF)>60
	let MRUF=MRUF(:40)
	let MRUL=MRUL(:40) |en
let NoMRUsav=0
if !exists('CURCS') | let CURCS={} | el | call CSLoad(CURCS) |en
if !exists('SWATCHES') | let SWATCHES={} |en
if !argc() && len(MRUF)>0
	sil exe 'e '.g:MRUF[0]
	sil call CheckFormatted()
	call RemHist() |en
au BufWinEnter * call RemHist()
au BufRead * call CheckFormatted()
au BufNewFile * call OnNewBuf()
au BufWinLeave * call InsHist(expand('%'),line('.'),col('.'),line('w0'))
au VimLeavePre * call WriteVimState()
se noshowmode nowrap linebreak sidescroll=1 ignorecase smartcase incsearch
se ai tabstop=4 history=150 mouse=a ttymouse=xterm2 hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
se whichwrap+=h,l wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:< showbreak=\ \ 
se stl=\ %l.%02c/%L\ %<%f%=\ %{PrintTime(localtime()-LastTime)}
nohl
redir END

let normD={110:":noh\<cr>",(g:EscAsc):"\<esc>",96:'`',122:":wa\<cr>",
\99:":call CSChooser()\<cr>",9:":call TODO.show()\<cr>",
\114:":redi@t|sw|redi END\<cr>:!rm \<c-r>=escape(@t[1:],' ')\<cr>\<bs>*",
\80:":call IniPaint()\<cr>",108:":call g:LOGDIC.show()\<cr>",
\101:":call CenterLine()\<cr>",119:"\<c-w>\<c-w>",
\103:"vawly:h \<c-r>=@\"[-1:-1]=='('? @\":@\"[:-2]\<cr>",
\111:":call GetMRU()\<cr>",
\49:":exe 'e '.g:MRUF[0]\<cr>",50:":exe 'e '.g:MRUF[1]\<cr>",
\113:"\<esc>",51:":exe 'e '.g:MRUF[2]\<cr>",
\112:"i\<c-r>=eval(input('Put: ','','var'))\<cr>",109:":mes\<cr>",
\42:":,$s/\\<\<c-r>=expand('<cword>')\<cr>\\>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\35:":'<,'>s/\<c-r>=expand('<cword>')\<cr>//gc\<left>\<left>\<left>",
\'help':'123:buff c/olor c[e]nter g/ethelp l/og n/ohl r/mswp
\ m/sg o/pen p/utvar w/ind z:wa *#:sub',
\'msg':"expand('%:t').' '.join(map(g:MRUF[:2],'GetLbl(v:val)'),' ').' '
\.line('.').'.'.col('.').'/'.line('$').' '.PrintTime(localtime()-g:LastTime)"}

let insD={103:"\<c-r>=getchar()\<cr>",(g:EscAsc):"\<c-o>\<esc>",96:'`',
\113:"\<c-o>\<esc>",111:"\<c-r>=input('Open recent:','','customlist,CmpMRU')\<cr>",
\49:"\<esc>:exe 'e '.g:MRUF[0]\<cr>",50:"\<esc>:exe 'e '.g:MRUF[1]\<cr>",
\51:"\<esc>:exe 'e '.g:MRUF[2]\<cr>",110:"\<c-o>:noh\<cr>",
\102:"\<c-r>=escape(expand('%'),' ')\<cr>",119:"\<c-o>\<c-w>\<c-w>",
\'help':'123:buff f/ilename g/etchar o/pen w/indow:',
\'msg':"expand('%:t').' '.join(map(g:MRUF[:2],'GetLbl(v:val)'),' ').' '
\.line('.').'.'.col('.').'/'.line('$').' '.PrintTime(localtime()-g:LastTime)"}

let g:visD={(g:EscAsc):"",42:"y:,$s/\<c-r>=@\"\<cr>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\120:"y:exe substitute(@\",\"\\n\\\\\",'','g')\<cr>",99:"y:\<c-r>\"",
\'help':'*:sub g/etvar x/ec c/opy2cmd:','msg':"expand('%:t').' '.line('.').'.'.col('.')
\.'/'.line('$').' '.PrintTime(localtime()-g:LastTime)"}
