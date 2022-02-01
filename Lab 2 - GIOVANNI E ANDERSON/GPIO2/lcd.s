;------------Constantes------------


;------------Área de Código------------
;Tudo abaixo da diretiva a seguir será armazenado na memória de código

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
            
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms		
		IMPORT  SysTick_Wait1us				
		IMPORT PortA_Output			; Permite chamar PortA_Output de outro arquivo
		IMPORT PortB_Output			; Permite chamar PortB_Output de outro arquivo
		IMPORT PortP_Output			; Permite chamar PortP_Output de outro arquivo
		IMPORT PortQ_Output			; Permite chamar PortQ_Output de outro arquivo
		IMPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
		IMPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo	
		IMPORT PortN_Output			; Permite chamar PortM_Output de outro arquivo
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
		EXPORT LCD_Inst
		EXPORT LCD_Dado
		EXPORT LCD_rst
        EXPORT LCDlinha_2 
        EXPORT LCD_escreve	
		EXPORT LCD_Init

        ALIGN
            
;------------LCD_Init------------

LCD_Init
	PUSH {LR}
	MOV R3, #0x38				; Inicializar o modo 2 linhas
	BL LCD_Inst
	MOV R3, #0x06				; Cursor com autoincremento para a direita
	BL LCD_Inst
	MOV R3, #0x0E				; Configurar cursor (habilita o diplay + cursor + pisca)
	BL LCD_Inst
	MOV R3, #0x01				; Limpar o display e levar o cursor para home
	BL LCD_Inst
	POP {LR}
	BX LR

LCD_Inst
	PUSH {LR}
	MOV R0, #2_00000100			;Modo INSTRUÇÃO ativo (RS=0 , RW=0 , EN=1)
	BL PortM_Output
	MOV R0, R3
	BL  PortK_Output
	MOV R0, #10
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
	MOV R0, #10
	BL SysTick_Wait1ms			;Delay para a instrução ser executada
	MOV R0, #2_00000000			;Modo DADO desativo (RS=0 , RW=0 , EN=0)
	BL PortM_Output
	POP {LR}
	BX LR

LCD_rst
	PUSH	{LR}
	MOV	R3, #0x01				;Limpar o display e levar o cursor para home
	BL	LCD_Inst
	MOV R0, #10
	BL SysTick_Wait1ms			;Delay para a instrução ser executada
	POP {LR}
	BX LR
	
LCDlinha_2
	PUSH {LR}
	MOV R3, #0xC0
	BL LCD_Inst
	MOV R0, #10
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
	MOV R0, #10
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

    
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo