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
uint16_t  bufferRX;
uint8_t estado;
uint8_t position;
uint8_t ADC_ADA;
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
 			updateDutyCyclePWM2A(ADCH);			// Se llama la función de la librería

 			//inicializar ADC6
 			initADC(6);
 			ADCSRA |= (1<< ADSC);				// Comenzar conversion
 			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 			updateDutyCyclePWM1A(ADCH);			// Se llama la función de la librería
		
 			//inicializar ADC5
 			initADC(5);
 			ADCSRA |= (1<< ADSC);				// Comenzar conversion
 			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 			updateDutyCyclePWM0A(ADCH);			// Se llama la función de la librería
 		
 			//inicializar ADC4
 			initADC(4);
 			ADCSRA |= (1<< ADSC);				// Comenzar conversion
 			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
 			updateDutyCyclePWM0B(ADCH);			// Se llama la función de la librería
			 
			 if (position == 0){
			 PORTD &= ~((1<<PORTD4)|(1<<PORTD3));}
			 else if(position==1){
				 PORTD &= ~(1<<PORTD3);
			 PORTD |= (1<<PORTD4);}
			 else if(position==2){
				 PORTD &= ~(1<<PORTD4);
			 PORTD |= (1<<PORTD3);}
			 else if(position==3){
				 PORTD |= (1<<PORTD3)|(1<<PORTD4);
			 }
		}
		
		// Modo MEMORIA
		else if ( estado == 1)
		{
			
			PORTB |= (1<<PORTB5);
			
			memoria1 = eeprom_read_byte((uint8_t*)(0+(4*position))) ;
			memoria2 = eeprom_read_byte((uint8_t*)(1+(4*position))) ;
			memoria3 = eeprom_read_byte((uint8_t*)(2+(4*position))) ;
			memoria4 = eeprom_read_byte((uint8_t*)(3+(4*position))) ;
			updateDutyCyclePWM2A(memoria1/0.166);			// Actualizar el DutyCycle
			updateDutyCyclePWM1A(memoria2/0.139);			// Actualizar el DutyCycle
			updateDutyCyclePWM0A(memoria3/0.15);			// Actualizar el DutyCycle
			updateDutyCyclePWM0B(memoria4/0.15);			// Actualizar el DutyCycle
			if (position == 0){
				PORTD &= ~((1<<PORTD4)|(1<<PORTD3));}
			else if(position==1){
				PORTD &= ~(1<<PORTD3);
				PORTD |= (1<<PORTD4);}
			else if(position==2){
				PORTD &= ~(1<<PORTD4);
				PORTD |= (1<<PORTD3); }
			else if(position==3){
				PORTD |= (1<<PORTD3)|(1<<PORTD4); }
		}	
		else if (estado == 2){
			
			updateDutyCyclePWM1A(bufferRX);
			
		}
    }
}

void setup(void)
{
	estado = 0;
	position = 0;
	DDRD |= (1<<DDD2)|(1<<DDD3)|(1<<DDD4);
	//ESTABLECER PUERTO C1, C2 Y C3 COMO ENTRADA
	DDRC &= ~((1<<PORTC1)|(1<<PORTC2)|(1<<PORTC3));
	//Habilitar la interrupción puerto C
	PCICR |= (1<<PCIE1);
	// Habilitar mascara para pines PC1 PC2, PC3
	PCMSK1 = 0b00001110;
	
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
	//updateDutyCyclePWM2A(bufferRX);
	writeUART(bufferRX);
	}
	
ISR(PCINT1_vect)
{
	if(!(PINC&(1<<PINC3))) // Si PINC3 se encuentra apagado ejecutar instrucción
	{
		if(estado <= 2){estado ++;}
			else{estado=0; }
	}
	else if(!(PINC&(1<<PINC2))) // Si PINC2 se encuentra apagado ejecutar instrucción
	{
		
		if (position < 3){
			position ++;	
		}
		else{
			position = 0;
		}
	}
	else if(!(PINC&(1<<PINC1))) // Si PINC1 se encuentra apagado ejecutar instrucción
	{
		//inicializar ADC7
		//initADC(7);
		//ADCSRA |= (1<< ADSC);				// Comenzar conversion
		//while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((uint8_t*)(0+(position*4)), OCR2A);

		//inicializar ADC6
		//initADC(6);
		//ADCSRA |= (1<< ADSC);				// Comenzar conversion
		//while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((uint8_t*)(1+(position*4)), OCR1A);
		
		//inicializar ADC5
		//initADC(5);
		//ADCSRA |= (1<< ADSC);				// Comenzar conversion
		//while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((uint8_t*)(2+(position*4)), OCR0A);
		
		//inicializar ADC4
		//initADC(4);
		//ADCSRA |= (1<< ADSC);				// Comenzar conversion
		//while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
		eeprom_write_byte((uint8_t*)(3+(position*4)), OCR0B);
	}
	
	PCIFR |= (1<<PCIF1); // Apagar la bandera de interrupción
}	