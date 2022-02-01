// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado da chave USR_SW2 e acende os LEDs 1 e 2 caso esteja pressionada
// Prof. Guilherme Peron

#include <stdint.h>

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
uint32_t PortJ_Input(void);
void PortN_Output(uint32_t leds);
void PortQ_Output(uint32_t leds);
void PortA_Output(uint32_t leds);
void PortP_Output(uint32_t transistor);
void PortB_Output(uint32_t transistor);


int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	PortP_Output(0x20);
	PortB_Output(0x00);
	
	while (1)
	{
        //Se a USR_SW2 estiver pressionada
		if (PortJ_Input() == 0x1){
			while (1){
			PortA_Output(0xF0);
			PortQ_Output(0x0F);
			SysTick_Wait1ms(27);
			PortA_Output(0x00);
			PortQ_Output(0x00);
			SysTick_Wait1ms(27);
		}}
        //Se a USR_SW1 estiver pressionada
		else if (PortJ_Input() == 0x2)
			PortN_Output(0x2);
        //Se ambas estiverem pressionadas
		else if (PortJ_Input() == 0x0)
			PortN_Output(0x3);
        //Se nenhuma estiver pressionada
		else if (PortJ_Input() == 0x3)
			PortN_Output(0x0);
      PortA_Output(0x00);
			PortQ_Output(0x00);		
	}
}
