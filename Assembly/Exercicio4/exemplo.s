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
	MOV   R0, #101                   ;Salva no registrador R0 o valor 
    ADDS  R0, #253	                 ;Adiciona o R0 com 253 e atualiza o C
		
	MOV   R1, #40543                 ;Salva no registrador R1 o valor 
	ADD   R1, #1500                  ;Adiciona R1 com 1500
		
	MOV   R2, #340                   ;Salva no registrador R2 o valor 
    SUBS  R2, #123	                 ;Subtrai os dois n�meros e atualiza o C		

	MOV   R3, #1000                  ;Salva no registrador R3 o valor 
    SUBS  R3, #2000	                 ;Subtrai os dois n�meros e atualiza o C	
	
	MOV   R4, #54378                ;Salva no registrador R4 o valor 
	MOV   R11, #4                   ;Salva no registrador R11 o valor
    MUL   R4, R11                   ;Multiplica o n�mero por 4 ou desloca para esquerda

	MOV   R5, #0x3344                ;Salva os n�meros menos significativos no R5 
	MOVT  R5, #0x1122                ;Salva os n�meros mais significativos no R5
	MOV   R6, #0x2211                ;Salva os n�meros menos significativos no R6 
	MOVT  R6, #0x4433                ;Salva os n�meros mais significativos no R6
	UMULL  R7, R8, R5, R6            ;Multiplica R5 por R6 e salva os mais significativos
									 ;em R8 e os menos significativos em R7
			
	MOV   R9, #0x7560                ;Salva os n�meros menos significativos no R9 
	MOVT  R9, #0xFFFF                ;Salva os n�meros mais significativos no R9
	MOV   R11, #1000                 ;Salva no registrador R11 o valor	
	SDIV  R9, R11                    ;Divide R9 por 1000 com sinal
	
	MOV   R10, #0x7560               ;Salva os n�meros menos significativos no R10 
	MOVT  R10, #0xFFFF               ;Salva os n�meros mais significativos no R10 									 
    UDIV  R10,  R11                  ;Divide R9 por 1000 sem sinal


    NOP
	

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
