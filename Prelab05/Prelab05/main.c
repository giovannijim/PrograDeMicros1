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
#include "PWM2/PWM2.h"
#include "Timer0/Timer0.h"

// Prototipos
void setup(void);

uint8_t contador;

int main(void)
{
	
    cli();								// Deshabilitar interrupciones globales
    setup();							// Dirigirse a la subrutina setup
	initPWM1FastA(no_invertido, 1024);
	initPWM2FastA(no_invertido, 1024);
	initTimer0();
    sei();								// Habilitar interrupciones globales
	
    while (1)
    {
	    			
		initADC(5);		 // Se comienza la conversion en ADC5
		ADCSRA |= (1<< ADSC);
		while(ADCSRA&(1<<ADSC));
		updateDutyCyclePWM2A(ADCH);
		
		//_delay_ms(20);	 // Delay de 20 ms
		initADC(6);		// Se comienza la conversion en ADC6
	    ADCSRA |= (1<< ADSC);
		while(ADCSRA&(1<<ADSC));
		updateDutyCyclePWM1A(ADCH);	
			
		//_delay_ms(20);  // Delay de 20 ms
		initADC(7);		// Se comienza la conversion en ADC7
		ADCSRA |= (1<< ADSC);
		while(ADCSRA&(1<<ADSC));
		contador = 0;
		revisar(contador, ADCH);
		
		/*_delay_us(255);
		PORTD |= (1<<PORTD1);
		_delay_us(254);
		PORTD &= ~(1<<PORTD1);*/
		
    }
}

// Subrutina setup ------------------------------------------------------------
void setup(void){
	// Se apaga tx y rx
	UCSR0B = 0;
	
	DDRD |= (1<<DDD1);
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
	contador ++;
	// Se carga el valor inicial
	TCNT0 = 1;
	// Se escribe con un 1 lógico la bandera para apagarla
	TIFR0 |= (1<<TOV0);
}
