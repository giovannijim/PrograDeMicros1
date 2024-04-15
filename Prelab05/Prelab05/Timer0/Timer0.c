/*
 * Timer0.c
 * Created: 4/14/2024 5:50:17 PM
 *  Author: alesa
 */ 

#include <avr/io.h>
#include <stdint.h>

uint8_t mapeado;

void initTimer0(void){
	DDRD |= (1<<DDD0);						//Configurando PD0 como salida
	TCCR0B |= (1<< CS02)|(1<<CS00) ;		// CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 16MHZ
	TCNT0 = 255;								// CARGA EL VALOR INICIAL DEL CONTADOR
	TIMSK0 |= (1 << TOIE0);						// Habilita la interrupción del overflow en el timer 2
}

void revisar(uint8_t counter, uint8_t CounterADCH){
	
	mapeado = CounterADCH;
	if( counter == 0 ) {
		
		if(!(counter && mapeado)){
			PORTD |= (1<<PORTD0);	
		}
		else if (counter && mapeado) {
			PORTD &= !(1<<PORTD0);
		}
		
	}
	
}
