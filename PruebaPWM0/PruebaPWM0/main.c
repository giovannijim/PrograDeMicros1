/*
 * PruebaPWM0.c
 *
 * Created: 5/4/2024 11:48:15 PM
 * Author : GIOLESS
 */ 

// Incluyendo librerias
#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>
#include "ADC/initADC.h"
#include "PWM0/PWM0.h"

// Prototipo de setup
void setup(void);

int main(void)
{
	
	cli();								// Deshabilitar interrupciones globales
	setup();							// Dirigirse a la subrutina setup
	initPWM0FastA(no_invertido, 1024);	// Se llama la funcion de la libreria y se envian datos
	initPWM0FastB(no_invertido, 1024);	// Se llama la funcion de la libreria y se envian datos
	sei();								// Habilitar interrupciones globales
	
	while (1)
	{
		
		initADC(7);				// Se comienza la conversion en ADC5
		ADCSRA |= (1<< ADSC);	// Comenzar conversion
		while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
		updateDutyCycleA(ADCH);		// Se llama la funcion de la libreria
		
 		initADC(6);				// Se comienza la conversion en ADC6
 		ADCSRA |= (1<< ADSC);	// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
 		updateDutyCycleB(ADCH);		// Se llama la funcion de la libreria
		
	}
}

// Subrutina setup ------------------------------------------------------------
void setup(void){
	// Se apaga tx y rx
	UCSR0B = 0;
}

// Vector de interrupcion ADC -------------------------------------------------
ISR(ADC_vect)
{
	// Se escribe con un 1 lógico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}