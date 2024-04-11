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

// Prototipos
void setup(void);

int main(void)
{
	
    cli();								// Deshabilitar interrupciones globales
    setup();							// Dirigirse a la subrutina setup
	initADC(6);
	initPWM1FastA(invertido, 1024);
    sei();								// Habilitar interrupciones globales
	
    while (1)
    {
	    _delay_ms(20);					// Delay de 20 ms
	    // Se comienza la conversion en ADC
	    ADCSRA |= (1<< ADSC);
		updateDutyCyclePWM1A(ADCH);
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
