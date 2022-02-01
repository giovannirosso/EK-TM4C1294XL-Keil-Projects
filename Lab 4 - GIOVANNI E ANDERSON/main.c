// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Controle do motor DC
// Giovanni de Rosso Unruh
// Anderson Kmetiuk

#include <stdint.h>
#include <string.h>
#include "tm4c1294ncpdt.h"

typedef enum estMotor
{
	Estado_Parado,
	Estado_Selecionando,
	Estado_UsandoTeclado,
	Estado_UsandoPotenciometro,
}estadosMotor;

//DECLARA INICIALIZACOES
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
void ConversorAD_Init(void);
void Timer_INIT(void);

//DECLARA PORTAS
uint32_t PortJ_Input(void); //BOTÃO INTERRUPÇÃO
uint32_t PortL_Input(void); //TECLADO IN
void PortE_Output(uint32_t ponteH);
void PortF_Output(uint32_t EnMotor);
void PortK_Output(uint32_t lcd);
void PortM_Output(uint32_t teclado);

//DECLARA FUNÇOES
void Timer0A_Handler(void);
void Config_Interrupt_J(void);
void GPIOPortJ_Handler(void);

void Acha_Estado(estadosMotor estados);
void DisplayLCD_Init(void);
void Limpa_LCD(void);
void Escreve_LCD(uint32_t valor);
void Escreve_Frase(char *frase1, char *frase2);
void Escreve_Linha2(void);
uint32_t Verifica_Teclado(void);
uint32_t Identifica_Tecla(uint32_t tecla);
uint16_t Converte(void);

float  Seleciona_modo(uint32_t temp);
float	 Seleciona_vel(uint32_t temp);
void PWM(int speed);
void Ativa_Motor(void);
uint16_t Converte(void);

//VERIAVEIS GLOBAIS
volatile int reset=0;
volatile int sentido=0;
int alto=0;
int ativo=0;
int PWM_alto;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	ConversorAD_Init();
	SysTick_Wait1ms(10);
	DisplayLCD_Init();
	Timer_INIT();
	Limpa_LCD();
	Acha_Estado(Estado_Parado);
}

void Acha_Estado(estadosMotor estados)
{	
	Config_Interrupt_J();
	
	uint32_t aux = 0xFF,aux2 = 0xFF;
	int vel=0, escolha = 0, adc;

	while(1)
	{
	if(reset==1){reset=0; alto=0; ativo=0; sentido=0; escolha = 0; aux = 0xFF; estados = Estado_Parado;} // if reset sw1 - reinicia variaveis 
	switch (estados)
	{
		case Estado_Parado:
			
			Limpa_LCD();
			Escreve_Frase("MOTOR PARADO","Aperte algo");
			while(aux==0xFF && reset==0)
				{
					aux = Verifica_Teclado();
					estados = Estado_Selecionando;
				}
			
			Identifica_Tecla(aux);
			SysTick_Wait1ms(250);
			aux = 0xFF;
				
			break;
			
		case Estado_Selecionando:
			
			Limpa_LCD();
			Escreve_Frase("Digite 1 p/ TEC","Digite 2 p/ POT");
		
			while(escolha==0 && reset==0)
			{
				escolha = Seleciona_modo(aux);
			}
			if(escolha==1){estados = Estado_UsandoTeclado;}
			if(escolha==2){estados = Estado_UsandoPotenciometro;}
			
			aux=0xFF;
			escolha = 0;
			
			break;
			
		case Estado_UsandoTeclado:
			
			if(escolha==0)
			{
				
				Limpa_LCD();
				Escreve_Frase("Modo Teclado","Sentido?");
				SysTick_Wait1ms(1000);
				Limpa_LCD();
				
				Escreve_Frase("1 p/ Horario ","2 p/ AntiHorario");
				while(escolha==0 && reset==0)
				{
					escolha = Seleciona_modo(aux);
				}
				
				Limpa_LCD();
				Escreve_Frase("Modo Teclado", "Motor Parado");
				aux = 0xFF;
			}
			
			if(escolha==1){sentido=1;}
			if(escolha==2){sentido=2;}
			
			aux2 = Verifica_Teclado();
			if(aux2 != aux && aux2 != 0xFF && (aux2 == 0xEE || aux2 == 0xDE || 
				aux2 == 0xD7 || aux2 == 0xBE || aux2 == 0xED || aux2 == 0xDD || aux2 == 0xBD))
			{
				aux = aux2;
				vel = Seleciona_vel(aux);
			}
			
			if(aux2 == 0xE7){escolha=2;}  // *
			if(aux2 == 0xB7){escolha=1;}  // #
			
			if(vel == 0)
			{ 
				PortF_Output(0x00);
				break;
			}
			if(vel != 0)
			{
				PWM(vel);
			}
			break;
		
		case Estado_UsandoPotenciometro:
			
			if(escolha==0)
			{
				Limpa_LCD();
				Escreve_Frase("Modo Potenci","Sentido?");
				SysTick_Wait1ms(1000);
				
				Limpa_LCD();
				Escreve_Frase("1 p/ Horario ","2 p/ AntiHorario");
				
				while(escolha==0 && reset==0)
				{
					escolha = Seleciona_modo(aux);
				}
				
				Limpa_LCD();
				Escreve_Frase("Modo","Potenciometro");
				aux = 0xFF;
			}
			
			if(escolha==1){sentido=1;}
			if(escolha==2){sentido=2;}
			
			aux = Verifica_Teclado();
			if(aux == 0xE7){escolha=2;}  //*
			if(aux == 0xB7){escolha=1;}  //#
			
			adc = Converte();
			adc = adc/41;
			if(adc != 0){PWM(adc);}
			break;
			
		default:
			break;
		
	}
	}
}

void PWM(int speed)
{
	int vel = speed;
	if(sentido == 1){PortE_Output(0x02);}
	if(sentido == 2){PortE_Output(0x01);}
	
	if(vel==50){PWM_alto = 40000;	}
	if(vel==60){PWM_alto = 48000; }
	if(vel==70){PWM_alto = 56000; }
	if(vel==80){PWM_alto = 64000; }
	if(vel==90){PWM_alto = 72000;	}
	if(vel==100){PWM_alto = 80000;}
	
	if(ativo==0){
	TIMER0_CTL_R |= 0x1;
	ativo=1;
	}
}

void Timer0A_Handler()
{ 
	//a) Se a interrupção estiver habilitada, a rotina de tratamento da interrupção (e.g. TimerXn_Handler)deve tratar o evento, escrevendo 1 no bit TnTOCINT
	//para limpar o flagde interrupção no registrador GPTMICR (acknowledgment).
	TIMER0_ICR_R  |= 0x1;
		
	if (alto==1)
	{
		alto=0;
    PortF_Output(0x00);
		TIMER0_TAILR_R = 80000 - PWM_alto; //valortotal - valor_alto
	}
	else
	{
		PortF_Output(0x04);
		TIMER0_TAILR_R = PWM_alto;
		alto=1;
	}	
	
	//recomeçar a contagem , carregar valor de alto e baixo
}


float Seleciona_modo(uint32_t temp)
{
	while(temp != 0xEE && temp != 0xDE && reset==0)
	{
		temp = Verifica_Teclado();
	}
	if(temp == 0xEE){Identifica_Tecla(temp);SysTick_Wait1ms(250);return 1;}
	if(temp == 0xDE){Identifica_Tecla(temp);SysTick_Wait1ms(250);return 2;}
	return 0;
}

float Seleciona_vel(uint32_t temp)
{
	if(temp == 0xD7){Identifica_Tecla(temp);SysTick_Wait1ms(250);Limpa_LCD();Escreve_Frase("Modo Teclado", "Motor Parado");return 0; }
	if(temp == 0xEE){Identifica_Tecla(temp);SysTick_Wait1ms(250);Limpa_LCD();Escreve_Frase("Modo Teclado", "50%da Velocidade");return 50; }
	if(temp == 0xDE){Identifica_Tecla(temp);SysTick_Wait1ms(250);Limpa_LCD();Escreve_Frase("Modo Teclado", "60%da Velocidade");return 60; }
	if(temp == 0xBE){Identifica_Tecla(temp);SysTick_Wait1ms(250);Limpa_LCD();Escreve_Frase("Modo Teclado", "70%da Velocidade");return 70; }
	if(temp == 0xED){Identifica_Tecla(temp);SysTick_Wait1ms(250);Limpa_LCD();Escreve_Frase("Modo Teclado", "80%da Velocidade");return 80; }
	if(temp == 0xDD){Identifica_Tecla(temp);SysTick_Wait1ms(250);Limpa_LCD();Escreve_Frase("Modo Teclado", "90%da Velocidade");return 90; }
	if(temp == 0xBD){Identifica_Tecla(temp);SysTick_Wait1ms(250);Limpa_LCD();Escreve_Frase("Modo Teclado", "Velocidade Max");return 100;}
	return 0;
}

void GPIOPortJ_Handler(void)
{
		reset = 1;
		TIMER0_CTL_R = 0x0;
		PortF_Output(0x00);
		int temp;
		temp = 0x00000001;
		temp = temp | GPIO_PORTJ_AHB_ICR_R;
		GPIO_PORTJ_AHB_ICR_R = temp;
	
		Limpa_LCD();
		Escreve_Frase("---CANCELADO---","---------------");
		SysTick_Wait1ms(500);
}

		
