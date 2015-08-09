se noloadplugins

let opt_autocap=0
if !exists('opt_device')
	echom "Warning: opt_device is undefined."
	let opt_device='' | en
if opt_device=~?'windows'
	let Working_Dir='C:\Users\q335r49\Desktop\Dropbox\q335writings'
	let Viminfo_File='C:\Users\q335r49\Desktop\Dropbox\q335writings\viminfo' | en
if opt_device=~?'cygwin'
	no! <c-h> <left>
	no! <c-j> <down>
	no! <c-k> <up>
	no! <c-l> <right>
	no <c-h> <left>
	no <c-j> <down>
	no <c-k> <up>
	no <c-l> <right>
	cno <c-_> <c-w>
	vno <c-c> "*y
	vno <c-v> "*p
	no! <c-_> <c-w>
	nno <c-_> db
	let Viminfo_File= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings/viminfo'
	let Working_Dir= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings' | en
	se ttimeoutlen=10
if opt_device=~?'notepad'
	se noswapfile
	nno <c-s> :wa<cr>
	nno <c-w> :wqa<cr>
	nno <c-v> "*p
	nno <c-q> <c-v>
	let Viminfo_File= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings/viminfo-notepad'
en
if opt_device=~?'droid4'
	set diffexpr=MyDiff()
	fun! MyDiff()
	   silent! exe "!~/difftools/diff ".(&diffopt=~"icase"? "-i ":"").(&diffopt =~ "iwhite"? "-b ":"").v:fname_in." ".v:fname_new." > ".v:fname_out." 2> /dev/null"
	endfun
	exe "ino <c-[>[3~ <bs>"
	exe "ino <c-[>OQ @"
	exe "no \<c-v>\eOP !" | exe "no! \<c-v>\eOP !"
	exe "no \<c-v>\eOQ @" | exe "no! \<c-v>\eOQ @"
	exe "map \<c-v>\eOR #" | exe "map! \<c-v>\eOR #"
	exe "map \<c-v>\eOS $" | exe "map! \<c-v>\eOS $"
	exe "map \<c-v>\[15~ %" | exe "map! \<c-v>\[15~ %"
	exe "map \<c-v>\[17~ ^" | exe "map! \<c-v>\[17~ ^"
	exe "map \<c-v>\[18~ *" | exe "map! \<c-v>\[18~ &"
	exe "map \<c-v>\[19~ *" | exe "map! \<c-v>\[19~ *"
	exe "map \<c-v>\[20~ (" | exe "map! \<c-v>\[20~ ("
	exe "map \<c-v>\[21~ )" | exe "map! \<c-v>\[21~ )"
	let Viminfo_File='/sdcard/q335writings/viminfo-d4'
	let Working_Dir='/sdcard/q335writings'
	let EscChar='@'
	let opt_autocap=1
	ino <c-b> <c-w>
	nn <c-r> <nop>
en
if has("gui_running")
	se guifont=Envy_Code_R:h11:cANSI
	colorscheme solarized
	hi ColorColumn guibg=#222222
	hi Vertsplit guifg=grey15 guibg=grey15
	se guioptions-=T
en
let [Qnrm,Qnhelp,Qvis,Qvhelp]=[{},{},{},{}]

let [Qnrm['-'],Qnhelp['-']]=[":earlier\<cr>",'earlier']
let [Qnrm['='],Qnhelp['=']]=[":later\<cr>",'later']

let QK=exists('QK')? QK : ':to 25sp'
nn <silent> <expr> <f3> QK."\|let QK=':".(QK[1]=='1'? 'to'.winheight(1).'sb'.winbufnr(1)."'\n" : '1winc w\|q\|'.winnr()."winc w'\n")

let [Qnrm[','],Qnhelp[',']]=[":let q_num=line('.')|exe 'norm! dd}P'.q_num.'G'\<cr>",'Rotate line dn']
let [Qnrm['.'],Qnhelp['.']]=[":let q_num=line('.')|exe 'norm! dd{p'.q_num.'G'\<cr>",'Rotate line up']
let [Qvis.44,Qvhelp[',']]=["x}P\<c-o>","Rotate line dn"]
let [Qvis.46,Qvhelp['.']]=["x{p\<c-o>k","Rotate line up"]

let Pbrush={111:"norm! \<leftmouse>r○"}
for i in [112,113,121,122,123,131,132,133,211,212,213,221,222,223,231,232,233,333]
	let Pbrush[i]=Pbrush.111
endfor
let Pbrush.311="norm! \<leftmouse>r○" "n
let Pbrush.312="norm! \<leftmouse>r." "b
let Pbrush.313="norm! \<leftmouse>r↓"
let Pbrush.321="norm! \<leftmouse>r'" "u
let Pbrush.322="norm! \<leftmouse>r○" "y
let Pbrush.323="norm! \<leftmouse>r↑"
let Pbrush.331="norm! \<leftmouse>r→"
let Pbrush.332="norm! \<leftmouse>r←"
fun! Paint()
	redr
	let [ve,&ve]=[&ve,'all']
	let c=getchar()
	while c!="\<leftdrag>"
		let c=getchar()
	endwhile
	exe g:Pbrush.333
	let next=[v:mouse_win,v:mouse_lnum,v:mouse_col]
	let prev=next
	while c!="\<leftrelease>"
		let diff=join(map([0,1,2],'next[v:val]>prev[v:val]? 1 : next[v:val]<prev[v:val]? 2 : 3'),'')
		undoj|exe g:Pbrush[diff]
		redr
		let c=getchar()
		let prev=copy(next)
		let next=[v:mouse_win,v:mouse_lnum,v:mouse_col]
	endwhile
	exe g:Pbrush.333
	let &ve=ve
endfun
let Qnrm.c=":call Paint()\<cr>"
let Qnhelp.c="canvas"


nno U gUww

let seed=reltime()[1]
fun! RAND()
	let g:seed=g:seed*1664525+1013904223
	return g:seed
endfun

fun! WWGoPar(count,dir)
	for i in range(a:count)
		let NUL=a:dir? search('\S\n\s*.\|\n\s*\n\s*.\|\%^','Wbe') : cursor(line('.'),col('.')+1)+search('\S\n\|\s\n\s*\n\|\%$','W')
	endfor
	return setpos("'t",[0,line('.'),col('.'),0])? "\<esc>" : "`t"
endfun

fun! NormG(count)
	let [mode,line]=[mode(1),a:count? a:count : cursor(line('.')+1,1)+search('\S\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n','W')? line('.') : line('$')]
	return (mode=='no'? "\<esc>0".v:operator : mode==?'v'? "\<esc>".mode : "\<esc>").line.'G'.(mode=='v'? '$' : '')
endfun
fun! Normgg(count)
	let [mode,line]=[mode(1),a:count? a:count : cursor(line('.')-1,1)+search('\S\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n','Wb')? line('.') : 1]
	return (mode=='no'? "\<esc>$".v:operator :  mode==?'v'? "\<esc>".mode : "\<esc>").line.'G'.(mode=='v'? '0' : '')
endfun
no <expr> G NormG(v:count)
no <expr> gg Normgg(v:count)

fun! Writeroom(...)
	let margin=a:0? a:1 : input("margin: ", &tw? max([(&columns-&tw-3)/2,10]) : 25)
	if margin
		only
		exe 'topleft'.margin.'vsp blank'
		wincmd l
	en
endfun
com! Write call Writeroom()

let g:db=1
fun! PRINT(vars)
	redr!
	return g:db? "exe eval('\"'.input('\n'.join(map(split('".a:vars."','|'),'v:val.\":\".string(eval(v:val))'),'\n'),'').'\"')" : '""'
endfun
let [Qnrm["\e[15~"],Qnhelp['<f5>']]=[":let g:db=!g:db|ec g:db? 'DEBUG ON' : 'DEBUG OFF'\<cr>","Toggle PRINT()"]

let [pvft,pvftc]=[1,32]
fun! Multift(x,c,i)
	let [g:pvftc,g:pvft]=[a:c,a:i]
    let pos=searchpos((a:x==2? mode(1)=='no'? '\C\V\_.\zs' : '\C\V\_.' : '\C\V').(a:x==1 && mode(1)=='no' || a:x==-2? nr2char(g:pvftc).'\zs' : nr2char(g:pvftc)),a:x<0? 'bW':'W')
	call setpos("'x", pos[0]? [0,pos[0],pos[1],0] : [0,line('.'),col('.'),0])
	return "`x"
endfun
no <expr> F Multift(-1,getchar(),-1)
no <expr> f Multift(1,getchar(),1)
no <expr> T Multift(-2,getchar(),-2)
no <expr> t Multift(2,getchar(),2)
no <expr> ; Multift(pvft,pvftc,pvft)
no <expr> , Multift(-pvft,pvftc,pvft)
om a/ :<c-u>norm F/vt/<cr>

let s:ujx_pvXpos=[0,0,0,0]
let s:ujx_eolnotreached=1
fun! Undojx(cmd)
	if getpos('.')==s:ujx_pvXpos
		try
			undoj
		catch *
			let @x=''
			let s:ujx_eolnotreached=1
		endtry
	else
		let @x=''
		let s:ujx_eolnotreached=1
	en
	exe 'norm! '.v:count1.a:cmd
	let newpos=getpos('.')
	if newpos[2]==s:ujx_pvXpos[2]
		let @x.=@"
	elseif a:cmd==#'x' && s:ujx_eolnotreached && !empty(@x)
		let @x.=@"
		let s:ujx_eolnotreached=0
	el
		let @x=@".@x
	en
	echo strtrans(@x)[-&columns+1:]
	let s:ujx_pvXpos=newpos
endfun
nno <silent> x :<c-u>call Undojx('x')<cr>
nno <silent> X :<c-u>call Undojx('X')<cr>

nno q :<c-u>call Qmenu()<cr>
nno Q q
vno Q q
fun! QmenuKeyHandler(c)
	let [&stal,&ls]=g:qmenuView[1:]
	call winrestview(g:qmenuView[0])
	ec strftime('%r %x').' <'.g:LOGDIC[-1][1].(localtime()-g:LOGDIC[-1][0])/60.'>'
	if g:qmenuExitIfNoCycle
		let g:qmenuExitIfNoCycle=0
		if index(["\<c-i>"," ",'s','d','w','e',"\<c-w>",'M','m'],a:c)==-1
			call feedkeys(a:c)
		else
			call feedkeys(get(g:Qnrm,a:c,a:c[0]=="\e"? a:c[1] : g:Qnrm.default),'n')
		en
	else
		call feedkeys(get(g:Qnrm,a:c,a:c[0]=="\e"? a:c[1] : g:Qnrm.default),'n')
	en
endfun
fun! Qmenu()
	let g:q_count=v:count
	let g:qmenuView=[winsaveview(),&stal,&ls]
	let [g:qmenuView[0].topline,&stal,&ls]=[g:qmenuView[0].topline+!g:qmenuView[1],2,2]
	ec strftime('%r %x').' ['.g:LOGDIC[-1][1].(localtime()-g:LOGDIC[-1][0])/60.']'
	cal winrestview(g:qmenuView[0])
	redr
	let g:qmenuView[0].topline=g:qmenuView[0].topline-!g:qmenuView[1]
	let g:TxbKeyHandler=function("QmenuKeyHandler")
	cal feedkeys("\<plug>TxbZ")
endfun

let g:qmenuExitIfNoCycle=0
vmap <expr> q Qmenuv(v:count)
fun! Qmenuv(count)
	let g:q_count=v:count
	let [view,stal]=[winsaveview(),&stal]
	let [view.topline,&stal,&ls,ls]=[view.topline+!stal,1,2,&ls]
	echo strftime('%r %x').' ['.g:LOGDIC[-1][1].(localtime()-g:LOGDIC[-1][0])/60.']'
	call winrestview(view)
	redr
	let [c,view.topline,&stal,&ls]=[getchar(),view.topline-!stal,stal,ls]
	call winrestview(view)
	redr
   	return get(g:Qvis,c,g:Qvis.default)
endfun
let [Qvis.113,Qvhelp.q]=["","exit"]
let Qvis.default=":\<c-u>ec PrintDic(Qvhelp,28)\<cr>"
let [Qvis.42,Qvhelp['*']]=["y:if g:q_count && g:q_count<=3|exe g:q_count.'match Match'.g:q_count.' \"'.escape(@\",'\"').'\"'|else|,$s/\\V\<c-r>=@\"\<cr>//gce|echo 'Continue at beginning of file? (y/q)'|if getchar()==121|1,''-&&|en|en".repeat("\<left>",80),"Replace selection"]
let [Qvis.120,Qvhelp.x]=["y: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>","Source selection"]
let [Qvis.67,Qvhelp.C]=["\"*y:let @*=substitute(@*,\" \\n\",' ','g')\<cr>","Copy to clipboard"]
let [Qvis.103,Qvhelp.g]=["y:\<c-r>\"","Copy to command line"]
let [Qvis.115,Qvhelp.s]=["y/\<c-r>\"\<cr>","Search"]
let Qvis.124=":\<c-u>let q_sav=[&fo,&tw]|let &tw=&tw-4|exe stridx(&fo,'a')==-1? '' : 'norm! gvgq'|let &fo=''|'<,'>norm! I  | \<cr>:let [&fo,&tw]=q_sav\<cr>"
let Qnrm.default=":ec PrintDic(g:Qnhelp,28)\<cr>"
let g:LASTFUNC=exists('g:LASTFUNC')? g:LASTFUNC : ''
let [Qnrm.f,Qnhelp.f]=[":if g:q_count|call search('^f\\S*\\ \\S*'.g:LASTFUNC.'(')|exe 'norm! '.g:q_count.'j'|else|let g:LASTFUNC=expand('<cword>')|call search('^f\\S*\\ \\S*'.expand('<cword>').'(')|en\<cr>","Go to function"]
let [Qnrm.F,Qnhelp.F]=[":if !&ls|se stal=2|se ls=2|else|se stal=0|se ls=0|en\n","Enable status & tab"]
let [Qnrm[':'],Qnhelp[':']]=["q:","commandline normal"]
let [Qnrm.i,Qnhelp.i]=[":se invlist\<cr>","List invisible chars"]
let [Qnrm.v,Qnhelp.v]=[":se invwrap|echo 'Wrap '.(&wrap? 'on' : 'off')\<cr>","Wrap toggle"]
let [Qnrm.z,Qnhelp.z]=[":wa\<cr>","Write all buffers"]
let [Qnrm.D,Qnhelp.D]=[":redi@t|sw|redi END\<cr>:!rm \<c-r>=escape(@t[1:],' ')\<cr>\<bs>*","Remove this swap file"]
let [Qnrm.q,Qnhelp.q]=["","exit"]
let Qnrm["\<c-[>"]=""
let [Qnrm.g,Qnhelp.g]=[":noh\<cr>","go away highlight"]
let [Qnrm.G,Qnhelp.G]=[":noh|match|2match|3match\<cr>","go away highlight"]
let [Qnrm["\<f1>"],Qnhelp["<f1>"]]=["vawly:h \<c-r>=@\"[-1:-1]=='('? @\":@\"[:-2]\<cr>\<cr>","Help word under cursor"]
let [Qnrm.1,Qnrm.2,Qnrm.3]=map(range(1,3),'":tabn".v:val."\<cr>"')
	let Qnhelp['1..3']="Switch tabs"
let [Qnrm.4,Qnrm.5,Qnrm.6]=map(range(4,6),'"@".v:val')
	let Qnhelp['4..6']="Playback macro"
let [Qnrm["\<c-i>"],Qnrm[" "],Qnhelp['<tab,space']]=[":tabp|let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>",":tabn|let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>","Tabs <>"]
let [Qnrm.d,Qnrm.s,Qnhelp.sd]=[":wincmd w|let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>",":wincmd W|let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>","Columns <>"]
let [Qnrm.w,Qnrm.e,Qnhelp.we]=[":norm! g;zz\<cr>:let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>",":norm! g,zz\<cr>:let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>","Changes <>"]
let [Qnrm["\<c-w>"],Qnhelp['^W']]=[":tabc|let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>","tabc"]
let [Qnrm.M,Qnrm.m,Qnhelp['mM']]=[":tabm -1|let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>",":tabm +1|let g:qmenuExitIfNoCycle=1|call feedkeys('q')\<cr>","tabm <>"]
let Qnrm["*"]=":if g:q_count && g:q_count<=3|exe g:q_count.'match Match'.g:q_count.' \"'.escape(expand('<cword>'),'\"').'\"'|else|,$s/\\<\<c-r>=expand('<cword>')\<cr>\\>//gce|echo 'Continue at beginning of file? (y/q)'|if getchar()==121|1,''-&&|en|en".repeat("\<left>",80)
let Qnrm["#"]=":'<,'>s/\<c-r>=expand('<cword>')\<cr>//gc\<left>\<left>\<left>"
	let Qnhelp['*#']="Replace word"
let [Qnrm.x,Qnhelp.x]=["vipy: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>","Source paragraph"]
let [Qnrm.t,Qnhelp.Tt]=[":cal g:logdic.show()\<cr>","Show log files"]
let Qnrm.T=Qnrm.t
let [Qnrm.I,Qnhelp.I]=[":startreplace\<cr>","Replace mode"]
	nn R <c-r>

fun! PrintDic(dict,width)
	let [L,cols,keys]=[len(a:dict),min([(&columns-1)/a:width,18]),sort(keys(a:dict))]
	let rows=L/cols+(L%cols!=0)
	return join(map(map(range(rows),"map(range(v:val,cols*rows-1+v:val,rows),'v:val>=L? \"\" : keys[v:val].\" \".(type(a:dict[keys[v:val]])<=1? a:dict[keys[v:val]] : string(a:dict[keys[v:val]]))')"),'printf("'.join(map(range(cols),'"%-".a:width.".".a:width.(v:version>703? "S":"s")'),'').'",'.join(map(range(cols),"'v:val['.v:val.']'"),',').')'),"\n")
endfun

let asciidic={}
for i in range(1,256)
	let asciidic[printf("%3d",i)]=strtrans(nr2char(i))
endfor
fun! AsciiUI()
	ec PrintDic(g:asciidic,7) "\n"
	let word=expand("<cword>")
	norm! ga
	if word>0
		ec 'Number under cursor: '.word.' --> '.strtrans(nr2char(word+0))
	en
	ec "Enter number or char: "
	let c=getchar()
	let char=''
	while c>=48 && c<=57
		echon nr2char(c)
		let char.=nr2char(c)
		if len(char)>2 || char>25
			break
		en
		let c=getchar()
	endwhile
	if empty(char)
  		redr | echon strtrans(nr2char(c)) ' --> ' c
		let @"=c
	else
		let @"=nr2char(char+0)
		redr | echon char ' --> ' strtrans(@")
	en
endfun
let [Qnrm.a,Qnhelp.a]=[":call AsciiUI()\<cr>","Show Ascii"]

if !exists("g:EscChar") | let g:EscChar="\e" | let g:EscAsc=27
el | let g:EscAsc=char2nr(g:EscChar) |en
if g:EscChar!="\e"
	exe 'no <F2>' g:EscChar
	exe 'no' g:EscChar '<Esc>'
   	exe 'no!' g:EscChar '<Esc>'
   	exe 'cno' g:EscChar '<C-C>'
en

nno <space> <c-e>
nno <bs> <c-y>
nno <c-i> <c-y>
vn j gj
vn k gk
nn j gj
nn k gk
nn gp :exe 'norm! `['.strpart(getregtype(), 0, 1).'`]'<cr>
nn gA :let @_=!search('\S\s*\n\s*\n','W') && !search('\%$','W') \|startinsert!<cr>

let s:sur_pairs={'(':')','{':'}','<':'>','[':']'}
fun! VisTrimWhitespace()
	norm! `<
	call search('\S','c')
	norm! m<`>
	call search('\S','bc')
	norm! m>
endfun
fun! VisSurround(brace)
	call VisTrimWhitespace()
	let @t=nr2char(a:brace)
	let @u=get(s:sur_pairs,@t,@t)
	norm! `>"up`<"tP
endfun
vn S :<c-u>call VisSurround(getchar())<cr>
vn T :<c-u>call VisTrimWhitespace()<cr>`>x`<x

fun! SoftCap()
	norm! a^
	redr
	let key=getchar()
	while key!=g:EscAsc && key!=8
		if key=="\<bs>"
			undoj | norm! X
		elseif key==23 || key==31
			undoj | norm! db
		el | undoj | exe "norm! i".toupper(nr2char(key))."\el" |en
		redr
		let key=getchar()
	endwhile
	undoj | norm! x
	if col(".")+1==col("$")
		startinsert!
	else
		startinsert
	en
endfun
let [Qnrm["\<c-m>"],Qnhelp['<enter>']]=[":call SoftCap()\<cr>","Caps lock"]
ino <c-h> <esc>:call SoftCap()<cr>

com! -nargs=+ -complete=var Editlist call New('NestedList',<args>).show()
com! DiffOrig belowright vert new|se bt=nofile|r #|0d_|diffthis|winc p|diffthis

hi CS_LightOnDark ctermfg=15 ctermbg=0 cterm=NONE
if opt_device=='cygwin'
	hi CS_DarkOnLight ctermfg=15 ctermbg=0 cterm=Bold
else
	hi CS_DarkOnLight ctermfg=0 ctermbg=15 cterm=NONE
en
let CS_attr=['NONE','bold','underline','undercurl','reverse','italic','standout']
let CS_attrIx={'NONE':0,'bold':1,'underline':2,'undercurl':3,'reverse':4,'italic':5,'standout':6}
let CS_histL=[[0,7,'NONE']]
let CS_histi=0
let CS_grp='Normal'
fun! CS_hi(group,list)
	exe a:list[0] is 'LINK-->'? 'hi! link '.a:group.' '.a:list[1] : 'hi '.a:group.' ctermfg='.a:list[0].' ctermbg='.a:list[1].' cterm='.a:list[2]
endfun
fun! CSLoad(scheme)
	if has_key(g:SCHEMES,a:scheme)
		for k in keys(g:SCHEMES[a:scheme])
			call CS_hi(k,g:SCHEMES[a:scheme][k])
		endfor
	else
    	let g:SCHEMES[a:scheme]={}
	en
endfun
fun! CompleteSwatches(Arglead,CmdLine,CurPos)
	return filter(keys(g:SCHEMES.swatches),'v:val=~a:Arglead')
endfun
fun! CompleteSchemes(Arglead,CmdLine,CurPos)
	return filter(keys(g:SCHEMES),'v:val=~a:Arglead')
endfun
fun! CS_UI()
    cno <expr> = g:CS_input=='group'? "\<cr>" : "="
    cno <expr> <bs> g:CS_input=='group' && getcmdline()==''? "CS_EXIT\<cr>" : "\<bs>"
    exe "cno <expr> ".nr2char(31)." g:CS_input=='group' && getcmdline()==''? \"CS_EXIT\\<cr>\" : \"\\<c-u>\""
    cno . <cr>
	sil exe "norm! :hi \<c-a>')\<c-b>let \<right>\<right>=split('\<del>\<cr>"
	let hlUnderCursor=synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name')
	if !empty(hlUnderCursor)
		let g:CS_grp=hlUnderCursor
 		let fg=synIDattr(synIDtrans(hlID(g:CS_grp)),'fg')
 		let bg=synIDattr(synIDtrans(hlID(g:CS_grp)),'bg')
		let hl=copy(get(g:SCHEMES[g:CS_NAME],g:CS_grp,[fg>-1? fg : 'NONE',bg>-1? bg : 'NONE','NONE']))
	else
		let hl=copy(get(g:SCHEMES[g:CS_NAME],g:CS_grp,g:CS_histL[-1]))
	en
	let swatchlist=keys(g:SCHEMES.swatches)
	let continue=1
	let g:CS_input=''
	let field=0
	while continue
		if g:CS_histi<=len(g:CS_histL)-1
			let g:CS_histL[g:CS_histi]=copy(hl)
		el| call add(g:CS_histL,copy(hl))
			let g:CS_histi=len(g:CS_histL)-1 |en
		call CS_hi(g:CS_grp,hl)
		redr!
		echohl CS_LightOnDark
		if len(hl)<3
			let hl+=['NONE']
		en
		echon '> let SCHEMES.' g:CS_NAME '.' g:CS_grp
		if hl[0] is 'LINK-->'
			echon ' --> '.hl[1]
		else
			echon ' = [ '
			for i in range(3)
				if field==i
					echohl CS_DarkOnLight
					echon hl[i]
					echohl CS_LightOnDark
					echon ' '
				else
					echon hl[i].' '
				en
			endfor
			echon ']'
		en
		exe "echoh" g:CS_grp
		echon ' hjklJKr <bs>Up <cr>Save [L]ink [g]oLink [WR]Favs [bf]Hist [U]nlet [^R]eload [*]Random'
		exe get(g:colorD,getchar(),'')
	endwhile
	if len(g:CS_histL)>100
		let CS_histL=g:CS_histi<25? (g:CS_histL[:50]) : g:CS_histi>75? (g:CS_histL[50:])
		\: g:CS_histL[g:CS_histi-25:g:CS_histi+25] |en
	echoh None
	redr! | ec ''
	cunmap =
	cunmap <bs>
	cunmap .
endfun
let colorD={}
let colorD.103='if hl[0] is "LINK-->" | let g:CS_grp=hl[1] | let hl=get(g:SCHEMES[g:CS_NAME],g:CS_grp,hl) | en'
let colorD.76='echohl CS_LightOnDark | let name=input("> Link to: ","","highlight") | if !empty(name) | let hl=["LINK-->",name,"NONE"] |en'
let colorD.113="let continue=0 | if has_key(g:SCHEMES[g:CS_NAME],g:CS_grp) | call CS_hi(g:CS_grp,g:SCHEMES[g:CS_NAME][g:CS_grp]) | en"
let colorD[EscAsc]=colorD.113
let colorD.10="call CS_hi(g:CS_grp,hl) | let g:SCHEMES[g:CS_NAME][g:CS_grp]=copy(hl) | echohl CS_LightOnDark | ec '> SCHEMES.'.g:CS_NAME.'.'.g:CS_grp.' saved' | sleep 700m"
let colorD.13=colorD.10
let colorD.101="redr | echohl CS_LightOnDark | let in=input('> let SCHEMES.'.g:CS_NAME.'.'.g:CS_grp.'['.field.'] = ') | if !empty(in) | let hl[field]=in | en"
let colorD.99=colorD.101
let colorD.74="if hl[0] isnot 'LINK-->' | let hl[field]='NONE' | en"
let colorD.75="if hl[0] isnot 'LINK-->' | let hl[field]=field==2? 'NONE' : 100 | en"
let colorD.104='let field=(field+2)%3'
let colorD.108='let field=(field+1)%3'

let colorD.106='if hl[0] isnot "LINK-->" | let [hl[field],g:CS_histi]=field<2? [hl[field] is "NONE"? 255 : hl[field] == 0? "NONE" : hl[field]-1,g:CS_histi+1] : [g:CS_attr[(get(g:CS_attrIx,hl[2], 1)-1)%len(g:CS_attr)],g:CS_histi+1] | el | let hl=[synIDattr(synIDtrans(hlID(g:CS_grp)),"fg"),synIDattr(synIDtrans(hlID(g:CS_grp)),"bg"),"NONE"] | en'
let colorD.107='if hl[0] isnot "LINK-->" | let [hl[field],g:CS_histi]=field<2? [hl[field] is "NONE"? 0 : hl[field] == 255? "NONE" : hl[field]==0? 1 : hl[field]+1,g:CS_histi+1] : [g:CS_attr[(get(g:CS_attrIx,hl[2],-1)+1)%len(g:CS_attr)],g:CS_histi+1] | el | let hl=[synIDattr(synIDtrans(hlID(g:CS_grp)),"fg"),synIDattr(synIDtrans(hlID(g:CS_grp)),"bg"),"NONE"] | en'

let colorD.98='if g:CS_histi > 0 | let g:CS_histi-=1 | let hl=copy(g:CS_histL[g:CS_histi]) | en'
let colorD.102='if g:CS_histi<len(g:CS_histL)-1|let g:CS_histi+=1|let hl=copy(g:CS_histL[g:CS_histi]) |en'
let colorD.114='let [hl[field],g:CS_histi]=[field==2? hl[field] : reltime()[1]%256,g:CS_histi+1]'
let colorD.42='let [hl,g:CS_histi]=[[reltime()[1][0:2]%256,reltime()[1][3:5]%256,hl[2]],g:CS_histi+1]'
let colorD.85="redr | echohl CS_LightOnDark\n
\if input('> unlet SCHEME.'.g:CS_NAME.'.'.g:CS_grp.'? (y/n)','')==?'y' && has_key(g:SCHEMES[g:CS_NAME],g:CS_grp)\n
	\unlet g:SCHEMES[g:CS_NAME][g:CS_grp]\nen"
let colorD["\<bs>"]="if has_key(g:SCHEMES[g:CS_NAME],g:CS_grp)\n
	\call CS_hi(g:CS_grp,g:SCHEMES[g:CS_NAME][g:CS_grp])\n
\en\nredr!\nechoh None\n
\let g:CS_input='group'\n
\echohl CS_LightOnDark\n
\let in=input('> let SCHEMES.'.g:CS_NAME.'.',g:CS_grp,'highlight')\n
\let g:CS_input=''\n
\if in=='CS_EXIT'\n
	\redr\n
	\let g:CS_input='scheme'\n
	\echohl CS_LightOnDark\n
	\let name=input('> let SCHEMES.',g:CS_NAME,'customlist,CompleteSchemes')\n
	\let g:CS_input=''\n
	\if !empty(name)\n
		\let g:CS_NAME=name\n
		\call CSLoad(name)\n
		\exe g:colorD[\"\<bs>\"]\n
	\else\n
		\let continue=0\n
	\en\n
\elseif !empty(in)\n
	\if has_key(g:SCHEMES[g:CS_NAME],in)\n
		\let hl=copy(g:SCHEMES[g:CS_NAME][in])\n
	\elseif hlID(in)\n
		\let id=synIDtrans(hlID(in))\n
		\let hl=[synIDattr(id,'fg','cterm'),synIDattr(id,'bg','cterm'),join(filter(copy(g:CS_attr[1:]),'synIDattr(id,v:val,\"cterm\")'),',')]\n
		\let hl=[hl[0]==-1? 'NONE' : hl[0],hl[1]==-1? 'NONE' : hl[1],empty(hl[2])? 'NONE' : hl[2]]\n
	\en\n
	\let g:CS_grp=in\n
\el\nlet continue=0\nen"
let colorD.31=colorD["\<bs>"]
let colorD.21=colorD["\<bs>"]
let colorD.87='echohl CS_LightOnDark | let name=input("  save as: SCHEMES.swatches.","","customlist,CompleteSwatches") | if !empty(name) | let g:SCHEMES.swatches[name]=copy(hl) |en'
let colorD.82="echo ''|let ix=0|for i in sort(keys(g:SCHEMES.swatches))\n
	\call CS_hi('CS_'.ix,g:SCHEMES.swatches[i])\n
	\exe 'echohl CS_'.ix\n
	\echon '   '.i.'   '\n
	\let ix+=1\n
\endfor\n".'echohl CS_LightOnDark | let name=input("> let SCHEMES.".g:CS_NAME.".".g:CS_grp." = SCHEMES.swatches.","","customlist,CompleteSwatches") | if !empty(name) && has_key(g:SCHEMES.swatches,name) | let g:CS_histi=g:CS_histi+1 | let hl=copy(g:SCHEMES.swatches[name]) | else | echo "  **Swatch not found**" | sleep 1 | en'
let colorD.18='call CSLoad(g:CS_NAME)'
let [Qnrm.C,Qnhelp.C]=[":call CS_UI()\<cr>","Colors chooser"]
let [Qnrm["\<c-g>"],Qnhelp['^G']]=[":ec 'hi<' . synIDattr(synID(line('.'),col('.'),1),'name') . '> trans<'
\ . synIDattr(synID(line('.'),col('.'),0),'name') . '> lo<'
\ . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . '>'\<cr>","Get highlight"]

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

cnorea <expr> we ((getcmdtype()==':' && getcmdpos()<4)? 'w\|e' :'we')
cnorea <expr> ws ((getcmdtype()==':' && getcmdpos()<4)? 'echom "========================== sourcing ".expand("%").": ".strftime("%c")." =========================="\|up\|so%' : 'ws')
cnorea <expr> wd ((getcmdtype()==':' && getcmdpos()<4)? 'w\|bd':'wd')

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
	elseif stridx(b:CapSeparators,a:prev)!=-1
		let g:charL=[]
		return (next=~#'[A-Z]'? tolower(next) : toupper(next)). "\<del>"
	el| let g:charL=[]
		return next."\<del>"
	endif
endfun
fun! CapHere()
	let trunc = getline(".")[:col(".")-2]
	return col(".")==1 ? (b:CapSeparators!=' '? CapWait("\r") : "\<del>") : (trunc=~'[?!.]\s*$\|^\s*$' && trunc!~'\.\.\s*$') ? (CapWait(trunc[-1:-1])) : "\<del>"
endfun
fun! LoadFormatting()
	if !filereadable(expand('%'))
		echom 'New file '.expand('%')
	en
	let options=getline(1)
	if options=~?'foldmark'
		exe "ab <buffer> /f {{{\<cr>\<cr>\<cr>\}}}\<esc>3k$a\<c-o>"
		nn <buffer>	<lf> za
		nn <buffer> <rightmouse> <leftmouse>za
		setl fdm=marker
		setl fdt=FoldText()
	elseif options=~?'foldpara'
		nn <buffer>	<lf> za
		nn <buffer> <rightmouse> <leftmouse>za
		setl fdm=expr
		setl foldexpr=getline(v:lnum)=~'^\\s*$'&&getline(v:lnum+1)=~'\\S'?'<1':1
		setl fdt=getline(v:foldstart) | en
	if options=~?'hardwrap'
		setl nowrap fo=aw
		let number=matchstr(options,'hardwrap\zs\d*')
		exe "setl tw=".(empty(number)? 70 : number)
		nn <buffer>	<cr> +
		nn <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
		nn <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
	elseif options=~?'prose' |  setl wrap | en
	if &fo=~#'a'
		if &fo=~#'w'
			no <buffer> <silent> <expr> { WWGoPar(v:count1,1)
			no <buffer> <silent> <expr> } WWGoPar(v:count1,0)
			nn <buffer> <silent> I :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>i
			nn <buffer> <silent> A 0:exe 'norm! '.(search('\S\n\\|\s\n\s*\n','W')? 'g' : '$')<CR>a
		el| nn <buffer> <silent> I :call search('^\s*\n\s*\S\\!\%^','Wbec')<CR>i
			nn <buffer> <silent> A 0:exe 'norm! '.(search('\S\s*\n\s*\n','Wc')? 'g' : '$')<CR>a
		en|en
	if options=~?'prose'
		syntax region Bold matchgroup=Normal start=+\(\W\|^\)\zs\*\ze\w+ end=+\w\zs\*+ concealends
		syntax region Underline matchgroup=Normal start=+\(\W\|^\)\zs\/\ze\w+ end=+\w\zs\/+ concealends
		syntax match Label +^txb\S*: \zs.[^#\n]*+ oneline display
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
	en
endfun

com! -nargs=? -complete=file RestoreSettings call LoadViminfoData(<f-args>)
fun! LoadViminfoData(...)
	if a:0
		if a:1 isnot 0
			if filereadable(a:1)
				exe 'rv!' a:1
			else
				echohl ErrorMsg
					echo 'File unreadable: ' a:1
				echohl None
				return
			en
		en
	else
		if filereadable('viminfo.bak')
			rv! viminfo.bak
		else
			echohl ErrorMsg
				echo 'viminfo.bak unreadable'
			echohl None
			return
		en
	en
	silent exe "norm! :let v=g:SAVED_\<c-a>'\<c-b>\<right>\<right>\<right>\<right>\<right>\<right>'\<cr>"
	if exists('v') && len(v)>8
		for var in split(v)
			unlet! {'g:'.var[8:]}
			let {'g:'.var[8:]}=eval({var})
		endfor
	en
	let g:logdic=exists('g:LOGDIC')? New('Log',g:LOGDIC) : New('Log')
	let g:LOGDIC=g:logdic.L
	cal g:logdic.setcursor(len(g:LOGDIC)-1)
	let g:SCHEMES=exists('g:SCHEMES')? g:SCHEMES : {'swatches':{},'default':{}}
	let g:SCHEMES.swatches=has_key(g:SCHEMES,'swatches')? g:SCHEMES.swatches : {}
	let g:CS_NAME=exists('g:CS_NAME')? g:CS_NAME : 'default'
	cal CSLoad(g:CS_NAME)
	echom "Something wrong? Use :RestoreSettings viminfo.bak to load previous states."
endfun
fun! WriteViminfo(file,...)
	if v:version<703 || v:version==703 && !has("patch30") || a:0>=1 && !empty(a:1)
		sil exe "norm! :unlet! g:SAVED_\<c-a>\<cr>"
		sil exe "norm! :let g:\<c-a>'\<c-b>\<right>\<right>\<right>\<right>v='\<cr>"
		for name in split(v)
			if name[2:]==#toupper(name[2:])
				if "000110"[type({name})]
					let {"g:SAVED_".name[2:]}=substitute(string({name}),"\n",'''."\\n".''',"g")
					if a:file==#'exit'
						exe "unlet!" name
					en
			en | en
		endfor
	en
	if a:file==#'exit'  "curdir is necessary to retain relative path
		exe 'cd '.g:Working_Dir
		se sessionoptions=winpos,resize,winsize,tabpages,folds,curdir
		if argc()
			argd *
		else
			if !has('gui_running')
				mksession! .lastsession
			else
				mksession! .lastsession-gvim
			en
		en
		sil exe '!mv '.g:Viminfo_File.' '.g:Viminfo_File.'.bak'
		exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".g:Viminfo_File
	el| exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".a:file
		wv! |en
endfun

fun! CIcompare(a,b)
	return toupper(a:a)<toupper(a:b)? -1:1
endfun
fun! MyCompare(i1, i2)
   return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc
fun! PagerSearch() dict
	let self.searchterm=input('Search: ',self.searchterm)
	let match=match(self.type==3? self.L : self.Lkeys,self.searchterm,self.cursor+1)
	if match==-1 | let match=match(self.type==3? self.L : self.Lkeys,self.searchterm) | en
	if match!=-1 | let self.cursor=match | en
endfun
fun! PagerEval() dict
	let ix=self.type==4? self.Lkeys[self.cursor] : self.cursor
	let self.L[ix]=eval(self.L[ix])
endfun
fun! PagerPrint() dict
	if self.type==3
		echon "\n" join(map(range(self.offset,self.offset+&lines-2),'(v:val<0 || v:val>='.len(self.L).')? "" : (('.self.cursor.'==v:val? ">":" ").'.(self._shownum? 'v:val.' : '').'(type(self.L[v:val])>1? string(self.L[v:val]) : self.L[v:val]))[:&columns-4]'),"\n") "\n" self.cursor ' / ' len(self.L)
	else
		echon "\n" join(map(range(self.offset,self.offset+&lines-2),'(v:val<0 || v:val>='.len(self.L).')? "" : (('.self.cursor.'==v:val? ">":" ").self.Lkeys[v:val]." ".(type(self.L[self.Lkeys[v:val]])>1? string(self.L[self.Lkeys[v:val]]) : self.L[self.Lkeys[v:val]]))[:&columns-4]'),"\n") "\n"
	en
endfun
fun! PagerT() dict
	let self.cursor=0
endfun
fun! PagerG() dict
	let self.cursor=len(self.L)-1
endfun
fun! PagerA() dict
	if self.type==4 | call self.dictchange() | return | en
	let in=input("Append: ")
	if !empty(in)
		call add(self.L,in)
		let self.cursor=len(self.L)-1 |en
endfun
fun! Pageri() dict
	if self.type==4 | call self.dictchange() | return | en
	let in=input("Insert before: ")
	if !empty(in)
		if len(self.L)==0
			call insert(self.L,in)
			let self.cursor==0
		el| call insert(self.L,in,self.cursor) |en
	en
endfun
fun! Pagera() dict
	if self.type==4 | call self.dictchange() | return | en
	let in=input("Insert after: ")
	call insert(self.L,in,self.cursor+1)
	let self.cursor+=1
endfun
fun! PagerDictChange() dict
	let key=input("Enter key: ",self.Lkeys[self.cursor])
	if has_key(self.L,key)
		let self.L[key]=input("Change: ",type(self.L[key])>1? string(self.L[key]):self.L[key])
		let self.cursor=match(self.Lkeys,'^'.key.'$')
	el| let self.L[key]=input("New: ")
		call add(self.Lkeys,key)
		let self.cursor=len(self.Lkeys)-1 |en
endfun
fun! Pagerq() dict
	let self.ent=g:EscAsc
endfun
fun! PagerDictPaste()
	let key=input("Enter key: ",self.Lkeys[self.cursor])
	if has_key(self.L,key)
		if input("Overwrite existing key?(y/n)")==?'y'
			let self.L[key]=@"	
		en
		let self.cursor=match(self.Lkeys,'^'.key.'$')
	el| let self.L[key]=@"
		call add(self.Lkeys,key)
		let self.cursor=len(self.Lkeys)-1 |en
endfun
fun! Pagerp() dict
	if self.type==3
		call insert(self.L,@",self.cursor+1)
		let self.cursor+=1
	el| call self.dictpaste() | en
endfun
fun! PagerP() dict
	if self.type==4 | call self.dictpaste() | return | en
	if len(self.L)==0
		call insert(self.L,@",self.cursor+1)
		let self.cursor+=1
	el| call insert(self.L,@",self.cursor) |en
endfun
fun! Pagerm() dict
	let ix=self.type==4? self.Lkeys[self.cursor] : self.cursor
	if type(self.L[ix])<=1
		if self.L[ix][:1]=='x '
			let self.L[ix]='+ '.self.L[ix][2:]
		elseif self.L[ix][:1]=='+ '
			let self.L[ix]=self.L[ix][2:]
		el | let self.L[ix]='x '.self.L[ix] |en
	en
endfun
fun! Pagerc() dict
	if self.type==3
		let ix=self.cursor
		let in=input("Change: ",type(self.L[ix])>1? string(self.L[ix]) : self.L[ix])
		if !empty(in) | let self.L[ix]=in | en
	el| let ix=self.Lkeys[self.cursor]
		let in=input("Change key: ")
		if !empty(in)
			let self.L[in]=self.L[ix]
			unlet self.L[ix]
			let self.Lkeys=keys(self.L)
		en
	en
endfun
fun! Pagerj() dict
	if self.cursor<len(self.L)-1 | let self.cursor+=1 | en
endfun
fun! Pagerk() dict
	if self.cursor>0 | let self.cursor-=1 | en
endfun
fun! Pagery() dict
	if self.type==3
		let @"=type(self.L[self.cursor])>1? string(self.L[self.cursor]) : self.L[self.cursor]
	else
		let @"=type(self.L[self.Lkeys[self.cursor]]])>1? string(self.L[self.Lkeys[self.cursor]]) : self.L[self.Lkeys[self.cursor]]
	en
endfun
fun! Pagerx() dict
	let ix=self.type==4? self.Lkeys[self.cursor] : self.cursor
	let @"=type(self.L[ix])%5>1? string(self.L[ix]) : self.L[ix]
	unlet self.L[ix]
	if self.type==4
		unlet self.Lkeys[self.cursor]
	en
	if self.cursor==len(self.L) | let self.cursor=len(self.L)-1 | en
endfun
fun! PagerSetCursor(pos) dict
	let self.cursor=a:pos	
	let self.offset=self.cursor<self.offset? self.cursor : self.cursor>self.offset+&lines-2? self.cursor-&lines+2 : self.offset
endfun
fun! PagerShow() dict
	let self.ent=''
	let moresave=&more
	se nomore
	call self.print()
	while self.ent!=g:EscAsc
		let self.ent=getchar()
		if has_key(self,self.ent)
			call self[self.ent]()
			let self.offset=self.cursor<self.offset? self.cursor : self.cursor>self.offset+&lines-2? self.cursor-&lines+2 : self.offset
			call self.print()
		elseif self.ent!=g:EscAsc
			ec PrintDic(self.helpD,18)
		en
	endw
	redr! | let &more=moresave
endfun
fun! InitPager(list) dict
	let self.L=a:list
	let self.type=type(a:list)
	if self.type==4
		let self.Lkeys=sort(keys(self.L),"CIcompare")
	elseif self.type!=3
		echoerr "Must be list or dictionary!"
		return | en
	let self.helpD={}
	let self.cursor=0
	let self.offset=0
	let self.searchterm=''
	let self._shownum=0
	let self.setcursor=function('PagerSetCursor')
	let self.show=function('PagerShow')
	let self.print=function('PagerPrint')
	let self.dictchange=function('PagerDictChange')
	let self.dictpaste=function('PagerDictPaste')
	let [self.107,self.helpD.k]=[function('Pagerk'),'cursor up']
	let [self.106,self.helpD.j]=[function('Pagerj'),'cursor down']
	let [self.113,self.helpD.q]=[function('Pagerq'),'quit']
	let [self.84,self.helpD.T]=[function('PagerT'),'goto top']
	let [self.120,self.helpD.x]=[function('Pagerx'),'delete']
	let [self.47,self.helpD['/']]=[function('PagerSearch'),'search']
	let [self.121,self.helpD.y]=[function('Pagery'),'yank']
	let [self.69,self.helpD.E]=[function('PagerEval'),'Eval']
	let [self.71,self.helpD.G]=[function('PagerG'),'goto end']
	let [self.99,self.helpD.c]=[function('Pagerc'),'change']
	let [self.109,self.helpD.m]=[function('Pagerm'),'mark']
	let [self.105,self.helpD.i]=[function('Pageri'),'insert']
	let [self.79,self.helpD.O]=[function('Pageri'),'insert']
	let [self.65,self.helpD.A]=[function('PagerA'),'append to end']
	let [self.97,self.helpD.a]=[function('Pagera'),'append']
	let [self.111,self.helpD.o]=[function('Pagera'),'append']
	let [self.80,self.helpD.P]=[function('PagerP'),'paste before']
	let [self.112,self.helpD.p]=[function('Pagerp'),'paste after']
endfun

let s:pagerhlarray={0:'echohl visual',1:'echohl none'}
fun! LogPrint() dict
	echon "\n"
	let loct=[localtime()]
	let sftexpr='printf("%%2d%%s%d %%2d:%M%%s %%4.1f %%.'.(&columns-20).'s",%m,"smtwrfa"[%w],%I,tolower("%p"[0]),(get(self.L,i+1,loct)[0]-self.L[i][0])/3600.0,self.L[i][1])'
	for i in range(max([0,self.offset]),min([len(self.L)-1,self.offset+&lines-2]))
		exe get(s:pagerhlarray,i-self.cursor,'')
		echo eval(strftime(sftexpr,self.L[i][0]))
	endfor
	echohl None
	echon repeat("\n",self.offset+&lines-len(self.L))
	echo strftime('%c',localtime()) self.cursor '/' (len(self.L)-1)
endfun
fun! LogChange() dict
	let in=input('Change: ',self.L[self.cursor][1])
	if !empty(in) | let self.L[self.cursor][1]=in | en
endfun
fun! LogStill() dict
	let self.L[len(self.L)-1][0]=localtime()
	let self.cursor=len(self.L)-1
endfun
fun! LogInsert() dict
	if len(self.L)==0 | let time=localtime()
	el| let time=self.L[self.cursor][0] |en
	let in=input('Insert: ')
	if !empty(in) | call insert(self.L,[time,in],self.cursor) | en
endfun
fun! LogAppend(...) dict
	let in=input('Append: '.strftime('%m.%d %I:%M ',localtime()).'0m ')
	if !empty(in)
		call insert(self.L,[localtime(),in],len(self.L))
		let self.cursor=len(self.L)-1
			if self.cursor<self.offset
				let self.offset=self.cursor
			elseif self.cursor>self.offset+&lines-2
				let self.offset=self.cursor-&lines+2
			endif
		en
endfun
fun! LogBkmrk() dict
	let sepix=stridx(self.L[self.cursor][1],' | ')
	if sepix==-1 | let self.L[self.cursor][1].=' | '.line('.').' '.expand('%')
	el| let self.L[self.cursor][1]=self.L[self.cursor][1][:sepix-1] | en
endfun
fun! Logx() dict
	if len(self.L)>1 | call remove(self.L,self.cursor) | en
	if self.cursor==len(self.L) | let self.cursor=len(self.L)-1 | en
endfun
fun! LogGomrk() dict
	let linenr=stridx(self.L[self.cursor][1],' | ')
	let name=stridx(self.L[self.cursor][1],' ',linenr+3)
	if linenr!=-1 && name!=-1
		let name=self.L[self.cursor][1][name+1:]
		let linenr=self.L[self.cursor][1][linenr+3:name-1]
		if glob(name)!=#glob('%') | exe 'e '.name | en
		call cursor(linenr,0) | norm! zz
	en
endfun
fun! IncMin() dict
	let self.L[self.cursor][0]+=60
endfun
fun! DecMin() dict
	let self.L[self.cursor][0]-=60
endfun
fun! IncHour() dict
	let self.L[self.cursor][0]+=3660
endfun
fun! DecHour() dict
	let self.L[self.cursor][0]-=3660
endfun
fun! PrintChart() dict
	let wd=&columns-15-(&columns-15)%4
	let offset=(localtime()-eval(strftime("%H*3600+%M*60+%S")))%86400
	let initm=self.L[0][0]-(self.L[0][0]-offset)%86400
	let tline=repeat('.',(self.L[0][0]-initm)*wd/86400)
	let marker='-'
	let histL=[[initm,0]]
	for i in range(len(self.L)-1)
		let endm=self.L[i+1][0]-(self.L[i+1][0]-offset)%86400
		let tline.=repeat(self.L[i][1][0],(self.L[i+1][0]-initm)*wd/86400-len(tline))
		if self.L[i][1][0]!=marker | continue | en
		let startm=self.L[i][0]-(self.L[i][0]-offset)%86400
		if startm==histL[-1][0]
			let histL[-1][1]+=min([self.L[i+1][0],startm+86400])-self.L[i][0]
		el| if startm>histL[-1][0]+86400
				call extend(histL,map(range(histL[-1][0]+86400,startm-86400,86400),'[v:val,0]')) |en 
			call add(histL,[startm,min([self.L[i+1][0],startm+86400])-self.L[i][0]]) |en
		if endm>startm
			if endm>startm+86400
				call extend(histL,map(range(startm+86400,endm-86400,86400),'[v:val,86400]'))|en
			call add(histL,[endm,self.L[i+1][0]-endm]) |en
	endfor
	let tline.=repeat(self.L[-1][1][0],(localtime()-initm)*wd/86400-len(tline))
	let [startm,endm]=self.L[-1][1][0]==marker? 
	\[self.L[-1][0]-(self.L[-1][0]-offset)%86400,localtime()-(localtime()-offset)%86400]
	\:[localtime()-(localtime()-offset)%86400,0]
 	let extendval=(self.L[-1][1][0]==marker)*86400
	if startm==histL[-1][0]
 		if extendval
			let histL[-1][1]+=min([localtime(),startm+86400])-self.L[-1][0] |en
	el| if startm>histL[-1][0]+86400
			call extend(histL,map(range(histL[-1][0]+86400,startm-86400,86400),'[v:val,extendval]')) |en 
		call add(histL,[startm,(self.L[-1][1][0]==marker)*(min([localtime(),startm+86400])-self.L[-1][0])]) |en
	if endm>startm
		if endm>startm+86400
			call extend(histL,map(range(startm+86400,endm-86400,86400),'[v:val,extendval]'))|en
		call add(histL,[endm,(self.L[-1][1][0]==marker)*(localtime()-endm)]) |en
	echon "\n\n" join(map(histL,'eval(strftime("printf(\"%%d%%s%d%%2d:%%02d \",%m,\"SMTWRFA\"[%w],v:val[1]/3600,v:val[1]/60%%60)",v:val[0])).tline[v:key*wd : v:key*wd+wd/4-1]." ".tline[v:key*wd+wd/4:v:key*wd+wd/2-1]." ".tline[v:key*wd+wd/2: v:key*wd+3*wd/4-1]." ".tline[v:key*wd+3*wd/4:(v:key+1)*wd-1]'),"\n") "\n Press any key to continue"
	call getchar()
endfun
fun! LogClear() dict
	if input("Type 'clear' to clear log: ")==?'clear'
		unlet self.L[:]
		call add(self.L,[localtime(),'-'])
		call self.cons()
	en
endfun
fun! InitLog(...) dict
	let self.supercons=function('InitPager')
	if a:0==0
		if has_key(self,'L') | call self.supercons(self.L)
		el| call self.supercons([[localtime(),'-']]) |en
	el| call self.supercons(a:1) | en
	let self.columns=&columns
	let self.print=function('LogPrint')
	let [self.65,self.helpD.A]=[function('LogAppend'),'Append']
	let [self.105,self.helpD.i]=[function('LogInsert'),'insert']
	let [self.115,self.helpD.s]=[function('LogStill'),'still']
	let [self.103,self.helpD.g]=[function('LogGomrk'),'goto bookmark']
	let [self.98,self.helpD.b]=[function('LogBkmrk'),'bookmark']
	let [self.99,self.helpD.c]=[function('LogChange'),'change']
	let [self.97,self.helpD.a]=[function('LogAppend'),'Append']
	let [self.111,self.helpD.o]=[function('LogAppend'),'Append']
	let [self.120,self.helpD.x]=[function('Logx'),'delete']
	let [self.79,self.helpD.O]=[function('LogInsert'),'insert']
	let [self.40,self.helpD['{']]=[function('DecMin'),'minute--']
	let [self.41,self.helpD['}']]=[function('IncMin'),'minute++']
	let [self.123,self.helpD['(']]=[function('DecHour'),'hour--']
	let [self.125,self.helpD[')']]=[function('IncHour'),'hour++']
	let [self.112,self.helpD.p]=[function('PrintChart'),'print chart']
	let [self.67,self.helpD.C]=[function('LogClear'),'Clear Log']
	unlet! self.69 self.helpD.E self.80 self.helpD.P
endfun

fun! Nestedl() dict      "+ + + + Nested + + + +
	if self.type==3
		if '111001'[type(self.L[self.cursor])] | retu|en
		call add(self.cursorpath,self.cursor)
		call add(self.displaypath,self.cursor)
		call add(self.lengthpath,len(self.L)-self.offset)
		call self.reroot(self.L[self.cursor])
	elseif self.type==4
		if '111001'[type(self.L[self.Lkeys[self.cursor]])] | retu|en
		cal add(self.cursorpath,"'".self.Lkeys[self.cursor]."'")
		call add(self.displaypath,self.cursor)
		call add(self.lengthpath,len(self.Lkeys)-self.offset)
		cal self.reroot(self.L[self.Lkeys[self.cursor]])
	el| retu|en
	let pfexpr="%-".(self.depth*9).".".(self.depth*9)."s"
	call add(self.pathec,range(&lines-1))
	for i in range(len(self.ec))
		let self.pathec[-1][i]=printf(pfexpr,self.pathec[-2][i]).self.ec[i]
	endfor
	for i in range(len(self.ec),&lines-2)
		let self.pathec[-1][i]=self.pathec[-2][i]
	endfor
	cal add(self.offsetpath,self.offset)
	let [self.cursor,self.offset]=has_key(self.historyD,join(self.cursorpath))? self.historyD[join(self.cursorpath)][0]<len(self.L)?  self.historyD[join(self.cursorpath)] : [0,0] : [0,0]
	let self.depth+=1
endfun
fun! Nestedh() dict
	if self.depth>0
		let entryname=join(self.cursorpath)
		let self.historyD[entryname]=[self.cursor,self.offset]
		let [self.cursor, self.offset]=[remove(self.cursorpath,-1),remove(self.offsetpath,-1)]
		call remove(self.displaypath,-1)
		call remove(self.lengthpath,-1)
		call remove(self.pathec,-1)
		let self.depth-=1
		cal self.reroot(self.depth==0? self.root : eval('self.root['.join(self.cursorpath,'][').']'))
		if self.type==4 | let self.cursor=match(self.Lkeys,'^'.self.cursor[1:-2].'$') |en
	en
endfun
fun! Nestedc() dict
	if self.type==3
		let ix=self.cursor
		let in=input("Change: ",type(self.L[ix])>1? string(self.L[ix]) : self.L[ix])
		if !empty(in) | let self.L[ix]=in | en
	el| let ix=self.Lkeys[self.cursor]
		let in=input('New name: ',ix)
		if !empty(in)
			if in!=#ix
				let self.L[in]=self.L[ix]
				unlet self.L[ix]
				let self.Lkeys=sort(keys(self.L))
			en
			let self.L[in]=input('New value: ',type(self.L[in])>1? string(self.L[in]) : self.L[in])
		en
	en
endfun
fun! NestedPrint() dict
	let cursorline=self.cursor-(self.offset>0? self.offset : 0)
	if self.prevdisp!=[self.offset,self.depth] || (self.ent!=106 && self.ent!=107)
		let self.ec=map(range(self.offset>0? self.offset : 0,min([len(self.L)-1,self.offset+&lines-2])),self.type==3? (self._shownum? 'v:val." ".' : "").'strtrans(string(self.L[v:val]))' : 'self.Lkeys[v:val]." ".strtrans(string(self.L[self.Lkeys[v:val]]))')
		let trml=max([self.depth*9+9-&columns+2+min([max(map(range(len(self.ec)),'len(self.ec[v:val])')),&columns/2]),0])
		let self.pathw=self.depth*9-trml
		let self.disp1=map(range(len(self.ec)),'(printf("%-'.self.pathw.'.'.self.pathw.'s",strpart(self.pathec[-1][v:val],'.trml.','.self.pathw.')).self.ec[v:val])[:'.(&columns-3).']."\n"')
		if len(self.ec)<&lines-1
			call extend(self.disp1,map(range(len(self.ec),&lines-2),'strpart(self.pathec[-1][v:val],'.trml.','.(&columns-2).')."\n"'))
		en
	en
	let self.prevdisp=[self.offset,self.depth]
	if self.pathw<1
		echon "\n".join(self.disp1[:cursorline-1],"")
		echohl visual
		echon self.disp1[cursorline]
		echohl none
		echon join(self.disp1[cursorline+1:],"")
	el
		let bytecount=range(len(self.disp1)+1)
		for i in range(1,len(self.disp1))
			let bytecount[i]=bytecount[i-1]+len(self.disp1[i-1])
		endfor
		let pathL=-self.pathw/9-(self.pathw%9!=0)
		let pos=self.displaypath[pathL]-self.offsetpath[pathL]
		let [length,broken]=[(self.pathw-1)%9+1,0]
		for j in range(pathL+1,-1)
			if pos>self.lengthpath[j]	
				let length+=9
			else
				let broken=1
				break
			en
		endfor
		let colorsplits=[0,bytecount[pos],!broken && pos>=len(self.L)-self.offset? bytecount[pos+1]-1 : min([bytecount[pos+1]-1,bytecount[pos]+length])]
		if pathL<-1
			for i in range(pathL+1,-1)
				let pos=self.displaypath[pathL-i]-self.offsetpath[pathL-i]
				let entry=bytecount[pos]+(self.pathw-1)%9-9*i-8
				let [length,broken]=[9,0]
				for j in range(i+1,-1)
					if pos>self.lengthpath[j]	
						let length+=9
					else
						let broken=1
						break
					en
				endfor
				call extend(colorsplits,[entry,!broken && pos>=len(self.L)-self.offset? bytecount[pos+1]-1 : min([bytecount[pos+1]-1,entry+length])])
			endfor
		en
		call extend(colorsplits,[bytecount[cursorline]+self.pathw,bytecount[cursorline+1],bytecount[-1]])
		let self.ecstr=join(self.disp1,'')
		for i in range(1,len(sort(colorsplits,"MyCompare"))-1)
			exe i%2? 'echohl none' : 'echohl visual'
			echon self.ecstr[colorsplits[i-1]:colorsplits[i]-1]
		endfor
	en
endfun
fun! Reroot(list) dict
	let self.L=a:list
	let self.type=type(self.L)
	if self.type==4
		let self.Lkeys=sort(keys(self.L),"CIcompare")
	elseif self.type!=3
		echoerr "Must be list or dictionary!"
	en
endfun
fun! InitNestedList(...) dict
	let self.supercons=function('InitPager')
	call self.supercons(a:0>0? (a:1) : exists('self.root')? self.root : [])
	if a:0>1
		let self.cursor=a:2
		let self.offset=max([0,self.cursor-&lines+2])
	en
	let self.cursorpath=[]
	let self.displaypath=[]
	let self.lengthpath=[]
	let self.offsetpath=[]
	let self.pathec=[repeat([''],&lines-1)]
	let self.prevdisp=[-99,-99]
	let [self.99,self.helpD.c]=[function('Nestedc'),'change']
	let [self.108,self.helpD.l]=[function('Nestedl'),'expand']
	let [self.104,self.helpD.h]=[function('Nestedh'),'collapse']
	let self.reroot=function('Reroot')
	let self.print=function('NestedPrint')
	let self.root=self.L
	let self.historyD={}
	let self.depth=0
endfun

fun! Comp3(i1,i2)   "* * * * Recent Files * * * *
	return g:thisdict[a:i2][3]-g:thisdict[a:i1][3]
endfun
fun! FileListInsert(name,lnum,cnum,w0) dict
	if !empty(a:name) && a:name!~escape($VIMRUNTIME,'\') && !isdirectory(a:name)
		if !has_key(self.L,a:name) | call insert(self.Lkeys,a:name) | en
		let self.L[a:name]=[a:lnum,a:cnum,a:w0,localtime()]
	en
endfun
fun! FileListLoad(file) dict
	let pos=get(self.L,a:file,[])
	if !empty(pos)
		exe "norm! ".pos[2]."z\<cr>".(pos[0]>pos[2]? (pos[0]-pos[2]).'j':'').pos[1].'|'
	en
endfun
fun! FileListPrune(num) dict
	if len(self.L)<a:num+20
		return | en
	let keys=keys(self.L)
	let cutoff=sort(map(copy(keys),"self.L[v:val][3]"))[a:num]
	for i in keys
		if self.L[i][3]>cutoff	
			unlet self.L[i]
		en
		let self.Lkeys=keys(self.L)
	endfor
endfun
fun! FileListEd() dict
	exe 'e '.escape(self.Lkeys[self.cursor],' ')
	let self.ent=g:EscAsc
endfun
fun! FileListTabe() dict
	exe 'tabe '.escape(self.Lkeys[self.cursor],' ')
	let self.ent=g:EscAsc
endfun
fun! FileListSortName() dict
	call sort(self.Lkeys,"CIcompare")	
endfun
fun! FileListSortDate() dict
	let g:thisdict=self.L
	call sort(self.Lkeys,"Comp3")	
endfun
fun! FileListPrint() dict
	let ec=map(range(self.offset,self.offset+&lines-2),'printf("%-'.(&columns-30).'.'.(&columns-30).'s %s",get(self.Lkeys,v:val,""),strftime("%c",get(get(self.L,get(self.Lkeys,v:val,""),""),3)))')
	let hlrow=self.cursor-self.offset
	let str1=join(ec[0:(hlrow)-1],"\n")
	let str2=ec[hlrow]
	let str3=join(ec[hlrow+1:],"\n")."\n".(self.cursor).' / '.(len(self.L)-1)
	redr!
	if hlrow
		ec str1
	en
	echohl visual
	   ec str2
	echohl none
	ec str3
endfun
fun! InitFileList(list) dict
	let self.supercons=function('InitPager')
	call self.supercons(a:list)
	let [self.10,self.helpD['<lf>']]=[function('FileListEd'),'edit file']
	let [self.13,self.helpD['<cr>']]=[function('FileListEd'),'edit file']
	let [self.101,self.helpD.e]=[function('FileListEd'),'edit file']
	let [self.116,self.helpD.t]=[function('FileListTabe'),'tab edit']
	let [self.110,self.helpD.n]=[function('FileListSortName'),'name sort']
	let [self.100,self.helpD.d]=[function('FileListSortDate'),'date sort']
	let self.insert=function("FileListInsert")
	let self.restorepos=function("FileListLoad")
	let self.print=function('FileListPrint')
	let self.prune=function('FileListPrune')
endfun


if !exists('firstrun')
	let firstrun=0
	if !exists('Working_Dir')
		ec 'Warning: g:Working_Dir undefined; using '.$HOME
		let Working_Dir=$HOME
	elseif !isdirectory(glob(Working_Dir))
		ec 'Warning: g:Working_Dir='.Working_Dir.' invalid, using '.$HOME
		let Working_Dir=$HOME
	en
	for file in ['abbrev','nav.vim']   "+utils
		if !empty(glob(Working_Dir.'/'.file))
			exe 'so '.Working_Dir.'/'.file
		el
			ec 'Warning:' Working_Dir.'/'.file 'doesn''t exist'
		en
	endfor
	if !argc() | exe 'cd '.Working_Dir | en
	let setViExpr="se viminfo=!,'120,<100,s10,/50,:500,h,n"
	if !exists('g:Viminfo_File')
		ec "Warning: g:Viminfo_File undefined, falling back to default"
		exe setViExpr[:-3]
	else
"		let viminfotime=strftime("%Y-%m-%d-%H-%M-%S",getftime(glob(g:Viminfo_File)))
"		let conflicts=sort(split(glob(g:Viminfo_File.' (conflicted*'),"\n"))
"		let latest_date=matchstr(get(conflicts,-1,''),'conflicted copy \zs.*\ze)')
"		if !empty(latest_date) && latest_date>viminfotime && input("\nCurrent viminfo (".viminfotime.") older than ".conflicts[-1]."; load latter instead? (y/n)")=~?'^y'
"			echo "Loading" conflicts[-1] "...\nUse :wv to overrite current viminfo."
"			exe setViExpr.conflicts[-1]
"		else
			exe setViExpr.g:Viminfo_File
"		en
	en
	au VimEnter * call LoadViminfoData(0)
	se linebreak sidescroll=1 ignorecase smartcase incsearch wiw=72
	se ai tabstop=4 history=1000 mouse=a hidden backspace=2 stal=0 ls=0
	se wildmode=list:longest,full display=lastline modeline t_Co=256
	se whichwrap+=b,s,h,l,,>,~,[,] wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
	se fcs=vert:\  showbreak=.\ 
    se ttymouse=sgr
	se stl=%t\ %{getwinvar(0,'txbi','-').'\ '.line('w0')}-%l/%L\ %c%V
	if opt_device!~?'windows'
		se term=screen-256color
	en
	if opt_device=~?'cygwin'
		let &t_ti.="\e[2 q"
		let &t_SI.="\e[6 q"
		let &t_EI.="\e[2 q"
		let &t_te.="\e[0 q"
	se noshowmode | en
	au BufRead * call LoadFormatting()
	au BufReadPost * if &key != "" | set noswapfile nowritebackup viminfo= nobackup noshelltemp secure | endif
	au BufNewFile plane* exe "norm! iProse hardwrap60\<esc>500o\<esc>gg" | call LoadFormatting()
	au VimLeavePre * call WriteViminfo('exit')
	if !argc() && filereadable('.lastsession')
		if !has('gui_running')
	 		so .lastsession
		else
			so .lastsession-gvim
		en
	en
	unlet! i conflicts file latest_date setViExpr viminfotime
en

fun! <SID>G(count)
	let [mode,line]=[mode(1),a:count? a:count : cursor(line('.')+1,1)+search('\S\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n','W')? line('.') : line('$')]
	return (mode=='no'? "\<esc>0".v:operator : mode==?'v'? "\<esc>".mode : "\<esc>").line.'G'.(mode=='v'? '$' : '')
endfun
fun! <SID>gg(count)
	let [mode,line]=[mode(1),a:count? a:count : cursor(line('.')-1,1)+search('\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n\S\zs','Wb')? line('.') : 1]
	return (mode=='no'? "\<esc>$".v:operator :  mode==?'v'? "\<esc>".mode : "\<esc>").line.'G'.(mode=='v'? '0' : '')
endfun
no <expr> G <SID>G(v:count)        "G goes to the next nonblank line followed by 6 blank lines (counts still work normally)
no <expr> gg <SID>gg(v:count)      "gg goes to the previous nonblank line followed by 6 blank lines (counts still work normally)

for i in filter(keys(Qnrm),"!has_key(Qnrm,v:val)")
	let Qnrm[i]=":exe exists('t:txb')? \"call TxbKey('\<c-v>".i."')\" : 'ec \"Plane not loaded!\"'\<cr>"
endfor
let Qnrm.o=":exe exists('t:txb')? \"call TxbKey('o')\" : 'ec \"Plane not loaded!\"'\<cr>"
let Qnrm.O=":exe exists('t:txb')? \"call TxbKey('O')\" : 'ec \"Plane not loaded!\"'\<cr>"
let Qnrm[':']=""
