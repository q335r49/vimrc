se nocompatible
redir => g:StartupErr

let opt_autocap=0
if !exists('opt_device')
	echom "Warning: opt_device is undefined, device specific settings will not be loaded."
	let opt_device='' | en
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
	let Viminfo_File= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings/viminfo'
	let Cyg_Working_Dir= '/cygdrive/c/Documents\ and\ Settings/q335r49/Desktop/Dropbox/q335writings'
	let Working_Dir= 'C:/Users/q335r49/Desktop/Dropbox/q335writings'
	en
if opt_device=~?'notepad'
	se noswapfile
	nno <c-s> :wa<cr>
	nno <c-w> :wqa<cr>
	nno <c-v> "*p
	nno <c-q> <c-v> 
	let opt_colorscheme='notepad' | en
if opt_device=~?'droid4'
	exe "map \<c-v>\eOP !" | exe "map! \<c-v>\eOP !"
	exe "map \<c-v>\eOQ @" | exe "map! \<c-v>\eOQ @"
	exe "map \<c-v>\eOR #" | exe "map! \<c-v>\eOR #"
	exe "map \<c-v>\eOS $" | exe "map! \<c-v>\eOS $"
	exe "map \<c-v>\[15~ %" | exe "map! \<c-v>\[15~ %"
	exe "map \<c-v>\[17~ ^" | exe "map! \<c-v>\[17~ ^"
	exe "map \<c-v>\[18~ *" | exe "map! \<c-v>\[18~ &"
	exe "map \<c-v>\[19~ *" | exe "map! \<c-v>\[19~ *"
	exe "map \<c-v>\[20~ (" | exe "map! \<c-v>\[20~ ("
	exe "map \<c-v>\[21~ )" | exe "map! \<c-v>\[21~ )"
	let Viminfo_File='/mnt/sdcard/q335writings/viminfo'
	let Working_Dir='/mnt/sdcard/q335writings'
	let EscChar='@'
	let opt_autocap=1
	ino <c-b> <c-w>
	se timeout ttimeout timeoutlen=100 ttimeoutlen=100
	nn <silent> <leftmouse> <leftmouse>:call getchar()<cr><leftmouse>:exe (Mscroll()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
	nn R <c-r>
	nn <c-r> <nop> 
	let opt_LongPressTimeout=[0,500000] | en
if empty(opt_device)
	nn <silent> <leftmouse> <leftmouse>:call getchar()<cr><leftmouse>:exe (Mscroll()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
	let opt_LongPressTimeout=[0,500000] | en
if has("gui_running")
	colorscheme slate
	hi ColorColumn guibg=#222222 
	hi Vertsplit guifg=grey15 guibg=grey15
	se guioptions-=T
en

nno Q q
vno Q q
let [Qnrm,Qnhelp,Qvis,Qvhelp]=[{},{},{},{}]
let [Qnrm.81,Qnhelp.Q,Qvis.81,Qvhelp.Q]=["Q","Ex mode","Q","Ex mode"]
fun! Qmenu(cmd)
	exe a:cmd.msg
	return get(a:cmd, getchar(), a:cmd.default)
endfun
nno <expr> q Qmenu(g:Qnrm)
vno <expr> q Qmenu(g:Qvis)

let Qnrm.default=":ec PrintDic(Qnhelp,28)\<cr>"
let Qvis.default=":\<c-u>ec PrintDic(Qvhelp,28)\<cr>"

fun! PrintDic(dict,width)
	let ec=""
	let cols=min([(&columns-1)/a:width,18])
	let keys=sort(keys(a:dict),"CIcompare")
	let L=len(keys)
	let rows=len(keys)/cols+(len(keys)%cols!=0)
	let printfexpr='let ec.="\n".printf("'.join(map(range(cols),'"%-".a:width.".".a:width."s"'),'').'",'.join(map(range(cols),"'cell'.v:val.''"),',').')'
	for i in range(rows)
		for [j,n] in map(range(cols),'[v:val*rows+i,v:key]')
			let cell{n}=j>=L? '' : keys[j].'  '.(type(a:dict[keys[j]])<=1? a:dict[keys[j]] : string(a:dict[keys[j]]))
		endfor
		exe printfexpr
	endfor
	return ec
endfun

let asciidic={}
for i in range(1,256)
	let asciidic[printf("%3d",i)]=strtrans(nr2char(i))
endfor
let [Qnrm.103,Qnhelp.g]=[":ec PrintDic(asciidic,11)\<cr>","Show Ascii"]

fun! Scrollbind()
	norm! mtHmu
	let winnr=winnr()
	windo se invscb|1
	windo se scb
	exe winnr.'wincmd w'
	norm! 'uzt't
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
let Qnrm[EscAsc]="\e"
let Qvis[EscAsc]=""

nno <space> <c-e>
nno <backspace> <c-y>
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

function! SafeSearchCommand(line1, line2, theCommand)
  let search = @/
  exe a:line1 . "," . a:line2 . a:theCommand
  let @/ = search
endfunction
com! -range -nargs=+ SS call SafeSearchCommand(<line1>, <line2>, <q-args>)
com! -range -nargs=* S call SafeSearchCommand(<line1>, <line2>, 's' . <q-args>)

nn j gj
nn k gk
let gnmap=map(range(256),'"g".nr2char(v:val)')
let gvmap=copy(gnmap)
let gnmap[char2nr('p')]=":exe 'norm! `['.strpart(getregtype(), 0, 1).'`]'\<cr>"
let gnmap[char2nr('j')]='j'
let gnmap[char2nr('k')]='k'
let gnmap[char2nr('$')]="G:call search('^.*\\S.*$','Wcb')\<cr>"
let gnmap[char2nr('A')]="A"
let gnmap[char2nr('{')]="{"
let gnmap[char2nr('}')]="}"
let gvmap[char2nr('U')]=":S/\\<\\(\\w\\)\\(\\w*\\)\\>/\\u\\1\\L\\2/g\<cr>"
let gvmap[char2nr('p')]="\<esc>:call search('\\S\\n\\s*.\\|\\n\\s*\\n\\s*.\\|\\%^','Wbe')\<cr>m<:call search('\\S\\n\\|\\s\\n\\s*\\n\\|\\%$','W')\<cr>m>gv"
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
let [Qnrm.99,Qnhelp.c]=[":call SoftCapsLock()\<cr>","Caps lock"]

let Pad=repeat(' ',200)
fun! FoldTextPara()
	let l=getline(v:foldstart)
	return l[0]==#l[1]? l[:match(l,'[?!\.]\s\|\zs -')] : ' - '.l[:match(l,'[?!\.]\s\|\zs -')]
endfun
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
let [Qnrm.23,Qnhelp['^W']]=[":if winwidth(0)==&columns | silent call Writeroom(exists('g:OPT_WRITEROOMWIDTH')? g:OPT_WRITEROOMWIDTH : 25) | else | only | en\<cr>","Writeroom mode"]

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
fun! CSLoad(scheme)
	let g:SCHEMES.current=deepcopy(a:scheme)
	for k in keys(g:SCHEMES.current)
		exe 'hi' k 'ctermfg='.g:SCHEMES.current[k][0].' ctermbg='.g:SCHEMES.current[k][1]
	endfor
endfun
fun! CompleteSwatches(Arglead,CmdLine,CurPos)
	return filter(keys(g:SCHEMES.swatches),'v:val=~a:Arglead')
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
	elseif a:0==1 && type(a:1)==1 && has_key(g:SCHEMES.swatches,a:1)
		let [fg,bg]=g:SCHEMES.swatches[a:1]
		call add(gName:CShst,[fg,bg])
	el|retu|en
	let swatchlist=keys(g:SCHEMES.swatches)
	exe 'hi' g:CSgrp 'ctermfg='.fg 'ctermbg='.bg | redr
	let msg=g:CSgrp
	exe "echoh" g:CSgrp
	ec msg fg bg
	let continue=1
	let c=getchar()
	exe get(g:colorD,c,'ec PrintDic(g:colorDh,20)|call getchar()')
	while continue
		if g:CShix<=len(g:CShst)-1
			let g:CShst[g:CShix]=[fg,bg]
		el| call add(g:CShst,[fg,bg])
			let g:CShix=len(g:CShst)-1 |en
		exe 'hi' g:CSgrp 'ctermfg='.fg 'ctermbg='.bg |redr
		exe "echoh" g:CSgrp
		ec msg fg bg
		let msg=g:CSgrp
		let c=getchar()
		exe get(g:colorD,c,'ec PrintDic(g:colorDh,20)|call getchar()')
	endwhile
	if len(g:CShst)>100
		let CShst=g:CShix<25? (g:CShst[:50]) : g:CShix>75? (g:CShst[50:])
		\: g:CShst[g:CShix-25:g:CShix+25] |en
	echoh None
endfun
let colorD={}
let colorDh={}
let [colorD.113,colorDh['q/esc']]=["let continue=0\n
\if has_key(g:SCHEMES.current,g:CSgrp)\n
\    exe 'hi' g:CSgrp 'ctermfg='.(g:SCHEMES.current[g:CSgrp][0]).' ctermbg='.(g:SCHEMES.current[g:CSgrp][1])|en","Quit"]
let colorD[EscAsc]=colorD.113
let colorD.10="let continue=0 | exe 'hi' g:CSgrp 'ctermfg='.fg.' ctermbg='.bg
\|let g:SCHEMES.current[g:CSgrp]=[fg,bg]"
let colorD.13=colorD.10
let [colorD.101,colorDh['e']]=["let [fg,bg]=eval(input('[fg,bg]=',\"[,]\<home>\<right>\"))",'enter color']
let colorD.104='let [fg,g:CShix]=[fg is "NONE"? 255 : fg is 0? "NONE" : fg-1, g:CShix+1]'
let colorD.108='let [fg,g:CShix]=[fg is "NONE"? 0 : fg is 255? "NONE" : fg+1,g:CShix+1]'
let colorDh.hl="cycle fg"
let colorD.106='let [bg,g:CShix]=[bg is "NONE"? 255 : bg is 0? "NONE" : bg-1,g:CShix+1]'
let colorD.107='let [bg,g:CShix]=[bg is "NONE"? 0 : bg is 255? "NONE" : bg+1,g:CShix+1]'
let colorDh.jk="cycle bg"
let colorD.98='let [g:SwchIx,g:CShix]=[(g:SwchIx+len(swatchlist)-1)%len(swatchlist),g:CShix+1] | let [fg,bg]=g:SCHEMES.swatches[swatchlist[g:SwchIx]] | let msg.=" ".swatchlist[g:SwchIx]'
let colorD.102='let [g:SwchIx,g:CShix]=[(g:SwchIx+1)%len(swatchlist),g:CShix+1] | let [fg,bg]=g:SCHEMES.swatches[swatchlist[g:SwchIx]] | let msg.=" ".swatchlist[g:SwchIx]'
let colorDh.bf="cycle swatches"
let colorD.112='if g:CShix > 0 | let g:CShix-=1 | let [fg,bg]=g:CShst[g:CShix] | en'
let colorD.110='if g:CShix<len(g:CShst)-1|let g:CShix+=1|let [fg,bg]=g:CShst[g:CShix]|en'
let colorDh.np="nav history"
let colorD.42='let [fg,0bg,g:CShix]=[reltime()[1]%256,reltime()[1]%256,g:CShix+1]'
let colorD.114='let [fg,g:CShix]=[reltime()[1]%256,g:CShix+1]'
let colorD.82='let [bg,g:CShix]=[reltime()[1]%256,g:CShix+1]'
let colorDh['rR*']="Random"
let [colorD.105,colorDh.i]=['let [fg,bg]=[bg,fg]',"invert"]
let [colorD.103,colorDh.g]=["let in=input('Group: ','','highlight')\n
\if !empty(in)\n
\if has_key(g:SCHEMES.current,in)\n
\     let [fg,bg]=g:SCHEMES.current[in]\n
\en\n
\if has_key(g:SCHEMES.current,g:CSgrp)\n
\    exe 'hi' g:CSgrp 'ctermfg='.(g:SCHEMES.current[g:CSgrp][0]).' ctermbg='.(g:SCHEMES.current[g:CSgrp][1])\n
\en\n
\let g:CSgrp=in\n
\let msg=g:CSgrp | en","hl group"]
let [colorD.115,colorDh.s]=['let name=input("Save swatch as: ","","customlist,CompleteSwatches") |
\if !empty(name) | let g:SCHEMES.swatches[name]=[fg,bg] |en','Save swatch']
let [colorD.83,colorDh.S]=['let name=input("Save scheme as: ","","customlist,CompleteSchemes") | if !empty(name) | let g:SCHEMES[name]=deepcopy(g:SCHEMES.current) | en | let continue=0','Save Scheme']
let [colorD.76,colorDh.L]=["let in=get(g:SCHEMES,input('Load scheme: ','','customlist,CompleteSchemes'),{})\n
\if !empty(in)\n
\    call CSLoad(in) | en\n
\let continue=0",'Load scheme']
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
cnorea <expr> wsd ((getcmdtype()==':' && getcmdpos()<5)? 'w\|so%\|bd':'wsd')

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
		setl fdt=FoldTextPara()
	en
	if options=~?'hardwrap'
		setl nowrap fo=aw
		let number=matchstr(options,'hardwrap\zs\d*') 
		if !empty('number')
			exe "setl tw=".number." wiw=".(number+2)
		el| setl tw=70 wiw=72
		en
		nn <buffer>	<cr> za
		nn <buffer> <silent> > :se ai<CR>mt>apgqap't:se noai<CR>
		nn <buffer> <silent> < :se ai<CR>mt<apgqap't:se noai<CR>
		if &fo=~#'w'	
			nn <buffer> <silent> { :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>
			nn <buffer> <silent> } :call search('\S\n\\|\s\n\s*\n\\|\%$','W')<CR>
			nn <buffer> <silent> I :call search('\S\n\s*.\\|\n\s*\n\s*.\\|\%^','Wbe')<CR>i
			nn <buffer> <silent> A :call search('\S\n\\|\s\n\s*\n\\|\%$','W')<CR>a
		el| nn <buffer> <silent> I :call search('^\s*\n\s*\S\\!\%^','Wbec')<CR>i
			nn <buffer> <silent> A :call search('\S\s*\n\s*\n\\|\%$','Wc')<CR>a
		en
	elseif options=~?'prose' |  setl wrap
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
endfun

fun! RestoreSavedVars()
	exe "norm! :let v=g:SAVED_\<c-a>'\<c-b>\<right>\<right>\<right>\<right>\<right>\<right>'\<cr>"
	if exists('v') && len(v)>8
		for var in split(v)
			unlet! {'g:'.var[8:]}
			let {'g:'.var[8:]}=eval({var})	
		endfor | en
	if !exists('g:LOGDIC') | let g:logdic=New('Log') | let g:LOGDIC=g:logdic.L
	el| let g:logdic=New('Log',g:LOGDIC) | en
	if !exists('g:TODO') | let g:TODO=[] |en
	let g:todo=New('NestedList',g:TODO)	
	if !exists('g:MRUF') | let g:MRUF={} | en
	let g:mruf=New('FileList',g:MRUF)	
	call g:mruf.prune(60)
	if !exists('g:SCHEMES') | let g:SCHEMES={'swatches':{},'current':{}} | en
	if !has_key(g:SCHEMES,'swatches')
		let g:SCHEMES.swatches={} |en
	hi clear tabline
	if exists('g:opt_colorscheme') && has_key(g:SCHEMES,g:opt_colorscheme)
		call CSLoad(g:SCHEMES[g:opt_colorscheme])
	el| call CSLoad(g:SCHEMES.current) | en
	let g:Qnrm.msg="ec printf('%-23.23s %'.(&columns-26).'s',eval(strftime('printf(\" %%d%%s%%d %%d:%M %%s%%.2f\",%m,\"smtwrfa\"[%w],%d,%I,g:logdic.L[-1][1],(localtime()-g:logdic.L[-1][0])/3600.0)',localtime())),(expand('%').' ('.join(getpos('.')[1:2],',').') $'.line('$'))[-&columns+26:])"
	try | silent exe g:Qnrm.msg
	catch | let g:Qnrm.msg="ec line('.').','.col('.').'/'.line('$')" | endtry
	let g:Qvis.msg=g:Qnrm.msg
endfun
fun! WriteVimState(file) "empty file means, execute exit routine
	echoh ErrorMsg
		if empty('a:file') && g:StartupErr=~?'error' && input("Startup errors were encountered! ".g:StartupErr."\nSave settings anyways?")!~?'^y'
			retu|en
	echoh None
	sil exe "norm! :unlet! g:SAVED_\<c-a>\<cr>"
	sil exe "norm! :let g:\<c-a>'\<c-b>\<right>\<right>\<right>\<right>v='\<cr>"
	let removeOriginal=empty(a:file) && (v:version>703 || (v:version==703 && has("patch30")))
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
	if empty(a:file)
		"curdir is necessary to retain relative path
		exe 'cd '.(g:opt_device=~?'cygwin'? g:Cyg_Working_Dir : g:Working_Dir)
		se sessionoptions=winpos,resize,winsize,tabpages,folds,curdir
		if argc() | argd *
		el | mksession! .lastsession | en
		sil exe '!mv '.g:Viminfo_File.' '.g:Viminfo_File.'.bak'
		exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".g:Viminfo_File
	el| exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".a:file
		wv! |en
endfun

let [Qnrm.46,Qnhelp['.']]=["g;","Next edit"]
let [Qnrm.44,Qnhelp[',']]=["g;","Prev edit"]
let [Qnrm.58,Qnhelp[':']]=["q:","commandline normal"]
let [Qnrm.116,Qnhelp.t]=[":let &showtabline=!&showtabline\<cr>","Tabline toggle"]
let [Qnrm.118,Qnhelp.v]=[":if empty(&ve) | se ve=all | el | se ve= | en\<cr>","Virtual edit toggle"]
let [Qnrm.76,Qnhelp.L]=[":se invlist\<cr>","List invisible chars"]
let [Qnrm.115,Qnhelp.s]=[":let &ls=&ls>1? 0:2\<cr>","Status line toggle"]
let [Qnrm.119,Qnhelp.w]=[":exe 'wincmd w'.(&scb? '|'.line('.') : '')\<cr>","Next Window"]
let [Qnrm.87,Qnhelp.W]=[":exe 'wincmd W'.(&scb? '|'.line('.') : '')\<cr>","Prev Window"]
let [Qnrm.114,Qnhelp.r]=[":se invwrap\<cr>","Wrap toggle"]
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
let [Qnrm.32,Qnhelp['<space>']]=[":call todo.show()\<cr>","Todo list"]
if opt_device=='droid4' | let [Qnrm.73,Qnhelp.I]=["R","Replace mode"] | en

if !exists('firstrun')
	let firstrun=0
	if !exists('Working_Dir') || !isdirectory(glob(Working_Dir))
		ec 'Error: g:Working_Dir='.Working_Dir.' invalid, using '.$HOME
		let Working_Dir=$HOME |en
	for file in ['abbrev','pager']
		if filereadable(Working_Dir.'/'.file) | exe 'so '.Working_Dir.'/'.file
		el| ec 'Error:' Working_Dir.'/'.file 'unreadable'|en
	endfor
	if !argc() && isdirectory(Working_Dir)
		if opt_device=~?'cygwin'
			exe 'cd '.Cyg_Working_Dir
		el| exe 'cd '.Working_Dir | en | en
	if !exists('g:Viminfo_File')
		cal Ec("Error: g:Viminfo_File undefined, falling back to default")
	el
		exe "se viminfo=!,'120,<100,s10,/50,:500,h,n".g:Viminfo_File
	en
	au VimEnter * call RestoreSavedVars() 
	au VimEnter * au BufWinEnter * call mruf.restorepos(expand('%')) 
	au VimEnter * au BufLeave * call mruf.insert(expand('<afile>'),line('.'),col('.'),line('w0'))
	se nowrap linebreak sidescroll=1 ignorecase smartcase incsearch wiw=72
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
		se noshowmode | en
	au BufWinEnter * call CheckFormatted()
	au VimLeavePre * call WriteVimState('')
	redir END
	if !argc() && filereadable('.lastsession')
		so .lastsession | en
en
