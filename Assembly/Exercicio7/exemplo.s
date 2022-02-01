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
loop1
	ADD   R0, #5                    ;Salva no registrador R1 o valor
    CMP   R0, #50                   ;Compara o R0 com o número 50
	BNE   loop1                     ;Se não for igual a 50, continua 
	BL    Func1
    NOP
fim	B     fim
	
; ---------------------------------------------------------------------------------
Func1
       MOV R1, R0					;Copia R0 para R1
	   CMP R1, #50                  ;Compara R1 com 50
	   BGE else                     ;Se a comparação for maior ou igual vai para else
	   ADD R1, R1, #1               ;Se for menor, incrementa
	   B pula                       ;Tem que pular para não executar a linha de baixo
else   MOV R1, #-50                 ;Muda o R1 para -50
pula   BX LR                        ;Retorna da função
; ---------------------------------------------------------------------------------

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
