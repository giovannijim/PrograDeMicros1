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

// Se establecen las variables y su tipos

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
    
    initUART9600();		// Se inicia UART con un baudrate de 9600
    
    sei(); //Activar interrupciones
	
	Menu("\n Que desea realizar? \n 1. Leer Pot \n 2. Enviar ASCII \n 3. Reiniciar \n"); // Se utiliza la funcion de la libreria para enviar la cadena
	
    while (1)
    {
		//Verificar en que estado se encuentan
		if (estado==1){
		initADC(7);				// Inicializar ADC7
		ADCSRA |= (1 << ADSC);   //Leer puerto de ADC
		ADCONvalue = ADCH;		// Guardar el valor de ADCH en la variable uint ADCONvalue
		}
		else if (estado==2){
		Respuesta(bufferRX);	//Registrar la respuesta proveniente del buffer
		}
		 
	    _delay_ms(10);			// Delay de 10 ms
		
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
	//Se almacena en la variable lo que se recibe de UDR0
	 bufferRX = UDR0;
	// Conversion de ASCII
	if (bufferRX == 0x31){
		estado = 1; // Se establece estado 1
		// Se obtienen las centenas
		if(ADCONvalue/100 != 0){
			res++;
			USB_In_Buffer[0] = (ADCONvalue / 100) + 0x30;
		}
		// Aqui se obtendran las unidades y decenas
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
			USB_In_Buffer[0] = ADCONvalue % 10 + 0x30;		// Se almacenan las unidades
			}else if(res == 2){
			USB_In_Buffer[1] = ADCONvalue % 10 + 0x30;		// Se almacenan las Decenas
			}else{
			USB_In_Buffer[2] = ADCONvalue % 10 + 0x30;		// Se almacenan las Centenas
		}
		cadena(USB_In_Buffer); // Se utiliza la funcion de la libreria para enviar la cadena
	}
	else if (bufferRX == 0x32) {
		estado = 2;			// Se establece estado 2
		Menu("\n Ingrese el ASCII a enviar \n"); // Se utiliza la funcion de la libreria para enviar la cadena
	}
	else if (bufferRX == 0x33) {
		estado = 3;			// Se establece estado 3
		Menu("\n Que desea realizar? \n 1. Leer Pot \n 2. Enviar ASCII \n 3. Reiniciar \n"); // Se utiliza la funcion de la libreria para enviar la cadena
		PORTB = 0x00;	// Se limpia el puerto B
		PORTC = 0x00;	// Se limpia el puerto C
	}
	//PORTB = bufferTX;
	//PORTC |= bufferTX>> 6;
	//	while(!(UCSR0A & (1<<UDRE0)));  //hasta que la bandera este en 1
	//UDR0 = bufferTX;	
}