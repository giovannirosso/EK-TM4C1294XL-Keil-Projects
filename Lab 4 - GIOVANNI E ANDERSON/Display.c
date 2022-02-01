// Display.c //+TECLADO
// Desenvolvido para a placa EK-TM4C1294XL
// Giovanni de Rosso Unruh
// Anderson Kmetiuk

#include <stdint.h>
#include <string.h>

void SysTick_Wait1ms(uint32_t delay);

uint32_t PortL_Input(void); //TECLADO IN
void PortK_Output(uint32_t lcd);
void PortM_Output(uint32_t teclado);

void DisplayLCD_Init(void);
void Limpa_LCD(void);
void Escreve_LCD(uint32_t valor);
void Escreve_Frase(char *frase1, char *frase2);
void Escreve_Linha2(void);
uint32_t Verifica_Teclado(void);
uint32_t Identifica_Tecla(uint32_t tecla);

void DisplayLCD_Init(void)
{
	PortM_Output(0x04);
	PortK_Output(0x38);
	SysTick_Wait1ms(10);
	PortM_Output(0x00);
	
	PortM_Output(0x04);
	PortK_Output(0x06);
	SysTick_Wait1ms(10);
	PortM_Output(0x00);
	
	PortM_Output(0x04);
	PortK_Output(0x0E);
	SysTick_Wait1ms(10);
	PortM_Output(0x00);
	
	PortM_Output(0x04);
	PortK_Output(0x01);
	SysTick_Wait1ms(10);
	PortM_Output(0x00);
	
	PortM_Output(0x04);
	PortK_Output(0x38);
	SysTick_Wait1ms(10);
	PortM_Output(0x00);
}

void Limpa_LCD(void)
{
	PortM_Output(0x04);
	PortK_Output(0x01);
	SysTick_Wait1ms(10);
	PortM_Output(0x00);
}

void Escreve_LCD(uint32_t valor)
{
	PortM_Output(0x05);
	PortK_Output(valor);
	SysTick_Wait1ms(2);
	PortM_Output(0x00);
}

void Escreve_Frase(char *frase1, char*frase2)
{
	int i;
	for(i=0;i<strlen(frase1);i++)
	{
		Escreve_LCD(frase1[i]);
	}
	Escreve_Linha2();
	for(i=0;i<strlen(frase2);i++)
	{
		Escreve_LCD(frase2[i]);
	}
}

void Escreve_Linha2(void)
{
	PortM_Output(0x04);
	PortK_Output(0xC0);
	SysTick_Wait1ms(10);
	PortM_Output(0x00);
}

uint32_t Verifica_Teclado(void)
{
		int cont;
		uint32_t temp;
		uint32_t temp2;
		uint32_t temp3;
		for(cont=0;cont<=3;cont++)
		{
			temp2 = 0x0F;
			if(cont==0){temp= 0xE0; PortM_Output(temp);}
			if(cont==1){temp= 0xD0; PortM_Output(temp);}
			if(cont==2){temp= 0xB0; PortM_Output(temp);}
			temp3 = PortL_Input();
			temp2 = temp2 & temp3;
			if(temp2 != 0x0F)
				{
					temp = temp | temp2;
					return temp;
				}
		}
		return 0xFF;
}

uint32_t Identifica_Tecla(uint32_t tecla)
{
		switch(tecla)
		{
			case 0xEE:
				Escreve_LCD('1');
				return 1;
			case 0xDE:
				Escreve_LCD('2');
				return 2; 
			case 0xBE:
				Escreve_LCD('3');
				return 3;
			case 0xED:
				Escreve_LCD('4');
				return 4;
			case 0xDD:
				Escreve_LCD('5');
				return 5;
			case 0xBD:
				Escreve_LCD('6');
				return 6;
			case 0xEB:
				Escreve_LCD('7');
				return 7;
			case 0xDB:
				Escreve_LCD('8');
				return 8;
			case 0xBB:
				Escreve_LCD('9');
				return 9;
			case 0xD7:
				Escreve_LCD('0');
				return 10;
			case 0xE7:
				Escreve_LCD('*');
				break;
			case 0xB7:
				Escreve_LCD('#');
				break;
		}
}
