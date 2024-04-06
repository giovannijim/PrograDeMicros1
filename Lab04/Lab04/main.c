/*
 * Lab04.c
 * Created: 4/5/2024 4:50:09 PM
 * Author : Giovanni Jimenez
 * Hardware: AtMega328P
 */ 
#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>

// Variables y listas
uint8_t mylist [] = {0xFC, 0xC0, 0x6E, 0xEA, 0xD2, 0xBA, 0xBE, 0xE2, 0xFE, 0xF2, 0xF6, 0x9E, 0x3C, 0xCE, 0x3E, 0x36};
uint8_t pointer1;
uint8_t pointer2;
uint8_t contador;
uint8_t contador_desp;

// Prototipos
void initADC(void);
void setup(void);
void alarma(void);

int main(void)
{	
	cli();
    setup();
	initADC();
	sei();
	
    while (1) 
    {
		// Multiplexacion
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
		contador_desp = contador  >> 6;
		PORTC = PORTC | contador_desp;
		alarma();
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
	// ESTABLECER PORT C0, C1, C4 Y C5 como salida
	DDRC |= (1<<PORTC0)|(1<<PORTC1)|(1<<PORTC4)|(1<<PORTC5);
	PORTC = 0 ;
	// ESTABLECER PULLUP EN PUERTO C2 Y C3
	PORTC |= (1<<PORTC2)|(1<<PORTC3);
	//ESTABLECER PUERTO C2 Y C3 COMO ENTRADA
	DDRD &= ~(1<<PORTC2)|~(1<<PORTC3);
	//Habilitar la interrupci�n puerto C
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
	// Se realiza una selecci�n de los bits que nos importan
	pointer1 = ADCH & 0x0F;	
	pointer2 = ADCH & 0xF0;
	// Se realizar un corrimiento del pointer 2
	pointer2 = pointer2 >> 4;
	// Se escribe con un 1 l�gico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}

ISR(PCINT1_vect)
{
	if(!(PINC&(1<<PINC2))) // Si PINC2 se encuentra apagado ejecutar instrucci�n
	{
		contador ++; // Aumentar el contador
	}
	else if(!(PINC&(1<<PINC3))) // Si PINC3 se encuentra apagado ejecutar instrucci�n
	{
		contador --; // Disminuir el contador
	}
	PCIFR |= (1<<PCIF1); // Apagar la bandera de interrupci�n
}

void alarma(void){
	if( ADCH > contador){
			PORTD |= (1<<PORTD1);
	}
	else {
		PORTD &= ~(1<<PORTD1);
	}
}