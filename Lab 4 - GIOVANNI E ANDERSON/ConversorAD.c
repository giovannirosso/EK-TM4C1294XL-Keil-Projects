// ConversorAD.c
// Desenvolvido para a placa EK-TM4C1294XL
// Giovanni de Rosso Unruh
// Anderson Kmetiuk

#include <stdint.h>
#include <string.h>
#include "tm4c1294ncpdt.h"

void ConversorAD_Init(void)
{
	// Ativar o clock para a porta setando o bit correspondente no registrador RCGCADC
	SYSCTL_RCGCADC_R = SYSCTL_RCGCADC_R0;
	// Após isso verificar no PRADC se a porta está pronta para uso.
  while((SYSCTL_PRADC_R & SYSCTL_RCGCADC_R0 ) != SYSCTL_RCGCADC_R0 ){};
	
	ADC0_PC_R =  0x07;
	ADC0_ACTSS_R &= ~0x00000800;
	ADC0_EMUX_R &= 0x0FFF;
	ADC0_SSMUX3_R = 0x9;
	ADC0_SSCTL3_R = 0x0006;
	ADC0_ACTSS_R = 0x0008;
}

uint16_t Converte(void)
{
	uint16_t temp = 0x0FFF;
	ADC0_PSSI_R=0x0008;
	while((ADC0_RIS_R & 0x08)!=0x08){}
	temp &= ADC0_SSFIFO3_R;
	ADC0_ISC_R = 0x08;
	return temp;
}
