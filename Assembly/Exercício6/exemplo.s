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
	MOV   R0, #10                   ;Salva no registrador R0 o valor
	MOV   R1, #0xCC22               ;Salva no registrador R1 o valor
	MOVT  R1, #0xFF11               ;Salva no MSB do R1 o valor
    MOV   R2, #1234                 ;Salva no R2 o valor
    MOV   R3, #0x300                ;Salva no R3 o valor
	
	PUSH  {R0}                      ;Empurra para a pilha o R0
	PUSH  {R1-R3}                   ;Empurra para a pilha os R1, R2 e R3
	
	MOV   R1, #60                   ;Salva no registrador R0 o valor
	MOV   R2, #0xCC22               ;Salva no registrador R1 o valor

    POP   {R1-R3}                   ;Puxando da pilha
	POP   {R0}                      ;Puxando da pilha

    NOP
	

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
