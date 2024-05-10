/*
 * Proyecto2.c
 * Created: 4/26/2024 5:22:26 PM
 * Hardware: ATMEGA328P
 * Author : Giovanni Jimenez
 */ 

#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>
#include "ADC/initADC.h"
#include "PWM0/PWM0.h"
#include "PWM2/PWM2.h"
#include "PWM1/PWM1.h"
#include "UART/UART.h"

void setup(void);

volatile uint8_t  bufferRX;

int main(void)
{
	initUART9600();
	cli();
	setup();
	initPWM0FastA(no_invertido, 1024);
	initPWM0FastB(no_invertido, 1024);
	initPWM2FastA(no_invertido, 1024);
	initPWM1FastA(no_invertido, 1024);
	sei();
	
    while (1) 
    {
 		//inicializar ADC7
 		initADC(7);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 		updateDutyCyclePWM2A(ADCH);			// Se llama la funci�n de la librer�a
		

 		//inicializar ADC6
 		initADC(6);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 		updateDutyCyclePWM1A(ADCH);			// Se llama la funci�n de la librer�a
		
 		//inicializar ADC5
 		initADC(5);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 		updateDutyCyclePWM0A(ADCH);			// Se llama la funci�n de la librer�a
 		
 		//inicializar ADC4
 		initADC(4);
 		ADCSRA |= (1<< ADSC);				// Comenzar conversion
 		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 		updateDutyCyclePWM0B(ADCH);			// Se llama la funci�n de la librer�a
    }
}

void setup(void)
{
	//ESTABLECER PUERTO C1, C2 Y C3 COMO ENTRADA
	DDRC &= ~(1<<PORTC1)|~(1<<PORTC2)|~(1<<PORTC3);
	//Habilitar la interrupci�n puerto C
	PCICR |= (1<<PCIE1);
	// Habilitar mascara para pines PC1 PC2, PC3
	PCMSK1 |= 0b00001110;
	
}

// Vector de interrupcion ADC -------------------------------------------------
ISR(ADC_vect)
{
	// Se escribe con un 1 l�gico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}


ISR(USART_RX_vect)
{
	//Se almacena en la variable lo que se recibe de UDR0
	bufferRX = UDR0;
	updateDutyCyclePWM2A(bufferRX);
	}
	
ISR(PCINT1_vect)
{
	if(!(PINC&(1<<PINC2))) // Si PINC2 se encuentra apagado ejecutar instrucci�n
	{
		PORTB |= (1<<PORTB5);
		Menu("LED2\n");
	}
	PCIFR |= (1<<PCIF1); // Apagar la bandera de interrupci�n
}	