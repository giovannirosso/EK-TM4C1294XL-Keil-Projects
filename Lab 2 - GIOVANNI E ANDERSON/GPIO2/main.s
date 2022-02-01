; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Definições de Valores
BIT0	EQU 2_00000001
BIT1	EQU 2_00000010
BIT2	EQU 2_00000100
BIT3	EQU 2_00001000
BIT4	EQU 2_00010000
BIT5	EQU 2_00100000
BIT6	EQU 2_01000000
BIT7	EQU 2_10000000

; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM
senha SPACE 8									

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
		IMPORT  SysTick_Wait1us				
		IMPORT  GPIO_Init
		IMPORT PortA_Output			; Permite chamar PortA_Output de outro arquivo
		IMPORT PortB_Output			; Permite chamar PortB_Output de outro arquivo
		IMPORT PortP_Output			; Permite chamar PortP_Output de outro arquivo
		IMPORT PortQ_Output			; Permite chamar PortQ_Output de outro arquivo
		IMPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
		IMPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo	
		IMPORT PortN_Output			; Permite chamar PortM_Output de outro arquivo
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
		;IMPORTA AS FUNÇOES DO LCD
		IMPORT LCD_Inst
		IMPORT LCD_Dado
		IMPORT LCD_rst
        IMPORT LCDlinha_2 
        IMPORT LCD_escreve
		IMPORT LCD_Init


; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init             ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	BL LCD_Init					;Chama a subrotina para inicializar o LCD
								;R3 - PARA INSTRUÇOES / DADOS
								;R4 - STRINGS
	MOV R5, #1 					;R5 - FLAGs/Passos/ 1-PEDE SENHA / 2-CADASTRA SENHA / 3-TRANCANDO / 4-TRANCADO / 5e6 - TRAVADO SENHA MESTRA
	MOV R6, #1000				;R6 - Puxa valor do teclado
	MOV R7, #0					;R7 - Contador de algarismos digitados / Percorre a memória
	LDR R8,= senha				;R8 - Primeira posição na memória
	MOV R9, #-1					;R9 - Recebe valor da memória e compara com a senha digitada
	MOV R10, #0					;R10 - Contador de Digitos certos
	MOV R11, #0					;R11 - Contador de erros
	STRB R9, [R8]
	MOV R12, #2					;R12 - 1º Digito senha mestra
	STRB R12, [R8, #5]
	MOV R12, #0					;R12 - 2º Digito senha mestra
	STRB R12, [R8, #6]
	MOV R12, #1					;R12 - 3º Digito senha mestra
	STRB R12, [R8, #7]
	MOV R12, #9					;R12 - 4º Digito senha mestra
	STRB R12, [R8, #8]
	MOV R12, #0					;R12 - FAZ TUDO
	B MainLoop	

ABRIR							;Função que vai resetar todos os flags e Abrir o cofre
	MOV R5, #1
	MOV R6, #1000
	MOV R7, #0
	MOV R10, #0
	MOV R11, #0
	MOV R12, #0
	BL LCD_rst
	LDR R4, =abrindo
	LTORG
	BL LCD_escreve
	MOV R0, #5000
	BL SysTick_Wait1ms
	B MainLoop

Destravar						;Função q ira destravar o cofre com a senha mestra
	MOV R12, #0
	MOV R0, #2_00000000			;desliga transistor displays
	BL PortB_Output
	MOV R0, #2_00100000			;seta transistor PP5
	BL PortP_Output
loop6
	MOV R0, #2_11111111			;pisca leds 5s
	BL	PortA_Output
	BL	PortQ_Output
	MOV R0, #100
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL	PortA_Output
	BL	PortQ_Output
	MOV R0, #100
	BL SysTick_Wait1ms
	ADD R12, R12, #1
	CMP R12, #25
	BNE loop6
	B ABRIR	

Trancado						;Função q verifica a senha enquanto o cofre permanece trancado
	BL LCDlinha_2
	LDR R4, =limpa
	BL LCD_escreve
	BL LCDlinha_2
	MOV R10, #0					;Reseta R10
	MOV R7, #0					;Reseta R10
	MOV R6, #1000				;Reseta R10
loop1
	BL Teclado					;recebe do teclado
	LDRB R9, [R8, R7]			;LE senha cadastrada na memoria
	CMP R6, R9					;Compara com digito recebido
	ADDEQ R10, R10, #1			;Se o digito esta correto add 1 em R10
	MOV R9, #-1					;joga os valores de r9 e R6 para qualquer valor apenas para n contar mais de uma vez o digito correto
	MOV R6, #1000
	CMP R10, #4					;Se R10 for 4 significa q os 4 digitos estão corretos
	BEQ ABRIR					;abre
	CMP R7, #4					;4 digitos recebidos - senha errada
	BEQ erro					;Caso erre a senha
	B loop1

erro							;Função q indica senha errada e conta quantos erros ocorreram
	BL LCD_rst
	LDR R4, =errou
	BL LCD_escreve
	MOV R0, #1500
	BL SysTick_Wait1ms
	CMP R11, #3
	ADDNE R11, R11, #1
	CMP R11, #3					;Se errar 3 vezes TRAVA
	BEQ Travou
	MOV R7, #0
	B Trancado
	
Travou							;COFRE TRAVADO
	MOV R5, #6
loop4
	MOV R6, #1000				;garante q o registrador n tenha valores q interfiram
	MOV R7, #4					;conta a partir da senha cadastrada, pois é onde a senha mestra esta salva
	MOV R10, #0					;zera o contador de digitos certos
	BL LCD_rst
	LDR R4, =travado
	BL LCD_escreve
loop5							;LOOP INFINITO ATÉ RECEBER O FLAG DA INTERRUPÇÃO
	CMP R5, #5
	BNE loop5
	BL LCDlinha_2
loop2
	BL Teclado
	LDRB R9, [R8, R7]			;LE senha cadastrada na memoria
	CMP R6, R9					;Compara com digito recebido
	ADDEQ R10, R10, #1			;Se o digito esta correto add 1 em R10
	MOV R9, #-1					;joga os valores de r9 e R6 para qualquer valor apenas para n contar mais de uma vez o digito correto
	MOV R6, #1000
	CMP R10, #4					;Se R10 for 4 significa q os 4 digitos estão corretos
	BEQ Destravar				;SE CORRETO DESTRAVA
	CMP R7, #8					;4 digitos recebidos - senha errada
	BEQ loop4					;reseta os flags e PERMANECE VERIFICANDO DE 4 EM 4 DIGITOS
	B loop2						;PERMANECE VERIFICANDO
	
MainLoop						;CHAMA AS FUNÇOES CONFORME O FLAG DE R5
	CMP R5, #4
	BEQ Trancado				;se o cofre ja está trancado
	CMP R5, #1
	BEQ PedeSenha				;inicialização pede senha para cadastro
	CMP R5, #2
	BEQ CadastrarSenha			;cadastar nova senha
	CMP R5, #3
	BEQ Trancar					;tranca
	B MainLoop
	
Trancar							;Função q representa o processo de fechamento e seta o R5 para TRANCADO
	MOV R0, #1000
	BL SysTick_Wait1ms
	BL LCD_rst
	LDR R4, =trancando
	BL LCD_escreve
	MOV R0, #5000
	BL SysTick_Wait1ms
	BL LCD_rst
	LDR R4, =trancado
	BL LCD_escreve
	BL LCDlinha_2
	LDR R4, =digite
	BL LCD_escreve
	MOV R0, #1000
	BL SysTick_Wait1ms
	MOV R5, #4					;SETA o R5 em TRANCADO
	B MainLoop

CadastrarSenha					;Função q cadastar senha e seta o R5 para TRANCANDO
	BL Teclado					;Recebe valor do teclado
	CMP R12, #99				;flag aux que só é setado quando ja foram digitados 4 digitos
	BEQ loop3
	STRB R6, [R8, R7]			;escreve na memória
	CMP R7, #4					;verifica 4 digitos
	BLT CadastrarSenha
	BL LCD_rst
	LDR R4, =confirma1			;Pede a confirmação #
	BL LCD_escreve
	BL LCDlinha_2
	LDR R4, =confirma2
	BL LCD_escreve
	MOV R12, #99				;Seta o flag aux
loop3
	CMP R5, #3					;Verifica a confirmação
	BNE CadastrarSenha
	B MainLoop

PedeSenha						;Função q representa o processo de pedir a senha e seta o R5 para CADASTRAMENTO
	BL LCD_rst
	LDR R4, =pedeSenha1
	BL LCD_escreve
	BL LCDlinha_2
	LDR R4, =pedeSenha2
	BL LCD_escreve
	MOV R0, #500
	BL SysTick_Wait1ms
	BL LCDlinha_2
	LDR R4, =pedeSenha3
	BL LCD_escreve
	MOV R0, #500
	BL SysTick_Wait1ms
	BL LCDlinha_2
	LDR R4, =pedeSenha4
	BL LCD_escreve
	MOV R0, #500
	BL SysTick_Wait1ms
	BL LCDlinha_2
	LDR R4, =limpa
	BL LCD_escreve
	BL LCDlinha_2
	MOV R5, #2
	B MainLoop

NUM_Hash						;Função q irá será o R5 Para TRANCANDO caso ja tenham sido inseridos 4 digitos
	PUSH {LR}
	CMP R7, #4
	MOVHS R5, #3
	BL TIMER					;tira repique
	POP {LR}
	BX LR
NUM_Ast
	PUSH {LR}
	MOV R6, #10
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_0
	PUSH {LR}
	MOV R6, #0
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR	
NUM_1
	PUSH {LR}
	MOV R6, #1
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_2
	PUSH {LR}
	MOV R6, #2
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_3
	PUSH {LR}
	MOV R6, #3
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
	
Teclado						;FUNÇÃO Q MAPEIA O TECLADO
	PUSH {LR}
	MOV R0, #2_11100000
	BL PortM_Output
	BL PortL_Input
	CMP R0, #2_1110			;número 1
	BEQ NUM_1
	CMP R0, #2_1101			;número 4
	BEQ NUM_4
	CMP R0, #2_1011			;número 7
	BEQ NUM_7
	CMP R0, #2_0111			;número *
	BEQ NUM_Ast
	
	MOV R0, #2_11010000
	BL PortM_Output
	BL PortL_Input
	CMP R0, #2_1110			;número 2
	BEQ NUM_2
	CMP R0, #2_1101			;número 5
	BEQ NUM_5
	CMP R0, #2_1011			;número 8
	BEQ NUM_8
	CMP R0, #2_0111			;número 0
	BEQ NUM_0
	
	MOV R0, #2_10110000
	BL PortM_Output
	BL PortL_Input
	CMP R0, #2_1110			;número 3
	BEQ NUM_3
	CMP R0, #2_1101			;número 6
	BEQ NUM_6
	CMP R0, #2_1011			;número 9
	BEQ NUM_9
	CMP R0, #2_0111			;número #
	BEQ NUM_Hash
	POP {LR}
	BX LR

NUM_4
	PUSH {LR}
	MOV R6, #4
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_5
	PUSH {LR}
	MOV R6, #5
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_6
	PUSH {LR}
	MOV R6, #6
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_7
	PUSH {LR}
	MOV R6, #7
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_8
	PUSH {LR}
	MOV R6, #8
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
NUM_9
	PUSH {LR}
	MOV R6, #9
	LDR R4, =numAst
	BL LCD_escreve
	BL TIMER
	ADD R7, R7, #1
	POP {LR}
	BX LR
	
TIMER								;tira repique
	PUSH {LR}
	MOV R0, #300
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

;STRINGS
abrindo    DCB "Abrindo         ",0
pedeSenha1 DCB "Cofre aberto    ",0
pedeSenha2 DCB "Digite nova     ",0
pedeSenha3 DCB "senha para      ",0
pedeSenha4 DCB "fechar o cofre  ",0
limpa 	   DCB "                ",0
numAst 	   DCB "*",0
confirma1  DCB "Pressione # para",0
confirma2  DCB "Confirmar       ",0
trancando  DCB "Cofre fechando  ",0
trancado   DCB "Cofre Fechado   ",0
errou 	   DCB "ERRO-TenteDeNovo",0
travado    DCB "ERR-SENHA MESTRA",0
digite	   DCB "Digite a Senha  ",0
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
