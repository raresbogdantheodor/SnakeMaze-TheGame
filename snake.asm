include 'emu8086.inc'
org     100h
 
jmp     start
;Lungimea coada snake
 
snake_size  equ     2   


 
snake dw snake_size dup(0)
 
tail    dw      ?
 
left    equ     4bh
right   equ     4dh
up      equ     48h
down    equ     50h

;Directia curenta snake 
cur_dir db      right
 
wait_time dw    0
 
;Definirea meniului de joc
msg1 db " _________         _________" , 0dh, 0ah
     db " /         \       /         \   SNAKE MAZE", 0dh, 0ah
     db " /  /~~~~~\  \     /  /~~~~~\  \  -THE GAME-", 0dh, 0ah
     db " |  |     |  |     |  |     |  |", 0dh, 0ah
     db " |  |     |  |     |  |     |  |", 0dh, 0ah
     db " |  |     |  |     |  |     |  |         /", 0dh, 0ah
     db " |  |     |  |     |  |     |  |       // ", 0dh, 0ah
     db "(o  o)    \  \_____/  /     \  \_____/ /", 0dh, 0ah
     db " \__/      \         /       \        /" , 0dh, 0ah
     db "  |         ~~~~~~~~~         ~~~~~~~~ ", 0dh, 0ah
     db "  ^", 0dh, 0ah
     db "                     ", 0dh, 0ah
     db "                     ", 0dh, 0ah
     db "PRESS ANY KEY OR MOUSE CLICK TO START!", 0dh, 0ah
     db "                           ", 0dh, 0ah
     db "                           ", 0dh, 0ah
     db "Or press B for BONUS!", 0dh, 0ah



;Definire labirint

msg  db "==============    =================="  ,0dh,0ah, "$"
msg2 db "==============    =================="  ,0dh,0ah , "$"
msg3 db "=============            ==========="  ,0dh,0ah , "$"
msg4 db "=============            ===========    SNAKE MAZE"  ,0dh,0ah , "$"
msg5 db "=====================    ===========    -THE GAME-"  ,0dh,0ah , "$"
msg6 db "=============           ============"  ,0dh,0ah , "$" 
msg7 db "=============     =================="  ,0dh,0ah , "$"  
msg8 db "=============     =================="  ,0dh,0ah , "$"
msg9 db "=============  ====================="  ,0dh,0ah , "$"
msg12 db "=============--====================="  ,0dh,0ah , "$"
msg14 db "           FINISH                   "  ,0dh,0ah , "$"

;Mesaje de castig/pierdere joc

msg10 db "                  GAME OVER!!", 0dh, 0ah , "$" 
msg11 db "             CONGRATS!!!", 0dh, 0ah, "$"
 
;Mesaj bonus Fibonacci

msg15 db "Generarea primilor 5 termeni Fibonacci:", 0dh, 0ah , "$"

; Sectiunea de cod 

start:

;Mesaje:

mov dx, offset msg1
mov ah, 9 
int 21h

mov ah, 7
int 21h       
cmp al, 'b'
je  bonus

mov ah, 00h
int 16h


;mov  ax, 0Ah    ; initializare mouse
;mov  bx, 01h
;int  33h  

;EMU8086 nu suporta mouse in modul text,inca...
;Pe DOSBox eroare dispare


;mov dx, offset msg2
;mov ah, 9
;int 21h

;Stergere ecran
clear_screen:
pusha
mov dx, 0           ; pozitionezi cursorul in pozitia stanga-sus
mov ah, 6           ; scroll full screen
mov al, 0            
mov bh, 7           
mov cx, 0           ; stanga-sus
mov dh, 24          ; dreapta-jos
mov dl, 79
int 10h
popa

;Generare labirint pe ecran (afisarea mesajelor)
mov dx, offset msg
mov ah, 9 
int 21h

mov dx, offset msg2
mov ah, 9 
int 21h 

mov dx, offset msg3
mov ah, 9 
int 21h

mov dx, offset msg4
mov ah, 9 
int 21h

mov dx, offset msg5
mov ah, 9 
int 21h

mov dx, offset msg6
mov ah, 9 
int 21h

mov dx, offset msg7
mov ah, 9 
int 21h

mov dx, offset msg8
mov ah, 9 
int 21h

mov dx, offset msg9
mov ah, 9 
int 21h 

mov dx, offset msg12
mov ah, 9 
int 21h

mov dx, offset msg14
mov ah, 9 
int 21h

        
mov dx, 0; repozitionare cursor
  

 
;ascundere cursor
mov     ah, 1
mov     ch, 2bh
mov     cl, 0bh
int     10h           

;Bucla jocului
 
loop_snake:


 
mov     al, 0 
mov     ah, 05h  ; Modul automat de conducere snake
int     10h      ; Modul automat de control
;mov     ah, 00h  ; Modul manual de conducere
;int     16h ;Modul manual de control
 
mov     dx, snake[0]
mov     ah, 02h
int     10h
 
mov     al, '@'
mov     ah, 09h
mov     bl, 0eh
mov     cx, 1 
int     10h
 
mov     ax, snake[snake_size*2-2]
mov     tail, ax
 
call    move_snake
 
mov     dx, tail
 
mov     ah, 02h
int     10h
 
mov     al, ' '
mov     ah, 09h
mov     bl, 0eh
mov     cx, 1  
int     10h

; Verificare apasare taste (directie/esc)
check_key: 
 
mov     ah, 01h
int     16h
jz      no_key
 
mov     ah, 00h
int     16h
 
cmp     al, 1bh
je      stop_game
 
 
mov     cur_dir, ah


 
no_key:
 
mov     ah, 00h
int     1ah
cmp     dx, wait_time
jb      check_key
add     dx, 4
mov     wait_time, dx
 
jmp     loop_snake
 

stop_game:
;mesajul lost 
mov dx, offset msg10
mov ah, 9 
int 21h

mov     ah, 1
mov     ch, 0bh
mov     cl, 0bh
int     10h
ret


win_game:
;mesajul win
mov dx, offset msg11
mov ah, 9 
int 21h
    
;+sound
;mov dl, 07h
;mov ah, 2
;int 21h
;mov dl, 07h
;mov ah, 2
;int 21h
;mov dl, 07h
;mov ah, 2
;int 21h

ret



 
ret

;Procedura pentru mutarile sarpelui 
move_snake proc near
 
mov     ax, 40h
mov     es, ax
 
mov   di, snake_size*2-2
mov   cx, snake_size-1


move_array:
mov   ax, snake[di-2]
mov   snake[di], ax
sub   di, 2
loop  move_array
 
; compararea directiei cursorului conform tastei apasate.
cmp     cur_dir, left
  je    move_left
cmp     cur_dir, right
  je    move_right
cmp     cur_dir, up
  je    move_up
cmp     cur_dir, down
  je    move_down
 
jmp     stop_move
 
 
move_left:
  mov   al, b.snake[0]
  dec   al
  mov   b.snake[0], al
  cmp   al, -1
  jne   stop_move       
  mov   al, es:[4ah]
  dec   al
  mov   b.snake[0], al
  jmp   stop_move
 
move_right:
  mov   al, b.snake[0]
  inc   al 
  mov   b.snake[0], al
  cmp   al, es:[4ah]   
  jb    stop_move
  mov   b.snake[0], 0 
  jmp   stop_move
 
move_up:
  mov   al, b.snake[1]
  dec   al
  mov   b.snake[1], al
  cmp   al, -1
  jne   stop_move
  mov   al, es:[84h] 
  mov   b.snake[1], al 
  jmp   stop_move
 
move_down:
  mov   al, b.snake[1]
  inc   al
  mov   b.snake[1], al
  cmp   al, es:[84h]    
  jbe   stop_move
  mov   b.snake[1], 0  
  jmp   stop_move
stop_move:
    ;Sunet la miscarea snake-ului
    mov dl, 08h
    mov ah, 2
    int 21h
   
   ;conditia de win
    cmp dh, 22
    int 10h
    je win_game
   
    
   ;conditia lost
    cmp dl,1
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,2
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,3
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,4
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,5
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,6
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,7
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,8
    cmp dh,13
    int 10h
    je stop_game 
    
    cmp dl,9
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,10
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,11
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl, 12
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,13
    cmp dh,13
    int 10h
    je stop_game
    
    cmp dl,14
    cmp dh,13
    int 10h
    je stop_game
    
ret
    ;jmp check_field

;check_field:

;cmp dx, "="
;je stop_game
;cmp dx, '-'
;je win_game  
;mov dx, snake[0]
;mov bh, 0
;mov ah, 02h
;int 10h



move_snake endp


;Saltul pentru bonus
bonus:

;Se sterge ecranul 
pusha
mov dx, 0           ; pozitionezi cursorul in pozitia stanga-sus
mov ah, 6           ; scroll full screen
mov al, 0            
mov bh, 7           
mov cx, 0           ; stanga-sus
mov dh, 24          ; dreapta-jos
mov dl, 79
int 10h

;Se afisaza mesajul pentru sirul FIBO
lea dx, msg15           
mov ah, 09h            
int 21h                                               
                            
mov dl, 20h             
mov ah, 02h             
int 21h                          
 
mov bh, 1

mov dh, 1 
mov cx, 5 

mov ah, 00h
int 16h

;Bucla Fibonacci
fiboloop:
or dl, 30h
mov ah, 02h
int 21h
mov dl, dh
mov dh, bh		    
push dx
mov al, dl
mov ah, dh
add ah, al
mov bh, ah 
pop dx
loop fiboloop

fibTerm db 12 Dup(0)  

mov ah, 00h
int 16h










