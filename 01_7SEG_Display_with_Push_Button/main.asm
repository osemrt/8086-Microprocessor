;STAK    SEGMENT PARA STACK 'STACK'
;        DW 20 DUP(?)
;STAK    ENDS

;DATA    SEGMENT PARA 'DATA'
;DIGITS  DB 0C0H
;DATA    ENDS

CODE    SEGMENT PARA 'CODE'
;        ASSUME CS:CODE, DS:DATA, SS:STAK
START:
;       MOV AX, DATA
;		MOV DS, AX


L1: 	
		IN AL, 64H	 	
	    CMP  AL, 0FFh	
	    JE L1
	    NOT al
	    OUT 64H, al	 
	    JMP L1
	

CODE    ENDS
        END START
