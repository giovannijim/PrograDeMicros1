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

volatile uint8_t  bufferRX;
uint8_t estado;
volatile char CharADCH;
uint8_t ADCONvalue;
unsigned char USB_In_Buffer[64];
uint8_t res;

int main(void)
{
	
    DDRB = 0xFF;  // Salida hacia LEDs
    PORTB = 0;	// Apagar el puerto B
	DDRC = 0x03; // Salida de PC0 Y PC1
	PORTC = 0; // Apagar el puerto C
    
    initUART9600();
    
    sei(); //Activar interrupciones
   // writeUART('\n');
    //cadena("HOLA MUNDO");
	
	Menu("\n Que desea realizar? \n 1. Leer Pot \n 2. Enviar ASCII \n 3. Reiniciar \n");
	
    while (1)
    {
		if (estado==1){
		initADC(7);
		ADCSRA |= (1 << ADSC);   //Leer puerto de ADC
		ADCONvalue = ADCH;		// Guardar el valor de ADCH en la variable uint ADCONvalue
		}
		
		else if (estado==2){
		Respuesta(bufferRX);	//Registrar la respuesta proveniente del buffer
		}
		 
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
	 bufferRX = UDR0;

	if (bufferRX == 0x31){
		estado = 1;
		if(ADCONvalue/100 != 0){
			res++;
			USB_In_Buffer[0] = (ADCONvalue / 100) + 0x30;
		}
		if(ADCONvalue/10 != 0){
			res++;
			if(res == 1){
				USB_In_Buffer[0] = (ADCONvalue / 10)%10 + 0x30;
				}else{
				USB_In_Buffer[1] = (ADCONvalue / 10)%10 + 0x30;
			}
		}
		res++;
		if(res == 1){
			USB_In_Buffer[0] = ADCONvalue % 10 + 0x30;
			}else if(res == 2){
			USB_In_Buffer[1] = ADCONvalue % 10 + 0x30;
			}else{
			USB_In_Buffer[2] = ADCONvalue % 10 + 0x30;
		}
		cadena(USB_In_Buffer);
	}
	else if (bufferRX == 0x32) {
		PORTB &= !(1<<PORTB1);
		estado = 2;
		Menu("\n Ingrese el ASCII a enviar \n");
	}
	else if (bufferRX == 0x33) {
		Menu("\n Que desea realizar? \n 1. Leer Pot \n 2. Enviar ASCII \n 3. Reiniciar \n");
	}
	//PORTB = bufferTX;
	//PORTC |= bufferTX>> 6;
	//	while(!(UCSR0A & (1<<UDRE0)));  //hasta que la bandera este en 1
	//UDR0 = bufferTX;	
}