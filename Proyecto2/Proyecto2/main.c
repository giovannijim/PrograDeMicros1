/*
 * Proyecto2.c
 * Created: 4/26/2024 5:22:26 PM
 * Hardware: ATMEGA328P
 * Author : Giovanni Jimenez
 */ 

#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>
#include "ADC/initADC.h"
#include "PWM0/PWM0.h"
#include "PWM2/PWM2.h"
#include "PWM1/PWM1.h"

uint8_t varADCH;
uint8_t duty;

int main(void)
{
	// Se apaga tx y rx
	UCSR0B = 0;
	duty =0;
	cli();
	initPWM0FastA(no_invertido, 1024);
	initPWM0FastB(no_invertido, 1024);
	initPWM2FastA(no_invertido, 1024);
	initPWM1FastA(no_invertido, 1024);
	sei();
	
    while (1) 
    {

 		//inicializar ADC7
 		initADC(7);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		varADCH = ADCH;
 		updateDutyCyclePWM2A(ADCH);			// Se llama la función de la librería
		

 		//inicializar ADC6
 		initADC(6);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 		updateDutyCyclePWM1A(ADCH);			// Se llama la función de la librería
		
 		//inicializar ADC5
 		initADC(5);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 		updateDutyCyclePWM0A(ADCH);			// Se llama la función de la librería
 		
 		//inicializar ADC4
 		initADC(4);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 		updateDutyCyclePWM0B(ADCH);			// Se llama la función de la librería
    }
}

// Vector de interrupcion ADC -------------------------------------------------
ISR(ADC_vect)
{
	// Se escribe con un 1 lógico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}