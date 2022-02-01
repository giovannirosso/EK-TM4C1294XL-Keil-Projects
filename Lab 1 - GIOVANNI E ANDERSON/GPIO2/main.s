; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este programa deve esperar o usuário pressionar uma chave.
; Caso o usuário pressione uma chave, um LED deve piscar a cada 1 segundo.

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Definições de Valores
BIT0	EQU 2_0001
BIT1	EQU 2_0010

; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
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
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
		IMPORT PortA_Output			; Permite chamar PortA_Output de outro arquivo
		IMPORT PortB_Output			; Permite chamar PortB_Output de outro arquivo
		IMPORT PortP_Output			; Permite chamar PortP_Output de outro arquivo
		IMPORT PortQ_Output			; Permite chamar PortQ_Output de outro arquivo			
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo


; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init             ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	MOV R4, #0					;Flag para os Leds
	MOV R5, #1					;PASSO=1
	MOV R6, #0					;Contador Unidades
	MOV R7, #0					;Contador Dezenas
	MOV R8, #0					;TEMPO
	MOV R9, #0					;Enables
	MOV R10, #2_10000000		;LED AUX
	MOV R11, #2_10000000		;LED SAIDA

MainLoop

	BL PortJ_Input
Nenhuma
	CMP R0, #2_00000011
	BNE VerificaSW1
	BEQ Inicializa
	B MainLoop
VerificaSW1
	CMP R0, #2_00000010
	BNE VerificaSW2
	BEQ IncrementaPasso
	B MainLoop
VerificaSW2
	CMP R0, #2_00000001
	BEQ DecrementaPasso
	B MainLoop

Inicializa

	CMP R9, #0
	BEQ EnableDS1
	CMP R9, #1
	BEQ EnableDS2
	CMP R9, #2
	BEQ EnableLeds
	
	MOV R9, #0
	ADD R8, #1					;;; Cada inicialização(atualização dos displays) conta um T

	B MainLoop
	
IncrementaPasso
	CMP R5, #9
	ADDNE R5, R5, #1
	MOV R0, #150
	BL 	SysTick_Wait1ms
	B 	MainLoop

DecrementaPasso
	CMP R5, #1
	SUBNE R5, R5, #1
	MOV R0, #150
	BL 	SysTick_Wait1ms
	B 	MainLoop
	
EnableDS1
	MOV R9, #1					;proximo enable
	MOV R0, #2_00000000			;desliga transistor leds
	BL PortP_Output
	MOV R0, #2_00010000			;seta transistor PB5
	BL PortB_Output
	B DS1

EnableDS2
	MOV R9, #2					;proximo enable
	MOV R0, #2_00100000			;seta transistor PB4
	BL PortB_Output
	B DS2

EnableLeds
	MOV R9, #3					;mantem r9 em um valor q não ira mais entrar no loop de inicialização
	MOV R0, #2_00000000			;desliga transistor displays
	BL PortB_Output
	MOV R0, #2_00100000			;seta transistor PP5
	BL PortP_Output
	B Acende_Led

DS1								;Display das dezenas(r7)
	CMP 	R7,#0
	BEQ 	ZERO
	CMP 	R7,#1
	BEQ 	UM	
	CMP 	R7,#2
	BEQ 	DOIS	
	CMP 	R7,#3		
	BEQ 	TRES
	CMP 	R7,#4
	BEQ 	QUATRO
	CMP 	R7,#5
	BEQ 	CINCO
	CMP 	R7,#6
	BEQ 	SEIS
	CMP 	R7,#7
	BEQ		SETE
	CMP 	R7,#8
	BEQ 	OITO
	CMP 	R7,#9
	BEQ 	NOVE
	BGT 	DEZds1				;Zera ds1, Colocar o valor incrementado corrigido no ds2
	
DS2								;Display das unidades(r6)
	CMP 	R6,#0
	BEQ 	ZERO
	CMP 	R6,#1
	BEQ 	UM	
	CMP 	R6,#2
	BEQ 	DOIS	
	CMP 	R6,#3		
	BEQ 	TRES
	CMP 	R6,#4
	BEQ 	QUATRO
	CMP 	R6,#5
	BEQ 	CINCO
	CMP 	R6,#6
	BEQ 	SEIS
	CMP 	R6,#7
	BEQ		SETE
	CMP 	R6,#8
	BEQ 	OITO
	CMP 	R6,#9
	BEQ 	NOVE
	BGT 	DEZds2				;Colocar +1 no ds1 quando ds2 > 9

Acende_Led						;;Coloca em R0 o bit para aceder os leds desejados
	MOV R0, R11
	B Saida

ZERO
	MOV 	R0, #2_00111111
	B	Saida
UM
	MOV		R0, #2_00000110
	B 	Saida
DOIS
	MOV 	R0, #2_01011011
	B 	Saida
TRES
	MOV 	R0, #2_01001111
	B 	Saida
QUATRO
	MOV 	R0, #2_01100110
	B 	Saida
CINCO
	MOV 	R0, #2_01101101
	B 	Saida
SEIS
	MOV 	R0, #2_01111101
	B 	Saida
SETE
	MOV 	R0, #2_00000111
	B 	Saida
OITO
	MOV 	R0, #2_01111111
	B 	Saida
NOVE
	MOV 	R0, #2_01101111
	B 	Saida
DEZds1				;;; EX= 98 + 4 = 102 --->> 0 NO R7(DEZENA) 2 NO R6(UNI) DEZds2 faz a correção pois é chamado junto
	MOV R7,#0		;;; DZ = 0
	MOV R9,#0		;;;CHAVEA DS1
	B 	MainLoop
DEZds2
	SUB R6, R6, #10  ;;;EX => R6 = 9 , passo(r5) = 3 , SOma = 12, incrementa 1 no R7(dezena), R6=12-10= 2 ;;;;
	MOV R9,#1		 ;;;CHAVEA DS2
	B 	SomaDS1
	
Saida
	BL	PortA_Output
	BL	PortQ_Output
	MOV R0, #5
	BL SysTick_Wait1ms
	CMP R8, #40			;;;;Numero de execuçoes do mainloop / tempo pra trocar o numero
	BEQ SomaDS2
	B MainLoop
	
SomaDS2					;;;;Executado a cada T
	MOV	R8, #0
	ADD R6, R6, R5
	CMP R4, #1 			;;;;Verifica o flag de acender(0) ou apagar(1)
	BEQ VoltaLed		
	CMP R11, #2_11111111	;;;;Verifica se acendeu todos os leds
	BNE ProxLed
	MOV R10, #2_10000000	;;;;se acendeu chama a função q apaga
	BEQ VoltaLed
	
SomaDS1
	ADD R7, #1			
	B MainLoop
	
ProxLed
	CMP R11, #2_00000000		;;;Verifica se todos os leds estão apagados
	ITEE EQ
	ADDEQ R11, R11, R10			;;;Acende o primeiro LED
	LSRNE R10, R10 ,#1			;;;Desloca o Bit do aux >>>
	ADDNE R11, R11, R10			;;;Soma o Aux com o R11 
	B MainLoop

VoltaLed
	MOV R4, #1					;;;Seta o flag pra retornar para a função de apagar os leds
	SUB R11, R11, R10			;;;Subtrai o de R11 o Aux
	LSR R10, R10, #1			;;;Desloca o aux para apagar o proximo Led
	CMP R11, #2_00000000		;;;Verifica se apagou todos
	BEQ rst						;;;Se sim chama o rst para retornar os registradores para o valor inicial
	B MainLoop

rst
	MOV R4, #0
	MOV R10, #2_10000000
	MOV R11, #2_00000000
	B MainLoop
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
