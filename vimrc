redir => g:StartupErr

let opt_autocap=0
if !exists('opt_device')
	echom "Warning: opt_device is undefined."
	let opt_device='' | en
if opt_device=~?'windows'
	let Working_Dir='C:\Users\q335r49\Desktop\Dropbox\q335writings'
	let Viminfo_File='C:\Users\q335r49\Desktop\Dropbox\q335writings\viminfo' | en
if opt_device=~?'cygwin'
	"se timeout ttimeout timeoutlen=100 ttimeoutlen=100
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
	small bug in @ mapping
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
	let Viminfo_File='/sdcard/q335writings/viminfo'
	let Working_Dir='/sdcard/q335writings'
	let EscChar='@'
	let opt_autocap=1
	ino <c-b> <c-w>
	let opt_mousepan=1
	nn <c-r> <nop> 
	en
if has("gui_running")
	se guifont=Envy_Code_R:h11:cANSI
	colorscheme solarized
	hi ColorColumn guibg=#222222 
	hi Vertsplit guifg=grey15 guibg=grey15
	se guioptions-=T | en

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

fun! BreakLines(str,w)
	let [seg,spc]=[[0],repeat(' ',len(&brk))]
	while seg[-1]<len(a:str)-a:w
		let ix=(a:w+strridx(tr(a:str[seg[-1]:seg[-1]+a:w-1],&brk,spc),' '))%a:w
		call extend(seg,[seg[-1]+ix-(a:str[seg[-1]+ix=~'\s']),seg[-1]+ix+1])
	endw
	call add(seg,-1)
	return map(range(len(seg)/2),'a:str[seg[2*v:val]:seg[2*v:val+1]]')
endfun
fun! Dialog(...)
	let [A,B,col,mg,off]=map(['Amadeus','Theophilus',50,5,10],"v:key<a:0? a:{v:key+1} : v:val")
	let Aparx='let pg[0]="'.printf(mg>1? '%-'.(mg-1).'.'.(mg-1).'s ':'%-'.mg.'.'.mg.'s',A).'".pg[0]['.mg.':]'
	let Bparx='let pg[0]=pg[0]."'.printf(mg>1? ' %-'.(mg-1).'.'.(mg-1).'s':'%-'.mg.'.'.mg.'s',B).'"'
	let Amapx='"'.repeat(' ',mg).'".v:val'
	let Bmapx='printf("%'.(col+off).'.'.(col+off).'s",v:val)'
	let [AB,input]=['A',input(A.': ')]
	echohl Question
	while input!='.'
		if !empty(input)
			let pg=map(BreakLines(input,col),{AB}mapx)
			exe {AB}parx
			call append(line('.'),pg)
			exe line('.')+len(pg)
			redr
		el| let AB="AB"[AB=='A'] | en
		let input=input({AB}.': ')
	endw | echohl None
endfun
fun! BlockText(text,...)
	let [width,col,line]=map([30,0,line('.')],"v:key<a:0? a:{v:key+1} : v:val")
	let lines=BreakLines(a:text,width)
	let mainTxt=getline(line,line+len(lines)-1)
	let col=col? col : max(map(range(len(lines)),'len(mainTxt[v:val])'))
	call setline(line,map(mainTxt,'printf("%-".col.".".col."s %s",v:val,lines[v:key])'))
endfun

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
let Qnrm[EscAsc]="g\e"
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

vn j gj
vn k gk
nn j gj
nn k gk
nn gp :exe 'norm! `['.strpart(getregtype(), 0, 1).'`]'<cr>

fun! SoftCapsLock()
	norm! i^
	redr
	let key=getchar()
	while key!=g:EscAsc
		if key=="\<backspace>"
			undoj | norm! X
		el | undoj | exe "norm! i".toupper(nr2char(key))."\el" |en
		redr
		let key=getchar()
	endwhile
	undojoin | norm! x
	startinsert
endfun
let [Qnrm.99,Qnhelp.c]=[":call SoftCapsLock()\<cr>","Caps lock"]

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
let [Qnrm.23,Qnhelp['^W']]=[":if winwidth(0)==&columns | silent call Writeroom(exists('g:OPT_WRITEROOMWIDTH')? g:OPT_WRITEROOMWIDTH : 25) | else | only | en\<cr>","Writeroom mode"]

if exists('opt_mousepan') && opt_mousepan
	nn <silent> <leftmouse> :call getchar()<cr><leftmouse>:exe (MousePan()==1? "keepj norm! \<lt>leftmouse>":"")<cr>
	let glidestep=[99999999]+map(range(11),'11*(11-v:val)*(11-v:val)')+repeat([1],40)
	fun! MousePan()
		if v:mouse_lnum>line('w$') || (&wrap && v:mouse_col%winwidth(0)==1) || (!&wrap && v:mouse_col>=winwidth(0)+winsaveview().leftcol) || v:mouse_lnum==line('$')
			if line('$')==line('w0') | exe "keepj norm! \<c-y>" |en
			return 1 | en
		exe "norm! \<leftmouse>"
		let [veon,frame,tl,dvl,dhl]=[&ve==?'all',-1,repeat([reltime()],4),[0,0,0,0],[0,0,0,0]]
		while getchar()=="\<leftdrag>"
			let [dV,dH]=[v:mouse_lnum-line('.'), veon*(v:mouse_col-virtcol('.'))]
			exe "norm! \<leftmouse>"
			let v=winsaveview()
			let [dV,dH,frame]=[dV>v.topline-1? v.topline-1 : dV, dH>v.leftcol? v.leftcol : dH,(frame+1)%4]
			let [v.topline,v.leftcol,v.lnum,v.col,v.coladd,tl[frame],dvl[frame],dhl[frame]]=[v.topline-dV,v.leftcol-dH,v.lnum-dV,0,v.curswant-dH,reltime(),dV,dH]
			call winrestview(v)
			if !(frame%2) | redr! | en
		endwhile
		let [sv,sh]=[dvl[0]+dvl[1]+dvl[2]+dvl[3],dhl[0]+dhl[1]+dhl[2]+dhl[3]]
		let [cmd,sv]=sv>2? ["\<c-y>",sv+10] : sv<-2? ["\<c-e>",-sv+10] : ["\<c-e>",0]
		let [cmd,sh,vc,hc]=sh>2? [cmd."zh",sh+10,0,0] : sh<-2? [cmd."zl",-sh+10,0,0] : [cmd.'zl',0,0,0]
		if eval(join(reltime(tl[(frame+1)%4]),'*1000000+'))>200000 || !sv && !sh | return | en
		while !getchar(1) && sv+sh>0
			let [y,x]=[vc>g:glidestep[sv],hc>g:glidestep[sh]]
			let [sv,sh,vc,hc]=[sv-y,sh-x,!y*vc+!y,!x*hc+!x]
			if !y<=2*x
				exe 'norm!' cmd[!y :2*x] | redr
			en
		endw
	endfun
en

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
	if !exists('g:SCHEMES') | let g:SCHEMES={'swatches':{},'current':{}} | en
	if !has_key(g:SCHEMES,'swatches')
		let g:SCHEMES.swatches={} |en
	hi clear tabline
	if exists('g:opt_colorscheme') && has_key(g:SCHEMES,g:opt_colorscheme)
		call CSLoad(g:SCHEMES[g:opt_colorscheme])
	el| call CSLoad(g:SCHEMES.current) | en
	"windows doesn't support %s
	let g:Qnrm.msg="ec printf('%-17.17s %'.(&columns-19).'s',eval(strftime('%m.\"smtwrfa\"[%w].%d.\" \".%I.\":%M \".g:LOGDIC[-1][1].(localtime()-g:LOGDIC[-1][0])/60')),(expand('% ').' '.line('.').'-'.col('.').'/'.line('$'))[-&columns+19:])"
	try | silent exe g:Qnrm.msg
	catch | let g:Qnrm.msg="ec line('.').','.col('.').'/'.line('$')" | endtry
	let g:Qvis.msg=g:Qnrm.msg
endfun
fun! WriteViminfo(file)
	if g:StartupErr=~?'error' && input("Startup errors were encountered! ".g:StartupErr."\nSave settings anyways?")!~?'^y'
		return |en
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

let [Qnrm.102,Qnhelp['f']]=["g;","foward edit"]
let [Qnrm.98,Qnhelp['b']]=["g;","back edit"]
let [Qnrm.58,Qnhelp[':']]=["q:","commandline normal"]
let [Qnrm.116,Qnhelp.t]=[":let &showtabline=!&showtabline\<cr>","Tabline toggle"]
let [Qnrm.118,Qnhelp.v]=[":if empty(&ve) | se ve=all | el | se ve= | en\<cr>","Virtual edit toggle"]
let [Qnrm.105,Qnhelp.i]=[":se invlist\<cr>","List invisible chars"]
let [Qnrm.76,Qnhelp.L]=[":exe colorD.76\<cr>","Load Colorscheme"]
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
let [Qnrm.86,Qnhelp['V']]=[":call WriteViminfo(input('Name of file to write: ',Viminfo_File,'file'))\n","Write viminfo"]
let [Qnrm.84,Qnhelp['T']]=[":call Dialog()\n","Talk"]

if !exists('firstrun')
	let firstrun=0
	if !exists('Working_Dir') || !isdirectory(glob(Working_Dir))
		ec 'Warning: g:Working_Dir='.Working_Dir.' invalid, using '.$HOME
		let Working_Dir=$HOME |en
	for file in ['abbrev','pager']
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
	au VimEnter * au BufWinEnter * call mruf.restorepos(expand('%')) 
	au VimEnter * au BufLeave * call mruf.insert(expand('<afile>'),line('.'),col('.'),line('w0'))
	se nowrap linebreak sidescroll=1 ignorecase smartcase incsearch wiw=72
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
	au BufWinEnter * call LoadFormatting()
	augroup WriteViminfo
		au VimLeavePre * call WriteViminfo('exit')
	augroup end
	redir END
	if !argc() && filereadable('.lastsession')
		so .lastsession | en
en
