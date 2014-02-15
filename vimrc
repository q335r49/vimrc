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
	nno <MiddleMouse> <LeftMouse>:q<cr>
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

let [Qnrm.112,Qnhelp.p]=["\<f10>","nav-mode hotkey"]

nno <silent> G :<c-u>exe v:count? v:count : search('\S\s*\n\n\n\n\n\n','W')? '' : 99999<cr>zz
nno <silent> gg :<c-u>exe v:count? v:count : search('\S\s*\n\n\n\n\n\n','Wb')? '' : 1<cr>zz

fun! DeleteHiddenBuffers()
	let tpbl=[]
	call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
	for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
		silent execute 'bwipeout' buf
	endfor
endfun

fun! Writeroom(...)
	let margin=a:0? a:1 : input("margin: ", &tw? max([(&columns-&tw-3)/2,10]) : 25)
	if margin
		only
		exe 'topleft'.margin.'vsp blank'
		wincmd l
	en
endfun
com! Write call Writeroom()

fun! PRINT(vars)
	redr
	return "exe eval('\"'.input(join(map(split('".a:vars."',','),'v:val.\":\".eval(v:val)'),' '),'').'\"')"
endfun

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

ino <f1> <c-o>zh
nn <f1> zh

let ujx_pvXpos=[0,0,0,0]
let ujx_eolnotreached=1
fun! Undojx(cmd)
	if getpos('.')==g:ujx_pvXpos
		try
			undoj
		catch *
			let @x=''
			let g:ujx_eolnotreached=1
		endtry
	else
		let @x=''
		let g:ujx_eolnotreached=1
	en
	exe 'norm! '.v:count1.a:cmd
	let newpos=getpos('.')
	if newpos[2]==g:ujx_pvXpos[2]
		let @x.=@"
	elseif a:cmd==#'x' && g:ujx_eolnotreached && !empty(@x)
		let @x.=@"
		let g:ujx_eolnotreached=0
	el
		let @x=@".@x
	en
	echo strtrans(@x)[-&columns+1:]
	let g:ujx_pvXpos=newpos
endfun
nno <silent> x :<c-u>call Undojx('x')<cr>
nno <silent> X :<c-u>call Undojx('X')<cr>

nmap <expr> q Qmenu(g:Qnrm)
vmap <expr> q Qmenu(g:Qvis)
nno <c-r> q
vno <c-r> q
se stl=%f\ %l/%L\ %c%V
fun! Qmenu(menu,...)
	let [view,stal]=[winsaveview(),&stal]
	let [view.topline,&stal,cuc,&cuc,&ls,ls]=[view.topline+!stal,1,&cuc,1,2,&ls]
	echohl StatusLineNC
	echo strftime('%c').' ['.g:LOGDIC[-1][1].(localtime()-g:LOGDIC[-1][0])/60.']'
	echohl None
	call winrestview(view)
	redr
	let c=getchar()
	let [view.topline,&stal,&cuc,&ls]=[view.topline-!stal,stal,cuc,ls]
	call winrestview(view)
	return get(a:menu,c,a:menu.default)
endfun
let Qnrm.default=":ec PrintDic(Qnhelp,28)\<cr>"
let Qvis.default=":\<c-u>ec PrintDic(Qvhelp,28)\<cr>"
let [Qnrm.81,Qnhelp.Q,Qvis.81,Qvhelp.Q]=["Q","Ex mode","Q","Ex mode"]
let [Qnrm[102],Qnhelp.f]=[":ec search('^\\S*\\ '.expand('<cword>').'(')\<cr>","Go to function"]
let Qnrm["\<leftmouse>"]="\<leftmouse>"
let [Qnrm.58,Qnhelp[':']]=["q:","commandline normal"]
let [Qnrm.70,Qnhelp.F]=[":let [&ls,&stal]=&ls>=1? [0,0]:[1,1]\<cr>","Fullscreen"]
let [Qnrm.118,Qnhelp.v]=[":let &ve=empty(&ve)? 'all' : '' | echo 'Virtualedit '.(empty(&ve)? 'off':'on')\<cr>","Virtual edit toggle"]
let [Qnrm.105,Qnhelp.i]=[":se invlist\<cr>","List invisible chars"]
let [Qnrm.114,Qnhelp.r]=[":se invwrap|echo 'Wrap '.(&wrap? 'on' : 'off')\<cr>","Wrap toggle"]
let [Qnrm.122,Qnhelp.z]=[":wa\<cr>","Write all buffers"]
let [Qnrm.82,Qnhelp.R]=[":redi@t|sw|redi END\<cr>:!rm \<c-r>=escape(@t[1:],' ')\<cr>\<bs>*","Remove this swap file"]
let [Qnrm.113,Qnhelp.q]=[":noh\<cr>","No highlight search"]
let [Qnrm.78,Qnhelp.N]=[":se invnumber\<cr>","Line number toggle"]
let [Qnrm.104,Qnhelp.h]=["vawly:h \<c-r>=@\"[-1:-1]=='('? @\":@\"[:-2]\<cr>","Help word under cursor"]
let [Qnrm.49,Qnrm.50,Qnrm.51,Qnrm.52,Qnrm.53,Qnrm.54,Qnrm.55,Qnrm.56,Qnrm.57]=map(range(1,9),'":tabn".v:val."\<cr>"')
	let Qnhelp['1..9']="Switch tabs"
let [Qnrm.9,Qnrm.32,Qnhelp['<tab,space']]=[":call QmenuCycle('tabp')\<cr>",":call QmenuCycle('tabn')\<cr>","Tabs <>"]
let [Qnrm.100,Qnrm.115,Qnhelp.sd]=[":call QmenuCycle('wincmd w')\<cr>",":call QmenuCycle('wincmd W')\<cr>","Columns <>"]
let [Qnrm.119,Qnrm.101,Qnhelp.we]=[":call QmenuCycle('norm! g;zz')\<cr>",":call QmenuCycle('norm! g,zz')\<cr>","Changes <>"]
let [Qnrm.23,Qnhelp['^W']]=[":call QmenuCycle('tabc')\<cr>","tabc"]
let [Qnrm.77,Qnrm.109,Qnhelp['<>']]=[":call QmenuCycle('tabm -1')\<cr>",":call QmenuCycle('tabm +1')\<cr>","tabm <>"]
let [Qnrm.62,Qnrm.60,Qnhelp['<>']]=[":call QmenuCycle('3wincmd >')\<cr>",":call QmenuCycle('3wincmd <')\<cr>","resize split"]
fun! QmenuCycle(cmd)
	let cmd=a:cmd
	while !empty(cmd)
		exe cmd
		let cmd=matchstr(Qmenu(g:Qnrm),'QmenuCycle(''\zs[^'']*')
	endw
endfun
let Qnrm.42=":,$s/\\<\<c-r>=expand('<cword>')\<cr>\\>//gce|1,''-&&\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>"
let Qnrm.35=":'<,'>s/\<c-r>=expand('<cword>')\<cr>//gc\<left>\<left>\<left>"
	let Qnhelp['*#']="Replace word"
let [Qvis.42,Qvhelp['*']]=["y:,$s/\\V\<c-r>=@\"\<cr>//gce|1,''-&&\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>","Replace selection"]
let [Qnrm.120,Qnhelp.x]=["vipy: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>","Source paragraph"]
let [Qvis.120,Qvhelp.x]=["y: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>","Source selection"]
let [Qvis.67,Qvhelp.C]=["\"*y:let @*=substitute(@*,\" \\n\",' ','g')\<cr>","Copy to clipboard"]
let [Qvis.103,Qvhelp.g]=["y:\<c-r>\"","Copy to command line"]
let [Qnrm.108,Qnhelp.Ll]=[":cal g:logdic.show()\<cr>","Show log files"]
let Qnrm.76=":cal g:logdic.show()\<cr>"
let [Qnrm.72,Qnhelp.H]=[":call mruf.show()\<cr>","Show recent files"]
let [Qnrm.86,Qnhelp['V']]=[":call WriteViminfo(input('Name of file to write: ',Viminfo_File,'file'))\n","Write viminfo"]
nn R <c-r>
let [Qnrm.73,Qnhelp.I]=["R","Replace mode"]

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
let [Qnrm.103,Qnhelp.g]=[":call AsciiUI()\<cr>","Show Ascii"]

if !exists("g:EscChar") | let g:EscChar="\e" | let g:EscAsc=27
el | let g:EscAsc=char2nr(g:EscChar) |en
if g:EscChar!="\e"
	exe 'no <F2>' g:EscChar
	exe 'no' g:EscChar '<Esc>'
   	exe 'no!' g:EscChar '<Esc>'
   	exe 'cno' g:EscChar '<C-C>'
en
let Qnrm[EscAsc]="g\e"
let Qvis[EscAsc]=""

nno <space> <c-e>
nno <bs> <c-y>
nno <c-i> <c-y>
vn j gj
vn k gk
nn j gj
nn k gk
nn gp :exe 'norm! `['.strpart(getregtype(), 0, 1).'`]'<cr>
nn gA :let @_=!search('\S\s*\n\s*\n','W') && !search('\%$','W') \|startinsert!<cr>

let sur_pairs={'(':')','{':'}','<':'>','[':']'}
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
	let @u=get(g:sur_pairs,@t,@t)
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
let [Qnrm.99,Qnhelp.c]=[":call SoftCap()\<cr>","Caps lock"]
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
let [CS_histi,SwchIx]=[0,0]
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
		echon ' hjklJKr <bs>Up <cr>Save [L]ink [g]oLink [WR]Favs [bf]Hist [U]nlet [^R]eload'
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
let colorD.10="call CS_hi(g:CS_grp,hl) | let g:SCHEMES[g:CS_NAME][g:CS_grp]=hl | echohl CS_LightOnDark | ec '> SCHEMES.'.g:CS_NAME.'.'.g:CS_grp.' saved' | sleep 700m"
let colorD.13=colorD.10
let colorD.101="redr | echohl CS_LightOnDark | let in=input('> let SCHEMES.'.g:CS_NAME.'.'.g:CS_grp.'['.field.'] = ',hl[field]) | if !empty(in) | let hl[field]=in | en"
let colorD.74="if hl[0] isnot 'LINK-->' | let hl[field]='NONE' | en"
let colorD.75="if hl[0] isnot 'LINK-->' | let hl[field]=field==2? 'NONE' : 100 | en"
let colorD.104='let field=(field+2)%3'
let colorD.108='let field=(field+1)%3'
let colorD.106='if hl[0] isnot "LINK-->" | let [hl[field],g:CS_histi]=field<2? [hl[field] is "NONE"? 255 : hl[field] == 0? "NONE" : hl[field]-1,g:CS_histi+1] : [g:CS_attr[(get(g:CS_attrIx,hl[2], 1)-1)%len(g:CS_attr)],g:CS_histi+1] | el | let hl=[0,15,"NONE"] | en'
let colorD.107='if hl[0] isnot "LINK-->" | let [hl[field],g:CS_histi]=field<2? [hl[field] is "NONE"? 0 : hl[field] == 255? "NONE" : hl[field]==0? 1 : hl[field]+1,g:CS_histi+1] : [g:CS_attr[(get(g:CS_attrIx,hl[2],-1)+1)%len(g:CS_attr)],g:CS_histi+1] | el | let hl=[0,15,"NONE"] | en'
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
let [Qnrm.67,Qnhelp.C]=[":call CS_UI()\<cr>","Colors chooser"]
let [Qnrm.7,Qnhelp['^G']]=[":ec 'hi<' . synIDattr(synID(line('.'),col('.'),1),'name') . '> trans<'
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
cnorea <expr> ws ((getcmdtype()==':' && getcmdpos()<4)? 'w\|so%':'ws')
cnorea <expr> wd ((getcmdtype()==':' && getcmdpos()<4)? 'w\|bd':'wd')

let g:charL=[]
let g:opt_disable_syntax_while_panning=1
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
			nn <buffer> <silent> { :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>
			nn <buffer> <silent> } 0:call search('\S\n\\|\s\n\s*\n\\|\%$','W')<CR>
			nn <buffer> <silent> I :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>i
			nn <buffer> <silent> A 0:exe 'norm! '.(search('\S\n\\|\s\n\s*\n','W')? 'g' : '$')<CR>a
		el| nn <buffer> <silent> I :call search('^\s*\n\s*\S\\!\%^','Wbec')<CR>i
			nn <buffer> <silent> A 0:exe 'norm! '.(search('\S\s*\n\s*\n','Wc')? 'g' : '$')<CR>a
		en|en
	if options=~?'prose'
		if !exists('g:opt_disable_syntax_while_panningfiles ')
			syntax region Bold matchgroup=Normal start=+\(\W\|^\)\zs\*\ze\w+ end=+\w\zs\*+ concealends
			syntax region Underline matchgroup=Normal start=+\(\W\|^\)\zs\/\ze\w+ end=+\w\zs\/+ concealends
		else
			syntax clear
		en
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

com! -nargs=+ -complete=file RestoreSettings rv! <args>|call LoadViminfoData()
fun! LoadViminfoData()
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
	let g:MRUF=exists('g:MRUF')? g:MRUF : {}
	let g:mruf=New('FileList',g:MRUF)	
	cal g:mruf.prune(60)
	let g:SCHEMES=exists('g:SCHEMES')? g:SCHEMES : {'swatches':{},'default':{}}
	let g:SCHEMES.swatches=has_key(g:SCHEMES,'swatches')? g:SCHEMES.swatches : {}
	let g:CS_NAME=exists('g:CS_NAME')? g:CS_NAME : 'default'
	cal CSLoad(g:CS_NAME)
	echom "Something wrong? Use :RestoreSettings viminfo.bak to load previous states."
endfun
fun! WriteViminfo(file)
	if v:version<703 || v:version==703 && !has("patch30")
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
		if argc() | argd *
		el | mksession! .lastsession | en
		sil exe '!mv '.g:Viminfo_File.' '.g:Viminfo_File.'.bak'
		exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".g:Viminfo_File
	el| exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".a:file
		wv! |en
endfun

if !exists('firstrun')
	let firstrun=0
	if !exists('Working_Dir') || !isdirectory(glob(Working_Dir))
		ec 'Warning: g:Working_Dir='.Working_Dir.' invalid, using '.$HOME
		let Working_Dir=$HOME |en
	for file in ['abbrev','pager','nav.vim']   "+utils
		if !empty(glob(Working_Dir.'/'.file)) | exe 'so '.Working_Dir.'/'.file
		el| ec 'Warning:' Working_Dir.'/'.file 'doesn't exist'
		en
	endfor
	if !argc() | exe 'cd '.Working_Dir | en
	let setViExpr="se viminfo=!,'120,<100,s10,/50,:500,h,n"
	if !exists('g:Viminfo_File')
		ec "Warning: g:Viminfo_File undefined, falling back to default"
		exe setViExpr[:-3]
	el| let viminfotime=strftime("%Y-%m-%d-%H-%M-%S",getftime(glob(g:Viminfo_File)))
		let conflicts=sort(split(glob(g:Viminfo_File.' (conflicted*'),"\n"))
		let latest_date=matchstr(get(conflicts,-1,''),'conflicted copy \zs.*\ze)')
		if !empty(latest_date) && latest_date>viminfotime && input("\nCurrent viminfo (".viminfotime.") older than ".conflicts[-1]."; load latter instead? (y/n)")=~?'^y'
			echo "Loading" conflicts[-1] "...\nUse :wv to overrite current viminfo."
			exe setViExpr.conflicts[-1]
		el| exe setViExpr.g:Viminfo_File | en
	en
	au VimEnter * call LoadViminfoData()
	au VimEnter * au BufRead * call mruf.restorepos(expand('%')) 
	au VimEnter * au BufLeave * call mruf.insert(expand('<afile>'),line('.'),col('.'),line('w0'))
	se linebreak sidescroll=1 ignorecase smartcase incsearch wiw=72
	se ai tabstop=4 history=1000 mouse=a ttymouse=xterm2 hidden backspace=2 stal=0 ls=0
	se wildmode=list:longest,full display=lastline modeline t_Co=256 ve=
	se whichwrap+=b,s,h,l,,>,~,[,] wildmenu sw=4 hlsearch listchars=tab:>\ ,eol:<
	se fcs=vert:\  showbreak=.\  
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
	au VimLeavePre * call WriteViminfo('exit')
	if !argc() && filereadable('.lastsession')
	 	so .lastsession | en
en
