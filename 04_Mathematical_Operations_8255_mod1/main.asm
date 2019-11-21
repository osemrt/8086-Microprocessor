;====================================================================
; YTU-CE
;
; Processor: 8086
; Compiler:  MASM32
;
; Before starting simulation set Internal Memory Size 
; in the 8086 model properties to 0x10000
;====================================================================

CODE	SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE, SS:STACK, DS:DATA
	
DATA	  SEGMENT PARA 'VERI'
BUTTONS   DB 10H ,10H,0H,10H, 10H, 3H, 2H, 1H, 10H, 6H, 5H, 4H, 10H, 9H, 8H, 7H
NUMBER1   DB 00H
ISLEM     DB 00H
NUMBER2   DB 00H
RESULT    DB 00H
FLAG      DB 00H
DATA ENDS

STACK SEGMENT STACK 'STACK'

	 DW 256 DUP(0)
	 
STACK ENDS

START:
     ; Write your code here
	 PUSH DS
	 XOR AX,AX
	 PUSH AX
	 MOV AX, DATA
	 MOV DS, AX
	 
	 PORTA EQU 200H				
	 PORTB EQU 202H
	 PORTC EQU 204H
	 CW    EQU 206H
	 
	 MOV DX, CW		
	 MOV AL, 0A7h			; 10100111 
	 OUT DX, AL				; CONTROL2 Word

ENDLESS:

	; check INTRB
	CONTROL1:
	XOR AX,AX       
	MOV DX, PORTC
	IN AL, DX
	TEST AL, 01H
	JNZ CONTROL1
	
	MOV DX, PORTB
	IN AL,DX		; read first digit
	
	XOR BX, BX	
	MOV BL,AL		; BL holds first digit	
	
	; check INTRA
	FIRST_READ:
	MOV DX, PORTC	
	IN AL,DX
	AND AL,08H
	CMP AL,00
	JNE FIRST_READ
	
	; if it is not a digit
	CMP BUTTONS[BX], 10H 
	JE ENDLESS
	
	
	MOV AL, BUTTONS[BX] ; take the number from the array
	MOV NUMBER1, AL		; NUMBER1 holds the first digit
	MOV DX,PORTA
	OR AL,10H			; use the second screen by making pa4 zero
	OUT DX,AL
;----------------------------------------------------------------------------
	;check INTRB
	CONTROL2:
	XOR AX,AX 
	MOV DX, PORTC
	IN AL, DX
	TEST AL, 01H
	JNZ CONTROL2
	
	MOV DX, PORTB
	IN AL,DX 		; Now, takes the opeartion from the port B
	XOR BX, BX
	MOV BL,AL
	
	SECOND_READ:
	MOV DX, PORTC
	IN AL,DX
	AND AL,08H 		; Look the output port is available or not by checking INTRA
	CMP AL,00
	JNE FIRST_READ
	
	CMP BUTTONS[BX], 10H
	JNE CONTROL2 	; read again If it is not a operation 
	
	MOV AL, BUTTONS[BX]
	MOV DX,PORTA 	; Let's display 0 on the led after taking the operation sign
	MOV AL,0
	OR AL,10H 		; activites the second led
	OUT DX,AL
	MOV ISLEM, BL	

	
;------------------------------------------------------------------------------

	CONTROL3:
	XOR AX,AX		; check INTRB
	MOV DX, PORTC
	IN AL, DX
	TEST AL, 01H
	JNZ CONTROL3
	
	MOV DX, PORTB	; read second digit
	IN AL,DX
	XOR BX, BX
	MOV BL,AL
	
	THIRD_READ:
	MOV DX, PORTC
	IN AL,DX
	AND AL,08H
	CMP AL,00
	JNE CONTROL3
	
	CMP BUTTONS[BX], 10H ; wait if it is operation
	JE CONTROL3
	MOV AL, BUTTONS[BX] 
	MOV NUMBER2, AL  
;-------------------------------------------------------------------------------
	; RESULT
	
	 MOV FLAG, 1
	
	 SUM:
	 CMP ISLEM,00H ; if the operation button is 0, SUM
	 JNE SUBSTRACTION
	 MOV AL,NUMBER1
	 ADD AL,NUMBER2
	 MOV RESULT,AL
	 JMP PRINT
	 
	 SUBSTRACTION:
	 CMP ISLEM,04H ;if the operation button is 0, SUBSTRACTION
	 JNE MULTIPLICATION
	 MOV AL,NUMBER1
	 SUB AL,NUMBER2
	 MOV RESULT,AL
	 JMP PRINT

	 MULTIPLICATION:
	 CMP ISLEM,08H ;if the operation button is 0, MULTIPLICATION
	 JNE DIVISON
	 MOV AL,NUMBER1
	 MUL NUMBER2
	 MOV RESULT,AL
	 JMP PRINT
	 
	 DIVISON:
	 MOV AL,NUMBER1 ;if the operation button is 0, DIVISION
	 DIV NUMBER2
	 MOV RESULT,AL
	 JMP PRINT
;--------------------------------------------------------------------------	 
	 PRINT:
	 MOV BL,RESULT
	 CMP BL,10
	 JAE TWO_DIGIT ; if RESULT is two-digit, jump to TWO_DIGIT to print
	 JMP ONE_DIGIT ; if RESULT is one-digit, jump to ONE_DIGIT to print

	 ONE_DIGIT:
	 MOV AL,BL
	 OR AL,10H
	 CALL SHOW
	 JMP ONE_DIGIT
	 
	 TWO_DIGIT:
	 XOR AX,AX
	 MOV AL,RESULT 
	 MOV BL,10
	 DIV BL    ; divide the result by 10
	 MOV AL,AH ; al holds the remain part
	 OR AL,10H ; print the remain part to the second led
	 CALL SHOW
	 XOR AX,AX
	 MOV AL,RESULT
	 DIV BL
	 OR AL,20H ; left PRINT
	 CALL SHOW
	 
	 
	 JMP TWO_DIGIT
;--------------------------------------------------------	     
    SHOW PROC NEAR
	MOV DX, PORTA
	OUT DX,AL
	RET
	SHOW ENDP
	
	
CODE    ENDS
        END START