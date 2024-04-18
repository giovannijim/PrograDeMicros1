/*
 * Prelab05.c
 * Created: 4/10/2024 10:15:47 PM
 * Author : Giovanni Jimenez
 */ 

// Incluyendo librerias
#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>
#include "ADC/initADC.h"
#include "PWM1/PWM1.h"
#include "PWM2/PWM2.h"
#include "Timer0/Timer0.h"

// Prototipo de setup
void setup(void);

//Variables
uint8_t contador;
uint8_t varADCH;

int main(void)
{
	
    cli();								// Deshabilitar interrupciones globales
    setup();							// Dirigirse a la subrutina setup
	initPWM1FastA(no_invertido, 1024);	// Se llama la funcion de la libreria y se envian datos
	initPWM2FastA(no_invertido, 1024);	// Se llama la funcion de la libreria y se envian datos
	initTimer0();						// Se llama la funcion de la libreria
    sei();								// Habilitar interrupciones globales
	
    while (1)
    {
	    			
		initADC(5);				// Se comienza la conversion en ADC5
		ADCSRA |= (1<< ADSC);	// Comenzar conversion
		while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
		updateDutyCyclePWM2A(ADCH);		// Se llama la funcion de la libreria
		
		initADC(6);				// Se comienza la conversion en ADC6
	    ADCSRA |= (1<< ADSC);	// Comenzar conversion
	    while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
		updateDutyCyclePWM1A(ADCH);		// Se llama la funcion de la libreria
		
		initADC(7);				// Se comienza la conversion en ADC7
		ADCSRA |= (1<< ADSC);	// Comenzar conversion
		while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
		varADCH = ADCH;			// Guarda el valor de ADCH en la variable varADCH
		manualPWM(contador, varADCH);	// Se llama la funcion de la libreria
    }
}

// Subrutina setup ------------------------------------------------------------
void setup(void){
	// Se apaga tx y rx
	UCSR0B = 0;
	// Establece el contado en 0
	contador = 0;
}

// Vector de interrupcion ADC -------------------------------------------------
ISR(ADC_vect)
{
	// Se escribe con un 1 lógico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}

// Vector de interrupcion TIMER0 -------------------------------------------------
ISR(TIMER0_OVF_vect)
{
	// Aumenta el valor del contador
	contador ++;
	// Se carga el valor inicial
	TCNT0 = 240;
	// Se escribe con un 1 lógico la bandera para apagarla
	TIFR0 |= (1<<TOV0);
}