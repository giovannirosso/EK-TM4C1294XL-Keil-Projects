// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Controle do motor de passo
// Giovanni de Rosso Unruh
// Anderson Kmetiuk

#include <stdint.h>
#include <string.h>
#include "tm4c1294ncpdt.h"

typedef enum est
{
	Inicio,
	Girar,
	FIM,
}estados;

//DECLARA INICIALIZACOES
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);

//DECLARA PORTAS
uint32_t PortJ_Input(void);
uint32_t PortL_Input(void);
void PortA_Output(uint32_t leds);
void PortB_Output(uint32_t transistor);
void PortH_Output(uint32_t motor);
void PortK_Output(uint32_t lcd);
void PortM_Output(uint32_t teclado);
void PortP_Output(uint32_t transistor);
void PortQ_Output(uint32_t leds);

//DECLARA FUNÇOES
void Config_Interrupt_J(void);
void GPIOPortJ_Handler(void);
void Acha_Estado(estados estado);
void DisplayLCD_Init(void);
void Limpa_LCD(void);
void Escreve_LCD(uint32_t valor);
void Escreve_Frase(char *frase1, char *frase2);
void Escreve_Linha2(void);
uint32_t Verifica_Teclado(void);
uint32_t Identifica_Tecla(uint32_t tecla);
void MotorHorario(int nvoltas);
void MeioPassoHorario(int nvoltas);
void MotorAntiHorario(int nvoltas);
void MeioPassoAntiHorario(int nvoltas);
uint32_t RecebeVoltas(void);
uint32_t RecebeSentido(void);
uint32_t RecebeModo(void);
void ativaMotor(int voltas, int sentido, int passo);
void EsperaReset(void);

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	SysTick_Wait1ms(10);
	DisplayLCD_Init();
	PortP_Output(0x20);
	PortB_Output(0x00);
	Limpa_LCD();
	Escreve_Frase("Motor parado","0 graus 0 voltas");
	Acha_Estado(Inicio);
}

void Acha_Estado(estados estado)
{	
	Config_Interrupt_J(); //CONFIGURA A INTERRUPCAO
	uint32_t aux, voltas, sentido, passo;
	while(1)
	{
	switch (estado)
	{
		case Inicio:
			aux=Verifica_Teclado();
			if(aux==0xE7)
			{
				voltas = RecebeVoltas();
				sentido = RecebeSentido(); //1-SentidoHorario 2-AntiHorario
				passo = RecebeModo();		//1-PassoCompleto 2-MeioPasso
				estado = Girar;
			}	
		break;
		
		case Girar:
			ativaMotor(voltas, sentido, passo);
			estado = FIM;
		break;
		
		case FIM:
			EsperaReset();
			Limpa_LCD();
			Escreve_Frase("Motor parado","0 graus 0 voltas");
			estado = Inicio;
		
		break;
				
		}
	}
}

void EsperaReset(void)
{
	uint32_t aux, i=0;
	Limpa_LCD();
	Escreve_Frase("FIM - pressione","'*' p/ Reiniciar");
	while(i<1)
	{
		aux = Verifica_Teclado();
			if(aux==0xE7)
			{
				Identifica_Tecla(aux);
				SysTick_Wait1ms(250);
				i++;
			}
	}
}

void ativaMotor(int voltas, int sentido, int passo)
{
	if(sentido==1){if(passo==1){MotorHorario(voltas);}}
	if(sentido==1){if(passo==2){MeioPassoHorario(voltas);}}
	if(sentido==2){if(passo==1){MotorAntiHorario(voltas);}}
	if(sentido==2){if(passo==2){MeioPassoAntiHorario(voltas);}}
}

uint32_t RecebeVoltas(void)
{
	uint32_t aux, i;
	uint32_t voltas;
	Limpa_LCD();
	Escreve_Frase("Insira o numero","de voltas ->");
	while(i<1)
	{
		aux = Verifica_Teclado();
			if(aux!=0xFF && aux!=0xB7 && aux!=0xE7)
			{
				voltas = Identifica_Tecla(aux);
				SysTick_Wait1ms(250);
				i++;
			}
	}
	return voltas;
}

uint32_t RecebeSentido(void)
{
	uint32_t aux, i;
	uint32_t sentido;
	Limpa_LCD();
	Escreve_Frase("1-SentidoHorario","2-AntiHorario->");
	while(i<1)
	{
		aux = Verifica_Teclado();
			if(aux==0xEE || aux==0xDE)
			{
				sentido = Identifica_Tecla(aux);
				SysTick_Wait1ms(250);
				i++;
			}
	}
	return sentido;
}

uint32_t RecebeModo(void)
{
	uint32_t aux, i;
	uint32_t passo;
	Limpa_LCD();
	Escreve_Frase("1-PassoCompleto","2-MeioPasso ->");
	while(i<1)
	{
		aux = Verifica_Teclado();
			if(aux==0xEE || aux==0xDE)
			{
				passo = Identifica_Tecla(aux);
				SysTick_Wait1ms(250);
				i++;
			}
	}
	return passo;
}

void MotorHorario(int nvoltas)
{
	int i,led=0x80;
	int aux,aux2;
	char voltas[2];
	for(aux=0;aux<nvoltas;aux++)
	{
		Limpa_LCD();
		aux2=nvoltas-aux;
		voltas[0]=aux2+'0';
		Escreve_Frase("Voltas Restantes",voltas);
		Escreve_Frase("-Horario-PassoC","");
		for(i=0;i<512;i++)
		{
			if(i%14==0)
			{
				PortA_Output(led);
				PortQ_Output(led);
				led=led>>1;
				if(led==0x00)led=0x80;
				SysTick_Wait1ms(1);
				PortA_Output(0);
				PortQ_Output(0);
			}
			PortH_Output(0x09);
			SysTick_Wait1ms(2);
			PortH_Output(0x03);
			SysTick_Wait1ms(2);
			PortH_Output(0x06);
			SysTick_Wait1ms(2);
			PortH_Output(0x0C);
			SysTick_Wait1ms(2);
		}
	}
}

void MeioPassoHorario(int nvoltas)
{
	int i,led=0x80;
	int aux,aux2;
	char voltas[2];
	for(aux=0;aux<nvoltas;aux++)
	{
		Limpa_LCD();
		aux2=nvoltas-aux;
		voltas[0]=aux2+'0';
		Escreve_Frase("Voltas Restantes",voltas);
		Escreve_Frase("-Horario-MPasso","");
		for(i=0;i<512;i++)
		{
			if(i%14==0)
			{
				PortA_Output(led);
				PortQ_Output(led);
				led=led>>1;
				if(led==0x00)led=0x80;
				SysTick_Wait1ms(1);
				PortA_Output(0);
				PortQ_Output(0);
			}
			PortH_Output(0x09);
			SysTick_Wait1ms(2);
			PortH_Output(0x01);
			SysTick_Wait1ms(2);
			PortH_Output(0x03);
			SysTick_Wait1ms(2);
			PortH_Output(0x02);
			SysTick_Wait1ms(2);
			PortH_Output(0x06);
			SysTick_Wait1ms(2);
			PortH_Output(0x04);
			SysTick_Wait1ms(2);
			PortH_Output(0x0C);
			SysTick_Wait1ms(2);
			PortH_Output(0x08);
			SysTick_Wait1ms(2);
		}
	}
}

void MotorAntiHorario(int nvoltas)
{
	int i,led=0x01;
	int aux,aux2;
	char voltas[2];
	for(aux=0;aux<nvoltas;aux++)
	{
		Limpa_LCD();
		aux2=nvoltas-aux;
		voltas[0]=aux2+'0';
		Escreve_Frase("Voltas Restantes",voltas);
		Escreve_Frase(" -AntiHr-PassoC","");
		for(i=0;i<512;i++)
		{
			if(i%14==0)
			{
				PortA_Output(led);
				PortQ_Output(led);
				led=led<<1;
				if(led==0x100)led=0x01;
				SysTick_Wait1ms(1);
				PortA_Output(0);
				PortQ_Output(0);
			}
			PortH_Output(0x0C);
			SysTick_Wait1ms(2);
			PortH_Output(0x06);
			SysTick_Wait1ms(2);
			PortH_Output(0x03);
			SysTick_Wait1ms(2);
			PortH_Output(0x09);
			SysTick_Wait1ms(2);
		}
	}
}

void MeioPassoAntiHorario(int nvoltas)
{
	int i,led=0x01;
	int aux,aux2;
	char voltas[2];
	for(aux=0;aux<nvoltas;aux++)
	{
		Limpa_LCD();
		aux2=nvoltas-aux;
		voltas[0]=aux2+'0';
		Escreve_Frase("Voltas Restantes",voltas);
		Escreve_Frase(" -AntiHr-MPasso","");
		for(i=0;i<512;i++)
		{
			if(i%14==0)
			{
				PortA_Output(led);
				PortQ_Output(led);
				led=led<<1;
				if(led==0x100)led=0x01;
				SysTick_Wait1ms(1);
				PortA_Output(0);
				PortQ_Output(0);
			}
			PortH_Output(0x08);
			SysTick_Wait1ms(2);
			PortH_Output(0x0C);
			SysTick_Wait1ms(2);
			PortH_Output(0x04);
			SysTick_Wait1ms(2);
			PortH_Output(0x06);
			SysTick_Wait1ms(2);
			PortH_Output(0x02);
			SysTick_Wait1ms(2);
			PortH_Output(0x03);
			SysTick_Wait1ms(2);
			PortH_Output(0x01);
			SysTick_Wait1ms(2);
			PortH_Output(0x09);
			SysTick_Wait1ms(2);
		}
	}
}

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
				Escreve_Frase("10","");
				return 10;
			case 0xE7:
				Escreve_LCD('*');
				break;
			case 0xB7:
				Escreve_LCD('#');
				break;
		}
}

void GPIOPortJ_Handler(void)
{
		int temp;
		temp = 0x00000001;
		temp = temp | GPIO_PORTJ_AHB_ICR_R;
		GPIO_PORTJ_AHB_ICR_R = temp;
	
		Limpa_LCD();
		Escreve_Frase("---CANCELADO---","---------------");
		SysTick_Wait1ms(2000);
		Acha_Estado(FIM);
}
		
