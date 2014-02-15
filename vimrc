redir => g:StartupErr

fun! CenterLine()
	let line=matchstr(getline('.'),'^\s*\zs.*\S\ze\s*$')
	call setline(line('.'),g:Pad[:(&columns-strdisplaywidth(line))/2].line)
endfun

fun! Save(name)
	let g:SaveD[a:name]=toupper(a:name)
endfun
fun! Unsave(name)
	exe 'unlet g:'.toupper(a:name)
	exe 'unlet g:'.a:name
	unlet g:SaveD[a:name]
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
	if g:FormatNewFiles
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
	elseif next=='' || next==g:EscChar
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

fun! SetOpt(...)
	let g:Input_Meth=a:0? a:1 : 'thumb'
	if g:Input_Meth==?"THUMB"
		let op=["@",64,1]
	el| let op=["\e",27,0] | en
	if !exists("g:EscChar") | let g:EscChar=op[0] |en
	if !exists("g:EscAsc") | let g:EscAsc=op[0] |en
	if exists(g:EscChar)
		exe 'unm '.g:EscChar
		exe 'unm! '.g:EscChar
		exe 'cu '.g:EscChar | en
	if g:EscChar!=?"\e"
		exe 'no <F2> '.g:EscChar
		exe 'no '.g:EscChar.' <Esc>'
   		exe 'no! '.g:EscChar.' <Esc>'
   		exe 'cno '.g:EscChar.' <C-C>' | en
	try|exe (op[2]? 'map <C-J> <C-M>' : 'unm <C-J>')
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
	let g:normD={110:":noh\<CR>",(g:EscAsc):"\<Esc>",96:'`',122:":wa\<CR>",
	\99:":call Cabinet.show()\<CR>",
	\114:":redi@t|sw|redi END\<CR>:!rm \<C-R>=escape(@t[1:],' ')\<CR>",
	\80:":call IniPaint()\<CR>",108:":call g:LogDic.show()\<CR>",
	\101:":call CenterLine()\<CR>",
	\103:"vawly:h \<C-R>=@\"[-1:-1]=='('? @\":@\"[:-2]\<CR>",
	\115:":let qcx=HistMenu()|if qcx>=0|exe 'e '.g:histL[qcx][0]|en\<CR>",
	\49:":exe 'e '.g:histL[0][0]\<CR>",50:":exe 'e '.g:histL[1][0]\<CR>",
	\113:"\<Esc>",51:":exe 'e '.g:histL[2][0]\<CR>",
	\112:"i\<C-R>=eval(input('Put: ','','var'))\<CR>",109:":mes\<CR>",
	\42:":,$s/\<C-R>=expand('<cword>')\<CR>//gc|1,''-&&\<left>\<left>
	\\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>",
	\35:":'<,'>s/\<C-R>=expand('<cword>')\<CR>//gc\<Left>\<Left>\<Left>",
	\'help':':b[123] [c]abinet c[e]nter [g]:h [l]og [n]ohl [P]nt [r]mswp l[s]
	\ :[m]es [p]utvar C-[w]C-w e[X]e [z]:wa s/[*#]',
	\'msg':"expand('%:t').' '.join(map(g:histLb[:2],'v:val[2:]'),' ').' '
	\.line('.').'.'.col('.').'/'.line('$').' '
	\.PrintTime(localtime()-g:LastTime)"}
	let g:insD={103:"\<C-R>=getchar()\<CR>",(g:EscAsc):"\<Esc>a",96:'`',
	\115:"\<Esc>:let qcx=HistMenu()|if qcx>=0|exe 'e '.g:histL[qcx][0]|en\<CR>",
	\49:"\<Esc>:exe 'e '.g:histL[0][0]\<CR>",
	\50:"\<Esc>:exe 'e '.g:histL[1][0]\<CR>",
	\51:"\<Esc>:exe 'e '.g:histL[2][0]\<CR>",
	\102:"\<C-R>=escape(expand('%'),' ')\<CR>",119:"\<Esc>\<C-W>\<C-W>",
	\113:"\<Esc>a",'help':'b[123] [f]ilename [g]etchar l[s]:',
	\'msg':"expand('%:t').' '.join(map(g:histLb[:2],'v:val[2:]'),' ').' '
	\.line('.').'.'.col('.').'/'.line('$').' '
	\.PrintTime(localtime()-g:LastTime)"}
	let g:visD={(g:EscAsc):"",103:"y:call GetVar(@\")\<CR>",
	\120:"y:@\"\<CR>",99:"y:\<C-R>\"",'help':'[g]etvar e[x]e 2[c]md:',
	\'msg':"expand('%:t').' '.line('.').'.'.col('.').'/'.line('$').' '
	\.PrintTime(localtime()-g:LastTime)"}
endfun
fun! Write_Viminfo()
	if match(g:StartupErr,'\cerror')!=-1
		let in=input("Startup errors were encountered, write viminfo anyways?")
		if in!=?'y' && in!='ye' && in!='yes' |retu|en |en
	if exists('g:SaveD')
		for i in keys(g:SaveD)
			exe 'let g:'.g:SaveD[i].'=string(g:'.i.')'
		endfor |en
	if has("gui_running")
		let g:S_GUIFONT=&guifont
		let g:WINPOS='se co='.&co.' lines='.&lines.
		\'|winp '.getwinposx().' '.getwinposy() |en
	se viminfo=!,'20,<1000,s10,/50,:50
	if !exists("g:Viminfo_File") | wviminfo
	el| silent exe '!rm '.g:Viminfo_File.'.bak'
		silent exe '!mv '.g:Viminfo_File.' '.g:Viminfo_File.'.bak'
		silent exe 'wv! '.g:Viminfo_File |en
	se viminfo=
endfun

if !exists('do_once') | let do_once=1 | el|finish|en
if !exists('Input_Meth')
	call Ec('Input_Meth invalid or not defined in .vimrc!')
	call Ec('...falling back to keyboard')
	let Input_Meth='keyboard' |en
call SetOpt(g:Input_Meth)
if !exists('Working_Dir') || !isdirectory(glob(Working_Dir))
	call Ec('Working_Dir='.Working_Dir.' invalid or not defined in .vimrc!')
	call Ec('...falling back to $HOME')
	let Working_Dir=$HOME |en
let sources=['abbrev','cmdnorm','pager']
for file in sources
	if filereadable(Working_Dir.'/'.file) | exe 'so '.Working_Dir.'/'.file
	el| call Ec(Working_Dir.'/'.file.' unreadable')|en
endfor
if !argc()
	let g:FormatNewFiles=1
	if isdirectory(Working_Dir)
		exe 'cd '.Working_Dir |en
el| let g:FormatNewFiles=0 |en
if glob(g:Working_Dir)=='/home/q335/Desktop/Dropbox/q335writings'
\ && !has("gui_running")
	syntax off
	map OA <Up>
	map OB <Down>
	map OD <Left>
	map OC <Right>
	map! OA <Up>
	map! OB <Down>
	map! OD <Left>
	map! OC <Right>
en
se viminfo=!,'20,<1000,s10,/50,:150
	if !exists('Viminfo_File')
		call Ec('Viminfo_File not defined in .vimrc!')
		call Ec('...falling back to default')
		rviminfo
	el| exe 'rv '.Viminfo_File |en
se viminfo=
if has("gui_running")
	colorscheme slate
	if exists("WINPOS") | exe WINPOS |en
	if !exists('S_GUIFONT')
		"se guifont=Envy\ Code\ R\ 10 
		se guifont=Envy_Code_R:h10 
		let S_GUIFONT=&guifont
	el| exe 'se guifont='.S_GUIFONT |en |en
if exists('PERMANENTD')
	let SaveD=eval(PERMANENTD)
	for key in keys(SaveD)
		exe 'let '.key.'='.eval(SaveD[key])
	endfor
el| let SaveD={} |en
if !exists('*InitLog')
	let g:LastTime=localtime()
elseif !exists('LogDic')
	let LogDic=New('Log')
el| let g:LastTime=LogDic.L[-1][0] |en
if !exists('histL') | let histL=[] |en
call InitHist()
call Save('histL')
call Save('LogDic')
call Save('SaveD')
if len(histL)>0
	silent exe 'e '.g:histL[0][0]
	call CheckFormatted() | call OnWinEnter() |en

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
se tabstop=4 history=150 mouse=a ttymouse=xterm2 hidden backspace=2
se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
se whichwrap+=h,l wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
se stl=\ %l.%02c/%L\ %<%f%=\ %{PrintTime(localtime()-LastTime)}
redir END
nohl

"merge history & Pager
	"glob() for all history entries not in Working_Dir
	"Separate history lists (for help, outside files) --perfect for nested array
	"undo list?
"cmdnorm R and <CR>, multiline cmdmenu, echoing tabs
	"cmdmenu - echo prepend, long lines
	"log-cmdmenu interaction bug
"connectbot
	"background color bug report?
	"hi normal + highlight lines for quick scheme changes
