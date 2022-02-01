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
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo


; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init             ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	BL LCD_Init					;Chama a subrotina para inicializar o LCD
	BL MainLoop					;Partiu MAIN
	;R3 - PARA INSTRUÇOES / DADOS
	;R4 - STRINGS

LCD_Init
	PUSH {LR}
	MOV R3, #0x38				; Inicializar o modo 2 linhas
	BL LCD_Inst
	MOV R3, #0x06				; Cursor com autoincremento para a direita
	BL LCD_Inst
	MOV R3, #0x0D				; Configurar cursor (habilita o diplay + cursor + pisca)
	BL LCD_Inst
	MOV R3, #0x01				; Limpar o display e levar o cursor para home
	BL LCD_Inst
	POP {LR}
	BX LR
	
TIMER
	ADD R9, #1
	MOV R0, #20
	BL SysTick_Wait1ms
	
MainLoop
;	BL LCD_rst
;	LDR R4, =UTFPR_STR
;	BL LCD_escreve
;	BL LCDlinha_2
;	LDR R4, =UTFPR_STR2
;	BL LCD_escreve
	
	MOV R0, #2_11100000
	BL PortM_Output
	BL PortL_Input
	CMP R0, #2_00001110			;número 1
	BEQ NUM_1
	CMP R0, #2_00001101			;número 4
	BEQ NUM_4
	CMP R0, #2_00001011			;número 7
	BEQ NUM_7
	
	MOV R0, #2_11010000
	BL PortM_Output
	BL PortL_Input
	CMP R0, #2_00001110			;número 2
	BEQ NUM_2
	CMP R0, #2_00001101			;número 5
	BEQ NUM_5
	CMP R0, #2_00001011			;número 8
	BEQ NUM_8
	
	MOV R0, #2_10110000
	BL PortM_Output
	BL PortL_Input
	CMP R0, #2_00001110			;número 3
	BEQ NUM_3
	CMP R0, #2_00001101			;número 6
	BEQ NUM_6
	CMP R0, #2_00001011			;número 9
	BEQ NUM_9
	
	B MainLoop
	
NUM_1
	BL LCD_rst
	LDR R4, =num1
	BL LCD_escreve
	B MainLoop

NUM_2
	BL LCD_rst
	LDR R4, =num2
	BL LCD_escreve
	B MainLoop

NUM_3
	BL LCD_rst
	LDR R4, =num3
	BL LCD_escreve
	B MainLoop

NUM_4
	BL LCD_rst
	LDR R4, =num4
	BL LCD_escreve
	B MainLoop

NUM_5
	BL LCD_rst
	LDR R4, =num5
	BL LCD_escreve
	B MainLoop

NUM_6
	BL LCD_rst
	LDR R4, =num6
	BL LCD_escreve
	B MainLoop

NUM_7
	BL LCD_rst
	LDR R4, =num7
	BL LCD_escreve
	B MainLoop

NUM_8
	BL LCD_rst
	LDR R4, =num8
	BL LCD_escreve
	B MainLoop

NUM_9
	BL LCD_rst
	LDR R4, =num9
	BL LCD_escreve
	B MainLoop

LCD_Inst
	PUSH {LR}
	MOV R0, #2_00000100			;Modo INSTRUÇÃO ativo (RS=0 , RW=0 , EN=1)
	BL PortM_Output
	MOV R0, R3
	BL  PortK_Output
	MOV R0, #5
	BL SysTick_Wait1ms			;Delay para a instrução ser executada
	MOV R0, #2_00000000			;Modo comando desativo (RS=0 , RW=0 , EN=0)
	BL PortM_Output
	POP {LR}
	BX LR

LCD_Dado
	PUSH {LR}
	MOV R0, #2_00000101			;Modo DADO ativo (RS=1 , RW=0 , EN=1)
	BL PortM_Output
	MOV R0, R3
	BL PortK_Output
	MOV R0, #5
	BL SysTick_Wait1ms			;Delay para a instrução ser executada
	MOV R0, #2_00000000			;Modo DADO desativo (RS=0 , RW=0 , EN=0)
	BL PortM_Output
	POP {LR}
	BX LR

LCD_rst
	PUSH	{LR}
	MOV	R3, #0x01				;Limpar o display e levar o cursor para home
	BL	LCD_Inst
	MOV R0, #5
	BL SysTick_Wait1ms			;Delay para a instrução ser executada
	POP {LR}
	BX LR
	
LCDlinha_2
	PUSH {LR}
	MOV R3, #0xC0
	BL LCD_Inst
	MOV R0, #5
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

LCD_escreve
	PUSH {LR}
LCD_escreve_b
	LDRB R3,[R4],#1
	CMP R3,#0
	BEQ LCD_fim
	BL LCD_Dado
	B LCD_escreve_b
LCD_fim
	MOV R0, #5
	BL SysTick_Wait1ms
	POP {LR}
	BX LR
	
UTFPR_STR DCB	"UTFPR",0
UTFPR_STR2 DCB	"Equipe - 04",0
num1 DCB "Numero 1",0
num2 DCB "Numero 2",0
num3 DCB "Numero 3",0
num4 DCB "Numero 4",0
num5 DCB "Numero 5",0
num6 DCB "Numero 6",0
num7 DCB "Numero 7",0
num8 DCB "Numero 8",0
num9 DCB "Numero 9",0

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
