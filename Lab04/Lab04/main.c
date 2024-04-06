/*
 * Lab04.c
 * Created: 4/5/2024 4:50:09 PM
 * Author : alesa
 */ 
#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>

uint8_t mylist [] = {0xFC, 0xC0, 0x6E, 0xEA, 0xD2, 0xBA, 0xBE, 0xE2, 0xFE, 0xF2, 0xF6, 0x9E, 0x3C, 0xCE, 0x3E, 0x36};
uint8_t pointer1;
uint8_t pointer2;
uint8_t contador;

void initADC(void);

void setup(void);

int main(void)
{	
	cli();
    setup();
	initADC();
	sei();
	
    while (1) 
    {
		_delay_ms(4);
		PORTC &= !(1<<PORTC5);
		PORTC |= (1<<PORTC4);
		PORTD = mylist[pointer1];
		_delay_ms(4);
		PORTC &= !(1<<PORTC4);
		PORTC |= (1<<PORTC5);
		PORTD = mylist[pointer2];
		// Se comienza la conversion en ADC
		ADCSRA |= (1<< ADSC);
		PORTB = contador;
    }
}


void setup(void){
	contador = 0;
	// Se apaga tx y rx
	UCSR0B = 0;
	// Se establece el puerto D como salida
	PORTD = 0x00;
	DDRD |= 0xFF;
	// Se establece el puerto B como salida
	PORTB = 0x00;
	DDRB |= 0xFF;
	// ESTABLECER PORT C4 Y C5 como salida
	DDRC |= (1<<PORTC4)|(1<<PORTC5);
	PORTC = 0 ;
	
	// ESTABLECER PULLUP EN PUERTO C2 Y C3
	PORTC |= (1<<PORTC2)|(1<<PORTC3);
	//ESTABLECER PUERTO C2 Y C3 COMO ENTRADA
	DDRD &= ~(1<<PORTC2)|~(1<<PORTC3);
	
	
	//Habilitar la interrupción puerto C
	PCICR |= (1<<PCIE1);
	// Habilitar mascara para pines PC5 Y PC4
	PCMSK1 |= 0x0C;

}

void initADC(void){
	// Se selecciona el canal 6 ADC
	ADMUX = 0;
	ADMUX |= (1<<MUX2)|(1<<MUX1);
	
	// Se selecciona el voltaje VREF 5V
	ADMUX |= (1<<REFS0);
	ADMUX &= ~(1<<REFS1);
	
	// Se justifica hacia la izquierda la salida del adc
	ADMUX |= (1 << ADLAR);
	
	// Habilitar prescaler de 16M/128 fadc = 125khz
	ADCSRA |= (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
	
	// Activar la interrupcion del ADC
	ADCSRA |= (1<<ADIE);
	
	// Se activa el ADC
	ADCSRA |= (1<< ADEN);
	
}

ISR(ADC_vect)
{
	 
	pointer1 = ADCH & 0x0F;	
	pointer2 = ADCH & 0xF0;
	pointer2 = pointer2 >> 4;
	ADCSRA |= (1<<ADIF);
}

ISR(PCINT1_vect)
{
	if(!(PINC&(1<<PINC2)))
	{
		contador ++;
	}
	else if(!(PINC&(1<<PINC3)))
	{
		contador --;
	}
	PCIFR |= (1<<PCIF1);
}
