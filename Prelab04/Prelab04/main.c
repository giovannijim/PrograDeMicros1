/*
 * Prelab04.c
 *
 * Created: 4/4/2024 10:05:52 AM
 * Author : GIOLESS
 */ 
#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

void setup(void);

char contador;

int main(void)
{
	cli();
	setup();
	sei();
	while(1)
	{
		contador ++;
		PORTD = contador;
		_delay_ms(200);
	}
}

void setup(void)
{
	contador = 0x00;
	// Establecer como salidas puerto B, C y D
	UCSR0B = 0;
	DDRD |= 0xFF;
	PORTD = 0;
	
	//Establecer el puerto C como entrada
	DDRC = 0;
	
	// Establecer con pull up el puerto PC5 Y PC4
	PORTC |= (1<<PORTC4);
	PORTC |= (1<<PORTC5);
	
	
}

ISR (PCINT1_vect) 
{
	
}