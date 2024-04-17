/*
 * Timer0.c
 * Created: 4/14/2024 5:50:17 PM
 *  Author: alesa
 */ 

#include <avr/io.h>
#include <stdint.h>

uint8_t mapeado;

void initTimer0(void){
	DDRD |= (1<<DDD1);						//Configurando PD0 como salida
	PORTD |= (1<<PORTD1);
	TCCR0B |= (1<<CS01) ;		// CONFIGURA EL PRESCALER A 8 PARA UN RELOJ DE 16MHZ
	TCNT0 = 1;								// CARGA EL VALOR INICIAL DEL CONTADOR
	TIMSK0 |= (1 << TOIE0);						// Habilita la interrupción del overflow en el timer 2
}

void revisar(uint8_t counter, uint8_t CounterADCH){
	
	mapeado = CounterADCH;
	if((counter == 0xFF)){
	PORTD |= (1<<PORTD1);	
	}
	else if((counter == CounterADCH)){
		PORTD &= ~(1<<PORTD1);
	}
		
	
}
