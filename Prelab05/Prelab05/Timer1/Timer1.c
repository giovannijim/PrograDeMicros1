/*
 * Timer1.c
 * Created: 4/14/2024 5:17:40 PM
 *  Author: Giovanni Jimenez
 */ 

#include <avr/io.h>
#include <stdint.h>

uint8_t signal;

void initTimer1(void){
	DDRD |= (1<<DDD0);						//Configurando PD0 como salida
	TCCR1B |= (0<< CS12)|(1<< CS11)|(1<<CS10) ; // CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 16MHZ
	TCNT1 = 0xFFF0;								// CARGA EL VALOR INICIAL DEL CONTADOR
	TIMSK1 |= (1 << TOIE1);						// Habilita la interrupción del overflow en el timer 2
		
}

void reviewTime(uint8_t counter){
	
	if( counter == 0 || counter == 20) {
		PORTD |= (1<<PORTD0);
	} 
	if(counter && ADCH){
		PORTD &= !(1<<PORTD0);
	}
	
}