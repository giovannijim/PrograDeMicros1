/*
 * Lab06.c
 * Created: 4/19/2024 9:02:37 AM
 * Author : Giovanni Jimenez
 */ 

// Se incluyen las librerias a usar
#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include "ADC/initADC.h"
#include "UART/UART.h"

// Prototipos de funciones

volatile uint8_t  bufferTX;

int main(void)
{
    DDRB = 0xFF;  // Salida hacia LEDs
    PORTB = 0;	// Apagar el puerto B
	DDRC = 0x03; // Salida de PC0 Y PC1
	PORTC = 0; // Apagar el puerto C
    
    initUART9600();
    
    sei(); //Activar interrupciones
   // writeUART('\n');
    
    while (1)
    {
		initADC(7);
	    ADCSRA |= (1 << ADSC);   //Leer puerto de ADC
		writeUART(ADCH);
	    _delay_ms(10); 
    }
}

// Vector de interrupcion ADC -------------------------------------------------
ISR(ADC_vect)
{
	// Se escribe con un 1 lógico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}

ISR(USART_RX_vect)
{
	bufferTX = UDR0;
	PORTB = bufferTX;
	PORTC |= bufferTX>> 6;
	//	while(!(UCSR0A & (1<<UDRE0)));  //hasta que la bandera este en 1
	//UDR0 = bufferTX;	
}