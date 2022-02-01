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
	MOV  R0, #0xF0              ;Salva no registrador R0 o valor hexa 0xF0
	ANDS R0, #2_01010101        ;AND do R0 com o binário 01010101 e salva em R0
		
	MOV  R1, #2_11001100        ;Salva no registrador R1 o valor binário 11001100
	ANDS R1, #2_00110011        ;AND do R1 com o binário 00110011 e salva em R1		
		
	MOV  R2, #0x80              ;Salva no registrador R2 o valor binário 10000000
	ORRS R2, #2_00110111        ;OR do R2 com o binário 00110111 e salva em R2		
		
	MOV  R3, #0xABCD            ;Salva no registrador R3 o valor binário ABCD
	MOVT R3, #0xABCD            ;Salva nos MSB registrador R3 o valor binário ABCD
	MOV R4, #0xFFFF             ;Salva o valor 0xFFFF em R4 porque se for imediato em BICS
	                            ;dá erro por causa do operando 2
	BICS R3, R4                 ;AND do R1 com o binário salvo em R4 0xFFFF0000 e salva em R3		
		
    NOP
	

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
