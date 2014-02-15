let opt_autocap=0
if !exists('opt_device')
	echom "Warning: opt_device is undefined."
	let opt_device='' | en
if opt_device=~?'windows'
	let Working_Dir='C:\Users\q335r49\Desktop\Dropbox\q335writings'
	let Viminfo_File='C:\Users\q335r49\Desktop\Dropbox\q335writings\viminfo' | en
if opt_device=~?'cygwin'
	cno <c-h> <left>
	cno <c-j> <down>
	cno <c-k> <up>
	cno <c-l> <right>
	cno <c-_> <c-w>
	vno <c-c> "*y
	vno <c-v> "*p
	no! <c-_> <c-w>
	nno <c-_> db
	nno <MiddleMouse> <LeftMouse>:q<cr>
	let Viminfo_File= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings/viminfo'
	let Working_Dir= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings' | en
if opt_device=~?'notepad'
	se noswapfile
	nno <c-s> :wa<cr>
	nno <c-w> :wqa<cr>
	nno <c-v> "*p
	nno <c-q> <c-v> 
	let opt_colorscheme='notepad' | en
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
	se guioptions-=T | en

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
	echo @x
	let g:ujx_pvXpos=newpos
endfun
nno <silent> x :<c-u>call Undojx('x')<cr>
nno <silent> X :<c-u>call Undojx('X')<cr>

nno Q q
vno Q q
if !exists('Qnrm') | let Qnrm={} | en
if !exists('Qnhelp') | let Qnhelp={} | en
if !exists('Qvis') | let Qvis={} | en
if !exists('Qvhelp') | let Qvhelp={} | en
let [Qnrm.81,Qnhelp.Q,Qvis.81,Qvhelp.Q]=["Q","Ex mode","Q","Ex mode"]
fun! Qmenu(cmd)
	exe a:cmd.msg
	return get(a:cmd, getchar(), a:cmd.default)
endfun
nno <expr> q Qmenu(g:Qnrm)
vno <expr> q Qmenu(g:Qvis)
let Qnrm.default=":ec PrintDic(Qnhelp,28)\<cr>"
let Qvis.default=":\<c-u>ec PrintDic(Qvhelp,28)\<cr>"

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
let [Qnrm.103,Qnhelp.g]=[":ec PrintDic(asciidic,7)\<cr>","Show Ascii"]

fun! Scrollbind()
	if &scb
		windo se noscb
		ec "Scrollbind off"
	else
		norm! mtHmu
		let winnr=winnr()
		windo se invscb|1
		windo se scb
		exe winnr.'wincmd w'
		norm! 'uzt't
		ec "Scrollbind on"
	en
endfun
let [Qnrm.83,Qnhelp.S]=[":call Scrollbind()\<cr>","Scrollbind on"]

if !hlexists('Inactive')
	hi Inactive ctermfg=235
en
fun! ToggleDimInactiveWin()
	if exists('#DimWindows')
		autocmd! DimWindows
		windo syntax clear Inactive
	el| windo syntax region Inactive start='^' end='$'
		syntax clear Inactive
		augroup DimWindows
			autocmd BufEnter * syntax clear Inactive
			autocmd BufLeave * syntax region Inactive start='^' end='$'
		augroup end
	en
endfun
let [Qnrm.68,Qnhelp.D]=[":call ToggleDimInactiveWin()\<cr>","Dim inactive windows"]

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
nno <backspace> <c-y>
nno <c-i> <c-y>
nno <f1> <c-y>

if has('signs')
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
		if exists('b:scrollexpr')
			unlet b:scrollexpr
			nun <buffer> <leftmouse>
			iun <buffer> <leftmouse>
			nun <buffer> <scrollwheelup>
			nun <buffer> <scrollwheeldown>
			iun <buffer> <scrollwheelup>
			iun <buffer> <scrollwheeldown>
			exe "sign unplace 789 file=" . expand("%:p")
			exe "sign unplace 788 file=" . expand("%:p")
		el| nno <silent> <buffer> <leftmouse> <leftmouse>:call ScrollbarGrab()<cr>
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
	let [Qnrm.66,Qnhelp.B]=[":call ToggleScrollbar()\<cr>","Scrollbar toggle"]
	let [Qnrm.77,Qnhelp.M]=[":call ToggleBookmarks()\<cr>","Bookmarks toggle"]
en

vn j gj
vn k gk
nn j gj
nn k gk
nn gp :exe 'norm! `['.strpart(getregtype(), 0, 1).'`]'<cr>

fun! SoftCapsLock()
	norm! a^
	redr
	let key=getchar()
	while key!=g:EscAsc && key!=8
		if key=="\<backspace>"
			undoj | norm! X
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
let [Qnrm.99,Qnhelp.c]=[":call SoftCapsLock()\<cr>","Caps lock"]
ino <c-h> <esc>:call SoftCapsLock()<cr>

let Pad=repeat(' ',200)
fun! FoldText()
	let l=getline(v:foldstart)
	let p=stridx(l,'{{{')
	return g:Pad[v:foldlevel].'('.(p==0? l[3:20].' ...' : l[:p-1]).')'
endfun

com! -nargs=+ -complete=var Editlist call New('NestedList',<args>).show()
com! DiffOrig belowright vert new|se bt=nofile|r #|0d_|diffthis|winc p|diffthis

fun! Writeroom(margin)
	wa | only
	exe 'botright' (a:margin*&columns/100) 'vsp blankR'
	exe 'topleft' (a:margin*&columns/100) 'vsp blank'
	wincmd l
endfun
let [Qnrm.23,Qnhelp['^W']]=[":if winwidth(0)==&columns | silent call Writeroom(exists('g:OPT_WRITEROOMWIDTH')? g:OPT_WRITEROOMWIDTH : 25) | redr|echo 'Writeroom on' | else | only | redr|echo 'Writeroom Off' | en\<cr>","Writeroom mode"]

let CShst=[[0,7]]
let [CShix,SwchIx]=[0,0]
let CSgrp='Normal'
fun! CSLoad(scheme)
	if has_key(g:SCHEMES,a:scheme)
		for k in keys(g:SCHEMES[a:scheme])
			exe 'hi' k 'ctermfg='.g:SCHEMES[a:scheme][k][0].' ctermbg='.g:SCHEMES[a:scheme][k][1]
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
hi CS_LightOnDark ctermfg=15 ctermbg=0
fun! CSChooser()
    cno <expr> = (g:CS_MODE=='group'? "\<cr>" : "=") 
    cno <expr> <bs> (g:CS_MODE=='group' && getcmdline()==''? "CS_EXIT\<cr>" : "\<c-u>") 
    cno . <cr>
	sil exe "norm! :hi \<c-a>')\<c-b>let \<right>\<right>=split('\<del>\<cr>"
	let [fg,bg]=get(g:SCHEMES[g:CS_NAME],g:CSgrp,g:CShst[-1])
	let swatchlist=keys(g:SCHEMES.swatches)
	exe 'hi' g:CSgrp 'ctermfg='.fg 'ctermbg='.bg | redr
	let msg=g:CSgrp
	exe "echoh" g:CSgrp
	let continue=1
	let g:CS_MODE=''
	while continue
		if g:CShix<=len(g:CShst)-1
			let g:CShst[g:CShix]=[fg,bg]
		el| call add(g:CShst,[fg,bg])
			let g:CShix=len(g:CShst)-1 |en
		exe 'hi' g:CSgrp 'ctermfg='.fg 'ctermbg='.bg |redr
		echohl CS_LightOnDark
		echon '> let SCHEMES.' g:CS_NAME '.' msg ' = [' fg ',' bg ']    '
		exe "echoh" g:CSgrp
		echon '  group/scheme:<bs> history:[bf] increment/decrement:[hjkl] swatches:[np] [e]dit [i]nvert [*rR]andom save/load-swatch:[SL] delete:[^X]'
		let msg=g:CSgrp
		let c=getchar()
		exe get(g:colorD,c,'ec PrintDic(g:colorDh,20)|call getchar()')
	endwhile
	if len(g:CShst)>100
		let CShst=g:CShix<25? (g:CShst[:50]) : g:CShix>75? (g:CShst[50:])
		\: g:CShst[g:CShix-25:g:CShix+25] |en
	echoh None
	redr | ec ''
	cunmap =
	cunmap <bs>
	cunmap .
endfun
let [colorD,colorDh]=[{},{}]
let [colorD.113,colorDh['q/esc']]=["let continue=0 | if has_key(g:SCHEMES[g:CS_NAME],g:CSgrp) | exe 'hi' g:CSgrp 'ctermfg='.g:SCHEMES[g:CS_NAME][g:CSgrp][0].' ctermbg='.g:SCHEMES[g:CS_NAME][g:CSgrp][1] | en","Quit"]
let colorD[EscAsc]=colorD.113
let colorD.10="let continue=0 | exe 'hi' g:CSgrp 'ctermfg='.fg.' ctermbg='.bg | let g:SCHEMES[g:CS_NAME][g:CSgrp]=[fg,bg]"
let colorD.13=colorD.10
let [colorD.101,colorDh['e']]=["redr | echohl CS_LightOnDark | let [fg,bg]=eval(input('> let SCHEMES.'.g:CS_NAME.'.'.g:CSgrp.'=',\"[,]\<home>\<right>\"))",'enter color']
let colorD.104='let [fg,g:CShix]=[fg is "NONE"? 255 : fg is 0? "NONE" : fg-1, g:CShix+1]'
let colorD.108='let [fg,g:CShix]=[fg is "NONE"? 0 : fg is 255? "NONE" : fg+1,g:CShix+1]'
let colorDh.hl="cycle fg"
let colorD.106='let [bg,g:CShix]=[bg is "NONE"? 255 : bg is 0? "NONE" : bg-1,g:CShix+1]'
let colorD.107='let [bg,g:CShix]=[bg is "NONE"? 0 : bg is 255? "NONE" : bg+1,g:CShix+1]'
let colorDh.jk="cycle bg"
let colorD.112='let [g:SwchIx,g:CShix]=[(g:SwchIx+len(swatchlist)-1)%len(swatchlist),g:CShix+1] | let [fg,bg]=g:SCHEMES.swatches[swatchlist[g:SwchIx]] | let msg.=" = SCHEMES.swatches.".swatchlist[g:SwchIx]'
let colorD.110='let [g:SwchIx,g:CShix]=[(g:SwchIx+1)%len(swatchlist),g:CShix+1] | let [fg,bg]=g:SCHEMES.swatches[swatchlist[g:SwchIx]] | let msg.=" = SCHEMES.swatches.".swatchlist[g:SwchIx]'
let colorDh.bf="nav history"
let colorD.98='if g:CShix > 0 | let g:CShix-=1 | let [fg,bg]=g:CShst[g:CShix] | en'
let colorD.102='if g:CShix<len(g:CShst)-1|let g:CShix+=1|let [fg,bg]=g:CShst[g:CShix]|en'
let colorDh.np="nav swatches"
let colorD.42='let [fg,bg,g:CShix]=[reltime()[1]%256,reltime()[1]%256,g:CShix+1]'
let colorD.114='let [fg,g:CShix]=[reltime()[1]%256,g:CShix+1]'
let colorD.82='let [bg,g:CShix]=[reltime()[1]%256,g:CShix+1]'
let colorDh['rR*']="Random"
let colorD.24="echohl CS_LightOnDark\n
\if input('Really delete '.g:CSgrp.' (y/n)? (Highlight group will remain until vim reload)','')==?'y' && has_key(g:SCHEMES[g:CS_NAME],g:CSgrp)\n
\       unlet g:SCHEMES[g:CS_NAME][g:CSgrp]\n
\en"
let colorDh['^X']="Delete group"
let [colorD.105,colorDh.i]=['let [fg,bg]=[bg,fg]',"invert"]
let [colorD["\<backspace>"],colorD["<bs>, <c-u>"]]=["if has_key(g:SCHEMES[g:CS_NAME],g:CSgrp)\n
\    exe 'hi' g:CSgrp 'ctermfg='.g:SCHEMES[g:CS_NAME][g:CSgrp][0].' ctermbg='.g:SCHEMES[g:CS_NAME][g:CSgrp][1]\n
\en\n
\redr\n
\echoh None\n
\let g:CS_MODE='group'\n
\echohl CS_LightOnDark\n
\let in=input('> let SCHEMES.'.g:CS_NAME.'.',c==21? '':g:CSgrp,'highlight')\n
\let g:CS_MODE=''\n
\if in=='CS_EXIT'\n
\   let g:CS_MODE='scheme'\n
\   echohl CS_LightOnDark\n
\   let name=input('> let SCHEMES.',g:CS_NAME,'customlist,CompleteSchemes')\n    
\   let g:CS_MODE=''\n
\   if !empty(name)\n
\      let g:CS_NAME=name\n
\      call CSLoad(name)\n
\      let c=21\n
\      exe g:colorD[\"\<bs>\"]\n
\   else\n
\      let continue=0\n
\   en\n
\elseif !empty(in)\n
\   if has_key(g:SCHEMES[g:CS_NAME],in)\n
\      let [fg,bg]=g:SCHEMES[g:CS_NAME][in]\n
\   en\n
\   if has_key(g:SCHEMES[g:CS_NAME],g:CSgrp)\n
\       exe 'hi' g:CSgrp 'ctermfg='.(g:SCHEMES[g:CS_NAME][g:CSgrp][0]).' ctermbg='.(g:SCHEMES[g:CS_NAME][g:CSgrp][1])\n
\   en\n
\   let g:CSgrp=in\n
\   let msg=g:CSgrp\n
\el\n
\   let continue=0\n
\en", "Select Group"]
let colorD[21]=colorD["\<backspace>"]
let [colorD.83,colorDh.S]=['echohl CS_LightOnDark | let name=input("  save as: SCHEMES.swatches.","","customlist,CompleteSwatches") | if !empty(name) | let g:SCHEMES.swatches[name]=[fg,bg] |en','Save swatch']
let [colorD.76,colorDh.L]=['echohl CS_LightOnDark | let name=input("> let SCHEMES.".g:CS_NAME.".".g:CSgrp." = SCHEMES.swatches.","","customlist,CompleteSwatches") | if !empty(name) && has_key(g:SCHEMES.swatches,name) | let g:CShix=g:CShix+1 | let [fg,bg]=g:SCHEMES.swatches[name] | let msg.=" = SCHEMES.swatches.".name | else | echo "  **Swatch not found**" | sleep 1 | en','Load swatch']
let [Qnrm.67,Qnhelp.C]=[":call CSChooser()\<cr>","Customize colors"]
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
cnorea <expr> qnv ((getcmdtype()==':' && getcmdpos()<5)? "let &viminfo=''\|exe 'autocmd! WriteViminfo' \|qa!":"qnv")

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
let ftfuncD={"f":function("MLf"),"t":function("MLt"),"F":function("MLF"),"T":function("MLT"),"nf":function("MLnf"),"nt":function("MLnt"),"nF":function("MLnF"),"nT":function("MLnT")}
let invftD={"f":"F","F":"f","t":"T","T":"t","nf":"nF","nt":"nT","nF":"nf","nT":"nt"}

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
	return col(".")==1 ? (b:CapSeparators!=' '? CapWait("\r") : "\<del>")
	\ : (trunc=~'[?!.]\s*$\|^\s*$' && trunc!~'\.\.\s*$') ? (CapWait(trunc[-1:-1])) : "\<del>"
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
		nn <buffer>	<cr> za
		nn <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
		nn <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
	elseif options=~?'prose' |  setl wrap | en
	if &fo=~#'a'
		if &fo=~#'w'	
			nn <buffer> <silent> { :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>
			nn <buffer> <silent> } :call search('\S\n\\|\s\n\s*\n\\|\%$','W')<CR>
			nn <buffer> <silent> I :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>i
			nn <buffer> <silent> A :call search('\S\n\\|\s\n\s*\n\\|\%$','W')<CR>a
		el| nn <buffer> <silent> I :call search('^\s*\n\s*\S\\!\%^','Wbec')<CR>i
			nn <buffer> <silent> A :call search('\S\s*\n\s*\n\\|\%$','Wc')<CR>a
		en|en
	if options=~?'prose'
		if !exists('g:opt_disable_syntax_while_panningfiles ')
			syntax region Bold start=+\(\s\|^\)\*\zs\S+ end=+\S\ze\*+
			syntax region Italics start=+\(\s\|^\)\/\zs\S+ end=+\S\ze\/+
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
endfun

com! -nargs=+ -complete=file RestoreSettings rv! <args>|call LoadViminfoData()
fun! LoadViminfoData()
	silent exe "norm! :let v=g:SAVED_\<c-a>'\<c-b>\<right>\<right>\<right>\<right>\<right>\<right>'\<cr>"
	if exists('v') && len(v)>8
		for var in split(v)
			unlet! {'g:'.var[8:]}
			let {'g:'.var[8:]}=eval({var})	
		endfor | en
	if !exists('g:LOGDIC') | let g:logdic=New('Log') | let g:LOGDIC=g:logdic.L
	el| let g:logdic=New('Log',g:LOGDIC) | en
	call g:logdic.setcursor(len(g:LOGDIC)-1)
	if !exists('g:MRUF') | let g:MRUF={} | en
	let g:mruf=New('FileList',g:MRUF)	
	call g:mruf.prune(60)
	if !exists('g:SCHEMES') | let g:SCHEMES={'swatches':{},'default':{}} | en
	if !has_key(g:SCHEMES,'swatches')
		let g:SCHEMES.swatches={} |en
	hi clear tabline
	if exists('g:opt_colorscheme') && has_key(g:SCHEMES,g:opt_colorscheme)
		call CSLoad(g:opt_colorscheme)
		let g:CS_NAME=g:opt_colorscheme
	elseif exists('g:CS_NAME')
		call CSLoad(g:CS_NAME)
	elseif has_key(g:SCHEMES,'default')
		call CSLoad('default')
   		let g:CS_NAME='default' 
	else
		let g:SCHEME.default={}
   		let g:CS_NAME='default' 
	en
	"windows doesn't support %s
	let g:Qnrm.msg="ec printf('%-17.17s %'.(&columns-19).'s',eval(strftime('%m.\"smtwrfa\"[%w].%d.\" \".%I.\":%M \".g:LOGDIC[-1][1].(localtime()-g:LOGDIC[-1][0])/60')),(expand('% ').' '.line('.').':'.col('.').'/'.line('$'))[-&columns+19:])"
	try | silent exe g:Qnrm.msg
	catch | let g:Qnrm.msg="ec line('.').','.col('.').'/'.line('$')" | endtry
	let g:Qvis.msg=g:Qnrm.msg
endfun
fun! WriteViminfo(file)
	sil exe "norm! :unlet! g:SAVED_\<c-a>\<cr>"
	sil exe "norm! :let g:\<c-a>'\<c-b>\<right>\<right>\<right>\<right>v='\<cr>"
	let removeOriginal=(a:file==#'exit') && (v:version>703 || (v:version==703 && has("patch30")))
	for name in split(v)  
		if name[2:]==#toupper(name[2:])	
			if "000110"[type({name})]
				let {"g:SAVED_".name[2:]}=substitute(string({name}),"\n",'''."\\n".''',"g")
				if removeOriginal "eliminates duplicates when vim already writes lists / dics
					exe "unlet!" name
				en
		en | en
	endfor
	if has("gui_running") | let g:S_GUIFONT=&guifont |en
	if a:file==#'exit'
		"curdir is necessary to retain relative path
		exe 'cd '.g:Working_Dir
		se sessionoptions=winpos,resize,winsize,tabpages,folds,curdir
		if argc() | argd *
		el | mksession! .lastsession | en
		sil exe '!mv '.g:Viminfo_File.' '.g:Viminfo_File.'.bak'
		exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".g:Viminfo_File
	el| exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".a:file
		wv! |en
endfun

let [Qnrm.109,Qnhelp.m]=[":call ToggleMousePanMode()\<cr>","Mouse pan Toggle"]
let [Qnrm.71,Qnhelp.G]=[":echo search('\\S\\s*\\n\\n\\n\\n\\n\\n','W')? '':search('\\S\\zs\\s*\\n\\n\\n\\n\\n\\n','Wb')\<cr>", "Goto section End"]
let [Qnrm.102,Qnhelp['f']]=["g;","foward edit"]
let [Qnrm.98,Qnhelp['b']]=["g;","back edit"]
let [Qnrm.58,Qnhelp[':']]=["q:","commandline normal"]
let [Qnrm.70,Qnhelp.F]=[":let [&ls,&stal]=&ls>1? [0,0]:[2,2]\<cr>","Fullscreen"]
let [Qnrm.118,Qnhelp.v]=[":let &ve=empty(&ve)? 'all' : '' | echo 'Virtualedit '.(empty(&ve)? 'off':'on')\<cr>","Virtual edit toggle"]
let [Qnrm.105,Qnhelp.i]=[":se invlist\<cr>","List invisible chars"]
let [Qnrm.76,Qnhelp.L]=[":exe colorD.76\<cr>","Load Colorscheme"]
let [Qnrm.119,Qnhelp.w]=[":wincmd w\<cr>","Next Window"]
let [Qnrm.87,Qnhelp.W]=[":wincmd W\<cr>", "Prev Window"]
let [Qnrm.114,Qnhelp.r]=[":se invwrap|echo 'Wrap '.(&wrap? 'on' : 'off')\<cr>","Wrap toggle"]
let [Qnrm.122,Qnhelp.z]=[":wa\<cr>","Write all buffers"]
let [Qnrm.82,Qnhelp.R]=[":redi@t|sw|redi END\<cr>:!rm \<c-r>=escape(@t[1:],' ')\<cr>\<bs>*","Remove this swap file"]
let [Qnrm.101,Qnhelp.e]=[":noh\<cr>","No highlight search"]
let [Qnrm.78,Qnhelp.N]=[":se invnumber\<cr>","Line number toggle"]
let [Qnrm.104,Qnhelp.h]=["vawly:h \<c-r>=@\"[-1:-1]=='('? @\":@\"[:-2]\<cr>","Help word under cursor"]
let [Qnrm.49,Qnrm.50,Qnrm.51,Qnrm.52,Qnrm.53,Qnrm.54,Qnrm.55,Qnrm.56,Qnrm.57]=map(range(1,9),'":tabn".v:val."\<cr>"')
let [Qnrm.112,Qnrm.110]=[":tabp\<cr>",":tabn\<cr>"]
	let Qnhelp['1..9']="Switch tabs"
	let Qnhelp.np="Next/prev tab"
let Qnrm.42=":,$s/\\<\<c-r>=expand('<cword>')\<cr>\\>//gce|1,''-&&\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>"
let Qnrm.35=":'<,'>s/\<c-r>=expand('<cword>')\<cr>//gc\<left>\<left>\<left>"
	let Qnhelp['*#']="Replace word"
let [Qvis.42,Qvhelp['*']]=["y:,$s/\\V\<c-r>=@\"\<cr>//gce|1,''-&&\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>\<left>","Replace selection"]
let [Qnrm.120,Qnhelp.x]=["vipy: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>","Source paragraph"]
let [Qvis.120,Qvhelp.x]=["y: exe substitute(@\",\"\\n\\\\\",'','g')\<cr>","Source selection"]
let [Qvis.67,Qvhelp.C]=["\"*y:let @*=substitute(@*,\" \\n\",' ','g')\<cr>","Copy to clipboard"]
let [Qvis.103,Qvhelp.g]=["y:\<c-r>\"","Copy to command line"]
let [Qnrm.108,Qnhelp.l]=[":cal g:logdic.show()\<cr>","Show log files"]
let [Qnrm.72,Qnhelp.H]=[":call mruf.show()\<cr>","Show recent files"]
let [Qnrm.86,Qnhelp['V']]=[":call WriteViminfo(input('Name of file to write: ',Viminfo_File,'file'))\n","Write viminfo"]
let [Qnrm.84,Qnhelp['T']]=[":call Dialog()\n","Talk"]

if !exists('firstrun')
	let firstrun=0
	if !exists('Working_Dir') || !isdirectory(glob(Working_Dir))
		ec 'Warning: g:Working_Dir='.Working_Dir.' invalid, using '.$HOME
		let Working_Dir=$HOME |en
	for file in ['abbrev','pager','nav.vim']
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
	se ai tabstop=4 history=1000 mouse=a ttymouse=xterm2 hidden backspace=2
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
	augroup WriteViminfo
		au VimLeavePre * call WriteViminfo('exit')
	augroup end
	redir END
	if !argc() && filereadable('.lastsession')
		so .lastsession | en
en
