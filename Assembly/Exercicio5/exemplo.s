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
	MOV   R0, #10                   ;Salva no registrador R0 o valor
	CMP   R0, #9
	ITTE GE
	  MOVGE R1, #50
	  ADDGE R2, R1, #32
	  MOVLT R3, #75
	  
    NOP
	

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
