/*
 * Timer0.c
 * Created: 4/14/2024 5:50:17 PM
 *  Author: Giovanni Jimenez
 */ 

//Se incluyen librerias
#include <avr/io.h>
#include <stdint.h>

void initTimer0(void){
	DDRD |= (1<<DDD1);						// Configurando PD1 como salida
	PORTD |= (1<<PORTD1);					// Se apaga el puertoD1
	TCCR0B |= (1<<CS01) ;					// CONFIGURA EL PRESCALER A 8 PARA UN RELOJ DE 16MHZ
	TCNT0 = 240;							// CARGA EL VALOR INICIAL DEL CONTADOR
	TIMSK0 |= (1 << TOIE0);					// Habilita la interrupción del overflow en el timer 0
}

void manualPWM(uint8_t counter, uint8_t CounterADCH){
	// Verificar si el contador es mayor al valor ADCH, si si apagar el puertoD1
	if((counter >= CounterADCH)){
		PORTD &= ~(1<<PORTD1);
		
	}
	// De lo contrario, prender el puertoD1
	else {
		PORTD |= (1<<PORTD1);
	}
		
}
