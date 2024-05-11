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
#include <avr/eeprom.h>

void setup(void);

volatile uint8_t  bufferRX;
uint8_t estado;
uint8_t position;

uint8_t memoria1;
uint8_t memoria2;
uint8_t memoria3;
uint8_t memoria4;


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
		// Modo MANUAL
		if (estado == 0){
			PORTB &= ~(1<<PORTB5);
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
		
		// Modo MEMORIA
		else if ( estado == 1)
		{
			PORTB |= (1<<PORTB5);
			memoria1 =  eeprom_read_byte((uint8_t*)(0+(4*position)));
			memoria2 =  eeprom_read_byte((uint8_t*)(1+(4*position)));
			memoria3 =  eeprom_read_byte((uint8_t*)(2+(4*position)));
			memoria4 =  eeprom_read_byte((uint8_t*)(3+(4*position)));
			updateDutyCyclePWM2A(memoria1);			// Actualizar el DutyCycle
			updateDutyCyclePWM2B(memoria2);			// Actualizar el DutyCycle
			updateDutyCyclePWM0A(memoria3);			// Actualizar el DutyCycle
			updateDutyCyclePWM0B(memoria4);			// Actualizar el DutyCycle
		}	
		
    }
}

void setup(void)
{
	estado = 0;
	position = 0;
	
	//ESTABLECER PUERTO C1, C2 Y C3 COMO ENTRADA
	DDRC &= ~(1<<PORTC1)|~(1<<PORTC2)|~(1<<PORTC3);
	//Habilitar la interrupci�n puerto C
	PCICR |= (1<<PCIE1);
	// Habilitar mascara para pines PC1 PC2, PC3
	PCMSK1 = 0b00001110;
	
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
	if(!(PINC&(1<<PINC3))) // Si PINC3 se encuentra apagado ejecutar instrucci�n
	{
		if(estado < 2){estado ++;}
			else{estado=0;}
	}
	else if(!(PINC&(1<<PINC2))) // Si PINC3 se encuentra apagado ejecutar instrucci�n
	{
		if(position < 3){position ++;}
			else{position=0;}
	}
	else if(!(PINC&(1<<PINC1))) // Si PINC3 se encuentra apagado ejecutar instrucci�n
	{
		//inicializar ADC7
		initADC(7);
		ADCSRA |= (1<< ADSC);				// Comenzar conversion
		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((unsigned char*)(0+(position*4)), ADCH);

		//inicializar ADC6
		initADC(6);
		ADCSRA |= (1<< ADSC);				// Comenzar conversion
		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((unsigned char*)(1+(position*4)), ADCH);
		
		//inicializar ADC5
		initADC(5);
		ADCSRA |= (1<< ADSC);				// Comenzar conversion
		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((unsigned char*)(2+(position*4)), ADCH);
		
		//inicializar ADC4
		initADC(4);
		ADCSRA |= (1<< ADSC);				// Comenzar conversion
		while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((unsigned char*)(3+(position*4)), ADCH);
	}
	
	PCIFR |= (1<<PCIF1); // Apagar la bandera de interrupci�n
}	