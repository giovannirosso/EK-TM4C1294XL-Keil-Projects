; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 15/03/2018
; Este programa espera o usuário apertar a chave USR_SW1 e/ou a chave USR_SW2.
; Caso o usuário pressione a chave USR_SW1, acenderá o LED2. Caso o usuário pressione 
; a chave USR_SW2, acenderá o LED1. Caso as duas chaves sejam pressionadas, os dois 
; LEDs acendem.

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
		IMPORT  GPIO_Init
        IMPORT  PortN_Output
        IMPORT  PortJ_Input

; -------------------------------------------------------------------------------
; Função main()
Start  			
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO

MainLoop
	BL PortJ_Input				 ;Chama a subrotina que lê o estado das chaves e coloca o resultado em R0
Verifica_Nenhuma
	CMP	R0, #2_00000011			 ;Verifica se nenhuma chave está pressionada
	BNE Verifica_SW1			 ;Se o teste viu que tem pelo menos alguma chave pressionada pula
	MOV R0, #0                   ;Não acender nenhum LED
	BL PortN_Output			 	 ;Chamar a função para não acender nenhum LED
	B MainLoop					 ;Se o teste viu que nenhuma chave está pressionada, volta para o laço principal
Verifica_SW1	
	CMP R0, #2_00000010			 ;Verifica se somente a chave SW1 está pressionada
	BNE Verifica_SW2             ;Se o teste falhou, pula
	MOV R0, #BIT0				 ;Setar o parâmetro de entrada da função como o BIT0
	BL PortN_Output				 ;Chamar a função para setar o LED1
	B MainLoop                   ;Volta para o laço principal
Verifica_SW2	
	CMP R0, #2_00000001			 ;Verifica se somente a chave SW2 está pressionada
	BNE Verifica_Ambas           ;Se o teste falhou, pula
	MOV R0, #BIT1				 ;Setar o parâmetro de entrada da função como o BIT2
	BL PortN_Output				 ;Chamar a função para setar o LED2
	B MainLoop                   ;Volta para o laço principal	
Verifica_Ambas
	CMP R0, #2_00000000			 ;Verifica se ambas as chaves estão pressionadas
	BNE MainLoop          		 ;Se o teste falhou, pula
	MOV R0, #BIT0				 ;Setar o parâmetro de entrada da função como o BIT0
	ORR R0, #BIT1				 ;e o BIT1
	BL PortN_Output		  	 	 ;Chamar a função para acender os dois LEDs
	B MainLoop                   ;Volta para o laço principal	


    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
