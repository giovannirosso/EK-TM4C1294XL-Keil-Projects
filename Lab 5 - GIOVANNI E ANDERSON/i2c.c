// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Controla a I2C
// Prof. Guilherme Peron


#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "utils.h"

//Variáveis para serem transferidas ao I2C
extern uint8_t seg_conf, min_conf, hora_conf, diasem_conf, dia_conf, mes_conf, ano_conf;
//Variáveis para serem lidas do I2C
extern uint8_t seg_lido, min_lido, hora_lido, diasem_lido, dia_lido, mes_lido, ano_lido;

// -------------------------------------------------------------------------------
// Função I2C_Init
// Inicializa o port B
// Parâmetro de entrada: Não tem
// Parâmetro de saída: Não tem
void I2c_Init(void)
{
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	//1b.   após isso verificar no PRGPIO se a porta está pronta para uso.
    SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R1;  
    while((SYSCTL_PRGPIO_R & (SYSCTL_RCGCGPIO_R1) ) != (SYSCTL_RCGCGPIO_R1) ){};
        
   	// 2. Desabilitar a funcionalidade analógica dos pinos do GPIO no registrador GPIOAMSEL.
	GPIO_PORTB_AHB_AMSEL_R = 0x00;

	// 3. Preencher a função alternativa dos pinos do GPIO, para o SCL e SDA, no registrador
	// GPIOPCTL (verificar a tabela 10-2 no datasheet páginas 743-746)
	//COLOCAR 0010 NO TERCEIRO BLOCO (PB2) E 0010 NO QUARTO BLOCO (PB3) CONFORME TABELA E PAG 788
    GPIO_PORTB_AHB_PCTL_R = 0x2200;
	
	// 4. Habilitar os bits de função alternativa no registrador GPIOAFSEL para o pino do GPIO.
    GPIO_PORTB_AHB_AFSEL_R = 0xC;
	
	// 5. Habilitar a função digital no pino do GPIO no registrador GPIODEN
	GPIO_PORTB_AHB_DEN_R = 0xC;
	
	// 6. Setar o pino que será I2CSDA para dreno aberto no registrador GPIOODR
	GPIO_PORTB_AHB_ODR_R = 0x8;
    
	SYSCTL_RCGCI2C_R |= 0x1;
	while((SYSCTL_PRI2C_R  & (0x1) ) != (0x1) ){};
	
	// 8. Habilitar a função de master no registrador I2CMCR escrevendo 1 no bit MFE.
	I2C0_MCR_R = 0x10;

    // 9. Configurar o clock no campo TPR registrador I2CMTPR.
	I2C0_MTPR_R = 0x27;
}	


// -------------------------------------------------------------------------------
// Função de transmissão da I2C para o RTC
// Transmiste os 7 bytes para a I2C
// Parâmetro de entrada: Não tem
// Parâmetro de saída: Se houve erro ou não
uint8_t I2C_Send_Multiple(void)
{
	uint8_t vezes = 7;
	
	SysTick_Wait1ms(1);
  // espera o I2C ficar pronto, checa o flag de busy
  while(I2C0_MCS_R&0x01){};
  
  I2C0_MSA_R = 0xD0;    // MSA[7:1] endereço do slave 
  I2C0_MSA_R |= 0x00;   // MSA[0] 1 para leitura
  I2C0_MDR_R = 0x00;	  //endereço do data pointer
  I2C0_MCS_R = (0 | 0x02 | 0x01); 

	//Parte da transmissão	
	while (vezes > 0)
	{
		  SysTick_Wait1ms(1); 
			while(I2C0_MCS_R & 0x01) {}; // espera a transmissão concluir
			
      //Verifica se tem erro 				
			if ((I2C0_MCS_R & 0x02) != 0)
			{
				SysTick_Wait1ms(1);
				I2C0_MCS_R = 0x04;
				return 0xFF; //error
			}
			
			//Transmite 7 vezes 
			switch (vezes)
			{
				case 7:
					I2C0_MDR_R = seg_conf;
				  break;
				case 6:
					I2C0_MDR_R = min_conf;
				  break;
				case 5:
					I2C0_MDR_R = hora_conf;
				  break;
				case 4:
					I2C0_MDR_R = diasem_conf;
				  break;
				case 3:
					I2C0_MDR_R = dia_conf;
				  break;
				case 2:
					I2C0_MDR_R = mes_conf;
				  break;
				case 1:
					I2C0_MDR_R = ano_conf;
				  break;
				default:
					break;
			}
			SysTick_Wait1ms(1);
			I2C0_MCS_R = (0  | 0x01);
			vezes--;
	}
	
	// espera a transmissão concluir
  while(I2C0_MCS_R & 0x01) {};
		
	SysTick_Wait1ms(1);	
	I2C0_MCS_R = (0 | 0x04 | 0x01);
		
  // espera a transmissão concluir
  while(I2C0_MCS_R & 0x01) {};
		
	return 0;    
}

// -------------------------------------------------------------------------------
// Função de recepção da I2C do RTC
// Recebe os 7 bytes da I2C
// Parâmetro de entrada: Não tem
// Parâmetro de saída: Se houve erro ou não
uint8_t I2C_Recv_Multiple(void)
{
	uint8_t vezes = 7;
	
	// espera o I2C ficar pronto, checa o flag de busy
	SysTick_Wait1ms(1);
  while(I2C0_MCS_R & 0x01){};
	
	// Primeiro realizar uma operação de escrita
  I2C0_MSA_R = 0xD0;    // MSA[7:1] endereço do slave 
  I2C0_MSA_R |= 0x00;   // MSA[0] 0 para escrita
	I2C0_MDR_R = 0x00;	  //endereço
  I2C0_MCS_R = (0 | 0x02 | 0x01);	
	SysTick_Wait1ms(1);

	while(I2C0_MCS_R & 0x01) {};// espera a transmissão concluir
		
	//Verifica se tem erro 		
	if ((I2C0_MCS_R & 0x02) != 0)
	{
		SysTick_Wait1ms(1);
		 I2C0_MCS_R = 0x01 | 0x02 | 0x08;
		 return 0xFF; //error
	}
	
	// Realiza a operação de leitura
  while(I2C0_MCS_R&0x01){};// espera o I2C ficar pronto, checa o flag de busy
  I2C0_MSA_R = 0xD0;    // MSA[7:1] endereço do slave 
  I2C0_MSA_R |= 0x01;   // MSA[0] 1 para leitura
  I2C0_MCS_R = (0 | 0x08 | 0x02 | 0x01); //gera start/restart/habilita o master
	
	SysTick_Wait1ms(1);
	while (vezes > 0)
	{
		SysTick_Wait1ms(1);
			while(I2C0_MCS_R & 0x01) {};// espera a transmissão concluir
			//Verifica se tem erro	
			if ((I2C0_MCS_R & 0x02) != 0)
			{
				SysTick_Wait1ms(1);
				I2C0_MCS_R = 0x04;
				return 0xFF; //error
			}
			
			SysTick_Wait1ms(1);
			switch (vezes)
			{
				case 7:
					seg_lido = I2C0_MDR_R;
				  break;
				case 6:
					min_lido = I2C0_MDR_R;
				  break;
				case 5:
					hora_lido = I2C0_MDR_R;
				  break;
				case 4:
					diasem_lido = I2C0_MDR_R;
				  break;
				case 3:
					dia_lido = I2C0_MDR_R;
				  break;
				case 2:
					mes_lido = I2C0_MDR_R;
				  break;
				case 1:
					ano_lido = I2C0_MDR_R;
				  break;				
			}
			SysTick_Wait1ms(1);
			I2C0_MCS_R = (0 | 0x08 | 0x01);
			vezes--;
	}
	
	// espera a transmissão concluir
  while(I2C0_MCS_R & 0x01) {};
		
	SysTick_Wait1ms(1);
	I2C0_MCS_R = (0 | 0x04 | 0x01);
  
	// espera a transmissão concluir	
  while(I2C0_MCS_R & 0x01) {};
		
	return 0;    
}




