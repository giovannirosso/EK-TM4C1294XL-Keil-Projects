; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018


; -------------------------------------------------------------------------------
; Declara��es EQU
;<NOME>         EQU <VALOR>

; -------------------------------------------------------------------------------

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
			
		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

; --------------------------------------------------------------------------------
Start
	MOV  R0, #65               ;Salva no registrador R0 o valor 65 decimal
	MOV  R1, #0x1B001B00       ;Salva no registrador R1 o valor 0x1B001B00
	MOV  R2, #0x5678           ;Salva nos bytes menos significativos 0x5678
	MOVT R2, #0x1234           ;Salva nos bytes mais significativos 0x1234
	
	LDR  R3, =0x20000040       ;Carrega o endere�o da mem�ria no R3
	STR  R0, [R3], #4          ;Salva na mem�ria cujo endere�o est� em R3 o conte�do de R0.
                               ;O endere�o � incrementado em 4 bytes
	STR  R1, [R3], #4          ;Salva na mem�ria cujo endere�o est� em R3 o conte�do de R1.
	                           ;O endere�o � incrementado em 4 bytes
	STR  R2, [R3], #4          ;Salva na mem�ria cujo endere�o est� em R3 o conte�do de R2.
	                           ;O endere�o � incrementado em 4 bytes
	MOV  R4, #0x1              ;Salva em R4 nos bytes menos significativos 0x0001
	MOVT R4, #0xF              ;Salva em R4 nos bytes mais significativos 0x000F
	STR  R4, [R3]              ;Salva na mem�ria cujo endere�o est� em R3 o conte�do de R4.
	
	MOV  R4, #0xCD             ;Salva no registrador R4 o byte 0xCD
	LDR  R3, =0x20000046       ;Carrega o endere�o de mem�ria no R3
	STRB R4, [R3]              ;Salva o BYTE que est� em R4 no endere�o de mem�ria de R3
	
	LDR  R3, =0x20000040       ;Carrega o endere�o de mem�ria no R3
	LDR  R7, [R3], #8          ;Carrega o conte�do do endere�o apontado por R3 em R7
	                           ;O endere�o � incrementado em 8 bytes
	LDR  R8, [R3]              ;Carrega o conte�do do endere�o apontado por R3 em R8
	MOV  R9, R7			       ;Copia o conte�do do registrador R7 para R9
	
    NOP
	
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
