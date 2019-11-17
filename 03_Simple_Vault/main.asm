;====================================================================
; SIMPLE VAULT HOMEWORK
; 2019/1, YTU - CE
;====================================================================

CODE   		 SEGMENT PARA 'CODE'
				ASSUME CS:CODE, DS:DATA, SS:STAK
			
STAK   		 SEGMENT PARA STACK 'STACK'
				DW 20 DUP(?)
STAK   		 ENDS
		
DATA   		 SEGMENT PARA 'DATA'
ISLOCKED 	 DB 1 ; 0 unlocked, 1 locked
KEYS   		 DB 5 DUP(?)  ;to store value of keys if necassary
MASTERUNLOCK DW 4583 ;pre-defined master unlock value. you may change the value as you wish
VALUE 		 DW 0
PINLOCK 	 DW 0
IS_STAR		 DB 0
DIGITS 		 DB 0C7H, 0C1H  ;0C7H: L, 0C1H: U
FAILS		 DB 0
DATA         ENDS




START PROC
;===============================================
				MOV AX, DATA
				MOV DS, AX
;===============================================				
				PORTA EQU 0A8H
				PORTB EQU 0AAH
				PORTC EQU 0ACH
				CWORD EQU 0AEH
				
				HASH EQU 10
;===============================================				
				; do 8255 preparation
				MOV AX, 089H
				OUT CWORD, AX
;===============================================				
				;lock the vault
				CALL LOCKVAULT
;===============================================
				
MAINLOOP:				
				CALL READKEYS
				CALL VAULT					
				JMP MAINLOOP
				
RET
START ENDP
			
ARRAYTOINT PROC NEAR 

				;function that responsible of calculating actual integer from byte array KEYS, 
				;if array contains 3,4,5,5 it should return 3455 to corresponding accumulator
				
				MOV BX, 10
				MOV CX, 3
				XOR AX, AX
				XOR SI, SI
				
REPEAT_ADDING:	ADD AL, KEYS[SI]
				MUL BX
				INC SI
				LOOP REPEAT_ADDING
				ADD AL, KEYS[SI]
				MOV VALUE, AX	
RET
ARRAYTOINT ENDP

LOCKVAULT PROC NEAR 
				XOR AX, AX
				MOV AL, DIGITS[0]
				MOV ISLOCKED, 1
				OUT PORTA, AX
RET
LOCKVAULT ENDP

UNLOCKVAULT 	PROC NEAR 
				XOR AX, AX
				MOV AL, DIGITS[1]
				MOV ISLOCKED, 0
				OUT PORTA, AX
				
				XOR AL, AL
				MOV FAILS, AL
				
RET
UNLOCKVAULT 	ENDP

SHOW 			PROC NEAR 
				CMP ISLOCKED, 1
				JE PRINTL
				JMP PRINTU
PRINTL:			CALL LOCKVAULT
				JMP QUIT
PRINTU:			CALL UNLOCKVAULT				
				
QUIT:
RET
SHOW 			ENDP

VAULT PROC NEAR ;function that responsible for locking/unlocking vault according to status
				;if vault locked:
				;compare value with PINLOCK or MASTERUNLOCK
				;if equals, unlock and write "U" to 7seg
				;if vault is unlocked:
				;check if star is pressed, otherwise reset.
				;if star, lock, save PIN to PINLOCK, write 7seg "L"
				CMP ISLOCKED, 1			;is it locked?
				JNE	UNLOCKED
				MOV AL, KEYS[4]
				CMP AL,HASH
				JNE RET_READKEYS
				CALL ARRAYTOINT
				
				MOV AX, VALUE
				CMP AX, MASTERUNLOCK
				JZ OPEN_VAULT
				
				MOV BL, FAILS
				CMP BL, 5
				JE RET_READKEYS
				
				CMP AX, PINLOCK
				JE OPEN_VAULT
				JMP FAIL
				
OPEN_VAULT:		CALL UNLOCKVAULT
				JMP RET_READKEYS
UNLOCKED:		CALL ARRAYTOINT
				MOV AX, VALUE
				MOV PINLOCK, AX
				CALL LOCKVAULT
				JMP RET_READKEYS
				
FAIL:			MOV AL, FAILS
				INC AL
				MOV FAILS, AL
RET_READKEYS:
RET
VAULT ENDP

READKEYS PROC NEAR   

				;function responsible for reading key from 4x3, it should store the value to some register.
				;Typical keypad reader.
				;It stores pressed button to next position of the array. 
				;No boundary check
				
				MOV SI, 0

AGAIN:  		CALL SHOW
				CMP ISLOCKED, 1
				JE READ_FIVE_KEYS
				CMP SI, 4
				JE TERMINATE
READ_FIVE_KEYS:	CMP SI, 5
				JE TERMINATE
				

				;first_column
				MOV AX, 00000100b
				OUT PORTB, AX
				
				IN AL, PORTC	
				AND AL, 0FH
				JNZ CHECK_FIRST_COL
				
				
				
				;second_column
				MOV AX, 00000010b
				OUT PORTB, AX
				
				IN AL, PORTC
				AND AL, 0FH
				JNZ CHECK_SECOND_COL
				
				;third_column
				MOV AX, 00000001b
				OUT PORTB, AX
				
				IN AL, PORTC
				AND AL, 0FH
				JNZ CHECK_THIRD_COL
				
				JMP AGAIN
				
				
CHECK_FIRST_COL:

				CALL RELEASE_KEY
				check_one:
				TEST AL, 00000001b
				JZ check_four
				MOV BL, 1
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_four:
				TEST AL, 00000010b
				JZ check_seven
				MOV BL, 4
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_seven:
				TEST AL, 00000100b
				JZ check_star
				MOV BL, 7
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_star:
				TEST AL, 00001000b
				JNZ STAR_PRESSED
				JMP AGAIN
				
				
				
CHECK_SECOND_COL:
				CALL RELEASE_KEY
				check_two:
				TEST AL, 00000001b
				JZ check_five
				MOV BL, 2
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_five:
				TEST AL, 00000010b
				JZ check_eight
				MOV BL, 5
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_eight:
				TEST AL, 00000100b
				JZ check_zero
				MOV BL, 8
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_zero:
				TEST AL, 00001000b
				JZ AGAIN
				MOV BL, 0
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
			
CHECK_THIRD_COL:
				CALL RELEASE_KEY
				check_three:
				TEST AL, 00000001b
				JZ check_six
				MOV BL, 3
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_six:
				TEST AL, 00000010b
				JZ check_nine
				MOV BL, 6
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_nine:
				TEST AL, 00000100b
				JZ check_hash
				MOV BL, 9
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				check_hash:
				TEST AL, 00001000b
				JZ AGAIN
				MOV BL, HASH
				MOV KEYS[SI], BL
				INC SI
				JMP AGAIN
				
				
STAR_PRESSED:	MOV SI,0
				JMP AGAIN
				
				
TERMINATE:		
RET
READKEYS ENDP


RELEASE_KEY  PROC NEAR
			 PUSH AX
			 
RL1:		 IN AL, PORTC
			 CMP AL, 0H
			 JNE RL1
			 
			 POP AX
RET
RELEASE_KEY  ENDP



CODE    ENDS
        END START