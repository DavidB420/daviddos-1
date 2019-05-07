;DavidDOS kernel Made by David Badiei
org 0000h

;set up stack
mov ax, 0800h
mov ds, ax
mov es, ax
mov ss, ax    
mov sp, 0

mov si,text_string
call print_string

mov si,text_string1
call print_string

call shellsub

start:

cmp bp,1
je afterprog

mov cx,0

mov si,newline
call print_string

mov ah,0eh
mov al,'>'
int 10h

mov di,buffer
call getinput

mov si,buffer
mov di,cmd_help
call strcmp
jc helpsub

mov si,buffer
mov di,cmd_clear
call strcmp
jc clearsub

mov si,buffer
mov di,cmd_restart
call strcmp
jc restartsub

mov si,buffer
mov di,cmd_calc
call strcmp
jc calcsub

mov si,buffer
mov di,cmd_echo
call strcmp
jc echosub

mov si,buffer
mov di,cmd_ascii
call strcmp
jc asciisub

mov si,buffer
mov di,cmd_guess
call strcmp
jc guesssub

mov si,buffer
mov di,cmd_shell
call strcmp
jc shellsub

mov si,buffer
mov di,cmd_sd
call strcmp
jc sdsub

mov si,buffer
mov di,cmd_time
call strcmp
jc timesub


mov si,invalid
call print_string

mov si,buffer
call print_string

jmp start

hlt

text_string db 'DavidDOS Copyright 2019 David Badiei', 0x0D, 0x0A, 0
text_string1 db '===============================================================================', 0
text_string2 db 'DavidDOS - Internal Commands', 0x0D, 0x0A, 'help - Brings this list', 0x0D, 0x0A, 'clear - Clear the screen', 0x0D, 0x0A, 'restart - Restarts the system', 0xD, 0xA, 'calc - A simple calculator', 0x0D, 0x0A, 'echo - Repeat an argument', 0x0D, 0x0A, 'ascii - Displays all ASCII characters', 0x0D, 0x0A, 'guess - A simple number guessing game', 0x0D, 0x0A, 'shell - Graphical Shell', 0x0D, 0x0A, 'sd - Shuts down the system', 0x0D, 0x0A, 'timed - Get time and date', 0
buffer times 64 db 0
newline db	0x0D, 0x0A, 0
invalid db 'Illegal Command!: ', 0
cmd_help db 'help', 0
cmd_clear db 'clear', 0
cmd_restart db 'restart', 0
cmd_calc db 'calc', 0
cmd_echo db 'echo', 0
cmd_ascii db 'ascii', 0
cmd_guess db 'guess', 0
cmd_shell db 'shell', 0
cmd_sd db 'sd', 0
cmd_time db 'timed', 0
print_string:			
			mov ah, 0eh				
			loop:
				lodsb					
				test al, al				
				jz done				
				int	10h				
				jmp loop				
			done:
				ret
getinput:
	mov ah,0
	int 16h
	cmp al,08h
	je delchar
	cmp al,0dh
	je entpress
	cmp al,3fh
	je getinput
	mov ah,0eh
	int 10h
	stosb
	inc cx
	jmp getinput
	delchar:
		cmp cx,0
		je getinput
		mov ah,0eh
		mov al,08h
		int 10h
		mov al,20h
		int 10h
		mov al,08h
		int 10h
		sub cx,1
		dec di
	    mov byte [di], 0
		jmp getinput
	entpress:
	   mov al,0
	   stosb
	   mov ah,0eh
	   mov al,0dh
	   int 10h
	   mov al,0ah
	   int 10h
	   ret
strcmp:
	loop1:
		mov al,[si]
		mov bl,[di]
		cmp al,bl
		jne notequal
		cmp al,0
		je done1
		add di,1
		add si,1
		jmp loop1
	notequal:
		clc
		ret
	done1:
		stc
		ret
helpsub:
	mov si,text_string2
	call print_string
	jmp start
clearsub:
	pusha
	mov ah, 00h
	mov al, 03h  
	int 10h
	popa
	mov si,text_string
	call print_string
	mov si,text_string1
	call print_string
    jmp start

restartsub:
	jmp 0xffff:0000h

calcsub:
	mov si,calc1
	call print_string
	mov di,num1
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov si,newline
	call print_string
	mov si,calc2
	call print_string
	mov di,num2
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov ah,0
	int 16h
	stosb
	mov ah,0eh
	int 10h
	mov si,newline
	call print_string
	mov si,calc3
	call print_string
	mov dx,[num1]
	sub dx,30h
	mov bx,[num2]
    add dx,bx
	mov [num3],dx
	mov si,num3
	mov ah,0eh
	lodsb
	cmp al,':'
	jge calcnumoverflow
	int 10h
    lodsb
	sub al,30h
	cmp al,':'
	jge tenormore
	calcline:
	int 10h
	mov dx,0
	jmp start
	tenormore:
		mov al,08h
		int 10h
		mov al,20h
		int 10h
		mov al,08h
		int 10h
		mov si,num3
		mov ah,0eh
		lodsb
		add al,1
		cmp al,':'
		jge calcnumoverflow
		int 10h
		lodsb
		sub al,30h
		sub al,10
		int 10h
		mov cx,0
		mov dx,[num3]
		jmp start
	calcnumoverflow:
		mov si,calc4
		call print_string
		jmp start
	calc1 db 'Enter first number: ', 0
	calc2 db 'Enter second number: ', 0
	calc3 db 'Answer: ', 0
	calc4 db 'Number Overflow!', 0 
	num1 times 2 db 0
	num2 times 2 db 0
	num3 db 0
	
echosub:
	mov ax,0
	mov dx,0
	mov cx,0
	mov si,echo1
	call print_string
	mov di,echobuffer
	getinputecho:
	mov ah,0
	int 16h
	cmp al,08h
	je delcharecho
	cmp al,0dh
	je entpressecho
	cmp cx,27h
	je getinputecho
	mov ah,0eh
	int 10h
	stosb
	inc cx
	jmp getinputecho
	delcharecho:
		cmp cx,0
		je getinputecho
		mov ah,0eh
		mov al,08h
		int 10h
		mov al,20h
		int 10h
		mov al,08h
		int 10h
		sub cx,1
		dec di
	    mov byte [di], 0
		jmp getinputecho
	entpressecho:
	    mov al,0
	    stosb
	    mov ah,0eh
	    mov al,0dh
	    int 10h
	    mov al,0ah
	    int 10h
		mov si,echo2
		call print_string
		mov si,newline
		call print_string
		mov ah,0h
		int 16h
		mov bl,al
		mov ah,0eh
		int 10h
		mov si,newline
		call print_string
		cmp bl,'1'
		je onesub
		cmp bl,'2'
		je fivesub
		cmp bl,'3'
		je tensub
		cmp bl,'4'
		je twentyfivesub
		cmp bl,'5'
		je fiftysub
		cmp bl,'6'
		je hundredsub
		mov si,echo3
		call print_string
		jmp start
		onesub:
			mov si,echobuffer
			call print_string
			jmp start
		fivesub:
			mov bx,5
			jmp outsub
		tensub:
			mov bx,10
			jmp outsub
		twentyfivesub:
			mov bx,25
			jmp outsub
		fiftysub:
			mov bx,50
			jmp outsub
		hundredsub:
			mov bx,75
			jmp outsub
		outsub:
			mov cx,0
			loop5:
				inc cx
				mov si,echobuffer
				call print_string
				cmp cx,bx
				je oof
				mov si,newline
				call print_string
				jmp loop5
			oof:
				jmp start
			echo1 db 'Enter argument: ', 0
			echo2 db 'How many times do you wanna loop the argument?', 0x0D, 0x0A, '1.Once', 0x0D,0x0A, '2.Five times', 0x0D, 0x0A, '3.Ten times', 0x0D, 0x0A, '4.Twenty five times', 0x0D, 0x0A, '5.Fifty times', 0x0D, 0x0A, '6.Hundred times', 0
			echo3 db 'Invalid option :-(', 0
			echobuffer times 40 db 0
			timesbuffer times 2 db 0
asciisub:
	mov si,asciiprompt
	call print_string
	mov cx,256
	mov al,0
	mov ah,0eh
	asciiloop:
		int 10h
		add al,1
		sub cx,1
		jnz asciiloop
	mov cx,0
	mov ax,0
	jmp start
	asciiprompt db 'Here are all the ASCII characters: ', 0

 guesssub:
	mov ah,00h
	int 1ah
	mov ax,dx
	xor dx,dx
	mov cx,10
	div cx
	add dl,30h
	mov al,dl
	mov di,randNum
	stosb
	mov cx,0fh
	mov dx,4240h
	mov ah,86h
	int 15h
	mov ah,00h
	int 1ah
	mov ax,dx
	xor dx,dx
	mov cx,10
	div cx
	add dl,30h
	mov al,dl
	stosb
	mov si,intro
	call print_string
	guessloop:
	mov si,askUser
	call print_string
	mov di,num
	mov ah,00h
	int 016h
	stosb
	cmp al,1bh
	je exit
	mov ah,0eh
	int 10h
	mov ah,00h
	int 016h
	stosb
	cmp al,1bh
	je exit
	mov ah,0eh
	int 10h
	mov si,newline
	call print_string
	mov si,num
	mov di,randNum
	mov al,[si]
	mov bl,[di]
	cmp al,bl
	jg lessthan
	cmp al,bl
	jl greatthan
	cmp al,bl
	je equalthan
	jmp guessloop
	exit:
	jmp start
	lessthan:
		mov si,less
		call print_string
		jmp guessloop
	greatthan:
		mov si,great
		call print_string
		jmp guessloop
	equalthan:
		mov si,num
		mov di,randNum
		mov al,[si+1]
		mov bl,[di+1]
		cmp al,bl
		jg lessthan
		cmp al,bl
		jl greatthan
		cmp al,bl
		je gameEnd
		jmp guessloop
	gameEnd:
		mov si,gameEndstr
		call print_string
		jmp start
	intro db 'Welcome to Guess the Number!', 0x0D, 0x0A, 'Please enter a number between 1 and 99', 0x0D, 0x0A, 0
	askUser db 'Enter Number: ', 0
	less db 'Oops the number is less than that one. Try another', 0x0D, 0x0A, 0
	great db 'Oops the number is greater than that one. Try another', 0x0D, 0x0A, 0
	gameEndstr db 'Congratulations! You got the number!', 0
	num times 2 db 0
	randNum times 2 db 0

shellsub:
	mov ah,01h
	mov cx,2607h
	int 10h
	mov bp,1
	;fill bg
	mov ah,06h
	xor al,al
	xor cx,cx
	mov dx,184fh
	mov bh,1fh
	int 10h
	call draw_cursor
	;gray bar on top
	xor dx,dx
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,80
	mov bl,70h
	mov al,' '
	int 10h
	mov si,text_string
	call print_string
	xor dx,dx
	call draw_cursor
	mov si,text_string
	call print_string
	;gray bar on bottom
	mov dl,0
	mov dh,24
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,80
	mov bl,70h
	mov al,' '
	int 10h
	;red box in middle
	mov dl,5
	mov dh,1
	call draw_cursor
	boxloop1:
	inc dh
	cmp dh,23
	je afterwrite
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,70
	mov bl,4fh
	mov al,' '
	int 10h
	jmp boxloop1
	afterwrite:
		mov dl,5
		mov dh,3-1
		call draw_cursor
		mov si,selectText
		call print_string
	;Add programs to list
	mov dl,5
	mov dh,3
	call draw_cursor
	call addtext
	mov dh,3
	;Add selections
	movehiglight:
	mov dl,5
	call draw_cursor
	mov ah,09h
	mov bh,0
	mov cx,70
	mov bl,0xf0
	mov al,' '
	int 10h
	call addtext
	mov dl,5
	mov dh,3
	call draw_cursor
	jmp keys
	app1 db 'restart - Restarts the system', 0
	app2 db 'calc - A simple calculator', 0
	app3 db 'echo - Repeat an argument', 0
	app4 db 'ascii - Displays all ASCII characters', 0
	app5 db 'guess - A simple number guessing game', 0
	app6 db 'exit - Return to command line', 0
	app7 db 'sd - Shuts down the system', 0
	app8 db 'timed - Get time and date', 0
	;move cursor with arrow keys and loop shell
	keys:
	mov ah,00h
	int 16h
	cmp ah,48h
	je uparrow
	cmp ah,50h
	je downarrow
	cmp al,1bh
	je clearsub
	cmp al,0dh
	je entersub
	jmp shellsub
	addtext:
		mov si,app1
		call print_string
		inc dh
		call draw_cursor
		mov si,app2
		call print_string
		inc dh
		call draw_cursor
		mov si,app3
		call print_string
		inc dh
		call draw_cursor
		mov si,app4
		call print_string
		inc dh
		call draw_cursor
		mov si,app5
		call print_string
		inc dh
		call draw_cursor
		mov si,app6
		call print_string
		inc dh
		call draw_cursor
		mov si,app7
		call print_string
		inc dh
		call draw_cursor
		mov si,app8
		call print_string
		ret
	draw_cursor:
		mov bh,0
		mov ah,2
		int 10h
		ret
	redraw_list:
		mov ch,dh
		mov cl,dl
		call draw_cursor
		mov dh,3
		mov dl,5
		call draw_cursor
		call addtext
		mov dh,ch
		mov dl,cl
		call draw_cursor
		ret
	uparrow:
		cmp dh,3
		je keys
		dec dh
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,0xf0
		mov al,' '
		int 10h
		add dh,1
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,4fh
		mov al,' '
		int 10h
		sub dh,1
		call draw_cursor
		call redraw_list
		jmp keys

	downarrow:
		cmp dh,10
		je keys
		inc dh
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,0xf0
		mov al,' '
		int 10h
		sub dh,1
		call draw_cursor
		mov ah,09h
		mov bh,0
		mov cx,70
		mov bl,4fh
		mov al,' '
		int 10h
		add dh,1
		call draw_cursor
		call redraw_list
		jmp keys
	entersub:
		pusha
		mov ah, 00h
		mov al, 03h  
		int 10h
		popa
		cmp dh,3
		je restartsub
		cmp dh,4
		je calcsub
		cmp dh,5
		je echosub
		cmp dh,6
		je asciisub
		cmp dh,7
		je guesssub
		cmp dh,8
		je gotocmd
		cmp dh,9
		je sdsub
		cmp dh,10
		je timesub
	gotocmd:
		mov bp,0
		mov si,text_string
		call print_string
		mov si,text_string1
		call print_string
		jmp start
	afterprog:
		mov si,pressKey
		call print_string
		mov ah,00h
		int 16h
		jmp shellsub
	selectText db 'Please select a program below:', 0
	pressKey db 0Dh, 0Ah, 'Press any key to continue...', 0

sdsub:
	mov ax,5300h
	mov bx, 0
	int 15h
	mov ax,5301h
	mov bx,0
	int 15h
	mov ax, 530Eh		
	mov bx, 0			
	mov cx, 0102h
	int 15h
	mov ax, 5307h		
	mov cx, 0003h		
	mov bx, 0001h		
	int 15h
	mov si,apmError
	call print_string		
	jmp start
	apmError db 'Sorry, but your system does not support APM so it cannot be shut down through DavidDOS. To shut down the system, just press the power button', 0

timesub:
	;Time section
	mov si,timeStr
	call print_string
	mov ah,02h
	int 1ah
	mov al,ch
	call bcdtoint
	mov ch,al
	mov al,cl
	call bcdtoint
	mov cl, al
	mov al, dh			
	call bcdtoint
	mov dh, al
	mov ah,0eh
	xor ax,ax
	mov al,ch
	call outputnum
	mov ah,0eh
	mov al,":"
	int 10h
	mov ah,0eh
	xor ax,ax
	mov al,cl
	call outputnum
	mov ah,0eh
	mov al,":"
	int 10h
	mov ah,0eh
	xor ax,ax
	mov al,dh
	call outputnum
	;Date section
	mov si,dateStr
	call print_string
	mov ah,04
	int 1ah
	mov al,dl
	call bcdtoint
	mov dl,al
	mov al,dh
	call bcdtoint
	mov dh,al
	mov al,ch
	call bcdtoint
	mov ch,al
	mov al,cl
	call bcdtoint
	mov cl,al
	mov al,dl
	call outputnum
	mov ah,0eh
	mov al,'/'
	int 10h
	mov al,dh
	call outputnum
	mov ah,0eh
	mov al,'/'
	int 10h
	mov al,ch
	call outputnum
	mov al,cl
	call outputnum
	jmp start
	bcdtoint:
		push cx
		push ax
		and al, 11110000b
		shr al,4
		mov cl,10
		mul cl
		pop cx
		and cl,00001111b
		add al,cl
		pop cx
		ret
	outputnum:		
		mov ah,0
		mov bl,10
		div bl
		mov bh,ah
		mov ah,0eh
		add al,'0'
		int 10h
		mov al,bh
		add al,'0'
		int 10h
		ret
	timeStr db 'Time: ', 0
	dateStr db 0x0D, 0x0A, 'Date: ', 0