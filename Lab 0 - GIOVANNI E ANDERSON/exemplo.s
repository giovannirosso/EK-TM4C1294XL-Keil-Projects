; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
			
vetor	SPACE 9					;ALOCA O 'VETOR'
	
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

; -------------------------------------------------------------------------------
; Fun��o main()
Start  				
; Comece o c�digo aqui <======================================================
	
; Lab 0 - GIOVANNI E ANDERSON

	LDR R0,= vetor				;R0 RECEBE O ENDERE�O DA PRIMEIRA POSI��O
;	LDR R1,= 0x2000000A 		;R1 RECEBE O ENDERE�O DA ULTIMA POSI��O (DESNECESS�RIO)
	
	MOV R4, #0					;AUX QUE PERCORRE
	MOV R5, #0					;AUX PARA O VALOR A SER OTIMIZADO
	
loop
	LDRB R2, [R0, R5]			;R2 RECEBE O VALOR DA PRIMEIRA POSI��O + VALOR DO INICIO
	LDRB R3, [R0, R4]			;R3 RECEBE VALOR DA PROXIMA POSI��O
	
	CMP R2, R3					;REALIZA A COMPARA��O
	ITTT GT						;CONDI��O PARA TROCA DOS VALORES
	MOVGT R12, R3				;REALIZA A TROCA COM AUZILIARES
	MOVGT R3, R2
	MOVGT R2, R12
	
	ITT GT						;REALIZA A TROCA NA MEM�RIA
	STRBGT R2, [R0, R5]
	STRBGT R3, [R0, R4]
	
	CMP R4, #9					;VERIFICA SE J� PERCOREU TODO VETOR
	ITTE EQ						;SE SIM
	ADDEQ R5, R5, #1			;INCREMENTA O AUX DO VALOR A SER OTIMIZADO
	MOVEQ R4, R5				;COLOCA O AUX QUE PERCORRE NO VALOR A SER OTIMIZADO
	ADDNE R4, R4, #1			;SE N�O, INCREMETA O AUX Q PERCORE
	
	CMP R5, #9					;VERIFICA SE J� OTIMIZOU TODOS OS VALORES

	BEQ fim						;SE S, FIM
	
	BNE loop					;SE N, CONTINUA
	
fim	
	NOP
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
