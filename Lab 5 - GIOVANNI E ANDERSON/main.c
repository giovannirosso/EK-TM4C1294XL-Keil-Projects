// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica se recebeu alguma coisa pela serial e acende um dos leds de acordo com o caractere recebido
// Verifica o estado da chave USR_SW2, e, caso seja pressionada envia o caracter A pela serial
// Prof. Guilherme Peron

#include <stdint.h>
#include <string.h>
#include "utils.h"
#include "i2c.h"

//Variáveis para serem transferidas ao I2C
uint8_t seg_conf, min_conf, hora_conf, diasem_conf, dia_conf, mes_conf, ano_conf;
//Variáveis para serem lidas do I2C
uint8_t seg_lido, min_lido, hora_lido, diasem_lido, dia_lido, mes_lido, ano_lido;

//Protótipos das funções
void Estado_Init_Func(void);
void Estado_Transmite_Hora_Func(void);
void Estado_Recebe_Hora_Func(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);

void DisplayLCD_Init(void);
void Limpa_LCD(void);
void Escreve_LCD(uint32_t valor);
void Escreve_Frase(char *frase1, char *frase2);
void Escreve_Linha2(void);
uint32_t Verifica_Teclado(void);
uint32_t Identifica_Tecla(uint32_t tecla);

//DECLARA PORTAS
uint32_t PortJ_Input(void); //BOTÃO INTERRUPÇÃO
uint32_t PortL_Input(void); //TECLADO IN
void PortK_Output(uint32_t lcd);
void PortM_Output(uint32_t teclado);

//Declarações dos estados
typedef enum MaqEstados
{
    ESTADO_INIT,
    MOSTRAR_HORA,   
    ESTADO_TRANSMITE_HORA_CONFIG,
    ALARME,
    ESTADO_RECEBE_HORA
} Estados;

Estados estado;

//Função main
int main(void)
{
    estado = ESTADO_INIT; 
		char hora,min,seg;
    
    while (1)
    {
        switch(estado)
        {
            case ESTADO_INIT:
              Estado_Init_Func();
              break;
            case ESTADO_TRANSMITE_HORA_CONFIG:
              Estado_Transmite_Hora_Func();  
              break;
            case ESTADO_RECEBE_HORA:
              Estado_Recebe_Hora_Func();  
              break;  
						case MOSTRAR_HORA:
							Limpa_LCD();
							Escreve_LCD(' ');
							Escreve_LCD(':');
							Escreve_LCD(' ');
							Escreve_LCD(':');
							Escreve_LCD(' ');
							Escreve_LCD(' ');
							//Escreve_LCD();
							//Escreve_LCD();
						
							break;
						case ALARME:
							
							break;
						
            default:
              break;
        }
    }
 
}


//
// Outras Funções
//
void Estado_Init_Func(void)
{
   	PLL_Init();
		GPIO_Init();
		SysTick_Init();
    I2c_Init();
    DisplayLCD_Init();
		SysTick_Wait1ms(10);
		Limpa_LCD();
		Escreve_Frase("Relogio_Giovanni","e Anderson");
    estado = ESTADO_TRANSMITE_HORA_CONFIG;
    seg_conf=0x10; min_conf=0x05; hora_conf=0x6; diasem_conf=1; dia_conf=0x09; mes_conf=2; ano_conf=0x18;
}
void Estado_Transmite_Hora_Func(void)
{
   	I2C_Send_Multiple();
    estado = ESTADO_RECEBE_HORA;    
}
void Estado_Recebe_Hora_Func(void)
{
    I2C_Recv_Multiple();
		estado = MOSTRAR_HORA;
}

