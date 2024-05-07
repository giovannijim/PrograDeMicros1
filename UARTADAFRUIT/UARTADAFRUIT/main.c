/*
 * UARTADAFRUIT.c
 *
 * Created: 5/7/2024 9:27:50 AM
 * Author : GIOLESS
 */ 

#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>
#include "UART/UART.h"

volatile uint8_t  bufferRX;
uint8_t estado;

int main(void)
{
	cli();
	DDRB |= (1<<DDB5);
	DDRC |= (1<<DDC0);
	//ESTABLECER PUERTO C2 Y C3 COMO ENTRADA
	DDRC &= ~(1<<PORTC2);
	//Habilitar la interrupción puerto C
	PCICR |= (1<<PCIE1);
	// Habilitar mascara para pines PC2
	PCMSK1 |= 0x04;
	sei();
	initUART9600();
    /* Replace with your application code */
    while (1) 
    {
		
	}
}

ISR(PCINT1_vect)
{
	if(!(PINC&(1<<PINC2))) // Si PINC2 se encuentra apagado ejecutar instrucción
	{
		PORTB |= (1<<PORTB5);
		Menu("LED2\n");
	}
	PCIFR |= (1<<PCIF1); // Apagar la bandera de interrupción
}

ISR(USART_RX_vect)
{
	//Se almacena en la variable lo que se recibe de UDR0
	bufferRX = UDR0;
	 if (bufferRX == 0x30) {
		estado = 0;			// Se establece estado 0
		PORTC &= ~(1<<PORTC0);
		PORTB &= ~(1<<PORTB5);
		Menu("APAGAR\n");
	}
	// Conversion de ASCII
	else if (bufferRX == 0x31){
		estado = 1; // Se establece estado 1
		PORTC |= (1<<PORTC0);
		Menu("LED1\n");
	}
	
	else if (bufferRX == 0x32) {
		estado = 2;			// Se establece estado 3
		PORTB |= (1<<PORTB5);
		Menu("LED2\n");
	}
}