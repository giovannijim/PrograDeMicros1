/*
 * UART.c
 * Created: 4/19/2024 10:32:15 AM
 *  Author: Giovanni Jimenez
 */ 

#include <avr/io.h>
#include <stdint.h>

void initUART9600(void){
	
	//Paso 1: RX y TX como salida
	DDRD &= ~(1<<DDD0);
	DDRD |= (1<<DDD1);
	
	//Paso 2:Configurar UCSR0A
	UCSR0A = 0;
	
	//Paso 3: configurar UCSR0B donde se habilita ISR de recepcion y se habilita RX y TX
	UCSR0B = 0;
	UCSR0B |= (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);
	
	//Paso 4: Configurar UCSR0C, asincrono, paridad: none, 1 bit stop, data bits de 8 bits
	UCSR0C = 0;
	UCSR0C |= (1<<UCSZ01) | (1<<UCSZ00);
	
	//Paso 5: COnfigurar velocidad de baudrate a 9600
	UBRR0 = 103;
	
}

void writeUART(char Caracter)
{
	while(!(UCSR0A & (1<<UDRE0)));  //hasta que la bandera este en 1
	UDR0 = Caracter;
	
}