se noloadplugins

let opt_autocap=0
se ttimeoutlen=10

if !exists('opt_device')
	echom "Warning: opt_device is undefined."
	let opt_device=''
en
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
	let &t_ti.="\e[2 q"
	let &t_SI.="\e[6 q"
	let &t_EI.="\e[2 q"
	let &t_te.="\e[0 q"
	se noshowmode
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
	let EscChar='@'
	let opt_autocap=1
	ino <c-b> <c-w>
	nn <c-r> <nop>
en
if opt_device!~?'windows'
	se term=screen-256color
en
if has("gui_running")
	se guifont=Envy_Code_R:h11:cANSI
	colorscheme solarized
	hi ColorColumn guibg=#222222
	hi Vertsplit guifg=grey15 guibg=grey15
	se guioptions-=T
en

se viminfo=!,'120,<100,s10,/50,:500,h
se linebreak sidescroll=1 ignorecase smartcase incsearch wiw=72
se ai tabstop=4 history=1000 mouse=a hidden backspace=2 stal=0 ls=0
se wildmode=list:longest,full display=lastline modeline t_Co=256
se whichwrap+=b,s,h,l,,>,~,[,] wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
se fcs=vert:\  showbreak=.\ 
se ttymouse=sgr
se stl=%t\ %{getwinvar(0,'txbi','-').'\ '.line('w0')}-%l/%L\ %c%V

if !exists('firstrun')
	au BufReadPost * if &key != "" | set noswapfile nowritebackup viminfo= nobackup noshelltemp secure | endif
en

let [Qnrm,Qnhelp,Qvis,Qvhelp]=[{},{},{},{}]
let [Qnrm['-'],Qnhelp['-']]=[":earlier\<cr>",'earlier']
let [Qnrm['='],Qnhelp['=']]=[":later\<cr>",'later']

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

if !exists('firstrun')
	au BufRead * call LoadFormatting()
	au BufNewFile plane* exe "norm! iProse hardwrap60\<esc>500o\<esc>gg" | call LoadFormatting()
	if !argc() && filereadable('.lastsession')
		so .lastsession
	en
en

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

"for i in filter(keys(txbCmd),"!has_key(Qnrm,v:val)")
"let Qnrm[i]=":exe exists('t:txb')? \"call TxbKey('\<c-v>".i."')\" : 'ec \"Plane not loaded!\"'\<cr>"
"endfor
let Qnrm.o=":exe exists('t:txb')? \"call TxbKey('o')\" : 'ec \"Plane not loaded!\"'\<cr>"
let Qnrm.O=":exe exists('t:txb')? \"call TxbKey('O')\" : 'ec \"Plane not loaded!\"'\<cr>"
let Qnrm[':']=""


"github.com/q335r49/microviche ***************************************

if &cp|se nocompatible|en                    "(Vital) Enable vim features
se noequalalways winwidth=1 winminwidth=0    "(Vital) Needed for correct panning
se sidescroll=1                              "Smoother panning
se nostartofline                             "Keeps cursor in the same position when panning
se mouse=a                                   "Enables mouse
se lazyredraw                                "Less redraws
se virtualedit=all                           "Makes leftmost split align correctly
se hidden                                    "Suppresses error messages when a modified buffer pans offscreen
se scrolloff=0                               "Ensures correct vertical panning

augroup TXB | au!

let TXB_HOTKEY=exists('TXB_HOTKEY')? TXB_HOTKEY : '<f10>'
let s:hotkeyArg=':if exists("w:txbi")\|call TxbKey("null")\|else\|if !TxbInit(exists("TXB")? TXB : "")\|let TXB=t:txb\|en\|en<cr>'
exe 'nn <silent>' TXB_HOTKEY s:hotkeyArg
au VimEnter * if escape(maparg('<f10>'),'|')==?s:hotkeyArg | exe 'silent! nunmap <f10>' | en | exe 'nn <silent>' TXB_HOTKEY s:hotkeyArg

if has('gui_running')
	nn <silent> <leftmouse> :exe txbMouse.default()<cr>
else
	au VimResized * if exists('w:txbi') | call s:redraw() |sil call s:nav(eval(join(map(range(1,winnr()-1),'winwidth(v:val)'),'+').'+winnr()-1+wincol()')/2-&co/4,line('w0')-winheight(0)/4+winline()/2) | en
	nn <silent> <leftmouse> :exe txbMouse[has_key(txbMouse,&ttymouse)? &ttymouse : 'default']()<cr>
en

fun! TxbInit(seed)
	se noequalalways winwidth=1 winminwidth=0
	if empty(a:seed)
		let wdir=input("# Creating a new plane...\n? Working dir: ",getcwd(),'file')
		while !isdirectory(wdir)
			if empty(wdir)
				return 1
			en
			let wdir=input("\n# (Invalid directory)\n? Working dir: ",getcwd(),'file')
		endwhile
		let plane={'settings':{'working dir':fnamemodify(wdir,':p')}}
		exe 'cd' fnameescape(plane.settings['working dir'])
			let input=input("\n? Starting files (single file or filepattern, eg, '*.txt'): ",'','file')
			let plane.name=split(glob(input),"\n")
		silent cd -
		if empty(input)
			return 1
		en
	else
		let plane=type(a:seed)==4? deepcopy(a:seed) : type(a:seed)==3? {'name':copy(a:seed)} : {'name':split(glob(a:seed),"\n")}
		call filter(plane,'index(["depth","exe","map","name","settings","size"],v:key)!=-1')
	en
	let prompt=''
	for i in keys(plane.settings)
		if !exists("s:option[i]['save']")
			unlet plane.settings[i]
			continue
		en
		unlet! arg | let arg=plane.settings[i]
		exe get(s:option[i],'check','let msg=0')
		if msg is 0
			continue
		en
		unlet! arg | exe get(s:option[i],'getDef','let arg=""')
		let plane.settings[i]=arg
		let prompt.="\n# Invalid setting (reverting to default): ".i.": ".msg
	endfor
	for i in filter(keys(s:option),'get(s:option[v:val],"save") && !has_key(plane.settings,v:val)')
		unlet! arg | exe get(s:option[i],'getDef','let arg=""')
		let plane.settings[i]=arg
	endfor
	let plane.settings['working dir']=fnamemodify(plane.settings['working dir'],':p')
	let plane_save=deepcopy(plane)
	let plane.size=has_key(plane,'size')? extend(plane.size,repeat([plane.settings['split width']],len(plane.name)-len(plane.size))) : repeat([60],len(plane.name))
	let plane.map=has_key(plane,'map') && empty(filter(range(len(plane.map)),'type(plane.map[v:val])!=4'))? extend(plane.map,eval('['.join(repeat(['{}'],len(plane.name)-len(plane.map)),',').']')) : eval('['.join(repeat(['{}'],len(plane.name)),',').']')
	let plane.exe=has_key(plane,'exe')? extend(plane.exe,repeat([plane.settings.autoexe],len(plane.name)-len(plane.exe))) : repeat([plane.settings.autoexe],len(plane.name))
	let plane.depth=has_key(plane,'depth')? extend(plane.depth,repeat([0],len(plane.name)-len(plane.depth))) : repeat([0],len(plane.name))
	exe 'cd' fnameescape(plane.settings['working dir'])
		let unreadable=[]
		for i in range(len(plane.name)-1,0,-1)
			if !filereadable(plane.name[i])
				if !isdirectory(plane.name[i])
					call add(unreadable,remove(plane.name,i))
				else
					call remove(plane.name,i)
				en
				call remove(plane.size,i)
				call remove(plane.exe,i)
				call remove(plane.map,i)
			en
		endfor
		let initCmd=index(map(copy(plane.name),'bufnr(fnamemodify(v:val,":p"))'),bufnr(''))==-1? 'tabe' : ''
	cd -
	ec "\n#" len(plane.name) "readable:" join(plane.name,', ') "\n#" len(unreadable) "unreadable:" join(unreadable,', ') "\n# Working dir:" plane.settings['working dir'] prompt
	if empty(plane.name)
		ec "# No matches\n? (N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
		let confirmKeys=[-1]
	elseif !empty(unreadable)
		ec "# Unreadable files will be removed!\n? (R)emove unreadable files and ".(empty(initCmd)? "restore " : "load in new tab ")."(N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
		let confirmKeys=[82,114]
	else
		ec "? (enter) ".(empty(initCmd)? "restore " : "load in new tab ")."(N)ew plane (S)et working dir & global options (f1) help (esc) cancel: "
		let confirmKeys=[10,13]
	en
	let c=getchar()
	echon strtrans(type(c)? c : nr2char(c))
	if index(confirmKeys,c)!=-1
		exe initCmd
		let t:txb=plane
		let t:txbL=len(t:txb.name)
		let dict=t:txb.settings
		for i in keys(dict)
			exe get(s:option[i],'onInit','')
		endfor
		exe 'cd' fnameescape(plane.settings['working dir'])
			let t:bufs=map(copy(plane.name),'bufnr(fnamemodify(v:val,":p"),1)')
		cd -
		exe empty(a:seed)? g:txbCmd.M : 'redr'
		call s:getMapDis()
		call s:redraw()
		return 0
	elseif index([83,115],c)!=-1
		let plane=plane_save
		call s:settingsPager(plane.settings,['Global','hotkey','mouse pan speed','Plane','working dir'],s:option)
		return TxbInit(plane)
	elseif index([78,110],c)!=-1
		return TxbInit('')
	elseif c is "\<f1>"
		exe g:txbCmd[c]
		ec mes
	en
	return 1
endfun

let txbMouse={}
fun! txbMouse.default()
	if exists('w:txbi')
		let cpos=[line('.'),virtcol('.'),w:txbi]
		let [c,w0]=[getchar(),-1]
		if c!="\<leftdrag>"
			call s:setCursor(cpos[0],cpos[1],cpos[2])
			echon getwinvar(v:mouse_win,'txbi') '-' v:mouse_lnum
			return "keepj norm! \<leftmouse>"
		en
		let ecstr=w:txbi.' '.line('.')
		while c!="\<leftrelease>"
			if v:mouse_win!=w0
				let w0=v:mouse_win
				exe "norm! \<leftmouse>"
				if !exists('w:txbi')
					return ''
				en
				let [b0,wrap]=[winbufnr(0),&wrap]
				let [x,y,offset]=wrap? [wincol(),line('w0')+winline(),0] : [v:mouse_col-(virtcol('.')-wincol()),v:mouse_lnum,virtcol('.')-wincol()]
			else
				if wrap
					exe "norm! \<leftmouse>"
					let [nx,l0]=[wincol(),y-winline()]
				else
					let [nx,l0]=[v:mouse_col-offset,line('w0')+y-v:mouse_lnum]
				en
				exe 'norm! '.bufwinnr(b0)."\<c-w>w"
				sil let [x,xs]=x && nx? [x,s:nav(x-nx,l0)] : [x? x : nx,0]
				let [x,y]=[wrap? v:mouse_win>1? x : nx+xs : x, l0>0? y : y-l0+1]
				redr
				ec ecstr
			en
			let c=getchar()
			while c!="\<leftdrag>" && c!="\<leftrelease>"
				let c=getchar()
			endwhile
		endwhile
		call s:setCursor(cpos[0],cpos[1],cpos[2])
		echon w:txbi '-' line('.')
		return ''
	en
	let possav=[bufnr('')]+getpos('.')[1:]
	call feedkeys("\<leftmouse>")
	call getchar()
	exe v:mouse_win."winc w"
	if v:mouse_lnum>line('w$') || &wrap && v:mouse_col%winwidth(0)==1 || !&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol || v:mouse_lnum==line('$')
		return line('$')==line('w0')? "keepj norm! \<c-y>\<leftmouse>" : "keepj norm! \<leftmouse>"
	en
	exe "norm! \<leftmouse>"
	redr!
	let [veon,fr,tl,v]=[&ve==?'all',-1,repeat([[reltime(),0,0]],4),winsaveview()]
	let [v.col,v.coladd,redrexpr]=[0,v:mouse_col-1,(exists('g:opt_device') && g:opt_device==?'droid4' && veon)? 'redr!':'redr']
	let c=getchar()
	if c!="\<leftdrag>"
		return "keepj norm! \<leftmouse>"
	en
	while c=="\<leftdrag>"
		let [dV,dH,fr]=[min([v:mouse_lnum-v.lnum,v.topline-1]), veon? min([v:mouse_col-v.coladd-1,v.leftcol]):0,(fr+1)%4]
		let [v.topline,v.leftcol,v.lnum,v.coladd,tl[fr]]=[v.topline-dV,v.leftcol-dH,v:mouse_lnum-dV,v:mouse_col-1-dH,[reltime(),dV,dH]]
		call winrestview(v)
		exe redrexpr
		let c=getchar()
	endwhile
	let glide=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')
	if str2float(reltimestr(reltime(tl[(fr+1)%4][0])))<0.2
		let [glv,glh,vc,hc]=[tl[0][1]+tl[1][1]+tl[2][1]+tl[3][1],tl[0][2]+tl[1][2]+tl[2][2]+tl[3][2],0,0]
		let [tlx,lnx,glv,lcx,cax,glh]=(glv>3? ['y*v.topline>1','y*v.lnum>1',glv*glv] : glv<-3? ['-(y*v.topline<'.line('$').')','-(y*v.lnum<'.line('$').')',glv*glv] : [0,0,0])+(glh>3? ['x*v.leftcol>0','x*v.coladd>0',glh*glh] : glh<-3? ['-x','-x',glh*glh] : [0,0,0])
		while !getchar(1) && glv+glh
			let [y,x,vc,hc]=[vc>get(glide,glv,1),hc>get(glide,glh,1),vc+1,hc+1]
			if y||x
				let [v.topline,v.lnum,v.leftcol,v.coladd,glv,vc,glh,hc]-=[eval(tlx),eval(lnx),eval(lcx),eval(cax),y,y*vc,x,x*hc]
				call winrestview(v)
				exe redrexpr
			en
		endw
	en
	exe min([max([line('w0'),possav[1]]),line('w$')])
	let firstcol=virtcol('.')-wincol()+1
	let lastcol=firstcol+winwidth(0)-1
	let possav[3]=min([max([firstcol,possav[2]+possav[3]]),lastcol])
	exe "norm! ".possav[3]."|"
	return ''
endfun

fun! txbMouse.sgr()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists('w:txbi')
			echon w:txbi '-' line('.')
		en
	elseif !exists('w:txbi')
		exe v:mouse_win.'winc w'
		if &wrap && (v:mouse_col%winwidth(0)==1 || v:mouse_lnum>line('w$')) || !&wrap && (v:mouse_col>=winwidth(0)+winsaveview().leftcol || v:mouse_lnum>line('w$'))
			exe "norm! \<leftmouse>"
		else
			let [s:pX,s:pY]=[0,0]
			nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
		en
	else
		let [s:pX,s:pY]=[0,0]
		nno <silent> <esc>[< :call <SID>doDragSGR()<cr>
	en
	return ''
endfun
fun! txbMouse.xterm2()
	if getchar()=="\<leftrelease>"
		exe "norm! \<leftmouse>\<leftrelease>"
		if exists('w:txbi')
			echon w:txbi '-' line('.')
		en
	elseif !exists('w:txbi')
		exe v:mouse_win.'winc w'
		if &wrap && (v:mouse_col%winwidth(0)==1 || v:mouse_lnum>line('w$')) || !&wrap && (v:mouse_col>=winwidth(0)+winsaveview().leftcol || v:mouse_lnum>line('w$'))
			exe "norm! \<leftmouse>"
		else
			let [s:pX,s:pY]=[0,0]
			nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
		en
	else
		let [s:pX,s:pY]=[0,0]
		nno <silent> <esc>[M :call <SID>doDragXterm2()<cr>
	en
	return ''
endfun
fun! txbMouse.xterm()
	return "norm! \<leftmouse>"
endfun

fun! <SID>doDragSGR()
	let k=map(split(join(map([getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)],'type(v:val)? v:val : nr2char(v:val)'),''),';'),'str2nr(v:val)')
	if len(k)<3
		let k=[32,0,0]
	elseif k[0]==0
		nunmap <esc>[<
		if !exists('w:txbi')
		elseif k[1:]==[1,1]
			call TxbKey('o')
		else
			echon w:txbi '-' line('.')
		en
	elseif !(k[1] && k[2] && s:pX && s:pY)
	elseif exists('w:txbi')
		sil call s:nav(s:mps[s:pX-k[1]],line('w0')+s:mps[s:pY-k[2]])
		echon w:txbi '-' line('.')
	else
		exe 'norm!'.s:panYCmd[s:pY-k[2]].s:panXCmd[s:pX-k[1]]
	en
	let [s:pX,s:pY]=k[1:2]
	while getchar(0) isnot 0
	endwhile
endfun
fun! <SID>doDragXterm2()
	let M=getchar(0)
	let X=getchar(0)
	let Y=getchar(0)
	if M==35
		nunmap <esc>[M
		if !exists('w:txbi')
		elseif [X,Y]==[33,33]
			call TxbKey('o')
		else
			echon w:txbi '-' line('.')
		en
	elseif !(X && Y && s:pX && s:pY)
	elseif exists('w:txbi')
		sil call s:nav(s:mps[s:pX-X],line('w0')+s:mps[s:pY-Y])
		echon w:txbi '-' line('.')
	else
		exe 'norm!'.s:panYCmd[s:pY-Y].s:panXCmd[s:pX-X]
	en
	let s:pX=X
	let s:pY=Y
	while getchar(0) isnot 0
	endwhile
endfun

fun! s:formatPar(str,w,...)
	let trspace=repeat(' ',len(&brk))
	let spaces=repeat(' ',a:w+2)
	let ret=[]
	for par in split(a:str,"\n")
		let tick=0
		while tick<len(par)-a:w
			let ix=strridx(tr(par,&brk,trspace),' ',tick+a:w-1)
			if ix>tick
				call add(ret,a:0? par[tick :ix].spaces[1:a:w-ix+tick-1] : par[tick :ix])
				let tick=ix
				while par[tick] is ' '
					let tick+=1
				endwhile
			else
				call add(ret,strpart(par,tick,a:w))
				let tick+=a:w
			en
		endw
		call add(ret,a:0? par[tick :].spaces[1:a:w-len(par)+tick] : par[tick :])
	endfor
	return ret
endfun

"loadk()    ret Get setting and load into ret (required for settings ui)
"apply(arg) msg When setting is changed, apply; optionally return str msg (required for settings ui)
"doc            (str) What the setting does
"getDef()   arg Load default value into arg
"check(arg) msg Normalize arg (eg convert from str to num) return msg (str if error, else num 0)
"getInput() arg Overwrite default (let arg=input('New value:')) [c]hange behavior
"save           (bool) t:txb.setting[key] will always exist (via getDef(), or '' if getDef() is undefined); unsaved keys will be filtered out from t:txb.settings
"onInit()       Exe when loading plane
let s:option = {'hist': {'doc': 'Jump history',
		\'getDef': 'let arg=[1,[0,0]]',
		\'check': 'let msg=type(arg)!=3 || len(arg)<2 || type(arg[0]) || arg[0]>=len(arg)? "Badly formed history" : 0',
		\'onInit': "if len(dict.hist)<98\n
			\elseif dict.hist[0]>0 && dict.hist[0]<len(dict.hist)\n
				\let dict.hist=(dict.hist[0]>32? [32]+dict.hist[dict.hist[0]-32+1 : dict.hist[0]] : dict.hist[:dict.hist[0]])+dict.hist[dict.hist[0]+1 : (dict.hist[0]+32<len(dict.hist)-1? dict.hist[0]+32 : -1)]\n
			\else\n
				\let dict.hist=[48]+dict.hist[len(dict.hist)-48 :]\n
			\en\n
			\let t:jhist=dict.hist",
		\'save': 1},
	\'autoexe': {'doc': 'Command when splits are revealed (for new splits, (c)hange for prompt to apply to current splits)',
		\'loadk': 'let ret=dict.autoexe',
		\'getDef': "let arg='se nowrap scb cole=2'",
		\'save': 1,
		\'apply': "if 'y'==?input('Apply new default autoexe to current splits? (y/n)')\n
				\let t:txb.exe=repeat([arg],t:txbL)\n
				\let msg='(Autoexe applied to current splits)'\n
			\else\n
				\let msg='(Only appended splits will inherit new autoexe)'\n
			\en\n
			\let dict.autoexe=arg"},
	\'current autoexe': {'doc': 'Command when current split is revealed',
		\'loadk': 'let ret=t:txb.exe[w:txbi]',
		\'apply': 'let t:txb.exe[w:txbi]=arg|call s:redraw()'},
	\'current file': {'doc': 'File associated with this split',
		\'loadk': 'let ret=t:txb.name[w:txbi]',
		\'getInput':"exe t:cwd\n
			\let arg=input('(Use full path if not in working dir '.dict['working dir'].')\nEnter file (do not escape spaces): ',type(disp[key])==1? disp[key] : string(disp[key]),'file')\n
			\cd -",
		\'apply': "if !empty(arg)\n
				\exe t:cwd\n
				\let t:bufs[w:txbi]=bufnr(fnamemodify(arg,':p'),1)\n
				\let t:txb.name[w:txbi]=arg\n
				\cd -\n
				\let curview=winsaveview()\n
				\call s:redraw()\n
				\call winrestview(curview)\n
			\en"},
	\'current width': {'doc': 'Width of current split',
		\'loadk': 'let ret=t:txb.size[w:txbi]',
		\'check': 'let arg=str2nr(arg)|let msg=arg>2? 0 : ''Split width must be > 2''',
		\'apply': 'let t:txb.size[w:txbi]=arg|call s:redraw()'},
	\'hotkey': {'doc': "Global hotkey. Examples: '<f10>', '<c-v>' (ctrl-v), 'vx' (v then x). WARNING: If the hotkey becomes inaccessible, :call TxbKey('S')",
		\'loadk': 'let ret=g:TXB_HOTKEY',
		\'getDef': 'let arg=''<f10>''',
		\'save': 1,
		\'apply': "if escape(maparg(g:TXB_HOTKEY),'|')==?s:hotkeyArg\n
				\exe 'silent! nunmap' g:TXB_HOTKEY\n
			\elseif escape(maparg('<f10>'),'|')==?s:hotkeyArg\n
				\silent! nunmap <f10>\n
			\en\n
			\let g:TXB_HOTKEY=arg\n
			\exe 'nn <silent>' g:TXB_HOTKEY s:hotkeyArg"},
	\'mouse pan speed': {'doc': 'Pan speed[N] steps for every N mouse steps (only applies in terminal and ttymouse=xterm2 or sgr)',
		\'loadk': 'let ret=g:TXBMPS',
		\'getDef': 'let arg=[0,1,2,4,7,10,15,21,24,27]',
		\'check': "if type(arg)==1\n
				\try\n
					\let temp=eval(arg)\n
				\catch\n
					\let temp=''\n
				\endtry\n
				\unlet! arg\n
				\let arg=temp\n
			\en\n
			\let msg=type(arg)!=3? 'Must evaluate to list, eg, [0,1,2,3]' : arg[0]? 'First element must be 0' : 0",
		\'apply': "let g:TXBMPS=arg\n
			\let s:mps=g:TXBMPS+repeat([g:TXBMPS[-1]],40)+repeat([-g:TXBMPS[-1]],40)+map(reverse(copy(g:TXBMPS[1:])),'-v:val')\n
			\let s:panYCmd=['']+map(copy(g:TXBMPS[1:]),'v:val.''\<c-e>''')+repeat([g:TXBMPS[-1].'\<c-e>'],40)+repeat([g:TXBMPS[-1].'\<c-y>'],40)+map(reverse(copy(g:TXBMPS[1:])),'v:val.''\<c-y>''')\n
			\let s:panXCmd=['g']+map(copy(g:TXBMPS[1:]),'v:val.''zl''')+repeat([g:TXBMPS[-1].'zl'],40)+repeat([g:TXBMPS[-1].'zh'],40)+map(reverse(copy(g:TXBMPS[1:])),'v:val.''zh''')"},
	\'label marker': {'doc': 'Regex for map marker, default ''txb:''. Labels are found via search(''^''.labelmark)',
		\'loadk': 'let ret=dict[''label marker'']',
		\'getDef': 'let arg=''txb:''',
		\'save': 1,
		\'getInput': "let newMarker=input('New label marker: ',disp[key])\n
			\let newAutotext=input('Label autotext (hotkey L; should be same as marker if marker doesn''t contain regex): ',newMarker)\n
			\if !empty(newMarker) && !empty(newAutotext)\n
				\let arg=newMarker\n
				\let dict['label autotext']=newAutotext\n
			\en",
		\'apply': 'let dict[''label marker'']=arg'},
	\'label autotext': {'doc': 'Text for insert label command (hotkey L)',
		\'getDef': 'let arg=''txb:''',
		\'save': 1},
	\'lines per map grid': {'doc': 'Lines mapped by each map line',
		\'loadk': 'let ret=dict[''lines per map grid'']',
		\'getDef': 'let arg=45',
		\'check': 'let arg=str2nr(arg)|let msg=arg>0? 0 : ''Lines per map grid must be > 0''',
		\'save': 1,
		\'apply': 'let dict[''lines per map grid'']=arg|call s:getMapDis()'},
	\'map cell width': {'doc': 'Display width of map column',
		\'loadk': 'let ret=dict[''map cell width'']',
		\'getDef': 'let arg=5',
		\'check': 'let arg=str2nr(arg)|let msg=arg>2? 0 : ''Map cell width must be > 2''',
		\'save': 1,
		\'onInit': 'let t:mapw=dict["map cell width"]',
		\'apply': 'let dict[''map cell width'']=arg|let t:mapw=arg|call s:getMapDis()'},
	\'split width': {'doc': 'Default split width (for appended splits, (c)hange for prompt to resize current splits)',
		\'loadk': 'let ret=dict[''split width'']',
		\'getDef': 'let arg=60',
		\'check': "let arg=str2nr(arg)|let msg=arg>2? 0 : 'Default split width must be > 2'",
		\'save': 1,
		\'apply': "if 'y'==?input('Apply new default width to current splits? (y/n)')\n
				\let t:txb.size=repeat([arg],t:txbL)\n
				\let msg='(All splits resized)'\n
			\else\n
				\let msg='(Only newly appended splits will inherit new width)'\n
			\en\n
			\let dict['split width']=arg"},
	\'writefile': {'doc': 'Default settings save file',
		\'loadk': 'let ret=dict[''writefile'']',
		\'check': 'let msg=type(arg)==1? 0 : "Writefile must be string"',
		\'save': 1,
		\'apply':'let dict[''writefile'']=arg'},
	\'working dir': {'doc': 'Directory assumed when loading splits with relative paths',
		\'loadk': 'let ret=dict["working dir"]',
		\'getDef': 'let arg=fnamemodify(getcwd(),":p")',
		\'check': "let [msg, arg]=isdirectory(arg)? [0,fnamemodify(arg,':p')] : ['Not a valid directory',arg]",
		\'onInit': 'let t:cwd="cd ".fnameescape(dict["working dir"])',
		\'save': 1,
		\'getInput': "let arg=input('Working dir (do not escape spaces; must be absolute path; press tab for completion): ',type(disp[key])==1? disp[key] : string(disp[key]),'file')",
		\'apply': "let msg='(Working dir not changed)'\n
			\if 'y'==?input('Are you sure you want to change the working directory? (Step 1/3) (y/n)')\n
				\let confirm=input('Step 2/3 (Recommended): Would you like to convert current files to absolute paths so that their locations remain unaffected? (y/n/cancel)')\n
				\if confirm==?'y' || confirm==?'n'\n
					\let confirm2=input('Step 3/3: Would you like to write a copy of the current plane to file, just in case? (y/n/cancel)')\n
					\if confirm2==?'y' || confirm2==?'n'\n
						\let curwd=getcwd()\n
						\if confirm2=='y'\n
							\exe g:txbCmd.W\n
						\en\n
						\if confirm=='y'\n
							\exe t:cwd\n
							\call map(t:txb.name,'fnamemodify(v:val,'':p'')')\n
						\en\n
						\let dict['working dir']=arg\n
						\let t:cwd='cd '.fnameescape(arg)\n
						\exe t:cwd\n
						\let t:bufs=map(copy(t:txb.name),'bufnr(fnamemodify(v:val,'':p''),1)')\n
						\exe 'cd' fnameescape(curwd)\n
						\let msg='(Working dir changed)'\n
					\en\n
				\en\n
			\en"}}
let arg=exists('TXBMPS') && type(TXBMPS)==3 && TXBMPS[0]==0? TXBMPS : [0,1,2,4,7,10,15,21,24,27,30]
exe s:option['mouse pan speed'].apply

fun! s:settingsPager(dict,entry,attr)
	let applyCmd="if empty(arg)\n
				\let msg='Input cannot be empty'\n
			\else\n
				\exe get(a:attr[key],'check','let msg=0')\n
			\en\n
			\if (msg is 0) && (arg!=#disp[key])\n
				\let undo[key]=get(undo,key,disp[key])\n
				\exe a:attr[key].apply\n
				\let disp[key]=arg\n
			\en\n
		\en"
	let case={68: "if !has_key(disp,key) || !has_key(a:attr[key],'getDef')\n
				\let msg='No default defined for this value'\n
			\else\n
				\unlet! arg\n
				\exe a:attr[key].getDef\n".applyCmd,
		\85: "if !has_key(disp,key) || !has_key(undo,key)\n
				\let msg='No undo defined for this value'\n
			\else\n
				\unlet! arg\n
				\let arg=undo[key]\n".applyCmd,
		\99: "if has_key(disp,key)\n
				\unlet! arg\n
				\exe get(a:attr[key],'getInput','let arg=input(''Enter new value: '',type(disp[key])==1? disp[key] : string(disp[key]))')\n".applyCmd,
		\113: "let continue=0",
		\27:  "let continue=0",
		\106: 'let s:spCursor+=1',
		\107: 'let s:spCursor-=1',
		\103: 'let s:spCursor=0',
		\71:  'let s:spCursor=entries-1'}
	call extend(case,{13:case.99,10:case.99})
	let dict=a:dict
	let entries=len(a:entry)
	let [chsav,&ch]=[&ch,entries+3>11? 11 : entries+3]
	let s:spCursor=!exists('s:spCursor')? 0 : s:spCursor<0? 0 : s:spCursor>=entries? entries-1 : s:spCursor
	let s:spOff=!exists('s:spOff')? 0 : s:spOff<0? 0 : s:spOff>entries-&ch? (entries-&ch>=0? entries-&ch : 0) : s:spOff
	let s:spOff=s:spOff<s:spCursor-&ch? s:spCursor-&ch : s:spOff>s:spCursor? s:spCursor : s:spOff
	let undo={}
	let disp={}
	for key in filter(copy(a:entry),'has_key(a:attr,v:val)')
		unlet! ret
		exe a:attr[key].loadk
		let disp[key]=ret
	endfor
	let [helpw,contentw]=&co>120? [60,60] : [&co/2,&co/2-1]
	let pad=repeat(' ',contentw)
	let msg=0
	let continue=1
	let settingshelp='jkgG:dn,up,top,bot (c)hange (U)ndo (D)efault (q)uit'
	let errlines=[]
	let doclines=s:formatPar(settingshelp,helpw)
	while continue
		redr!
		for [scrPos,i,key] in map(range(&ch),'[v:val,v:val+s:spOff,get(a:entry,v:val+s:spOff,"")]')
			let line=has_key(disp,key)? ' '.key.' : '.(type(disp[key])==1? disp[key] : string(disp[key])) : key
			if i==s:spCursor
				echohl Visual
			elseif !has_key(a:attr,key)
				echohl Title
			en
			if scrPos
				echon "\n"
			en
			if scrPos<len(doclines)
				if len(line)>=contentw
					echon line[:contentw-1]
				else
					echon line
					echohl
					echon pad[:contentw-len(line)-1]
				en
				if scrPos<len(errlines)
					echohl WarningMsg
				else
					echohl MoreMsg
				en
				echon get(doclines,scrPos,'')
			else
				echon line[:&co-2]
			en
			echohl
		endfor
		let key=a:entry[s:spCursor]
		let validkey=1
		exe get(case,getchar(),'let validkey=0')
		let s:spCursor=s:spCursor<0? 0 : s:spCursor>=entries? entries-1 : s:spCursor
		let s:spOff=s:spOff<s:spCursor-&ch+1? s:spCursor-&ch+1 : s:spOff>s:spCursor? s:spCursor : s:spOff
		let errlines=msg is 0? [] : s:formatPar(msg,helpw)
		let doclines=errlines+s:formatPar(validkey? get(get(a:attr,a:entry[s:spCursor],{}),'doc',settingshelp) : settingshelp,helpw)
	endwhile
	let &ch=chsav
	redr
	echo
endfun

nno <silent> <plug>TxbY<esc>[ :call <SID>getmouse()<cr>
nno <silent> <plug>TxbY :call <SID>getchar()<cr>
nno <silent> <plug>TxbZ :call <SID>getchar()<cr>
fun! <SID>getchar()
	if getchar(1) is 0
		sleep 1m
		call feedkeys("\<plug>TxbY")
	else
		call s:dochar()
	en
endfun
"mouse    leftdown leftdrag leftup  scrollup scrolldn
"xterm    32                35      96       97
"xterm2   32       64       35      96       97
"sgr      0M       32M      0m      64       65
"msStat   1        2        3       4        5         else 0
fun! <SID>getmouse()
	if &ttymouse=~?'xterm'
		let s:msStat=[getchar(0)*0+getchar(0),getchar(0)-32,getchar(0)-32]
		let s:msStat[0]=s:msStat[0]==64? 2 : s:msStat[0]==32? 1 : s:msStat[0]==35? 3 : s:msStat[0]==96? 4 : s:msStat[0]==97? 5 : 0
	elseif &ttymouse==?'sgr'
		let s:msStat=split(join(map([getchar(0)*0+getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0),getchar(0)],'type(v:val)? v:val : nr2char(v:val)'),''),';')
		let s:msStat=len(s:msStat)> 2? [str2nr(s:msStat[0]).s:msStat[2][len(s:msStat[2])-1],str2nr(s:msStat[1]),str2nr(s:msStat[2])] : [0,0,0]
		let s:msStat[0]=s:msStat[0]==#'32M'? 2 : s:msStat[0]==#'0M'? 1 : (s:msStat[0]==#'0m' || s:msStat[0]==#'32K') ? 3 : s:msStat[0][:1]==#'64'? 4 : s:msStat[0][:1]==#'65'? 5 : 0
	else
		let s:msStat=[0,0,0]
	en
	while getchar(0) isnot 0
	endwhile
	call g:TxbKeyHandler(-1)
endfun
fun! s:dochar()
	let [k,c]=['',getchar()]
	while c isnot 0
		let k.=type(c)==0? nr2char(c) : c
		let c=getchar(0)
	endwhile
	call g:TxbKeyHandler(k)
endfun

fun! s:setCursor(l,vc,ix)
	let wt=getwinvar(1,'txbi')
	let wb=wt+winnr('$')-1
	if a:ix<wt
		winc t
		exe "norm! ".(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').'g0'
	elseif a:ix>wb
		winc b
		exe 'norm! '.(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').(wb==wt? 'g$' : '0g$')
	elseif a:ix==wt
		winc t
		let offset=virtcol('.')-wincol()+1
		let width=offset+winwidth(0)-3
		exe 'norm! '.(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').(a:vc<offset? offset : width<=a:vc? width : a:vc).'|'
	else
		exe (a:ix-wt+1).'winc w'
		exe 'norm! '.(a:l<line('w0')? 'H' : line('w$')<a:l? 'L' : a:l.'G').(a:vc>winwidth(0)? '0g$' : '0'.a:vc.'|')
	en
endfun

fun! s:goto(sp,ln,...)
	let sp=(a:sp%t:txbL+t:txbL)%t:txbL
	let dln=a:ln>0? a:ln : 1
	let doff=a:0? a:1 : t:txb.size[sp]>&co? 0 : -(&co-t:txb.size[sp])/2
	let dsp=sp
	while doff<0
		let dsp=dsp>0? dsp-1 : t:txbL-1
		let doff+=t:txb.size[dsp-1]+1
	endwhile
	while doff>t:txb.size[dsp]
		let doff-=t:txb.size[dsp]+1
		let dsp=dsp>=t:txbL-1? 0 : dsp+1
	endwhile
	exe 'only|b'.t:bufs[dsp]
	let w:txbi=dsp
	if a:0
		exe 'norm! '.dln.(doff>0? 'zt0'.doff.'zl' : 'zt0')
		call s:redraw()
	else
		exe 'norm! 0'.(doff>0? doff.'zl' : '')
		call s:redraw()
		exe ((sp-getwinvar(1,'txbi')+1+t:txbL)%t:txbL).'wincmd w'
		let dif=line('w0')-(dln>winheight(0)/2? dln-winheight(0)/2 : 1)
		exe dif>0? 'norm! '.dif."\<c-y>".dln.'G' : dif<0? 'norm! '.-dif."\<c-e>".dln.'G' : dln
	en
	if t:jhist[t:jhist[0]][0]==sp && abs(t:jhist[t:jhist[0]][1]-dln)<23
	elseif t:jhist[0]<len(t:jhist)-1 && t:jhist[t:jhist[0]+1][0]==sp && abs(t:jhist[t:jhist[0]+1][1]-dln)<23
		let t:jhist[0]+=1
	else 
		call insert(t:jhist,[sp,dln],t:jhist[0]+1)
		let t:jhist[0]+=1
	en
endfun

let s:badSync=v:version<704 || v:version==704 && !has('patch131')
fun! s:redraw(...)
	if exists('w:txbi') && t:bufs[w:txbi]==bufnr('')
	elseif exists('w:txbi')
		exe 'b' t:bufs[w:txbi]
	elseif index(t:bufs,bufnr(''))==-1
		exe 'only|b' t:bufs[0]
		let w:txbi=0
	else
		let w:txbi=index(t:bufs,bufnr(''))
	en
	let win0=winnr()
	let pos=[bufnr(''),line('w0'),line('.'), virtcol('.')]
	if winnr('$')>1
		if win0==1 && !&wrap
			let offset=virtcol('.')-wincol()
			if offset<t:txb.size[w:txbi]
				exe (t:txb.size[w:txbi]-offset).'winc|'
			en
		en
		se scrollopt=jump
		let split0=win0==1? 0 : eval(join(map(range(1,win0-1),'winwidth(v:val)')[:win0-2],'+'))+win0-2
		let colt=w:txbi
		let colsLeft=0
		let remain=split0
		while remain>=1
			let colt=colt? colt-1 : t:txbL-1
			let remain-=t:txb.size[colt]+1
			let colsLeft+=1
		endwhile
		let colb=w:txbi
		let remain=&co-(split0>0? split0+1+t:txb.size[w:txbi] : min([winwidth(1),t:txb.size[w:txbi]]) )
		let colsRight=1
		while remain>=2
			let colb=(colb+1)%t:txbL
			let colsRight+=1
			let remain-=t:txb.size[colb]+1
		endwhile
		let colbw=t:txb.size[colb]+remain
	else
		let colt=w:txbi
		let colsLeft=0
		let colb=w:txbi
		let offset=&wrap? 0 : virtcol('.')-wincol()
		let remain=&co-max([2,t:txb.size[w:txbi]-offset])
		let colsRight=1
		while remain>=2
			let colb=(colb+1)%t:txbL
			let colsRight+=1
			let remain-=t:txb.size[colb]+1
		endwhile
		let colbw=t:txb.size[colb]+remain
	en
	let dif=colsLeft-win0+1
	if dif>0
		let colt=(w:txbi-win0+t:txbL)%t:txbL
		for i in range(dif)
			let colt=colt? colt-1 : t:txbL-1
			exe 'to vert sb' t:bufs[colt]
			let w:txbi=colt
			exe t:txb.exe[colt]
		endfor
	elseif dif<0
		winc t
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	let numcols=colsRight+colsLeft
	let dif=numcols-winnr('$')
	if dif>0
		let nextcol=((colb-dif)%t:txbL+t:txbL)%t:txbL
		for i in range(dif)
			let nextcol=(nextcol+1)%t:txbL
			exe 'bo vert sb' t:bufs[nextcol]
			let w:txbi=nextcol
			exe t:txb.exe[nextcol]
		endfor
	elseif dif<0
		winc b
		for i in range(-dif)
			exe 'hide'
		endfor
	en
	windo se nowfw
	winc =
	winc b
	let ccol=colb
	let changedsplits={}
	for i in range(1,numcols)
		se wfw
		exe 'b' t:bufs[ccol]
		let w:txbi=ccol
		exe t:txb.exe[ccol]
		if a:0
			let changedsplits[ccol]=1
			let t:txb.depth[ccol]=line('$')
			let t:txb.map[ccol]={}
			norm! 1G0
			let searchPat='^'.t:txb.settings['label marker'].'\zs'
			let line=search(searchPat,'Wc')
			while line
				let L=getline('.')
				let lnum=strpart(L,col('.')-1,6)
				if lnum!=0
					let lbl=lnum[len(lnum+0)]==':'? split(L[col('.')+len(lnum+0)+1:],'#',1) : []
					if lnum<line
						if prevnonblank(line-1)>=lnum
							let lbl=["! Error ".get(lbl,0,''),'ErrorMsg']
						else
							exe 'norm! kd'.(line-lnum==1? 'd' : (line-lnum-1).'k')
						en
					elseif lnum>line
						exe 'norm! '.(lnum-line)."O\ej"
					en
					let line=line('.')
				else
					let lbl=split(L[col('.'):],'#',1)
				en
				if !empty(lbl) && !empty(lbl[0])
					let t:txb.map[ccol][line]=[lbl[0],get(lbl,1,'')]
				en
				let line=search(searchPat,'W')
			endwhile
		en
		if i==numcols
			let offset=t:txb.size[colt]-winwidth(1)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
		elseif i==1
			let dif=colbw-winwidth(0)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
			norm! 0
		else
			let dif=t:txb.size[ccol]-winwidth(0)
			exe 'vert res'.(dif>=0? '+'.dif : dif)
			norm! 0
		en
		if s:badSync
			1
		en
		winc h
		let ccol=ccol? ccol-1 : t:txbL-1
	endfor
	if !empty(changedsplits)
		call s:getMapDis(keys(changedsplits))
	en
	se scrollopt=ver,jump
	silent exe "norm! :syncbind\<cr>"
	exe bufwinnr(pos[0]).'winc w'
	let offset=virtcol('.')-wincol()
	exe 'norm!' pos[1].'zt'.pos[2].'G'.(pos[3]<=offset? offset+1 : pos[3]>offset+winwidth(0)? offset+winwidth(0) : pos[3])
endfun

fun! s:nav(N,L)
	let ei=&ei
	se ei=WinEnter,WinLeave,BufEnter,BufLeave
	let cBf=bufnr('')
	let cVc=virtcol('.')
	let cL0=line('w0')
	let cL=line('.')
	let align='norm! '.cL0.'zt'
	let resync=0
	let extrashift=0
	if a:N<0
		let N=-a:N
		if N<&co
			while winwidth(winnr('$'))<=N
				winc b
				let extrashift=(winwidth(0)==N)
				hide
			endw
		else
			winc t
			only
		en
		if winwidth(0)!=&co
			winc t
			let topw=winwidth(0)
			if winwidth(winnr('$'))<=N+3+extrashift || winnr('$')>=9
				se nowfw
				winc b
				exe 'vert res-'.(N+extrashift)
				winc t
				if winwidth(1)==1
					winc l
					se nowfw
					winc t
					exe 'vert res+'.(N+extrashift)
					winc l
					se wfw
					winc t
				elseif winwidth(0)==topw
					exe 'vert res+'.(N+extrashift)
				en
				se wfw
			else
				exe 'vert res+'.(N+extrashift)
			en
			se nowfw scrollopt=jump
			while winwidth(0)>=t:txb.size[w:txbi]+2
				let nextcol=w:txbi? w:txbi-1 : t:txbL-1
				exe 'to' winwidth(0)-t:txb.size[w:txbi]-1 'vsp|b' t:bufs[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if !&scb
				elseif line('$')<cL0
					let resync=1
				else
					exe align
				en
				winc l
				se wfw
				norm! 0
				winc t
			endwhile
			se wfw scrollopt=ver,jump
			let offset=t:txb.size[w:txbi]-winwidth(0)-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let cWn=bufwinnr(cBf)
			if cWn==-1
				winc b
				norm! 0g$
			elseif cWn!=1
				exe cWn.'winc w'
				exe cVc>=winwidth(0)? 'norm! 0g$' : 'norm! '.cVc.'|'
			en
		else
			let tcol=w:txbi
			let loff=&wrap? -N-extrashift : virtcol('.')-wincol()-N-extrashift
			if loff>=0
				exe 'norm! '.(N+extrashift).(bufwinnr(cBf)==-1? 'zhg$' : 'zh')
			else
				let [loff,extrashift]=loff==-1? [loff-1,extrashift+1] : [loff,extrashift]
				while loff<=-2
					let tcol=tcol? tcol-1 : t:txbL-1
					let loff+=t:txb.size[tcol]+1
				endwhile
				se scrollopt=jump
				exe 'b' t:bufs[tcol]
				let w:txbi=tcol
				exe t:txb.exe[tcol]
				if &scb
					if line('$')<cL0
						let resync=1
					else
						exe align
					en
				en
				se scrollopt=ver,jump
				exe 'norm! 0'.(loff>0? loff.'zl' : '')
				if t:txb.size[tcol]-loff<&co-1
					let spaceremaining=&co-t:txb.size[tcol]+loff
					let nextcol=(tcol+1)%t:txbL
					se nowfw scrollopt=jump
					while spaceremaining>=2
						exe 'bo' spaceremaining-1 'vsp|b' t:bufs[nextcol]
						let w:txbi=nextcol
						exe t:txb.exe[nextcol]
						if &scb
							if line('$')<cL0
								let resync=1
							elseif !resync
								exe align
							en
						en
						norm! 0
						let spaceremaining-=t:txb.size[nextcol]+1
						let nextcol=(nextcol+1)%t:txbL
					endwhile
					se scrollopt=ver,jump
					windo se wfw
				en
				let cWn=bufwinnr(cBf)
				if cWn!=-1
					exe cWn.'winc w'
					exe cVc>=winwidth(0)? 'norm! 0g$' : 'norm! '.cVc.'|'
				else
					norm! 0g$
				en
			en
		en
		let extrashift=-extrashift
	elseif a:N>0
		let tcol=getwinvar(1,'txbi')
		let loff=winwidth(1)==&co? (&wrap? (t:txb.size[tcol]>&co? t:txb.size[tcol]-&co+1 : 0) : virtcol('.')-wincol()) : (t:txb.size[tcol]>winwidth(1)? t:txb.size[tcol]-winwidth(1) : 0)
		let N=a:N
		let botalreadysized=0
		if N>=&co
			let loff=winwidth(1)==&co? loff+&co : winwidth(winnr('$'))
			if loff>=t:txb.size[tcol]
				let loff=0
				let tcol=(tcol+1)%t:txbL
			en
			let toshift=N-&co
			if toshift>=t:txb.size[tcol]-loff+1
				let toshift-=t:txb.size[tcol]-loff+1
				let tcol=(tcol+1)%t:txbL
				while toshift>=t:txb.size[tcol]+1
					let toshift-=t:txb.size[tcol]+1
					let tcol=(tcol+1)%t:txbL
				endwhile
				if toshift==t:txb.size[tcol]
					let N+=1
					let extrashift=-1
					let tcol=(tcol+1)%t:txbL
					let loff=0
				else
					let loff=toshift
				en
			elseif toshift==t:txb.size[tcol]-loff
				let N+=1
				let extrashift=-1
				let tcol=(tcol+1)%t:txbL
				let loff=0
			else
				let loff+=toshift
			en
			se scrollopt=jump
			exe 'b' t:bufs[tcol]
			let w:txbi=tcol
			exe t:txb.exe[tcol]
			if &scb
				if line('$')<cL0
					let resync=1
				else
					exe align
				en
			en
			se scrollopt=ver,jump
			only
			exe 'norm! 0'.(loff>0? loff.'zl' : '')
		else
			if winwidth(1)==1
				let cWn=winnr()
				winc t
				hide
				let N-=2
				if N<=0
					if cWn!=1
						exe (cWn-1).'winc w'
					else
						1winc w
						norm! 0
					en
					exe cL
					let dif=line('w0')-a:L
					exe dif>0? 'norm! '.dif."\<c-y>" : dif<0? 'norm! '.-dif."\<c-e>" : ''
					let &ei=ei
					return
				en
			en
			let shifted=0
			let w1=winwidth(1)
			while w1<=N-botalreadysized
				let w2=winwidth(2)
				let extrashift=w1==N
				let shifted=w1+1
				winc t
				hide
				if winwidth(1)==w2
					let botalreadysized+=w1+1
				en
				let tcol=(tcol+1)%t:txbL
				let loff=0
				let w1=winwidth(1)
			endw
			let N+=extrashift
			let loff+=N-shifted
		en
		let ww1=winwidth(1)
		if ww1!=&co
			let N=N-botalreadysized
			if N
				winc b
				exe 'vert res+'.N
				if virtcol('.')!=wincol()
					norm! 0
				en
				winc t
				if winwidth(1)!=ww1-N
					exe 'vert res'.(ww1-N)
				en
			en
			while winwidth(winnr('$'))>=t:txb.size[getwinvar(winnr('$'),'txbi')]+2
				winc b
				se nowfw scrollopt=jump
				let nextcol=(w:txbi+1)%t:txbL
				exe 'bo' winwidth(0)-t:txb.size[w:txbi]-1 'vsp|b' t:bufs[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if &scb
					if line('$')<cL0
						let resync=1
					elseif !resync
						exe align
					en
				en
				winc h
				se wfw
				winc b
				norm! 0
				se scrollopt=ver,jump
			endwhile
			winc t
			let offset=t:txb.size[tcol]-winwidth(1)-virtcol('.')+wincol()
			exe (!offset || &wrap)? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let cWn=bufwinnr(cBf)
			if cWn==-1
				norm! g0
			elseif cWn!=1
				exe cWn.'winc w'
				exe cVc>=winwidth(0)? 'norm! 0g$' : 'norm! '.cVc.'|'
			else
				exe (cVc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.cVc.'|')
			en
		elseif &co-t:txb.size[tcol]+loff>=2
			let spaceremaining=&co-t:txb.size[tcol]+loff
			se nowfw scrollopt=jump
			while spaceremaining>=2
				let nextcol=(w:txbi+1)%t:txbL
				exe 'bo' spaceremaining-1 'vsp|b' t:bufs[nextcol]
				let w:txbi=nextcol
				exe t:txb.exe[nextcol]
				if &scb
					if line('$')<cL0
						let resync=1
					elseif !resync
						exe align
					en
				en
				norm! 0
				let spaceremaining-=t:txb.size[nextcol]+1
			endwhile
			se scrollopt=ver,jump
			windo se wfw
			let cWn=bufwinnr(cBf)
			if cWn==-1
				winc t
				norm! g0
			elseif cWn!=1
				exe cWn.'winc w'
				if cVc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.cVc.'|'
				en
			else
				winc t
				exe (cVc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.cVc.'|')
			en
		else
			let offset=loff-virtcol('.')+wincol()
			exe !offset || &wrap? '' : offset>0? 'norm! '.offset.'zl' : 'norm! '.-offset.'zh'
			let cWn=bufwinnr(cBf)
			if cWn==-1
				norm! g0
			elseif cWn!=1
				exe cWn.'winc w'
				if cVc>=winwidth(0)
					norm! 0g$
				else
					exe 'norm! '.cVc.'|'
				en
			else
				exe (cVc<t:txb.size[tcol]-winwidth(1)? 'norm! g0' : 'norm! '.cVc.'|')
			en
		en
	en
	if resync
		if s:badSync
			windo 1
		en
		silent exe "norm! :syncbind\<cr>"
	en
	exe cL
	let dif=line('w0')-a:L
	exe dif>0? 'norm! '.dif."\<c-y>" : dif<0? 'norm! '.-dif."\<c-e>" : ''
	let &ei=ei
	return extrashift
endfun

fun! s:getMapDis(...)
	let poscell=repeat(' ',t:mapw)
	let negcell=repeat('.',t:mapw)
	let gran=t:txb.settings["lines per map grid"]
	if !a:0
		let t:bgd=map(range(0,max(t:txb.depth)+gran,gran),'join(map(range(t:txbL),v:val.''>t:txb.depth[v:val]? "'.negcell.'" : "'.poscell.'"''),'''')')
		let t:deepR=len(t:bgd)-1
		let t:disTxt=copy(t:bgd)
		let t:disClr=eval('['.join(repeat(['[""]'],t:deepR+1),',').']')
		let t:disIx=eval('['.join(repeat(['[98989]'],t:deepR+1),',').']')
		let t:gridClr=eval('['.join(repeat(['{}'],t:txbL),',').']')
		let t:gridLbl=deepcopy(t:gridClr)
		let t:gridPos=deepcopy(t:gridClr)
		let t:oldDepth=copy(t:txb.depth)
	en
	let newR={}
	for sp in a:0? a:1 : range(t:txbL)
		let newD=t:txb.depth[sp]/gran
		while newD>len(t:bgd)-1
			call add(t:bgd,repeat('.',t:txbL*t:mapw))
			call add(t:disIx,[98989])
			call add(t:disClr,[''])
			call add(t:disTxt,'')
			let newR[len(t:bgd)-1]=1
		endwhile
		let i=t:oldDepth[sp]/gran
		let colIx=sp*t:mapw
		while i>newD
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].negcell.t:bgd[i][colIx+t:mapw :] : negcell.t:bgd[i][colIx+t:mapw :]
			let newR[i]=1
			let i-=1
		endwhile
		while i<=newD
			let t:bgd[i]=colIx? t:bgd[i][:colIx-1].poscell.t:bgd[i][colIx+t:mapw :] : poscell.t:bgd[i][colIx+t:mapw :]
			let newR[i]=1
			let i+=1
		endwhile
		let t:oldDepth[sp]=t:txb.depth[sp]
		let conflicts={}
		let splitLbl={}
		let splitClr={}
		let splitPos={}
		for j in keys(t:txb.map[sp])
			let r=j/gran
			if has_key(splitLbl,r)
				if has_key(conflicts,r)
				elseif splitLbl[r][0][0]=='!'
					let conflicts[r]=[splitLbl[r][0],splitPos[r][0]]
					let splitPos[r]=[]
				else
					let conflicts[r]=['$',0]
				en
				if t:txb.map[sp][j][0][0]=='!' && t:txb.map[sp][j][0]<?conflicts[r][0]
					if conflicts[r][1]
						call add(splitPos[r],conflicts[r][1])
					en
					let conflicts[r][0]=t:txb.map[sp][j][0]
					let conflicts[r][1]=j
				else
					call add(splitPos[r],j)
				en
			else
				let splitLbl[r]=[t:txb.map[sp][j][0]]
				let splitClr[r]=t:txb.map[sp][j][1]
				let splitPos[r]=[j]
			en
		endfor
		for r in keys(conflicts)
			call sort(splitPos[r])
			if conflicts[r][1]
				let splitLbl[r]=['+'.conflicts[r][0]]+map(copy(splitPos[r]),'t:txb.map[sp][v:val][0]')
				call insert(splitPos[r],conflicts[r][1])
				let splitClr[r]=t:txb.map[sp][conflicts[r][1]][1]
			else
				let splitLbl[r]=map(copy(splitPos[r]),'t:txb.map[sp][v:val][0]')
				let splitLbl[r][0]='+'.splitLbl[r][0]
				let splitClr[r]=t:txb.map[sp][splitPos[r][0]][1]
			en
		endfor
		let changed=copy(splitClr)
		for i in keys(t:gridLbl[sp])
			if !has_key(splitLbl,i)
				let changed[i]=''
			elseif splitLbl[i]==#t:gridLbl[sp][i] && splitClr[i]==t:gridClr[sp][i] 
				unlet changed[i]
			en
		endfor
		call extend(newR,changed,'keep')
		let t:gridLbl[sp]=splitLbl
		let t:gridClr[sp]=splitClr
		let t:gridPos[sp]=splitPos
	endfor
	let t:deepR=len(t:bgd)-1
	for i in keys(newR)
		let t:disTxt[i]=''
		let j=t:txbL-1
		let padl=t:mapw
		while j>=0
			let l=len(get(get(t:gridLbl[j],i,[]),0,''))
			if !l
				let padl+=t:mapw
			elseif l>=padl
				if empty(t:disTxt[i])
					let t:disTxt[i]=t:gridLbl[j][i][0]
					let intervals=[padl]
					let t:disClr[i]=[t:gridClr[j][i]]
				else
					let t:disTxt[i]=t:gridLbl[j][i][0][:padl-2].'#'.t:disTxt[i]
					if t:gridClr[j][i]==t:disClr[i][0]
						let intervals[0]+=padl
					else
						call insert(intervals,padl)
						call insert(t:disClr[i],t:gridClr[j][i])
					en
				en
				let padl=t:mapw
			elseif empty(t:disTxt[i])
				let t:disTxt[i]=t:gridLbl[j][i][0].strpart(t:bgd[i],j*t:mapw+l,padl-l)
				if empty(t:gridClr[j][i])
					let intervals=[padl]
					let t:disClr[i]=['']
				else
					let intervals=[l,padl-l]
					let t:disClr[i]=[t:gridClr[j][i],'']
				en
				let padl=t:mapw
			else
				let t:disTxt[i]=t:gridLbl[j][i][0].strpart(t:bgd[i],j*t:mapw+l,padl-l).t:disTxt[i]
				if empty(t:disClr[i][0])
					let intervals[0]+=padl-l
				else
					call insert(intervals,padl-l)
					call insert(t:disClr[i],'')
				en
				if empty(t:gridClr[j][i])
					let intervals[0]+=l
				else
					call insert(intervals,l)
					call insert(t:disClr[i],t:gridClr[j][i])
				en
				let padl=t:mapw
			en
			let j-=1
		endw
		if empty(get(t:gridLbl[0],i,''))
			let padl-=t:mapw
			if empty(t:disTxt[i])
				let t:disTxt[i]=strpart(t:bgd[i],0,padl)
				let intervals=[padl]
				let t:disClr[i]=['']
			else
				let t:disTxt[i]=strpart(t:bgd[i],0,padl).t:disTxt[i]
				if empty(t:disClr[i][0])
					let intervals[0]+=padl
				else
					call insert(intervals,padl)
					call insert(t:disClr[i],'')
				en
			en
		en
		let sum=0
		for j in range(len(intervals))
			let intervals[j]=sum+intervals[j]
			let sum=intervals[j]
		endfor
		let t:disIx[i]=intervals
		let t:disIx[i][-1]=98989
	endfor
endfun

fun! s:ecMap()
	let xe=s:mCoff+&co-2
	let b=s:mC*t:mapw
	if b<xe
		let selection=get(t:gridLbl[s:mC],s:mR,[t:bgd[s:mR][b : b+t:mapw-1]])
		let sele=s:mR+len(selection)-1
		let truncb=b>=s:mCoff? 0 : s:mCoff-b
		let trunce=truncb+xe-b
		let vxe=b-1
	else
		let sele=-999999
	en
	let i=s:mRoff>0? s:mRoff : 0
	let lastR=i+&ch-2>t:deepR? t:deepR : i+&ch-2
	while i<=lastR
		let j=0
		if i<s:mR || i>sele
			while t:disIx[i][j]<s:mCoff
				let j+=1
			endw
			exe 'echohl' t:disClr[i][j]
			if t:disIx[i][j]>xe
				echon t:disTxt[i][s:mCoff : xe] "\n"
			else
				echon t:disTxt[i][s:mCoff : t:disIx[i][j]-1]
				let j+=1
				while t:disIx[i][j]<xe
					exe 'echohl' t:disClr[i][j]
					echon t:disTxt[i][t:disIx[i][j-1] : t:disIx[i][j]-1]
					let j+=1
				endw
				exe 'echohl' t:disClr[i][j]
				echon t:disTxt[i][t:disIx[i][j-1] : xe] "\n"
			en
		else
			let seltext=selection[i-s:mR][truncb : trunce]
			if !truncb && b
				while t:disIx[i][j]<s:mCoff
					let j+=1
				endw
				exe 'echohl' t:disClr[i][j]
				if t:disIx[i][j]>vxe
					echon t:disTxt[i][s:mCoff : vxe]
				else
					echon t:disTxt[i][s:mCoff : t:disIx[i][j]-1]
					let j+=1
					while t:disIx[i][j]<vxe
						exe 'echohl' t:disClr[i][j]
						echon t:disTxt[i][t:disIx[i][j-1] : t:disIx[i][j]-1]
						let j+=1
					endw
					exe 'echohl' t:disClr[i][j]
					echon t:disTxt[i][t:disIx[i][j-1] : vxe]
				en
				let vOff=b+len(seltext)
			else
				let vOff=s:mCoff+len(seltext)
			en
			echohl Visual
			if vOff<xe
				echon seltext
				while t:disIx[i][j]<vOff
					let j+=1
				endw
				exe 'echohl' t:disClr[i][j]
				if t:disIx[i][j]>xe
					echon t:disTxt[i][vOff : xe] "\n"
				else
					echon t:disTxt[i][vOff : t:disIx[i][j]-1]
					let j+=1
					while t:disIx[i][j]<xe
						exe 'echohl' t:disClr[i][j]
						echon t:disTxt[i][t:disIx[i][j-1] : t:disIx[i][j]-1]
						let j+=1
					endw
					exe 'echohl' t:disClr[i][j]
					echon t:disTxt[i][t:disIx[i][j-1] : xe] "\n"
				en
			else
				echon seltext "\n"
			en
		en
		let i+=1
	endwhile
	echohl
endfun

fun! s:mapKeyHandler(c)
	if a:c != -1
		exe get(s:mCase,a:c,'let mapmes=" (0..9) count (f1) help (hjklyubn) move (HJKLYUBN) pan (c)enter (g)o (q)uit (z)oom (p)revious (P)Next"')
		if s:mExit==1
			call s:ecMap()
			ec (s:mC.'-'.s:mR*t:txb.settings['lines per map grid'].(s:mCount is '01'? '' : ' '.s:mCount).(exists('mapmes')? mapmes : ''))[:&co-2]
			call feedkeys("\<plug>TxbY")
			return
		en
		let [&ch,&more,&ls,&stal]=s:mSavSettings
		return s:mExit==2 && s:goto(s:mC,get(t:gridPos[s:mC],s:mR,[s:mR*t:txb.settings['lines per map grid']])[0])
	elseif s:msStat[0]==2 && s:mPrevCoor[0] && s:mPrevCoor[0]<3
		let s:mRoff=s:mRoff-s:msStat[2]+s:mPrevCoor[2]
		let s:mCoff=s:mCoff-s:msStat[1]+s:mPrevCoor[1]
		let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
		let s:mCoff=s:mCoff<0? 0 : s:mCoff>=t:txbL*t:mapw? t:txbL*t:mapw-1 : s:mCoff
		call s:ecMap()
	elseif s:msStat[0]>3
		let s:mRoff+=4*(s:msStat[0]==5)-2
		let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
		cal s:ecMap()
	elseif s:msStat[0]!=3
	elseif s:msStat==[3,1,1]
		let [&ch,&more,&ls,&stal]=s:mSavSettings
		return
	elseif s:mPrevCoor[0]!=1
	elseif &ttymouse=='xterm' && s:mPrevCoor[1:]!=s:msStat[1:]
		let s:mRoff=s:mRoff-s:msStat[2]+s:mPrevCoor[2]
		let s:mCoff=s:mCoff-s:msStat[1]+s:mPrevCoor[1]
		let s:mRoff=s:mRoff<0? 0 : s:mRoff>t:deepR? t:deepR : s:mRoff
		let s:mCoff=s:mCoff<0? 0 : s:mCoff>=t:txbL*t:mapw? t:txbL*t:mapw-1 : s:mCoff
		call s:ecMap()
	else
		let s:mR=s:msStat[2]-&lines+&ch-1+s:mRoff
		let s:mC=(s:msStat[1]-1+s:mCoff)/t:mapw
		let s:mR=s:mR<0? 0 : s:mR>t:deepR? t:deepR : s:mR
		let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC
		if [s:mR,s:mC]==s:mPrevClk
			let [&ch,&more,&ls,&stal]=s:mSavSettings
			call s:goto(s:mC,get(t:gridPos[s:mC],s:mR,[s:mR*t:txb.settings['lines per map grid']])[0])
			return
		en
		let s:mPrevClk=[s:mR,s:mC]
		call s:ecMap()
		echon s:mC '-' s:mR*t:txb.settings['lines per map grid']
	en
	let s:mPrevCoor=copy(s:msStat)
	call feedkeys("\<plug>TxbY")
endfun

let s:mCase={"\e":"let s:mExit=0|redr",
	\"\<f1>":'exe g:txbCmd["\<f1>"]|ec mes|cal getchar()|redr!',
	\'q':"let s:mExit=0",
	\'h':"let s:mC=s:mC>s:mCount? s:mC-s:mCount : 0",
	\'l':"let s:mC=s:mC+s:mCount<t:txbL? s:mC+s:mCount : t:txbL-1",
	\'j':"let s:mR=s:mR+s:mCount<t:deepR? s:mR+s:mCount : t:deepR",
	\'k':"let s:mR=s:mR>s:mCount? s:mR-s:mCount : 0",
	\'H':"let s:mCoff=s:mCoff>s:mCount*t:mapw? s:mCoff-s:mCount*t:mapw : 0|let s:mCount='01'",
	\'L':"let s:mCoff=s:mCoff+s:mCount*t:mapw<t:mapw*t:txbL? s:mCoff+s:mCount*t:mapw : t:mapw*t:txbL-1|let s:mCount='01'",
	\'J':"let s:mRoff=s:mRoff+s:mCount<t:deepR? s:mRoff+s:mCount : t:deepR|let s:mCount='01'",
	\'K':"let s:mRoff=s:mRoff>s:mCount? s:mRoff-s:mCount : 0|let s:mCount='01'",
	\'1':"let s:mCount=s:mCount is '01'? 1 : s:mCount.'1'",
	\'2':"let s:mCount=s:mCount is '01'? 2 : s:mCount.'2'",
	\'3':"let s:mCount=s:mCount is '01'? 3 : s:mCount.'3'",
	\'4':"let s:mCount=s:mCount is '01'? 4 : s:mCount.'4'",
	\'5':"let s:mCount=s:mCount is '01'? 5 : s:mCount.'5'",
	\'6':"let s:mCount=s:mCount is '01'? 6 : s:mCount.'6'",
	\'7':"let s:mCount=s:mCount is '01'? 7 : s:mCount.'7'",
	\'8':"let s:mCount=s:mCount is '01'? 8 : s:mCount.'8'",
	\'9':"let s:mCount=s:mCount is '01'? 9 : s:mCount.'9'",
	\'0':"let s:mCount=s:mCount is '01'? '01' : s:mCount.'0'",
	\'c':"let s:mR=s:mRoff+(&ch-2)/2\n
		\let s:mC=(s:mCoff+&co/2)/t:mapw\n
		\let s:mR=s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mC=s:mC>=t:txbL? t:txbL-1 : s:mC",
	\'C':"let s:mRoff=s:mR-(&ch-2)/2\n
		\let s:mCoff=s:mC*t:mapw-&co/2",
	\'z':"call s:ecMap()\n
		\let input=str2nr(input('File lines per map line (>=10): ',t:txb.settings['lines per map grid']))\n
		\let width=str2nr(input('Width of map column (>=1): ',t:mapw))\n
		\if input<1 || width<1\n
			\echoerr 'Granularity, width must be > 0'\n
			\sleep 500m\n
			\redr!\n
		\elseif input!=t:txb.settings['lines per map grid'] || width!=t:mapw\n
			\let s:mR=s:mR*t:txb.settings['lines per map grid']/input\n
			\let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0\n
			\let t:txb.settings['lines per map grid']=input\n
			\let t:txb.settings['lines per map grid']=input\n
			\let t:mapw=width\n
			\let s:mCoff=s:mC*t:mapw>&co/2? s:mC*t:mapw-&co/2 : 0\n
			\call s:getMapDis()\n
			\let s:mPrevClk=[0,0]\n
			\redr!\n
		\en\n",
	\'g':'let s:mExit=2',
	\'p':"let t:jhist[0]=max([t:jhist[0]-s:mCount,1])\n
		\let [s:mC,s:mR]=[t:jhist[t:jhist[0]][0],t:jhist[t:jhist[0]][1]/t:txb.settings['lines per map grid']]\n
		\let mapmes=' '.t:jhist[0].'/'.(len(t:jhist)-1)\n
		\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
		\let s:mR=s:mR<0? 0 : s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mCount='01'",
	\'P':"let t:jhist[0]=min([t:jhist[0]+s:mCount,len(t:jhist)-1])\n
		\let [s:mC,s:mR]=[t:jhist[t:jhist[0]][0],t:jhist[t:jhist[0]][1]/t:txb.settings['lines per map grid']]\n
		\let mapmes=' '.t:jhist[0].'/'.(len(t:jhist)-1)\n
		\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
		\let s:mR=s:mR<0? 0 : s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mCount='01'"}
call extend(s:mCase,
	\{'y':s:mCase.h.'|'.s:mCase.k, 'u':s:mCase.l.'|'.s:mCase.k, 'b':s:mCase.h.'|'.s:mCase.j, 'n':s:mCase.l.'|'.s:mCase.j,
	\ 'Y':s:mCase.H.'|'.s:mCase.K, 'U':s:mCase.L.'|'.s:mCase.K, 'B':s:mCase.H.'|'.s:mCase.J, 'N':s:mCase.L.'|'.s:mCase.J})
for i in split('h j k l y u b n p P C')
	let s:mCase[i].="\nlet s:mCount='01'\n
		\let s:mCoff=s:mCoff>=s:mC*t:mapw? s:mC*t:mapw : s:mCoff<s:mC*t:mapw-&co+t:mapw? s:mC*t:mapw-&co+t:mapw : s:mCoff\n
		\let s:mRoff=s:mRoff<s:mR-&ch+2? s:mR-&ch+2 : s:mRoff>s:mR? s:mR : s:mRoff"
endfor
call extend(s:mCase,{"\<c-m>":s:mCase.g,"\<right>":s:mCase.l,"\<left>":s:mCase.h,"\<down>":s:mCase.j,"\<up>":s:mCase.k," ":s:mCase.J,"\<bs>":s:mCase.K})

let s:count='03'
fun! TxbKey(cmd)
	let g:TxbKeyHandler=function("s:doCmdKeyhandler")
	call s:doCmdKeyhandler(a:cmd)
endfun
fun! s:doCmdKeyhandler(c)
	exe get(g:txbCmd,a:c,'let mes="(0..9) count (f1) help (hjklyubn) move (r)edraw (M)ap all (o)pen map (A)ppend (D)elete (L)abel (S)ettings (W)rite settings (q)uit"')
	if mes is ' '
		echon '? ' w:txbi '.' line('.') ' ' str2nr(s:count) ' ' strtrans(a:c)
		call feedkeys("\<plug>TxbZ")
	elseif !empty(mes)
		redr|echon '# ' mes
	en
endfun

let txbCmd={'S':"let mes=''\ncall call('s:settingsPager',exists('w:txbi')? [t:txb.settings,['Global','hotkey','mouse pan speed','Plane','split width','autoexe','lines per map grid','map cell width','working dir','label marker','Split '.w:txbi,'current width','current autoexe','current file'],s:option] : [{},['Global','hotkey','mouse pan speed'],s:option])",
	\'o':"let mes=''\n
		\let s:mCount='01'\n
		\let s:mSavSettings=[&ch,&more,&ls,&stal]\n
			\let [&more,&ls,&stal]=[0,0,0]\n
			\let &ch=&lines\n
		\let s:mPrevClk=[0,0]\n
		\let s:mPrevCoor=[0,0,0]\n
		\let s:mR=line('.')/t:txb.settings['lines per map grid']\n
		\call s:redraw(1)\n
		\redr!\n
		\let s:mR=s:mR>t:deepR? t:deepR : s:mR\n
		\let s:mC=w:txbi\n
		\let s:mC=s:mC<0? 0 : s:mC>=t:txbL? t:txbL-1 : s:mC\n
		\let s:mExit=1\n
		\let s:mRoff=s:mR>(&ch-2)/2? s:mR-(&ch-2)/2 : 0\n
		\let s:mCoff=s:mC*t:mapw>&co/2? s:mC*t:mapw-&co/2 : 0\n
		\call s:ecMap()\n
		\let g:TxbKeyHandler=function('s:mapKeyHandler')\n
		\if t:jhist[t:jhist[0]][0]==s:mC && abs(t:jhist[t:jhist[0]][1]-line('.'))<23\n
		\elseif t:jhist[0]<len(t:jhist)-1 && t:jhist[t:jhist[0]+1][0]==s:mC && abs(t:jhist[t:jhist[0]+1][1]-line('.'))<23\n
			\let t:jhist[0]+=1\n
		\else\n
			\call insert(t:jhist,[s:mC,line('.')],t:jhist[0]+1)\n
			\let t:jhist[0]+=1\n
		\en\n
		\call feedkeys(\"\\<plug>TxbY\")\n",
	\'M':"if 'y'==?input('? Entirely build map by scanning all files? (Map always partially updates on (o)pening and (r)edrawing) (y/n): ')\n
			\let curwin=exists('w:txbi')? w:txbi : 0\n
			\let view=winsaveview()\n
			\for i in map(range(t:txbL),'(curwin+v:val)%t:txbL')\n
				\exe 'b' t:bufs[i]\n
				\let t:txb.depth[i]=line('$')\n
				\let t:txb.map[i]={}\n
				\exe 'norm! 1G0'\n
				\let searchPat='^'.t:txb.settings['label marker'].'\\zs'\n
				\let line=search(searchPat,'Wc')\n
				\while line\n
					\let L=getline('.')\n
					\let lnum=strpart(L,col('.')-1,6)\n
					\if lnum!=0\n
						\let lbl=lnum[len(lnum+0)]==':'? split(L[col('.')+len(lnum+0)+1:],'#',1) : []\n
						\if lnum<line\n
							\if prevnonblank(line-1)>=lnum\n
								\let lbl=[' Error! '.get(lbl,0,''),'ErrorMsg']\n
							\else\n
								\exe 'norm! kd'.(line-lnum==1? 'd' : (line-lnum-1).'k')\n
							\en\n
						\elseif lnum>line\n
							\exe 'norm! '.(lnum-line).'O\ej'\n
						\en\n
						\let line=line('.')\n
					\else\n
						\let lbl=split(L[col('.'):],'#',1)\n
					\en\n
					\if !empty(lbl) && !empty(lbl[0])\n
						\let t:txb.map[i][line]=[lbl[0],get(lbl,1,'')]\n
					\en\n
					\let line=search(searchPat,'W')\n
				\endwhile\n
			\endfor\n
			\exe 'b' t:bufs[curwin]\n
			\call winrestview(view)\n
			\call s:getMapDis()\n
			\call s:redraw()\n
			\let mes='Plane remapped'\n
		\else\n
			\let mes='Plane remap cancelled'\n
		\en",
	\"\<f1>":"let warnings=(v:version<=703? '\n# Vim 7.4 is recommended.': '')
		\.(v:version<703 || v:version==703 && !has('patch30')?  '\n# Vim < 7.3.30: Plane can''t be automatically backed up in viminfo; use hotkey W instead.'
		\: empty(&vi) || stridx(&vi,'!')==-1? '\n# Put '':set viminfo+=!'' in your .vimrc file to remember plane between sessions (or write to file with hotkey W)' : '')
		\.(has('gui_running')? '\n# In gVim, auto-redrawing on resize is disabled because resizing occurs too frequently in gVim. Use hotkey r or '':call TxbKey(''r'')'' instead' : '')
		\.(has('gui_running') || !(has('unix') || has('vms'))? '\n# gVim and non-unix terminals do not support mouse in map mode'
		\: &ttymouse!=?'xterm2' && &ttymouse!=?'sgr'? '\n# '':set ttymouse=xterm2'' or ''sgr'' allows mouse panning in map mode.' : '')\n
		\let warnings=(empty(warnings)? 'WARNINGS       (none)' : 'WARNINGS '.warnings).'\n\nTIPS\n# Note the '': '' when both label anchor and title are supplied.\n
		\# The map is updated on hotkey o, r, or M. On update, displaced labels are reanchored by inserting or removing preceding blank lines. Anchoring failures are highlighted in the map.\n
		\# :call TxbKey(''S'') to access settings if the hotkey becomes inaccessible.\n
		\# When a title starts with ''!'' (eg, ''txb:321: !Title'') it will be shown instead of other labels occupying the same cell.\n
		\# Keyboard-free navigation: in normal mode, dragging to the top left corner opens the map and clicking the top left corner of the map closes it. (ttymouse=sgr or xterm2 only)\n
		\# Initializing a plane while the cursor is in a file in the plane will restore plane to that location.\n
		\# Label highlighting:\n:syntax match Title +^txb\\S*: \\zs.[^#\\n]*+ oneline display'\n
		\let commands='microViche 1.8.4.2 6/2014          HOTKEY        '.g:TXB_HOTKEY.'\n\n
		\HOTKEY COMMANDS                    MAP COMMANDS (hotkey o)\n
		\hjklyubn Pan (takes count)         hjklyubn      Move (takes count)\n
		\r / M    Redraw visible / all      HJKLYUBN      Pan (takes count)\n
		\A / D    Append / Delete split     g <cr> 2click Go\n
		\S / W    Settings / Write to file  click / drag  Select / pan\n
		\o        Open map                  z             Zoom\n
		\L        Label                     c / C         Center cursor / view\n
		\<f1>     Help                      <f1>          Help\n
		\q <esc>  Quit                      q <esc>       Quit\n
		\                                   p / P         Prev / next jump\n\n
		\LABEL marker(anchor)(:)( title)(#highlght)(#comment)\n
		\txb:345 bla bla            Anchor only\ntxb:345: Title#Visual      Anchor, title, color\n
		\txb: Title                 Title only\ntxb: Title##bla bla        Title only'\n
		\if &co>71+45\n
			\let blanks=repeat(' ',71)\n
			\let col1=s:formatPar(commands,71,1)\n
			\let col2=s:formatPar(warnings,&co-71-3>71? 71 : &co-71-3)\n
			\let mes='\n'.join(map(range(len(col1)>len(col2)? len(col1) : len(col2)),\"get(col1,v:val,blanks).get(col2,v:val,'')\"),'\n')\n
		\else\n
			\let mes='\n'.commands.'\n\n'.warnings\n
		\en",
	\'q':"let mes='  '",
	\-1:"let mes=''",
	\'null':'let mes=" "',
	\'h':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(-s:count,line('w0'))|redrawstatus!",
	\'j':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(0,line('w0')+s:count)|redrawstatus!",
	\'k':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(0,line('w0')-s:count)|redrawstatus!",
	\'l':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(s:count,line('w0'))|redrawstatus!",
	\'y':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(-s:count,line('w0')-s:count)|redrawstatus!",
	\'u':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(s:count,line('w0')-s:count)|redrawstatus!",
	\'b':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(-s:count,line('w0')+s:count)|redrawstatus!",
	\'n':"let mes=' '|let s:count='0'.str2nr(s:count)|sil call s:nav(s:count,line('w0')+s:count)|redrawstatus!",
	\1:"let mes=' '|let s:count=s:count[0] is '0'? 1   : s:count.'1'",
	\2:"let mes=' '|let s:count=s:count[0] is '0'? 2   : s:count.'2'",
	\3:"let mes=' '|let s:count=s:count[0] is '0'? 3   : s:count.'3'",
	\4:"let mes=' '|let s:count=s:count[0] is '0'? 4   : s:count.'4'",
	\5:"let mes=' '|let s:count=s:count[0] is '0'? 5   : s:count.'5'",
	\6:"let mes=' '|let s:count=s:count[0] is '0'? 6   : s:count.'6'",
	\7:"let mes=' '|let s:count=s:count[0] is '0'? 7   : s:count.'7'",
	\8:"let mes=' '|let s:count=s:count[0] is '0'? 8   : s:count.'8'",
	\9:"let mes=' '|let s:count=s:count[0] is '0'? 9   : s:count.'9'",
	\0:"let mes=' '|let s:count=s:count[0] is '0'? '01': s:count.'0'",
	\'L':"let L=getline('.')\n
		\let mes='Labeled'\n
		\if -1==match(L,'^'.t:txb.settings['label autotext'])\n
			\let prefix=t:txb.settings['label autotext'].line('.').' '\n
			\call setline(line('.'),prefix.L)\n
			\call cursor(line('.'),len(prefix))\n
			\startinsert\n
		\elseif setline(line('.'),substitute(L,'^'.t:txb.settings['label autotext'].'\\zs\\d*\\ze',line('.'),''))\nen",
	\'D':"redr\n
		\if t:txbL==1\n
			\let mes='Cannot delete last split!'\n
		\elseif input('Really delete current column (y/n)? ')==?'y'\n
			\call remove(t:txb.name,w:txbi)\n
			\call remove(t:bufs,w:txbi)\n
			\call remove(t:txb.size,w:txbi)\n
			\call remove(t:txb.exe,w:txbi)\n
			\call remove(t:txb.map,w:txbi)\n
			\call remove(t:gridLbl,w:txbi)\n
			\call remove(t:txb.depth,w:txbi)\n
			\call remove(t:oldDepth,w:txbi)\n
			\call remove(t:gridClr,w:txbi)\n
			\call remove(t:gridPos,w:txbi)\n
			\let t:txbL=len(t:txb.name)\n
			\call s:getMapDis()\n
			\winc W\n
			\let cpos=[line('.'),virtcol('.'),w:txbi]\n
			\call s:redraw()\n
			\let mes='Split deleted'\n
		\en\n
		\call s:setCursor(cpos[0],cpos[1],cpos[2])",
	\'A':"let cpos=[line('.'),virtcol('.'),w:txbi]\n
		\exe t:cwd\n
		\let file=input('(Use full path if not in working directory '.t:txb.settings['working dir'].')\nAppend file (do not escape spaces) : ',t:txb.name[w:txbi],'file')\n
		\if empty(file)\n
			\let mes='Cancelled'\n
		\else\n
			\let mes='[' . file . (index(t:txb.name,file)==-1? '] appended.' : '] (duplicate) appended.')\n
			\call insert(t:txb.name,file,w:txbi+1)\n
			\call insert(t:bufs,bufnr(fnamemodify(file,':p'),1),w:txbi+1)\n
			\call insert(t:txb.size,t:txb.settings['split width'],w:txbi+1)\n
			\call insert(t:txb.exe,t:txb.settings.autoexe,w:txbi+1)\n
			\call insert(t:txb.map,{},w:txbi+1)\n
			\call insert(t:txb.depth,100,w:txbi+1)\n
			\call insert(t:oldDepth,100,w:txbi+1)\n
			\call insert(t:gridLbl,{},w:txbi+1)\n
			\call insert(t:gridClr,{},w:txbi+1)\n
			\call insert(t:gridPos,{},w:txbi+1)\n
			\let t:txbL=len(t:txb.name)\n
			\call s:redraw(1)\n
			\call s:getMapDis()\n
		\en\n
		\cd -\n
		\call s:setCursor(cpos[0],cpos[1],cpos[2])",
	\'W':"exe t:cwd\n
		\let input=input('? Write plane to file (relative to '.t:txb.settings['working dir'].'): ',t:txb.settings.writefile,'file')\n
		\let [t:txb.settings.writefile,mes]=empty(input)? [t:txb.settings.writefile,'File write aborted'] : [input,writefile(['let TXB='.substitute(string(t:txb),'\n','''.\"\\\\n\".''','g'),'call TxbInit(TXB)'],input)? 'Error: File not writable' : 'File written, '':source '.input.''' to restore']\n
		\cd -",
	\'r':"call s:redraw(1)|redr|let mes='Redraw complete'"}
call extend(txbCmd,{"\<right>":txbCmd.l,"\<left>":txbCmd.h,"\<down>":txbCmd.j,"\<up>":txbCmd.k,"\e":txbCmd.q})



let firstrun=0
