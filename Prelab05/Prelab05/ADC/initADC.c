/*
 * initADC.c
 * Created: 4/11/2024 10:00:38 AM
 *  Author: Giovanni Jimenez
 */ 
#include <avr/io.h>
#include <stdint.h>

void initADC(uint8_t puertoADC){
	
	// Se selecciona un canal
	ADMUX = 0;
	if(puertoADC == 5){
		ADMUX |= (1<<MUX3)|(1<<MUX1);
	}	
	else if(puertoADC == 6){
		ADMUX |= (1<<MUX2)|(1<<MUX1);
	} 
	else if(puertoADC == 7){
		ADMUX |= (1<<MUX3)|(1<<MUX2)|(1<<MUX1);
	} 
	
	// Se selecciona el voltaje VREF 5V
	ADMUX |= (1<<REFS0);
	ADMUX &= ~(1<<REFS1);
	// Se justifica hacia la izquierda la salida del adc
	ADMUX |= (1 << ADLAR);
	// Habilitar prescaler de 16M/128 fadc = 125khz
	ADCSRA |= (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
	// Activar la interrupcion del ADC
	ADCSRA |= (1<<ADIE);
	// Se activa el ADC
	ADCSRA |= (1<< ADEN);
}
