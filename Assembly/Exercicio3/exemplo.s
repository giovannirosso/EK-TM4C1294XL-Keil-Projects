; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018


; -------------------------------------------------------------------------------
; Declarações EQU
;<NOME>         EQU <VALOR>

; -------------------------------------------------------------------------------

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
			
		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

; --------------------------------------------------------------------------------
Start
	MOV   R0, #701                   ;Salva no registrador R0 o valor 
    LSRS  R0, #5	                 ;Desloca 5 bits para a direita e atualiza o C
		
	MOV   R1, #32067                 ;Salva no registrador R1 o valor 
	MVN   R1, R1                     ;Transformar R1 em negativo
    LSRS  R1, #4	                 ;Desloca 4 bits para a direita e atualiza o C		
		
	MOV   R2, #701                   ;Salva no registrador R2 o valor 
    ASRS  R2, #3	                 ;Desloca 3 bits para a direita e atualiza o C		

	MOV   R3, #32067                 ;Salva no registrador R3 o valor 
	MVN   R3, R3                     ;Transformar R3 em negativo
    ASRS  R3, #5	                 ;Desloca 5 bits para a direita e atualiza o C

	MOV   R4, #255                   ;Salva no registrador R4 o valor 
    LSLS  R4, #8	                 ;Desloca 8 bits para a esquerda e atualiza o C

	MOV   R5, #58982                 ;Salva no registrador R5 o valor 
	MVN   R5, R5                     ;Transformar R3 em negativo
    LSLS  R5, #18	                 ;Desloca 18 bits para a esquerda e atualiza o C
	
	MOV   R6, #0x1234                ;Salva no registrador R6 o valor 
	MOVT  R6, #0xFABC                ;Salva nos MSBs do registrador R6 o valor
    ROR   R6, #10	                 ;Rotaciona 10 bits para a direita e atualiza o C	
	
	MOV   R7, #0x4321                ;Salva no registrador R6 o valor 
    RRXS  R7, R7                     ;Rotaciona um bit pra direita e atualiza o C
    RRXS  R7, R7   	                 ;Rotaciona um bit pra direita e atualiza o C	
	

    NOP
	

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
