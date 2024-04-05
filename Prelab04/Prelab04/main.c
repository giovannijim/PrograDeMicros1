/*
 * Prelab04.c
 *
 * Created: 4/4/2024 10:05:52 AM
 * Author : GIOLESS
 */ 
#define F_CPU = 16000000
#include <avr/io.h>


int main(void)
{
    DDRD |= 0xFF;
    PORTD = 0;
    DDRC |= 0xFF;
    PORTC = 0;
    DDRB |= 0xFF;
    PORTB = 0;

    DDRB &= ~(1<<PB1)
    DDRB &= ~(1<<PB0)
    while (1) 
    {
    }
}

