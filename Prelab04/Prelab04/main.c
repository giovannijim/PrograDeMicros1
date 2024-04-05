/*
 * Prelab04.c
 * Created: 4/4/2024 10:05:52 AM
 * Author : GIOLESS
 */ 
#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

void setup(void);

int main(void)
{
	cli();
	setup();
	sei();
	while(1)
	{	
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
	
	//Habilitar la interrupción puerto C
	PCICR |= (1<<PCIE1);
	// Habilitar mascara para pines PC5 Y PC4
	PCMSK1 |= 0xFF;
	
}

ISR (PCINT1_vect) 
{
	if(!(PINC&(1<<PINC4)))
	{
		_delay_ms(100);
		PORTD ++;
	}
	else if(!(PINC&(1<<PINC5)))
	{
		_delay_ms(100);
		PORTD --;
	}
	PINB |= (1<<PORTB5);
	PCIFR |= (1<<PCIF1);
}	