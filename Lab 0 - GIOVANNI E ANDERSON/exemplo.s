; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
			
vetor	SPACE 9					;ALOCA O 'VETOR'
	
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

; -------------------------------------------------------------------------------
; Função main()
Start  				
; Comece o código aqui <======================================================
	
; Lab 0 - GIOVANNI E ANDERSON

	LDR R0,= vetor				;R0 RECEBE O ENDEREÇO DA PRIMEIRA POSIÇÃO
;	LDR R1,= 0x2000000A 		;R1 RECEBE O ENDEREÇO DA ULTIMA POSIÇÃO (DESNECESSÁRIO)
	
	MOV R4, #0					;AUX QUE PERCORRE
	MOV R5, #0					;AUX PARA O VALOR A SER OTIMIZADO
	
loop
	LDRB R2, [R0, R5]			;R2 RECEBE O VALOR DA PRIMEIRA POSIÇÃO + VALOR DO INICIO
	LDRB R3, [R0, R4]			;R3 RECEBE VALOR DA PROXIMA POSIÇÃO
	
	CMP R2, R3					;REALIZA A COMPARAÇÃO
	ITTT GT						;CONDIÇÃO PARA TROCA DOS VALORES
	MOVGT R12, R3				;REALIZA A TROCA COM AUZILIARES
	MOVGT R3, R2
	MOVGT R2, R12
	
	ITT GT						;REALIZA A TROCA NA MEMÓRIA
	STRBGT R2, [R0, R5]
	STRBGT R3, [R0, R4]
	
	CMP R4, #9					;VERIFICA SE JÁ PERCOREU TODO VETOR
	ITTE EQ						;SE SIM
	ADDEQ R5, R5, #1			;INCREMENTA O AUX DO VALOR A SER OTIMIZADO
	MOVEQ R4, R5				;COLOCA O AUX QUE PERCORRE NO VALOR A SER OTIMIZADO
	ADDNE R4, R4, #1			;SE NÃO, INCREMETA O AUX Q PERCORE
	
	CMP R5, #9					;VERIFICA SE JÁ OTIMIZOU TODOS OS VALORES

	BEQ fim						;SE S, FIM
	
	BNE loop					;SE N, CONTINUA
	
fim	
	NOP
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
