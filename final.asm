  .MODEL SMALL
   INCLUDE SHIPMOVE.inc
        .STACK 64
        .DATA
        PLAYER1_NAME DB 15,?,15 dup('$')
        PLAYER2_NAME DB 15,?,15 dup('$')
        PLAYER_WIN DB ' WINS THE GAME!!$'
        ENDMESSAGE DB 'Press Backspace to return to MAIN MENU$'
        
        CHATMESSAGE  DB 'Chat coming soon in Phase 2!',10,13,'Press Backspace to return to Main Menu$'
        WELCOMEMESSAGE DB 'Welcome to BANG BROS!',10,13,'$' 
        MAINMENU DB 'MAIN MENU$' 
        PLAYER1MESSAGE DB 'Please enter Player 1 name:',10,13,'$'
        PLAYER2MESSAGE DB 'Please enter Player 2 name:',10,13,'$'
        MENU1 DB '*To start Chatting press 1',10,10,13,'$'
        MENU2 DB '*To start Banging Your Bro! press 2',10,10,13,'$'
        MENU3 DB '*To end the game press ESC',10,13,'$' 

        PLAYER1_HEALTH DW 5
        PLAYER2_HEALTH DW 5 

        MissileLength       EQU 0AH;MISSILE LENGTH IS 10PX
        
        MissileX            DW  25 DUP(0);ARRAY OF THE X STARTING POINT OF MISSILES. NOTE THAT IF MISSILE 
                                         ;IS BLUE (FROM LEFT SHIP) THEN THIS X POINT WILL BE ON THE LEFT OF THE 
                                         ;MISSILE, WHILE IF THE MISSILE IS RED (FROM THE RIGHT) THEN THE X-POINT
                                         ;WILL BE ON THE RIGHT OF THE MISSILE
                                         
        MissileY            DW  25 DUP(0);SAME AS MISSILEX
        MissileDirection    DW  25 DUP(0);FOR BLUE MISSILE=1, FOR RED MISSILE=-1
        
        MissileCount        DW  0;NOTE THAT MISSILECOUNT/2 IS ACTUAL MISSILE COUNT
                                 ;AS MISSILE COUNT WILL BE INCREMENTED TWICE TO ACCOUNT
                                 ;FOR WORD LENGTH
                                 
        MissileIndex        DW  0;MISSILE COUNT WILL ONLY BE USED AS A COUNTER FOR ITERATIONS ON THE 
                                 ;MISSILE ARRAY WHILE MISSILE INDEX MARKS THE BEGINNING OF THE MISSILE 
                                 ;ARRAY. THIS IS BECAUSE IN THE DELETEMISSILE PROC, WHEN A MISSILE IS 
                                 ;DELETED WE SHIFT THE MISSILE INDEX BY 2 AND SUB MISSILE COUNT BY 2.
                                 ;THIS ASSUMES THAT FIRST MISSILES FIRED WILL USUALLY DELETE FIRST
                                  
        RedMissileBoundary  DW  13D  ;THIS IS TO DETERMINE AT WHAT PIXEL RED MISSILE SHOULD BE DELETED
                                    ;IT IS EQUAL TO 0+SHIPLENGTH
                                    
        BlueMissileBoundary DW  307D;THIS IS TO DETERMINE AT WHAT PIXEL BLUE MISSILE SHOULD BE DELETED
                                    ;IT IS EQUAL TO 320-SHIPLENGTH 
                                    
        NumDeletedMissiles  DW  0D;THIS WILL BE USED IN THE DELETE FUNCTION TO COUNT THE NUMBER OF MISSILES
                                  ;THAT WERE DELETED AND DECREMENT THEM FROM MISSILE COUNT AFTER DELETE FUNCTION
                                  ;IS FINISHED 
                                  
                                  
        MissileSpeed        DW   0;1000     ;how many cycles to wait between each MoveMissile 
        PowerUPspeed        dw   0;8000
        
        BluePlayerFireRate  DB    10 
                                          ;Rate of continous fire if button is held
        RedPlayerFireRate   DB    10
        
        ;VARIABLES BASED ON SEHELY
        SHIPLENGTHH EQU 9D;THIS VARIABLE IS NOT ACTUALLY USED, IT'S JUST TO EXPLAIN THE RED AND BLUE MISSILE BOUNDARIES
        
        ;SHIPY DW 50D;THIS ASSUMES THE CURRENT X-POSITION OF THE FIRING SHIP
       ; SHIPX DW 15D;THIS ASSUMES THE CURRENT Y-POSITION OF THE FIRING SHIP 

     
        SHIPLENGTH EQU 6D
        SHIPWIDTH EQU 18D
        PLAYTOP EQU 25D
        
        PLAYER1START EQU 5D
        PLAYER2START EQU 315D
        
        SHIP1POS DW 93D
        SHIP2POS DW 93D   
        
        PowerUPx Dw 156
        PowerUPy DW 21
        PowerUPsize equ 8d
        PowerUPDropRate db 5 ;
        PowerUPType db 0 ;1 YELLOW Z
                         ;2 GREEN    S
                         ;3 BROWN   S
                         ;4 GREY   M
                         ;5 MAGENTA
                         
       REDTRILASER  DB 0
       BLUETRILASER DB 1         ;check which ship has the triple laser power up  
       TripleLaserAmmo DB 10  ; ammo for reset
       
       InvisibleBlue db 0
       InvisibleRed db 0
       
       SHIP1POWERUP DB 0
       SHIP2POWERUP DB 0
        
        BLUESHIELD  DB 1;THIS IS BOOLEAN OPERATOR TO CHECK THE PRESENCE OF SHIPSHIELD
        REDSHIELD  DB 0
        ReflectedMissiles db 3
        
        CURRENTSHIELD DB 0;THIS IS USED FOR DRAWING THE SHIELD 
        SHIELDDIRECTION DB 0;1 IS UP AND 2 IS DOWN
        
        CURRENTSHIP  DB 0;THIS VALUE CAN BE 1 OR 2 WHERE 1 MEANS SHIP1 AND 2 IS SHIP2
                         ;THIS IS SO WE CAN KNOW WHICH SHIP WILL NOW RECEIVE THE POWERUP
        CURRENTPOWERUP DB 0;THIS IS TO STORE THE
        MAXMISSILECOUNT DW 50D;THE MAXIMUM NUMBER OF MISSILES/2
        
        CLAYMORE1ACTIVE DB 0 ;0=no,1=present,2=fired,3=inposition
        CLAYMORE2ACTIVE DB 0
        CLAYMOREWIDTH EQU 5
        CLAYMORELENGTH EQU 10
        CLAYMORE1X DW ?
        CLAYMORE1Y DW ?
        CLAYMORE2X DW ?
        CLAYMORE2Y DW ?
        CLAYMORE1L DB 0
        CLAYMORE2L DB 0 
        
        SHIP1SPEED DW 2
        SHIP2SPEED DW 2
        
        INVISTIMERRED DW 0
        INVISTIMERBLUE DW 0     
        SHEILDCOLOUR DB 0
        .code
        
MAIN              PROC  FAR 
    MOV AX,@DATA
    MOV DS,AX
    
    
     
PLAYER1INFO:
    ;clear screen
    mov ah,0
    mov al,13h  ;video mode  
    int 10h
      
    mov ah,2
    mov dl,10
    mov dh,5
    int 10h     ;Move Cursor to the Centre of 320x200px
    
    
    mov ah, 9
    mov dx, offset WELCOMEMESSAGE ;display welcome message
    int 21h
    
    mov ah,2
    mov dl,0    
    mov dh,12
    int 10h     ;Move Cursor to the Centre of 320x200px
   
    mov ah, 9
    mov dx, offset PLAYER1MESSAGE ;display welcome message
    int 21h 
    
   
    
    ;read name from user
    mov ah,8 
    mov bh,0
    int 10h
    mov ah,0AH
    mov dx,offset PLAYER1_NAME
    int 21h         
     

PLAYER2INFO:

    ;clear screen
    mov ah,0
    mov al,13h  ;video mode  
    int 10h
    
    mov ah,2
    mov dl,10
    mov dh,5
    int 10h     ;Move Cursor to the Centre of 320x200px
    
    
    mov ah, 9
    mov dx, offset WELCOMEMESSAGE ;display welcome message
    int 21h
    
    mov ah,2
    mov dl,0
    mov dh,12
    int 10h     ;Move Cursor to the Centre of 320x200px  
            
    mov ah, 9
    mov dx, offset PLAYER2MESSAGE ;display welcome message
    int 21h 
    
    
    ;read name from user 
    mov ah,8 
    mov bh,0
    int 10h
    mov ah,0AH
    mov dx,offset PLAYER2_NAME
    int 21h     
    
    
    ;MENU SCREEN         
Menu: 
    ;clear screen
    mov ah,0
    mov al,13h  ;video mode  
    int 10h
    
    mov ah,2
    mov dl,13
    mov dh,5
    int 10h     ;Move Cursor to the Centre of 320x200px
    
    
    mov ah, 9
    mov dx, offset MAINMENU 
    int 21h
    
    mov ah,2
    mov dl,0
    mov dh,12
    int 10h     ;Move Cursor to the Centre of 200px   
            
    mov ah, 9
    mov dx, offset MENU1 ;DISPLAY MENU OPTION 1
    int 21h 
    
   
    mov ah, 9
    mov dx, offset MENU2 ;DISPLAY MENU OPTION 2
    int 21h 
    
    
    mov ah, 9
    mov dx, offset MENU3 ;DISPLAY MENU OPTION 3
    int 21h 
    
    mov cx,0 
    mov dx,160 
    mov al,0111b 
    mov ah,0ch
     
    BT_BORD: int 10h     ;bottom border
    inc cx
    cmp cx,320 
    jnz BT_BORD
    
    
    mov ah,2
    mov dl,0
    mov dh,160    ;MOVE CURSOR TO BELOW THE THRESHOLD
    int 10h
       
CHECKZ:
    mov ah,1       ;ASCII CHECK: ESC -> 27
    int 16h
    jz CHECKZ      ;ESC KEY CHECK
    cmp al,27d
    je ENDG
    cmp al,49     ;1 KEY CHECK
    je CHATMODE
    cmp al,50     ;2 KEY CHECK  
    je GAMEMODE
    mov ah,0                              ; clear buffer 
    int 16h
    jmp CHECKZ
    
;CHATMODE-----------------------------------------------------------------------------------------------------------------------------    
   
CHATMODE:
    mov ah,0
    mov al,13h  ;video mode  
    int 10h
 
    mov ah, 9
    mov dx, offset CHATMESSAGE ;display welcome message
    int 21h 
    
    CHECKCHAT:
    mov ah,1       ;ASCII CHECK:
    int 16h
    jz CHECKCHAT      ;BACKSPACE KEY CHECK
    cmp al,8
    je  Menu
    mov ah,0                              ; clear buffer 
    int 16h
    jmp CHECKCHAT
    


    
;GAMEMODE____________________________________________________________________________________________________________________________________________
    
    GAMEMODE:
    
    CALL RESETGAME
    
    mov ah,0
    mov al,13h  ;video mode  
    int 10h
    
    mov cx,0 
    mov dx,20 
    mov al,0111b 
    mov ah,0ch 
    TOP_BORDER: int 10h     ;top border
    inc cx
    cmp cx,320 ;320
    jnz TOP_BORDER
    
    mov cx,0 
    mov dx,165 
    mov al,0111b 
    mov ah,0ch 
    BOT_BORDER: int 10h     ;bottom border
    inc cx
    cmp cx,320 ;320
    jnz BOT_BORDER
    
    mov cx,160 
    mov dx,0 
    mov al,0111b 
    mov ah,0ch 
    MID_BORDER: int 10h     ;middle border
    inc dx
    cmp dx,20 
    jnz MID_BORDER  
    
    mov ah, 9
    mov dx, offset   PLAYER1_NAME         ;print player 1 name
    add dx,2 
    int 21h  
    
    mov ah,2
    mov dh,0                              ;change cursor for second name
    mov dl,30
    int 10h  
    
    mov ah, 9
    mov dx, offset   PLAYER2_NAME         ;print player 2 name
    add dx,2 
    int 21h 
     
    mov cx,PLAYER1_HEALTH                             ;set initial health
    CALL CHANGE_PLAYER1_HEALTH
    CALL CHANGE_PLAYER2_HEALTH
    
    CALL DRAWSHIP1                ; Draw initial ships
    CALL DRAWSHIP2
    
    mov REDPlayerFireRate,1          ;to ensure no delay in first shot
    mov BLUEPlayerFireRate,1
;----------------------------------------------------------------------------------------set up game   
    
  
   
CHECK:
    inc  MissileSpeed
    inc  PowerUpspeed
    
    cmp powerupspeed,8000
    JE POWERUP_MOVE
    cmp MissileSpeed,1000
    JE Missile_MOVE
    
    JMP DelayMissile
  POWERUP_MOVE:
    mov powerupspeed,0
    Call MovePowerUP   
    call CheckPowerUp
    CALL INVISTIME
    Missile_MOVE: 
    MOV  MissileSpeed,0
    CALL MOVEMISSILE
    CALL REPELMISSILE
    CALL DELETEMISSILE
        
    
    CMP CLAYMORE1ACTIVE,2
    JNZ NOCL1UPDATE
    CALL MOVECLAYMORE1
    
    
    NOCL1UPDATE:
    
    CMP CLAYMORE2ACTIVE,2   ;mesh hena law sama7t, proc
    JNZ NOCL2UPDATE
    CALL MOVECLAYMORE2
    
    
    NOCL2UPDATE:
    
    
    CMP CLAYMORE1ACTIVE,3
    JNZ NOCL1EXPLODE
    MOV AX,SHIP2POS
    MOV BX,CLAYMORE1Y
    CMP AX,BX
    JAE NOCL1EXPLODE
    ADD AX,SHIPWIDTH
    ADD BX,CLAYMOREWIDTH
    CMP AX,BX
    JBE NOCL1EXPLODE
    CALL EXPLODECLAYMORE1
    
    NOCL1EXPLODE:
    
    CMP CLAYMORE2ACTIVE,3
    JNZ NOCL2EXPLODE
    MOV AX,SHIP1POS
    MOV BX,CLAYMORE2Y
    CMP AX,BX
    JAE NOCL2EXPLODE
    ADD AX,SHIPWIDTH
    ADD BX,CLAYMOREWIDTH
    CMP AX,BX
    JBE NOCL2EXPLODE
    CALL EXPLODECLAYMORE2
    
    NOCL2EXPLODE:
    
DelayMissile:

    mov ah,1               ; get player input
    int 16h
    jz CHECK
    
    cmp ah,48h 
    je mov_2_up
    cmp ah,50h 
    je mov_2_down
    cmp ah,11h   
    je mov_1_up
    cmp ah,1fh                       ; check input 
    je mov_1_down
    cmp ah,4bh 
    je ship_2_fire
    cmp ah,20h 
    je ship_1_fire
    CMP AH,12H
    JZ CLAYMORE1FIRE
    CMP AH,35H 
    JZ CLAYMORE2FIRE
    CMP AH,19H
    JZ PAUSE
    JMP READKEY
    
    
    PAUSE:
    mov ah,0               ; get player input
    int 16h
    CMP AH,19H
    jNz PAUSE
    
   CLAYMORE1FIRE:
   
   CMP CLAYMORE1ACTIVE,1
   JNZ NOAMMO1
   CALL INITCLAYMORE1
   CALL DRAWCLAYMORE1 
   CLAYMOREINDICATOR1OFF
   NOAMMO1:
   JMP READKEY
   
   CLAYMORE2FIRE:
   CMP CLAYMORE2ACTIVE,1
   JNZ NOAMMO2
   CALL INITCLAYMORE2
   CALL DRAWCLAYMORE2
   CLAYMOREINDICATOR2OFF 
   NOAMMO2:
   JMP READKEY
    
   mov_2_up:
   MOV2UP
   MOV CURRENTSHIELD,2
   MOV SHIELDDIRECTION,1
   CALL MOVESHIELD
   cmp REDPlayerFireRate,3
   jbe  reset1 
   mov REDPlayerFireRate,2
   reset1:
   jmp ReadKey	                        
  
   mov_2_down:
   MOV2DOWN
   MOV CURRENTSHIELD,2
   MOV SHIELDDIRECTION,2
   CALL MOVESHIELD
   cmp REDPlayerFireRate,3
   jbe  reset2 
   mov REDPlayerFireRate,2
   reset2:                  ; reset fire rate when ships move
   jmp ReadKey   
  
   mov_1_up:
   MOV1UP
   MOV CURRENTSHIELD,1
   MOV SHIELDDIRECTION,1
   CALL MOVESHIELD
   cmp BluePlayerFireRate,3
   jbe  reset3 
   mov BluePlayerFireRate,2
   reset3: 
   jmp ReadKey   	
   
   mov_1_down:
   MOV1DOWN
   MOV CURRENTSHIELD,1
   MOV SHIELDDIRECTION,2
   CALL MOVESHIELD
   cmp BluePlayerFireRate,3
   jbe  reset4 
   mov BluePlayerFireRate,2
   reset4:                 ; reset fire rate when ships move
   jmp ReadKey 
   
   ship_2_fire:
   DEC REDPlayerFireRate
   CMP REDPlayerFireRate,0
   JNE DELAYREDFIRE
   MOV CX,PLAYER2START-6-SHIPWIDTH/2
   MOV DX,SHIP2POS
   ADD DX,SHIPWIDTH/2
   call DRAWMISSILE 
   ADD  REDPlayerFireRate,10
   ;triple laser
   cmp REDTRILASER,0
   je  DELAYREDFIRE
   cmp TripleLaserAmmo,0
   je  resetredlaser
   dec TripleLaserAmmo
   MOV CX,PLAYER2START+3-6-SHIPWIDTH/2   
   MOV DX,SHIP2POS
   call DRAWMISSILE
   MOV CX,PLAYER2START+3-6-SHIPWIDTH/2  
   MOV DX,SHIP2POS
   ADD DX,SHIPWIDTH
   call DRAWMISSILE
   jmp DELAYREDFIRE
resetredlaser:
    mov TripleLaserAmmo,10
    mov REDTRILASER,0   
DELAYREDFIRE:
   jmp ReadKey
   
   
      
   ship_1_fire:
   DEC BLUEPlayerFireRate
   CMP BLUEPlayerFireRate,0
   JNE DELAYBLUEFIRE
   MOV CX,PLAYER1START+6+SHIPWIDTH/2      
   MOV DX,SHIP1POS
   ADD DX,SHIPWIDTH/2
   call DRAWMISSILE 
   ADD  BLUEPlayerFireRate,10 
   
   ;triple laser
   cmp BLUETRILASER,0
   je  DELAYBLUEFIRE
   cmp TripleLaserAmmo,0    
   je  resetBluelaser
   dec TripleLaserAmmo
   MOV CX,PLAYER1START-3+6+SHIPWIDTH/2  
   MOV DX,SHIP1POS
   call DRAWMISSILE
   MOV CX,PLAYER1START-3+6+SHIPWIDTH/2  
   MOV DX,SHIP1POS
   ADD DX,SHIPWIDTH
   call DRAWMISSILE
    jmp DELAYREDFIRE
   
   resetBLUElaser:
    mov TripleLaserAmmo,10
    mov BLUETRILASER,0
   
DELAYBLUEFIRE:
   jmp ReadKey
   
   ReadKey:
    mov ah,0                              ; clear buffer 
    int 16h  
    jmp CHECK 
    
    ENDGAME_WIN_PLAYER1:
    
    mov ah,2
    mov dl,0
    mov bh,0
    mov dh,22    ;MOVE CURSOR TO BELOW THE THRESHOLD
    int 10h
    
    mov ah,9
    mov dx,offset PLAYER1_NAME
    add dx,2
    int 21h 
    
    mov ah,2
    mov dl,PLAYER1_NAME[1] 
    mov bh,0
    mov dh,22    ;MOVE CURSOR TO BELOW THE THRESHOLD
    int 10h
   
    mov ah,9
    mov dx,offset PLAYER_WIN
    int 21h 
    JMP ENDINGINSTRUCTIONS 
     
    ENDGAME_WIN_PLAYER2:
    
    mov ah,2
    mov dl,0 
    mov bh,0
    mov dh,22    ;MOVE CURSOR TO BELOW THE THRESHOLD
    int 10h 
    
    mov ah, 9
    mov dx, offset PLAYER2_NAME
    add dx,2
    int 21h 
    
    mov ah,2
    mov dl,PLAYER2_NAME[1] 
    mov bh,0
    mov dh,22    ;MOVE CURSOR TO BELOW THE THRESHOLD
    int 10h 
    
    mov ah,9
    mov dx, offset PLAYER_WIN
    int 21h
;_________________________________________________________________________________________________________________________-    

 ENDINGINSTRUCTIONS: 
 
    MOV DL,10
    MOV AH,02H
    INT 21H
    MOV DL,13
    MOV AH,02H
    INT 21H
    
    MOV AH,9
    MOV DX,OFFSET ENDMESSAGE
    INT 21H 
    
    CHECKEND:
    mov ah,1       ;ASCII CHECK: ESC -> 27, SCANCODE CHECK: F1 ->5B, F2->5C
    int 16h
    jz CHECKEND      ;ESC KEY CHECK
    cmp al,8
    je Menu
    mov ah,0                              ; clear buffer 
    int 16h
    jmp CHECKEND
    
 

 
    
    
    
ENDG:  mov ah,2
       mov dl,0 
       mov bh,0
       mov dh,22    ;MOVE CURSOR TO BELOW THE THRESHOLD
       int 10h    

       mov ah,004CH
       int 21h       ;TERMINATE PROGRAM AKA GIVE THE CONTROL BACK TO THE OS IN THIS CASE DOSBOX 
       HLT
MAIN   ENDP
   ;-------------------------------------------------------------------------------------------------PROCS  

 CHANGE_PLAYER1_HEALTH PROC
    mov bh,0
    mov ah,2
    mov dh,1                              ;change cursor for player 1 draw health 
    mov dl,0
    int 10h 
    
     mov bx,cx
     mov cx,5
DH1: mov ah,2                                       ;remove  player 1  old health   
     mov dl,0 
     int 21h  
     loop DH1
     
    mov cx,bx
    cmp cx,0
    jBE ENDGAME_WIN_PLAYER2
    CMP CX,5
    JA ENDGAME_WIN_PLAYER2
     
    mov ah,2
    mov dh,1                              ;change cursor for player 1 draw health 
    mov dl,0
    int 10h  
     
    mov bx,cx
NH1:mov ah,2                                       ;draw player 1 new health   
    mov dl,3 ;Blue on white background
    int 21h  
    loop NH1 
    mov cx,bx
                        RET
 CHANGE_PLAYER1_HEALTH ENDP
 
 CHANGE_PLAYER2_HEALTH PROC
    mov bh,0
    mov ah,2
    mov dh,1                              ;change cursor for player 2 draw health 
    mov dl,30
    int 10h 
    
     mov bx,cx
     mov cx,5
DH2: mov ah,2                                       ;remove  player 2  old health   
     mov dl,0 
     int 21h  
     loop DH2
     
    mov cx,bx
    cmp cx,0
    jBe ENDGAME_WIN_PLAYER1
    CMP CX,5
    JA ENDGAME_WIN_PLAYER1
     
    mov ah,2
    mov dh,1                              ;change cursor for player 2 draw health 
    mov dl,30
    int 10h  
     
    mov bx,cx
NH2:mov ah,2                                       ;draw player 2 new health   
    mov dl,3 ;Blue on white background
    int 21h  
    loop NH2 
    mov cx,bx
                        RET
 CHANGE_PLAYER2_HEALTH ENDP 
 
 DRAWMISSILE         PROC
;THIS FUNCTION DRAWS EACH MISSILE BASED ON A
;VARIABLE CALLED SHIP1-Y AND SHIP2-Y WITH A 
;MISSILE LENGTH = 10 PIXELS

                    MOV BX,MAXMISSILECOUNT
                    CMP BX,MissileCount
                    JE  SKIPDRAW
                    
                    MOV SI,0;MOV THE STARTING INDEX OF THE ARRAY INTO SI
                    
                    FINDEMPTYSLOT:;THIS IS TO FIND THE FIRST EMPTY ELEMENT TO ADD MISSILE
                    
                    CMP SI,MAXMISSILECOUNT;MAKE SURE THAT ARRAY HAS NOT LOOPED OVER ITSELF                   
                    JE  SKIPDRAW;MEANS WE HAVE LOOPED OVER ENTIRE MISSILE ARRAY WITHOUT FINDING AN EMPTY SLOT
                    CMP MissileX[SI],0
                    JE  ADJUSTEDINDEXDRAW
                    ADD SI,2
                    JMP FINDEMPTYSLOT
                    
                    
                    ADJUSTEDINDEXDRAW:
                    
                    MOV MissileY[SI],DX;ADDING THE Y-POSITION OF MISSILE TO MISSILEARRAY
                    MOV MissileX[SI],CX;ADDING THE X-POSITION OF MISSILE TO MISSILEARRAY
                    
                    CMP CX,120D;DETERMINE WHETHER THE SHOOOTING SHIP IS ON THE LEFT OR RIGHT
                                
                    JA NegativeDirection
                    
                    
PositiveDirection:  MOV MissileDirection[SI],1;SHOOTING SHIP IS FROM LEFT
                    MOV AL,1011B;SHOOTING SHIP IS BLUE
                    
                    
                    JMP DRAW
NegativeDirection:  MOV MissileDirection[SI],0ffffh;SHOOTING SHIP IS FROM RIGHT
                    MOV AL,1100B;SHOOTING SHIP IS RED                  
                  
                    
                    DRAW:
                    ;DRAW THE MISSILE WITH MISSILE LENGTH
                    
                    MOV AH,0CH
                    MOV BX,0
                    BACK:
                    INT 10H
                    ADD CX,MissileDirection[SI]
                    INC BX
                    CMP BX,MissileLength
                    JNZ BACK
                    
                    ADD MissileCount,2;NOTICE THAT WE INCREMENT 2 BECAUSE ARRAY OF WORDS
                                      ;TO GET REAL NUMBER OF MISSILES WE MOVE TO REGISTER 
                                      ;AND SHIFT RIGHT 
                    
                    
                  SKIPDRAW:  
                    
                                      
                    RET
DRAWMISSILE         ENDP

 
 

MOVEMISSILE         PROC
                    
                    CMP MissileCount,0
                    JE  ENDMOVE
                    MOV SI,0
                    
                    
STARTMOVE:          
                    CMP SI,MAXMISSILECOUNT;MAKE SURE THAT WE HAVE NOT PASSED OVER ALL ARRAY                   
                    JE  ENDMOVE;
                    CMP MissileX[SI],0
                    JE  INCREMENTMOVE
                    
                    ADJUSTEDINDEXMOVE:
                    
;FIRST WE ERASE THE FIRST PIXEL OF THE MISSILE                    
                    MOV CX,MissileX[SI]
                    MOV DX,MissileY[SI]
                    MOV AL,0
                    MOV AH,0CH
                    INT 10H
                    
;THEN WE MOVE THE MISSILE'S X-POSITION ACCORDING
;TO THE DIRECTION ARRAY WHICH IS EITHER 1 OR -1                    
                    ADD CX,MissileDirection[SI]
                    MOV MissileX[SI],CX
                    
                    
;THEN WE DRAW AN EXTRA PIXEL AT X-POSITION +OR- MissileLength

                    MOV BX,1
                    CMP BX,MissileDirection[SI];Determine whether shot is red or blue
                    JNE RedShot
                    
                    BlueShot:
                    ADD CX,MissileLength
                    SUB CX,1
                    MOV AL,1011B
                    INT 10H
                    JMP INCREMENTMOVE
                    
                    RedShot:
                    SUB CX,MissileLength
                    ADD CX,1
                    MOV AL,1100B
                    INT 10H
                    
                    
                    INCREMENTMOVE:
                    
                    ADD SI,2;NOTICE THAT WE INCREMENT 2 BECAUSE ARRAY OF WORDS
                    JMP STARTMOVE
                     
                                                                           
ENDMOVE:            RET
MOVEMISSILE         ENDP




DELETEMISSILE       PROC 
                    
                    
                    MOV SI,0
                    
STARTDELETE:        CMP MissileCount,0;WE COMPARED FIRST IN CASE MISSILE ARRAY IS EMPTY
                    JE  ENDDELETE
       
                    CMP SI,MAXMISSILECOUNT;THIS MEANS WE HAVE LOOPED OVER WHOLE ARRAY                   
                    JE  ENDDELETE
                    
                    CMP MissileX[SI],0 ;THIS MEANS THAT THIS ELEMENT IS EMPTY
                    JE  INCREMENTDELETE

                    
                    ADJUSTEDINDEXDELETE:
                    
                    
                    MOV BX,MissileDirection[SI]
                    CMP BX,1;TO DETERMINE WHEHTER BLUE OR RED MISSILE
                    JNE CHECKREDMISSILE
                    
CHECKBLUEMISSILE:
                    MOV CX,MissileX[SI]
                    ADD CX,MissileLength;END OF MISSILE
                    CMP CX,BlueMissileBoundary
                    JAE  ERASEMISSILE_HIT_RED_PLAYER;DID THIS AS ABOVE OR EQUAL NOT JUST EQUAL TO ACCOUNT
                                     ;POSSIBLE LAG OR PROBLEMS THAT MAY HAPPEN
                    JB INCREMENTDELETE;IF THE MISSILE HAS NOT YET REACHED BOUNDARS
                                      ;MOVE ON TO NEXT MISSILE IN ARRAY        
                    

CHECKREDMISSILE:
                    MOV CX,MissileX[SI]
                    SUB CX,MissileLength;END OF MISSILE                                                                  
                    CMP CX,RedMissileBoundary
                    JBE  ERASEMISSILE_HIT_blue_PLAYER
                    JA INCREMENTDELETE;MOVE ON TO NEXT MISSILE IN ARRAY  
                    
ERASEMISSILE_HIT_RED_PLAYER:
                   MOV CX,SHIP2POS
                   CMP MissileY[SI],CX      ;CMP top border of ship
                   JB ERASEMISSILE
                   ADD CX,SHIPWIDTH
                   CMP MissileY[SI],CX       ;CMP bottom border of ship
                   JA  ERASEMISSILE
                   dec PLAYER2_HEALTH
                   MOV CX,PLAYER2_HEALTH                             
                   CALL CHANGE_PLAYER2_HEALTH
                   JMP  ERASEMISSILE 
                   
ERASEMISSILE_HIT_blue_PLAYER:
                   MOV CX,SHIP1POS
                   CMP MissileY[SI],CX      ;CMP top border of ship
                   JB ERASEMISSILE
                   ADD CX,SHIPWIDTH
                   CMP MissileY[SI],CX       ;CMP bottom border of ship
                   JA  ERASEMISSILE
                   dec PLAYER1_HEALTH
                   MOV CX,PLAYER1_HEALTH                             
                   CALL CHANGE_PLAYER1_HEALTH
                   JMP  ERASEMISSILE
                    
                    
ERASEMISSILE: 
                    MOV CX,MissileX[SI]
                    MOV DX,MissileY[SI]                                                         
                    
                    MOV AH,0CH
                    MOV AL,0000B
                    MOV BX,0ffffh;-1 BECAUSE FOR SOME REASON THERE IS ALWAYS 1 PIXEL LEFT
                              ;IF BX=0/                                                       
                    
                    ;THIS LOOP DRAWS BLACK OVER THE MISSILE
                    BACK2:
                    INT 10H
                    ADD CX,MissileDirection[SI]
                    INC BX
                    CMP BX,MissileLength
                    JNZ BACK2
                    
                    
                    SUB MissileCount,2
                    MOV MissileX[SI],0
                    MOV MissileY[SI],0
                    
INCREMENTDELETE:    
                    ADD SI,2;MOVE ON TO NEXT MISSILE
                    
                    JMP STARTDELETE
                    
ENDDELETE:
                    
                    RET
DELETEMISSILE       ENDP

;WHEN MISSILE IS ERASED FROM ARRAY AND NEW MISSILE IS FIRED
;REJECT MORE THAN 25 MISSILES 
    
DRAWSHIP1   PROC 
    
    cmp SHIP1POS,49
    jne PowerUP3 
    dec PowerUPDropRate
    cmp PowerUPDropRate,0            ; random drop rate generation 
    jne PowerUP3
    mov PowerUPDropRate,5
    call Generate_powerup
    Call CreatPowerUP 
    
PowerUP3:        
    cmp SHIP1POS,109
    jne NOPOWERUP2 
    dec PowerUPDropRate
    cmp PowerUPDropRate,0            ; random drop rate generation 
    jne NOPOWERUP2
    mov PowerUPDropRate,5
    call Generate_powerup
    Call CreatPowerUP 
           
   NOPOWERUP2:
    
    cmp InvisibleBlue,1           ; draw black if inv
    JE invblue
    
    MOV AL,01H
    jmp drawblueship
            
    invblue:
    MOV AL,00H
    
    
drawblueship:
    MOV AH,0CH
       
    MOV DX,SHIP1POS
    MOV BX,SHIP1POS
    ADD BX,SHIPWIDTH/3
    LENGTH1:
    MOV CX,PLAYER1START 
    
    WIDTH1:
    INT 10H
    INC CX 
    CMP CX,PLAYER1START+SHIPLENGTH
    JNZ WIDTH1
    
    INC DX
     
    CMP DX,BX
    JNZ LENGTH1
    ADD BX,SHIPWIDTH/3
    LENGTH2:
    MOV CX,PLAYER1START+SHIPLENGTH/3 
    
    WIDTH2:
    INT 10H
    INC CX 
    CMP CX,PLAYER1START+SHIPLENGTH*4/3
    JNZ WIDTH2
    INC DX 
    CMP DX,BX
    JNZ LENGTH2
    ADD BX,SHIPWIDTH/3
    LENGTH3:
    MOV CX,PLAYER1START
    WIDTH3:
    INT 10H
    INC CX 
    CMP CX,PLAYER1START+SHIPLENGTH
    JNZ WIDTH3
    
    INC DX
     
    CMP DX,BX
    JNZ LENGTH3
    RET
DRAWSHIP1   ENDP




DRAWSHIP2   PROC
    
    
    cmp SHIP2POS,49
    jne PowerUP2 
    dec PowerUPDropRate
    cmp PowerUPDropRate,0            ; random drop rate generation 
    jne PowerUP2
    mov PowerUPDropRate,5
    call Generate_powerup  ;; generate
    Call CreatPowerUP 
    
PowerUP2:        
    cmp SHIP2POS,109
    jne PowerUP5 
    dec PowerUPDropRate
    cmp PowerUPDropRate,0            ; random drop rate generation 
    jne NOPOWERUP
    mov PowerUPDropRate,5
   call Generate_powerup
    Call CreatPowerUP 
PowerUP5:    
    cmp SHIP2POS,95
    jne NOPOWERUP 
    dec PowerUPDropRate
    cmp PowerUPDropRate,0            ; random drop rate generation 
    jne NOPOWERUP
    mov PowerUPDropRate,5
    call Generate_powerup
    Call CreatPowerUP 
           
   NOPOWERUP:
   
    cmp InvisibleRED,0
    jne rinv
    mov al,4
    jmp drawREDship
    
    rinv:
    mov al,0
    
    
drawREDship:
    
    MOV AH,0CH
    
    MOV DX,SHIP2POS
    MOV BX,SHIP2POS
    ADD BX,SHIPWIDTH/3
    LENGTHA:
    MOV CX,PLAYER2START
    WIDTHA:
    INT 10H
    DEC CX 
    CMP CX,PLAYER2START-SHIPLENGTH
    JNZ WIDTHA
    
    INC DX 
    CMP DX,BX
    JNZ LENGTHA 
    ADD BX,SHIPWIDTH/3
    LENGTHB:
    MOV CX,PLAYER2START-SHIPLENGTH/3
    WIDTHB:
    INT 10H
    DEC CX 
    CMP CX,PLAYER2START-SHIPLENGTH*4/3
    JNZ WIDTHB
    INC DX 
    CMP DX,BX
    JNZ LENGTHB
    ADD BX,SHIPWIDTH/3
    LENGTHC:
    MOV CX,PLAYER2START
    WIDTHC:
    INT 10H
    DEC CX 
    CMP CX,PLAYER2START-SHIPLENGTH
    JNZ WIDTHC
    
    INC DX 
    CMP DX,BX
    JNZ LENGTHC
    RET
DRAWSHIP2   ENDP  

CLEARSHIP1  PROC
        
    MOV AL,00H
    MOV AH,0CH
    MOV DX,SHIP1POS
    MOV BX,SHIP1POS
    ADD BX,SHIPWIDTH
    YAX1:
    MOV CX,PLAYER1START
    XAX1:    
    INT 10H
    INC CX
    CMP CX,PLAYER1START+SHIPLENGTH*4/3
    JNZ XAX1
    INC DX
    CMP DX,BX
    JNZ YAX1 
    RET   
CLEARSHIP1  ENDP
        
        
        
CLEARSHIP2  PROC
       
    MOV AL,00H
    MOV AH,0CH
    MOV DX,SHIP2POS
    MOV BX,SHIP2POS
    ADD BX,SHIPWIDTH
    YAX2:
    MOV CX,PLAYER2START
    XAX2:    
    INT 10H
    DEC CX
    CMP CX,PLAYER2START-SHIPLENGTH*4/3
    JNZ XAX2
    INC DX
    CMP DX,BX
    JNZ YAX2   
    RET   
CLEARSHIP2  ENDP 

proc CreatPowerUP
    
    cmp PowerUPType,0                              ; check if power up already exists 
    jne Dontadd 
    mov si,offset PowerUPx 
    mov bx,PowerUPsize
    
     
    cmp PowerUpType,0
    jz Dontadd
    cmp PowerUpType,1
    jz YELLOWp
    cmp PowerUpType,2 
    jz GREENp
    cmp PowerUpType,3
    jz BROWNp 
    cmp PowerUpType,4 
    jz GREYp
    cmp PowerUpType,5
    jz MAGENTAp
    

    YELLOWp:
    mov al,1110B
    JMP ColorSET
    GREENp:
    mov al,0010B 
    JMP ColorSET
    BROWNp:
    mov al,0110B
    JMP ColorSET
    GREYp:
    mov al,1000B 
    JMP ColorSET
    MAGENTAp:
    mov al,0101B 

ColorSET:    
mov cx,PowerUPx ;Column
add [SI],PowerUPsize ; for comp
mov dx,PowerUPy ;Row

mov ah,0ch ;Draw Pixel Command
dr:drrow: int 10h
inc cx
cmp cx,[si]
jnz drrow
sub cx,PowerUPsize
inc dx
dec bx
cmp bx,0
jne dr 

sub [si],PowerUPsize

DontAdd:    
             ret
CreatPowerUP endp



proc MovePowerUP

 cmp PowerUPType,0                                     ; check if power powerup exists 
 je Dontmove 
    
mov si,offset PowerUPx
mov cx,PowerUPx ;Column
mov dx,PowerUPy ;Row
mov ah,0ch ;Draw Pixel Command

mov al,0 ;   delete row by drawing black
add [SI],PowerUPsize ; for comp

delr: int 10h
inc cx
cmp cx,[si]
jnz delr

sub [SI],PowerUPsize ; for comp
add dx,PowerUPsize
 
    cmp PowerUpType,1
    je YELLOWpp
    cmp PowerUpType,2 
    je GREENpp
    cmp PowerUpType,3
    je BROWNpp 
    cmp PowerUpType,4 
    je GREYpp
    cmp PowerUpType,5
    je MAGENTApp
    
    YELLOWpp:
    mov al,1110B
    JMP ColorSETp
    GREENpp:
    mov al,0010B 
    JMP ColorSETp
    BROWNpp:
    mov al,0110B
    JMP ColorSETp
    GREYpp:
    mov al,1000B 
    JMP ColorSETp
    MAGENTApp:
    mov al,0101B 

ColorSETp:  

mover:
dec cx
int 10h
cmp cx,[si]
jne mover
inc PowerUPy



cmp PowerUPy,152
jne Dontmove
mov poweruptype,0
Call DELPowerUP
Dontmove:
            ret
MovePowerUP endp


proc   DELPowerUP
    
    mov si,offset PowerUPx 
    mov bx,PowerUPsize 

    
mov cx,PowerUPx ;Column
add [SI],PowerUPsize ; for comp
mov dx,PowerUPy ;Row

mov al,0B ;
mov ah,0ch ;Draw Pixel Command
delc:delrow: int 10h
inc cx
cmp cx,[si]
jnz delrow
sub cx,PowerUPsize
inc dx
dec bx
cmp bx,0
jne delc 

sub [si],PowerUPsize

CALL EXECPOWERUP 
mov PowerUPType,0 
mov PowerUPy,21

    
             ret
DELPowerUP endp


CheckPowerUp proc 
                    CMP MissileCount,0
                    JE  ENDCHECK
                    MOV SI,0
                    
                    
STARTCHECK:         CMP SI,MAXMISSILECOUNT;TO SEE IF WE HAVE LOOPED OVER ALL ARRAY
                    JE  ENDCheck                    
                    
                    
                    
                    ADJUSTEDINDEXCHECK: 
                    
                    MOV BX,MissileDirection[SI]
                    CMP BX,1;TO DETERMINE WHEHTER BLUE OR RED MISSILE
                    JNE REDpowerup
                    
BLUEpowerup:        
                    mov bx,PowerUPX
                    add bx,PowerUPSize/2
                    MOV CX,MissileX[SI]
                    ADD CX,MissileLength;END OF MISSILE
                    sub CX,1                                
                    CMP CX,bx
                    JAE  INCREMENTCHECK
                    sub  BX,PowerUPSize                                
                    CMP CX,bx
                    JB  INCREMENTCHECK             
                                                   
                    JMP REMOVEPOWERUP        
                    

REDpowerup:         
                    mov bx,PowerUPX
                    add bx,PowerUPSize/2
                    MOV CX,MissileX[SI]
                    sub CX,MissileLength;END OF MISSILE
                    sub CX,1              ; distance to center of powerup                    
                    CMP CX,BX
                    JA  INCREMENTCHECK
                    sub  BX,PowerUPSize                                
                    CMP CX,bx                ;only register tip
                                                   
                    JB  INCREMENTCHECK             
                                                   
                    JMP REMOVEPOWERUP   
                    
REMOVEPOWERUP:
                   MOV CX,PowerUPy
                   CMP MissileY[SI],CX      ;CMP top border of ship
                   JB INCREMENTCHECK
                   ADD CX,PowerUPSize
                   CMP MissileY[SI],CX       ;CMP bottom border of ship
                   JA  INCREMENTCHECK
                    
                   MOV BX,MissileDirection[SI]
                   CMP BX,1
                   JE  MOVETOBLUESHIP
                   
               MOVETOREDSHIP:
                   MOV BL,PowerUPType
                   MOV SHIP1POWERUP,BL
                   MOV CURRENTSHIP,2
                   JMP DEL1
                   
                MOVETOBLUESHIP:
                   MOV BL,PowerUPType
                   MOV SHIP2POWERUP,BL
                   MOV CURRENTSHIP,1
                   
                   DEL1:
                   CALL DELPOWERUP
                   JMP  ENDCheck 
               
INCREMENTCHECK:    
                    ADD SI,2;MOVE ON TO NEXT MISSILE
                    JMP STARTCHECK
                    

    
    
ENDCheck:    
      ret
CheckPowerUp endp


EXECPOWERUP         PROC                                                                                               ;!!!!!!!!!!
                    
                    MOV BL,PowerUPType;DETERMINE POWERUP TYPE AND JUMP ACCORDINGLY
                    cmp BL,0
                    JE ENDEXECUTEPOWERUP
                    
                    CMP BL,1
                    JE  SHIELD
                     
                    CMP BL,2
                    JE  CLAYMORE
                     
                    CMP BL,3
                    JE  SPEED
                    
                    CMP BL,4
                    JE  TRIPlaser
                    
                    CMP BL,5
                    JE  Invis                                        
                    
CLAYMORE:
        CMP CURRENTSHIP,1
        JZ CLAYMORE1
        
        CLAYMORE2:
        cmp CLAYMORE2ACTIVE,0
        jNZ  dontaddclay
        MOV CLAYMORE2ACTIVE,1
        CLAYMOREINDICATOR2ON 
        JMP ENDEXECUTEPOWERUP
        
        CLAYMORE1:
        cmp CLAYMORE1ACTIVE,0
        jNZ  dontaddclay
        MOV CLAYMORE1ACTIVE,1
        CLAYMOREINDICATOR1ON
        
        dontaddclay:
        JMP ENDEXECUTEPOWERUP
        
        
SPEED:
        CMP CURRENTSHIP,1
        JZ SPEED1
        
        SPEED2:
        MOV SHIP2SPEED,4
        JMP ENDEXECUTEPOWERUP
        
        SPEED1:
        
        MOV SHIP1SPEED,4
        JMP ENDEXECUTEPOWERUP
                    
SHIELD:             MOV BL,CURRENTSHIP
                    MOV CURRENTSHIELD,BL                                                                              
                    CMP BL,1
                    JNE TURNONRED
                    
                    TURNONBLUE:
                    MOV BLUESHIELD,1
                    
                    CALL DRAWSHIELD
                    JMP ENDEXECUTEPOWERUP
                    
                    TURNONRED:
                    MOV REDSHIELD,1 
                    CALL DRAWSHIELD
                    JMP ENDEXECUTEPOWERUP
                    
TRIPlaser:           cmp CURRENTSHIP,1
                     je BlueTrip
                     mov REDTRILASER,1
                     JMP ENDEXECUTEPOWERUP                    
            BlueTrip:mov BlueTRILASER,1       
                     JMP ENDEXECUTEPOWERUP
                     
Invis:               cmp CURRENTSHIP,1
                     je Blueinv
                     mov InvisibleRed,1
                     JMP ENDEXECUTEPOWERUP                    
            Blueinv:mov InvisibleBlue,1       
                     JMP ENDEXECUTEPOWERUP
                    

ENDEXECUTEPOWERUP:
                    MOV CURRENTSHIP,0
                                        
                    RET
EXECPOWERUP         ENDP 

DRAWSHIELD          PROC 
                    
                    CMP CURRENTSHIELD,1;SEE IF CURRENTSHIELD IS ON BLUE OR RED SHIP
                    JNE REDSHIELDDRAW
                   
                    MOV CX,PLAYER1START+10;DISTANCE FOR BLUE SHIELD TO BE DRAWN
                    MOV DX,SHIP1POS
                    CMP InvisibleBlue,0
                    JZ BYELLSHEILD
                    MOV SHEILDCOLOUR,0
                    JMP SETCOLOR
                    BYELLSHEILD:
                    MOV SHEILDCOLOUR,0EH
                    JMP SETCOLOR
                    
                    REDSHIELDDRAW:
                    MOV CX,PLAYER2START-10;DISTANCE FOR SHIELD TO BE DRAWN
                    MOV DX,SHIP2POS
                    CMP InvisibleRED,0
                    JZ RYELLSHEILD
                    MOV SHEILDCOLOUR,0
                    JMP SETCOLOR
                    RYELLSHEILD:
                    MOV SHEILDCOLOUR,0EH
     
                    
                    SETCOLOR:
                    MOV AL,SHEILDCOLOUR;YELLOW COLOR OF SHIELD 
                    
                    
                    MOV AH,0CH
                    
                    MOV BX,0;THIS WILL SERVE AS A COUNTER TO ENSURE SHIELD LENGTH
                    
                    SHIELD1:
                    INT 10H
                    INC DX
                    INC BX
                    CMP BX,18;18 IS THE LENGTH OF EACH SHIP
                    JNZ SHIELD1 
                   
ENDDRAWSHIELD:    
                                    
                                       

                    RET    
DRAWSHIELD          ENDP




DeleteSHeild          PROC 
                    
                   
                    MOV CX,PLAYER1START+10;DISTANCE FOR BLUE SHIELD TO BE DRAWN
                    MOV BlueShield,0 
                    mov DX,SHIP1POS
 
               
                    MOV AL,0;black to delete 
                    MOV AH,0CH                 
                    MOV BX,0;THIS WILL SERVE AS A COUNTER TO ENSURE SHIELD LENGTH
                    
                    SHIELDdel:
                    INT 10H
                    INC DX
                    INC BX
                    CMP BX,18;18 IS THE LENGTH OF EACH SHIP
                    JNZ SHIELDdel
                    
                    
                    REDSHIELDdel:
                    MOV BX,0
                    MOV CX,PLAYER2START-10;DISTANCE FOR SHIELD TO BE DRAWN
                    MOV DX,SHIP2POS
                    cmp redshield,0 
                    je  ENDDELSHIELD
                    mov redShield,0
                    jmp shielddel
                    
                   
                   
ENDDELSHIELD:  
        ret
DeleteSHeild endp





MOVESHIELD          PROC
                    
                    MOV BL,CURRENTSHIELD
                    CMP BL,1;DETERMINE SHIELD BLUE OR RED
                    JNE CHECKREDSHIELD
                    CMP BLUESHIELD,1;CHECK ACTIVATION OF BLUE SHIELD
                    JNE ENDMOVESHIELD
                    
                    MOV CX,PLAYER1START+10
                    MOV DX,SHIP1POS
                    MOV SI,SHIP1SPEED
                    
                    JMP CHECKSHIELDDIRECTION
                    
                    CHECKREDSHIELD:
                    CMP REDSHIELD,1;CHECK ACTIVATION OF RED SHIELD
                    JNE ENDMOVESHIELD
                    
                    MOV CX,PLAYER2START-10
                    MOV DX,SHIP2POS
                    MOV SI,SHIP2SPEED 
                    
                    CHECKSHIELDDIRECTION:
                    CMP SHIELDDIRECTION,1
                    JNE MOVESHIELDDOWN
                    
                    MOVESHIELDUP:
                    MOV AL,1110B;YELLOW COLOR OF SHIELD
                    MOV AH,0CH
                    MOV BX,DX
                    ADD BX,SI
                    DMSU:
                    INT 10H
                    INC DX
                    CMP DX,BX
                    JNZ DMSU
                    ADD DX,18
                    MOV BX,DX
                    SUB BX,SI
                    MOV AL,0;BLACK COLOR TO ERASE PIXEL
                    CMSU:
                    INT 10H
                    DEC DX
                    CMP DX,BX
                    JNZ CMSU
                    
                    JMP ENDMOVESHIELD
                    
                    MOVESHIELDDOWN:
                    
                    MOV AL,0
                    MOV AH,0CH 
                    
                    MOV BX,DX
                    SUB BX,SI
                    CMSD:
                    DEC DX
                    INT 10H
                    CMP DX,BX
                    JNZ CMSD
                    
                    ADD DX,18
                    MOV BX,DX
                    ADD BX,SI
                    MOV AL,1110B
                    DMSD:
                    INT 10H
                    INC DX
                    CMP DX,BX
                    JNZ DMSD
                     
                       
ENDMOVESHIELD:                       
                        
                    RET    
MOVESHIELD          ENDP


REPELMISSILE        PROC
    
                    CMP MissileCount,0
                    JE  ENDREPELMISSILE
                    MOV SI,0;
                   
                    
                    CMP BLUESHIELD,1
                    JE  STARTREPELMISSILE
                    CMP REDSHIELD,1
                    JNE ENDREPELMISSILE
                    
                    
STARTREPELMISSILE: 
                    
                    CMP SI,MAXMISSILECOUNT;MAKE SURE THAT WE HAVE NOT LOOPED OVER ALL ARRAY                   
                    JE  ENDREPELMISSILE
                    
                    ADJUSTEDINDEXREPELMISSILE:
                    
                    MOV CX,MissileX[SI];GET THE CURRENT POSITION OF THE MISSILE
                    MOV DX,MissileY[SI]
                    
                    MOV BX,MissileDirection[SI];SEE WHETHER IT IS RED OR BLUE MISSILE
                    CMP BX,1
                    JE  CheckBlueMissileRepel
                    JNE CheckRedMissileRepel
                    
CheckRedMissileRepel:
                    MOV BL,BLUESHIELD ;SEE WHETHER BLUE SHIP HAS FILTER/SHIELD ACTIVATED
                    CMP BL,1
                    JNE INCREMENTREPELMISSILE
                    
                    
                    MOV BX,PLAYER1START+10;GET THE XCOORDINATE OF THE BLUE SHIELD
                   
                    SUB CX,MissileLength;GET 1+THE END OF MISSILE SO AS NOT TO DRAW OVER THE SHIELD
                    
                    CMP CX,BX;CHECK IF MISSILE HAS REACHED SHIELD
                    JNE INCREMENTREPELMISSILE
                    
                    
                    MOV BX,SHIP1POS;GET THE YCOORDINATE OF THE BLUE SHIELD
                    
                    CMP DX,BX;SEE IF THE MISSILE IS ABOVE SHIELD
                    JB  INCREMENTREPELMISSILE
                    
                    ADD BX,19;GET BOTTOM OF SHIELD
                    CMP DX,BX;SEE IF THE MISSILE IS BELOW SHIELD
                    JA  INCREMENTREPELMISSILE
                     
                    ;MISSILE SHOULD BE REPELLED 
                    MOV MissileDirection[SI],1
                    ADD CX,1
                    MOV MissileX[SI],CX
                    ;dec rem num of deflects
                    DEC ReflectedMissiles
                    CMP ReflectedMissiles,0
                    jne ENDREPELMISSILE
                    mov ReflectedMissiles,10
                    call DeleteSHeild
                    
                    JMP INCREMENTREPELMISSILE
                    
CheckBlueMissileRepel:
                    MOV BL,REDSHIELD ;SEE WHETHER RED SHIP HAS FILTER/SHIELD ACTIVATED
                    CMP BL,1
                    JNE INCREMENTREPELMISSILE
                    
                    
                    MOV BX,PLAYER2START-10;GET THE XCOORDINATE OF THE BLUE SHIELD
                   
                    ADD CX,MissileLength;GET 1+THE END OF MISSILE SO AS NOT TO DRAW OVER THE SHIELD
                    
                    CMP CX,BX;CHECK IF MISSILE HAS REACHED SHIELD
                    JNE INCREMENTREPELMISSILE
                    
                    
                    MOV BX,SHIP2POS;GET THE YCOORDINATE OF THE RED SHIELD
                    
                    CMP DX,BX;SEE IF THE MISSILE IS ABOVE SHIELD
                    JB  INCREMENTREPELMISSILE
                    
                    ADD BX,19;GET BOTTOM OF SHIELD
                    CMP DX,BX;SEE IF THE MISSILE IS BELOW SHIELD
                    JA  INCREMENTREPELMISSILE
                     
                    ;MISSILE SHOULD BE REPELLED 
                    MOV MissileDirection[SI],0FFFFH
                    SUB CX,1
                    MOV MissileX[SI],CX
                    ;dec rem num of ref
                    DEC ReflectedMissiles
                    CMP ReflectedMissiles,0
                    jne ENDREPELMISSILE
                    mov ReflectedMissiles,10
                    call DeleteSHeild
                    
                    JMP INCREMENTREPELMISSILE                    
 

      INCREMENTREPELMISSILE:
                    ADD SI,2
                    JMP STARTREPELMISSILE  
                                                                           
ENDREPELMISSILE:    
                     
                   
                    RET
REPELMISSILE        ENDP
    
RESETGAME           PROC;CALLED AT BEGINNIG OF GAME MODE, BEFORE DRAWING
    
    
                    MOV PLAYER1_HEALTH, 5
                    MOV PLAYER2_HEALTH, 5 
                    
                    MOV SHIP1POS, 93D
                    MOV SHIP2POS, 93D
                     
                    MOV SI,0 
                    RESETMISSILES:
                    MOV MissileX[SI],0
                    MOV MissileY[SI],0
                    ADD SI,2
                    CMP SI,MAXMISSILECOUNT
                    JNE RESETMISSILES
                    
                    MOV REDTRILASER, 0
                    MOV BLUETRILASER, 0         
       
                    MOV InvisibleBlue, 0
                    MOV InvisibleRed, 0
       
        
                    MOV BLUESHIELD, 0;THIS IS BOOLEAN OPERATOR TO CHECK THE PRESENCE OF SHIPSHIELD
                    MOV REDSHIELD, 0
                    
                    MOV MISSILECOUNT,0
                    
                    mov PowerUPType,0 
                    MOV POWERUPY,21
                    CALL DELPOWERUP
                    
                    mov claymore1active,0
                    mov claymore2active,0
                    
                    mov ship1speed ,2
                    mov ship2speed,2
    
                    
                    RET
RESETGAME           ENDP

    
 INITCLAYMORE1 PROC
 
 MOV CLAYMORE1X,PLAYER1START+SHIPLENGTH+3
 MOV AX,SHIP1POS
 MOV CLAYMORE1Y,AX
 ADD CLAYMORE1Y,SHIPWIDTH/3 
 SUB CLAYMORE1Y,1
 MOV CLAYMORE1ACTIVE,2 
    RET
 INITCLAYMORE1 ENDP 
 
 
 
 INITCLAYMORE2 PROC
 
 MOV CLAYMORE2X,PLAYER2START-SHIPWIDTH-3
 MOV AX,SHIP2POS
 MOV CLAYMORE2Y,AX
 ADD CLAYMORE2Y,SHIPWIDTH/3 
 SUB CLAYMORE2Y,1 
 MOV CLAYMORE2ACTIVE,2
    RET
 INITCLAYMORE2 ENDP
 
 
DRAWCLAYMORE1 PROC
 
 
 MOV AH,0CH  ;DRAWBODY
 MOV AL,07H   
 MOV DX,CLAYMORE1Y  
 MOV BX,CLAYMORE1Y
 ADD BX,SHIPWIDTH/3
 MOV SI,CLAYMORE1X
 ADD SI,CLAYMORELENGTH
 DYC:           
 MOV CX,CLAYMORE1X
 DXC:
 INT 10H
 INC CX
 CMP CX,SI
 JNZ DXC
 INC DX
 CMP DX,BX
 JNZ DYC
 
 
 SUB DX,3         ;DRAWHEAD
 MOV BX,CLAYMORE1Y
 ADD BX,1
 MOV SI,CLAYMORE1X
 ADD SI,CLAYMORELENGTH+2
 DYHC:
 MOV CX,CLAYMORE1X
 ADD CX,CLAYMORELENGTH
 DXHC:
 INT 10H
 INC CX
 CMP CX,SI
 JNZ DXHC
 DEC DX
 CMP DX,BX
 JNZ DYHC    
 
 CMP CLAYMORE1L,0
 JZ OFF1
 
 MOV AL,1011B  ;DRAWLIGHT 
 INC DX
 MOV BX,DX
 ADD BX,2
 MOV SI,CLAYMORE1X
 ADD SI,3
 DYLC:
 MOV CX,CLAYMORE1X
 DXLC:
 INT 10H
 INC CX
 CMP CX,SI
 JNZ DXLC
 INC DX
 CMP DX,BX 
 JNZ DYLC: 
 OFF1:
RET    
DRAWCLAYMORE1 ENDP

 
 DRAWCLAYMORE2 PROC
 
 
 MOV AH,0CH  ;DRAWBODY
 MOV AL,07H   
 MOV DX,CLAYMORE2Y  
 MOV BX,CLAYMORE2Y
 ADD BX,SHIPWIDTH/3
 MOV SI,CLAYMORE2X
 SUB SI,CLAYMORELENGTH
 DYC2:           
 MOV CX,CLAYMORE2X
 DXC2:
 INT 10H
 DEC CX
 CMP CX,SI
 JNZ DXC2
 INC DX
 CMP DX,BX
 JNZ DYC2
 
 
 SUB DX,3         ;DRAWHEAD
 MOV BX,CLAYMORE2Y
 ADD BX,1
 MOV SI,CLAYMORE2X
 SUB SI,CLAYMORELENGTH+2
 DYHC2:
 MOV CX,CLAYMORE2X
 SUB CX,CLAYMORELENGTH
 DXHC2:
 INT 10H
 DEC CX
 CMP CX,SI
 JNZ DXHC2
 DEC DX
 CMP DX,BX
 JNZ DYHC2    
 
 CMP CLAYMORE2L,0
 JZ OFF2
 MOV AL,1100B  ;DRAWLIGHT 
 INC DX
 MOV BX,DX
 ADD BX,2
 MOV SI,CLAYMORE2X
 SUB SI,3
 DYLC2:
 MOV CX,CLAYMORE2X
 DXLC2:
 INT 10H
 DEC CX
 CMP CX,SI
 JNZ DXLC2
 INC DX
 CMP DX,BX 
 JNZ DYLC2 
 OFF2:
RET    
DRAWCLAYMORE2 ENDP
 
 
 
 
 
MOVECLAYMORE1 PROC
    
 MOV AH,0CH  ;DRAWBODY
 MOV AL,00H   
 MOV DX,CLAYMORE1Y  
 MOV BX,CLAYMORE1Y
 ADD BX,SHIPWIDTH/3
 MOV SI,CLAYMORE1X
 ADD SI,CLAYMORELENGTH/3
 CYC:           
 MOV CX,CLAYMORE1X
 CXC:
 INT 10H
 INC CX
 CMP CX,SI
 JNZ CXC
 INC DX
 CMP DX,BX
 JNZ CYC 
 
 ADD CLAYMORE1X,CLAYMORELENGTH/3
 BLINKER1
 CALL DRAWCLAYMORE1
 
 CMP CLAYMORE1X,312-CLAYMORELENGTH
 JB NOTERMINAL1
 
 MOV CLAYMORE1ACTIVE,3
 
 NOTERMINAL1:
    
RET
MOVECLAYMORE1 ENDP


MOVECLAYMORE2 PROC
    
 MOV AH,0CH  ;DRAWBODY
 MOV AL,00H   
 MOV DX,CLAYMORE2Y  
 MOV BX,CLAYMORE2Y
 ADD BX,SHIPWIDTH/3
 MOV SI,CLAYMORE2X
 SUB SI,CLAYMORELENGTH/3
 CYC2:           
 MOV CX,CLAYMORE2X
 CXC2:
 INT 10H
 DEC CX
 CMP CX,SI
 JNZ CXC2
 INC DX
 CMP DX,BX
 JNZ CYC2 
 
 SUB CLAYMORE2X,CLAYMORELENGTH/3 
 BLINKER2
 CALL DRAWCLAYMORE2
 
 CMP CLAYMORE2X,PLAYER1START+3+CLAYMORELENGTH
 JA NOTERMINAL2
 
 MOV CLAYMORE2ACTIVE,3
 
 NOTERMINAL2:
 
    
RET
MOVECLAYMORE2 ENDP


EXPLODECLAYMORE1 PROC
 
SUB PLAYER2_HEALTH,2 
MOV CX,PLAYER2_HEALTH
CALL CHANGE_PLAYER2_HEALTH
 
    MOV AL,0EH
    MOV AH,0CH
    MOV DX,SHIP2POS
    MOV BX,SHIP2POS
    ADD BX,SHIPWIDTH
    YAX2C:
    MOV CX,PLAYER2START
    XAX2C:    
    INT 10H
    DEC CX
    CMP CX,PLAYER2START-SHIPLENGTH*4
    JNZ XAX2C
    INC DX
    CMP DX,BX
    JNZ YAX2C
    
     MOV CX,0FFFFH
    EXP1:
    LOOP EXP1
    
    
    MOV CX,0FFFFH
    EXP11:
    LOOP EXP11
    
    MOV AL,00H
    MOV AH,0CH
    MOV DX,SHIP2POS
    MOV BX,SHIP2POS
    ADD BX,SHIPWIDTH
    YAX22:
    MOV CX,PLAYER2START
    XAX22:    
    INT 10H
    DEC CX
    CMP CX,PLAYER2START-SHIPLENGTH*4
    JNZ XAX22
    INC DX
    CMP DX,BX
    JNZ YAX22
     
    MOV CLAYMORE1ACTIVE,0
    MOV CLAYMORE1L,0
    CALL DRAWSHIP2
    
RET
EXPLODECLAYMORE1 ENDP


EXPLODECLAYMORE2 PROC
 
SUB PLAYER1_HEALTH,2
MOV CX,PLAYER1_HEALTH 
CALL CHANGE_PLAYER1_HEALTH

    MOV AL,0EH
    MOV AH,0CH
    MOV DX,SHIP1POS
    MOV BX,SHIP1POS
    ADD BX,SHIPWIDTH
    YAX1C:
    MOV CX,PLAYER1START
    XAX1C:    
    INT 10H
    INC CX
    CMP CX,PLAYER1START+SHIPLENGTH*4
    JNZ XAX1C
    INC DX
    CMP DX,BX
    JNZ YAX1C 
     
      MOV CX,0FFFFH
    EXP2:
    LOOP EXP2
    
    MOV CX,0FFFFH
    EXP22:
    LOOP EXP22
     
    MOV AL,00H
    MOV AH,0CH
    MOV DX,SHIP1POS
    MOV BX,SHIP1POS
    ADD BX,SHIPWIDTH
    YAX11:
    MOV CX,PLAYER1START
    XAX11:    
    INT 10H
    INC CX
    CMP CX,PLAYER1START+SHIPLENGTH*4
    JNZ XAX11
    INC DX
    CMP DX,BX
    JNZ YAX11    
    
    MOV CLAYMORE2ACTIVE,0
    MOV CLAYMORE2L,0 
    
CALL DRAWSHIP1

RET
EXPLODECLAYMORE2 ENDP  

Generate_powerup proc
    
    mov ax,SHIP1POS
    add ax,SHIP2POS
    add ax,PLAYER1_HEALTH
    add ax,PLAYER2_HEALTH
    
    mov bl,6
    div bl
    
    mov poweruptype,ah
    
                  ret
Generate_powerup endp

INVISTIME PROC
 
CMP InvisibleBlue,0
JZ NOBLUE
INC INVISTIMERBLUE
CMP INVISTIMERBLUE,0FFH
JNZ NORED
MOV INVISIBLEBLUE,0
MOV INVISTIMERBLUE,0

NOBLUE:

CMP InvisibleRED,0
JZ NORED
INC INVISTIMERRED
CMP INVISTIMERRED,0FFH
JNZ NORED
MOV INVISIBLERED,0
MOV INVISTIMERRED,0
NORED:
 
    
RET
INVISTIME ENDP    
 
 END MAIN