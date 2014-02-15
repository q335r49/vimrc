redir => g:StartupErr

nno j gj
nno k gk

com! -nargs=1 -complete=var Editlist call New('NestedList',<args>).show()
com! DiffOrig belowright vert new|se bt=nofile|r #|0d_|diffthis|winc p|diffthis

let g:prevglide=0
fun! Mscroll(pos)
	let pos=a:pos
	let t0=reltime()
	let timeL=[]
	let posL=[]
	while getchar()=="\<leftdrag>"
		let diff=v:mouse_lnum-line('w0')-pos
		call add(timeL,eval(join(reltime(t0),'*1000000+')))
		call add(posL,diff)
		let t0=reltime()
		if diff
			let pos+=diff
			exe 'norm! '.(diff>0? diff."\<C-Y>":-diff."\<C-E>")
			redr|ec line('w0')|en
	endwhile
	let diff=v:mouse_lnum-line('w0')-pos
	call add(timeL,eval(join(reltime(t0),'*1000000+')))
	call add(posL,diff)
	if len(timeL)>2
		let timeL=timeL[(-min([4,len(timeL)])):]
		let posL=posL[(-min([4,len(posL)])):]
		let max=max(posL)
		let min=min(posL)
		let glide=max>1 || min>=0? max : min<-1 || max<=0? min : 0
		if eval(join(timeL,'+'))>160000 || glide==0 
			let g:prevglide=0
			return
		elseif g:prevglide>0 && glide>0
			let glide+=g:prevglide
			let g:prevglide=glide
		elseif g:prevglide<0 && glide<0
			let glide+=g:prevglide
			let g:prevglide=glide
		elseif g:prevglide==0
			let g:prevglide=glide
		else
			let g:prevglide=0
		en
		let cmd=glide>0?  "norm! \<C-Y>" : "norm! \<C-E>"
		let i=9999
		let mult=12
		let counter=mult*90/glide 
		let glide=glide<0? -glide : glide
		while 1
			let counter-=1
			if counter<0
				let mult+=4
				let counter=mult*90/glide/glide
				exe cmd
				redr|ec line('w0')
			endif
			if getchar(1)!=0 || mult>30*glide
				let g:prevglide=i<8999? g:prevglide*(9999-i)/9999 : 1
				break | en
		endwhile
	en
endfun
nnoremap <silent> <leftMouse> <leftmouse>:call Mscroll(line(".")-line("w0"))<CR>

finish

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
			if lenmatch>2*&columns | break|en
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
	return [qual!=0? match : -1,c]
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
	let continue=1
	while 1
		if has_key(g:CSChooserD,c)
			exe g:CSChooserD[c]
		el| let msg="[*]rand [fb]swatches [g]roup [hl]fg [i]nvert [jk]bg
			\ [np]history fgbg[rR]and [s]ave" |en
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

let Pad=repeat(' ',200)
fun! CenterLine()
	let line=matchstr(getline('.'),'^\s*\zs.*\ze\s*$')
	if &tw==0
		call setline(line('.'),g:Pad[1:(winwidth(0)-strdisplaywidth(line))/2].line)
	elseif &tw > strdisplaywidth(line)
		call setline(line('.'),g:Pad[1:(&tw-strdisplaywidth(line))/2].line)
	en
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
	exe 'cd '.g:Working_Dir 
	let modtimeL=map(range(5),'getftime("varsave".v:val)')
	let mostrecent=max(modtimeL)
	exe 'e varsave'.index(modtimeL,mostrecent)
	ec 'Last backup '.strftime("%c",mostrecent)
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

fun! EdMRU()
	let [sel,cmd]=QSel(g:MRUF,'Open: ')
	if sel==-1 || cmd==g:EscAsc | retu|en
	if cmd==22 "<c-v>
		let ro=1
		ec 'Read Only, split which direction? (CR,^L,^R,^T,^B)'
		let cmd=getchar()
	el| let ro=0 |en
	while 1
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
		el| ec '^L:vspleft ^R:vspright ^T:sptop ^B:spbot ^V:readonly CR:edit'
			let cmd=getchar()
			continue | en
		return
	endwhile
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
fun! RemHist(file)
	let i=match(g:MRUF,'^'.a:file.'$')
	if i==-1 | retu|en
	exe "norm! ".g:MRUL[i][2]."z\<cr>".(g:MRUL[i][0]>g:MRUL[i][2]? 
	\ (g:MRUL[i][0]-g:MRUL[i][2]).'j':'').g:MRUL[i][1].'|'
	cal remove(g:MRUF,i)
	cal remove(g:MRUL,i)
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

cnorea <expr> we ((getcmdtype()==':' && getcmdpos()<4)? 'w\|e' :'we')
cnorea <expr> ws ((getcmdtype()==':' && getcmdpos()<4)? 'w\|so%':'ws')
cnorea <expr> wd ((getcmdtype()==':' && getcmdpos()<4)? 'w\|bd':'wd')
cnorea <expr> wsd ((getcmdtype()==':' && getcmdpos()<5)? 'w\|so%\|bd':'wsd')
cnorea <expr> bd! ((getcmdtype()==':' && getcmdpos()<5)? 'let NoMRUsav=1\|bd!':'bd!')
cnorea <expr> wa ((getcmdtype()==':' && getcmdpos()<4)? "wa\|redr\|ec WriteVars('saveD')" :'wa')

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
	return col(".")==1 ? (g:AUTOCAPNL ? CapWait("\r") : "\<del>")
	\ : trunc=~'[?!.]\s*$\|^\s*$' ? CapWait(trunc[-1:-1]) : "\<del>"
endfun
fun! InitCap(capnl)
	ino <buffer> <silent> <F6> <ESC>mt:call search("'",'b')<CR>x`ts
	if a:capnl==1
		nm <buffer> <silent> O O_<Left><C-R>=CapWait("\r")<CR>
		nm <buffer> <silent> o o_<Left><C-R>=CapWait("\r")<CR>
		nm <buffer> <silent> cc cc_<Left><C-R>=CapHere()<CR>
		nm <buffer> <silent> I I_<Left><C-R>=CapHere()<CR>
		im <buffer> <silent> <CR> <CR>_<Left><C-R>=CapWait("\r")<CR>
		im <buffer> <silent> <NL> <NL>_<Left><C-R>=CapWait("\n")<CR>
	en
	im <buffer> <silent> . ._<Left><C-R>=CapWait('.')<CR>
	im <buffer> <silent> ? ?_<Left><C-R>=CapWait('?')<CR>
	im <buffer> <silent> ! !_<Left><C-R>=CapWait('!')<CR>
	nm <buffer> <silent> a a_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> A $a_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> i i_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> s s_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> cw cw_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> R R_<Left><C-R>=CapHere()<CR>
	nm <buffer> <silent> C C_<Left><C-R>=CapHere()<CR>
endfun

fun! CheckFormatted()
	let modeline=getline(1)
	if modeline=~?'prose'
		setl noai
		call InitCap(modeline=~#'Prose')
		iab <buffer> i I
		iab <buffer> Id I'd
		iab <buffer> id I'd
		iab <buffer> im I'm
		iab <buffer> Im I'm
	en
	if modeline=~'fo=aw'
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
	exe 'cd '.g:Working_Dir 
	let modtimeL=map(range(5),'getftime("varsave".v:val)')
	if localtime()-max(modtimeL)>86400
		call WriteVars('varsave'.index(modtimeL,min(modtimeL)))
	en
	call WriteVars('saveD')
	if has("gui_running")
		let g:S_GUIFONT=&guifont |en
	"curdir is necessary to retain relative path
	se sessionoptions=winpos,resize,winsize,tabpages,folds,curdir
	mksession! .lastsession
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
if !argc() && isdirectory(Working_Dir)
	exe 'cd '.Working_Dir |en
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
if !exists('CURCS') | let CURCS={} | el | call CSLoad(CURCS) |en
if !exists('SWATCHES') | let SWATCHES={} |en
au BufWinEnter * call RemHist(expand('<afile>'))
au BufRead * call CheckFormatted()
au BufWinLeave * call InsHist(expand('<afile>'),line('.'),col('.'),line('w0'))
au VimLeavePre * call WriteVimState()
se noshowmode wrap linebreak sidescroll=1 ignorecase smartcase incsearch
se ai tabstop=4 history=150 mouse=a ttymouse=xterm2 hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
se whichwrap+=h,l wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:< showbreak=
se stl=\ %l.%02c/%L\ %<%f%=\ }
se fcs=vert:\ ,fold:\ 
nohl
redir END
if !argc() && filereadable('.lastsession') | so .lastsession | en

let normD={110:":noh\<cr>",(g:EscAsc):"\<esc>",96:'`',122:":wa\<cr>",
\67:":call CSChooser()\<cr>",9:":call TODO.show()\<cr>",
\114:":redi@t|sw|redi END\<cr>:!rm \<c-r>=escape(@t[1:],' ')\<cr>\<bs>*",
\80:":call IniPaint()\<cr>",108:":call g:LOGDIC.show()\<cr>",
\99:":call CenterLine()\<cr>",119:"\<c-w>\<c-w>",
\103:"vawly:h \<c-r>=@\"[-1:-1]=='('? @\":@\"[:-2]\<cr>",
\101:":call EdMRU()\<cr>",
\49:":exe 'e '.escape(g:MRUF[0],' ')\<cr>",50:":exe 'e '.escape(g:MRUF[1],' ')\<cr>",
\113:"\<esc>",51:":exe 'e '.escape(g:MRUF[2],' ')\<cr>",
\112:"i\<c-r>=eval(input('Put: ','','var'))\<cr>",109:":mes\<cr>",
\42:":,$s/\\<\<c-r>=expand('<cword>')\<cr>\\>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\35:":'<,'>s/\<c-r>=expand('<cword>')\<cr>//gc\<left>\<left>\<left>",
\'help':'123:buff c/enter C/olor e/dit(^R^L^T^B) g/ethelp l/og n/ohl o:punchin r/mswp m/sg p/utvar s/till w/ind z:wa *#:sub',
\'msg':"expand('%:t').' '.join(map(g:MRUF[:2],'GetLbl(v:val)'),' ').' '
\.line('.').'.'.col('.').'/'.line('$').' '.PrintTime(localtime()-g:LOGDIC.L[-1][0]).g:LOGDIC.L[-1][1]",
\111:":call LOGDIC.111(1)\<cr>",
\115:":call LOGDIC.115()|ec PrintTime(localtime()-g:LOGDIC.L[-1][0]).g:LOGDIC.L[-1][1]\<cr>"}

let insD={103:"\<c-r>=getchar()\<cr>",(g:EscAsc):"\<c-o>\<esc>",96:'`',
\113:"\<c-o>\<esc>",111:"\<c-r>=input('`o','','customlist,CmpMRU')\<cr>",
\49:"\<esc>:exe 'e '.g:MRUF[0]\<cr>",50:"\<esc>:exe 'e '.g:MRUF[1]\<cr>",
\51:"\<esc>:exe 'e '.g:MRUF[2]\<cr>",110:"\<c-o>:noh\<cr>",
\102:"\<c-r>=escape(expand('%'),' ')\<cr>",119:"\<c-o>\<c-w>\<c-w>",
\'help':'123:buff f/ilename g/etchar o/pen w/indow:',
\'msg':"expand('%:t').' '.join(map(g:MRUF[:2],'GetLbl(v:val)'),' ').' '
\.line('.').'.'.col('.').'/'.line('$').' '.PrintTime(localtime()-g:LOGDIC.L[-1][0]).g:LOGDIC.L[-1][1]"}

let g:visD={(g:EscAsc):"",42:"y:,$s/\\V\<c-r>=@\"\<cr>//gce|1,''-&&\<left>\<left>
\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
\120:"y: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>",99:"y:\<c-r>\"",
\'help':'*:sub g/ofile x/ec c/opy2cmd:',
\103:"y:e \<c-r>\"\<cr>",
\'msg':"expand('%:t').' '.line('.').'.'.col('.')
\.'/'.line('$').' '.(exists(\"g:LOGDIC\")? PrintTime(localtime()-g:LOGDIC.L[-1][0]).g:LOGDIC.L[-1][1] : \"\")"}

let CSChooserD={113:"let continue=0 | if has_key(g:CURCS,g:CSgrp)
\|exe 'hi '.g:CSgrp.' ctermfg='.(g:CURCS[g:CSgrp][0]).' ctermbg='.(g:CURCS[g:CSgrp][1]) |en",
\(g:EscAsc):"let continue=0 | if has_key(g:CURCS,g:CSgrp)
\|exe 'hi '.g:CSgrp.' ctermfg='.(g:CURCS[g:CSgrp][0]).' ctermbg='.(g:CURCS[g:CSgrp][1]) |en",
\10: "let continue=0 | exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg
\|let g:CURCS[g:CSgrp]=[fg,bg]",
\13: "let continue=0 | exe 'hi '.g:CSgrp.' ctermfg='.fg.' ctermbg='.bg
\|let g:CURCS[g:CSgrp]=[fg,bg]",
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
\if has_key(g:CURCS,hi[in]) | let [fg,bg]=g:CURCS[hi[in]]|en|
\if has_key(g:CURCS,g:CSgrp) | 
\exe "hi ".g:CSgrp." ctermfg=".(g:CURCS[g:CSgrp][0])." ctermbg=".(g:CURCS[g:CSgrp][1])
\| en | let g:CSgrp=hi[in] | let msg=g:CSgrp | en',
\115:'let name=input("Save swatch as: ","","customlist,CompleteSwatches") |
\if !empty(name) | let g:SWATCHES[name]=[fg,bg] |en'}

"Added changelog
"Added shortcuts to log functions in normD command
