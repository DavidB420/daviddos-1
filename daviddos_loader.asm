;DavidDOS bootloader Made by David Badiei
org 7c00h

mov ah,0eh
mov al,07h
int 10h
mov al,08h
int 10h
mov al,20h
int 10h
mov al,08h
int 10h

pusha
mov ah, 00h
mov al, 03h  
int 10h
popa

mov     ah, 02h 
mov     al, 10  
mov     ch, 0   
mov     cl, 2   
mov     dh, 0

mov     bx, 0800h   
mov     es, bx
mov     bx, 0

int 13h

jmp 0800h:0000h 

hlt

times 510 - ($-$$) db 0
dw 0xAA55