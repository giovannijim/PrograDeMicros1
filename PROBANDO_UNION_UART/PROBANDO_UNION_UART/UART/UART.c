/*
 * UART.c
 * Created: 4/19/2024 10:32:15 AM
 *  Author: Giovanni Jimenez
 */ 
#define F_CPU 16000000
#include <util/delay.h>
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
	while(!(UCSR0A & (1<<UDRE0)));  // hasta que la bandera este en 1
	UDR0 = Caracter;				// Enviar el caracter al arduino
	
}

void cadena (unsigned char* texto){
	uint8_t i;
	// Se realiza un ciclo for para recorrer la cadena
	for(i=0; texto[i]!='\0'; i++){
		while(!(UCSR0A & (1<<UDRE0)));  //hasta que la bandera este en 1
		UDR0 = texto[i];				// Enviando caracter por caracter
	}
	
}

void Menu (char* text){
	// Se realiza un ciclo for para recorrer la cadena
	uint8_t i;
	for(i=0; text[i]!='\0'; i++){
		while(!(UCSR0A & (1<<UDRE0)));  //hasta que la bandera este en 1
		UDR0 = text[i];					 // Enviando caracter por caracter
	}
	
}

void Respuesta (uint8_t response){
	// Se carga el valor del ASCII dentro de los respectivos puesrtos
	PORTB = response;
	PORTC |= response>> 6;
}

uint8_t ValorRecibido(void){
	while (!(UCSR0A & (1 << RXC0)));
	return UDR0;
}

