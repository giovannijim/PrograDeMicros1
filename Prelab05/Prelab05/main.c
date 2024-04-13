/*
 * Prelab05.c
 * Created: 4/10/2024 10:15:47 PM
 * Author : Giovanni Jimenez
 */ 

#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>

#include "ADC/initADC.h"
#include "PWM1/PWM1.h"

uint8_t varad;

// Prototipos
void setup(void);

int main(void)
{
	
    cli();								// Deshabilitar interrupciones globales
    setup();							// Dirigirse a la subrutina setup
	
	initPWM1FastA(invertido, 1024);
	initPWM2FastA(no_invertido, 1024);
    sei();								// Habilitar interrupciones globales
	
    while (1)
    {
	    _delay_ms(20);					// Delay de 20 ms
	    // Se comienza la conversion en ADC
		initADC(6);
	    ADCSRA |= (1<< ADSC);
		while(ADCSRA&(1<<ADSC));
		updateDutyCyclePWM1A(ADCH);	
		initADC(5);
		ADCSRA |= (1<< ADSC);
		varad ++;
		while(ADCSRA&(1<<ADSC));
		updateDutyCyclePWM2A(ADCH);
    }
}

// Subrutina setup ------------------------------------------------------------
void setup(void){
	// Se apaga tx y rx
	UCSR0B = 0;
	varad =0;
}

// Vector de interrupcion ADC -------------------------------------------------
ISR(ADC_vect)
{
	// Se escribe con un 1 lógico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}
