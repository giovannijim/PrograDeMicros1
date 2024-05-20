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

volatile uint8_t  bufferRX;
uint8_t estado;
uint8_t position;
uint8_t ADC_ADA;
uint8_t memoria1;
uint8_t memoria2;
uint8_t memoria3;
uint8_t memoria4;
uint8_t contador_valor_recibido;
uint8_t servo_controlado;
char servo_cont;
char Rv1, Rv2, Rv3, Rv4;
int digit1, digit2, digit3, digit4;
uint8_t ValueReceived;

// Convertir una variable de tipo Char a una de tipo INT
int CharToInt(char num){return num - '0';}
	
// Convertir 3 digitos en un solo numero 
int MakeOneNumber(int digit1, int digit2, int digit3){return ((digit1*100) + (digit2*10) + digit3);}

void setup(void);
void save(void){
	// Guardar en su respectiva posicion y espacio de memoria EEPROM cada valor de OCRnA/B
	if(position==0){
		eeprom_write_byte((uint8_t*)0, OCR2A);
		eeprom_write_byte((uint8_t*)1, OCR1A);
		eeprom_write_byte((uint8_t*)2, OCR0A);
		eeprom_write_byte((uint8_t*)3, OCR0B);
	} else if (position==1){
		eeprom_write_byte((uint8_t*)4, OCR2A);
		eeprom_write_byte((uint8_t*)5, OCR1A);
		eeprom_write_byte((uint8_t*)6, OCR0A);
		eeprom_write_byte((uint8_t*)7, OCR0B);
	} else if (position==2){
		eeprom_write_byte((uint8_t*)8, OCR2A);
		eeprom_write_byte((uint8_t*)9, OCR1A);
		eeprom_write_byte((uint8_t*)10, OCR0A);
		eeprom_write_byte((uint8_t*)11, OCR0B);
	} else if (position==3){
		eeprom_write_byte((uint8_t*)12, OCR2A);
		eeprom_write_byte((uint8_t*)13, OCR1A);
		eeprom_write_byte((uint8_t*)14, OCR0A);
		eeprom_write_byte((uint8_t*)15, OCR0B);
	}
}
void tercer_led(void){
	PORTD |=  (1<<PORTD2);
	_delay_ms(50);
	PORTD &= ~ (1<<PORTD2);
	_delay_ms(50);
}
void leds(void){
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

int main(void)
{
	cli();
	initUART9600();
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
			PORTD |=  (1<<PORTD2);
			leds();
			if (position==1)
			{
				memoria1 = eeprom_read_byte((uint8_t*)0) ;
				memoria2 = eeprom_read_byte((uint8_t*)1) ;
				memoria3 = eeprom_read_byte((uint8_t*)2) ;
				memoria4 = eeprom_read_byte((uint8_t*)3) ;
				updateDutyCyclePWM2A(memoria1/0.166);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2/0.139);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3/0.15);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4/0.15);			// Actualizar el DutyCycle
			} else if (position==2){
				memoria1 = eeprom_read_byte((uint8_t*)4) ;
				memoria2 = eeprom_read_byte((uint8_t*)5) ;
				memoria3 = eeprom_read_byte((uint8_t*)6) ;
				memoria4 = eeprom_read_byte((uint8_t*)7) ;
				updateDutyCyclePWM2A(memoria1/0.166);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2/0.139);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3/0.15);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4/0.15);			// Actualizar el DutyCycle
			} else if (position==3){
				memoria1 = eeprom_read_byte((uint8_t*)8) ;
				memoria2 = eeprom_read_byte((uint8_t*)9) ;
				memoria3 = eeprom_read_byte((uint8_t*)10) ;
				memoria4 = eeprom_read_byte((uint8_t*)11) ;
				updateDutyCyclePWM2A(memoria1/0.166);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2/0.139);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3/0.15);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4/0.15);			// Actualizar el DutyCycle
			} else if (position==4){
				memoria1 = eeprom_read_byte((uint8_t*)12) ;
				memoria2 = eeprom_read_byte((uint8_t*)13) ;
				memoria3 = eeprom_read_byte((uint8_t*)14) ;
				memoria4 = eeprom_read_byte((uint8_t*)15) ;
				updateDutyCyclePWM2A(memoria1/0.166);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2/0.139);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3/0.15);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4/0.15);			// Actualizar el DutyCycle
			}
			
			
		}	
		else if (estado == 2){
			tercer_led();
			
			digit1=CharToInt(Rv1);
			digit2=CharToInt(Rv2);
			digit3=CharToInt(Rv3);
			digit4=CharToInt(Rv4);
			ValueReceived = MakeOneNumber(digit2,digit3, digit4);
			ValueReceived = map(ValueReceived, 0, 255, 6, 41);
			
			if (digit1 == 1)
			{
				OCR2A = ValueReceived;
			} else if (digit1 == 2)
			{
				OCR1A = ValueReceived;
			}
			else if (digit1 == 3)
			{
				OCR0A = ValueReceived;
			}
			else if (digit1 == 4)
			{
				OCR0B = ValueReceived;
			}
			
		}
    }
}

void setup(void)
{
	estado = 0;
	servo_controlado = 0;
	position = 0;
	contador_valor_recibido = 0;
	DDRD |= (1<<DDD2)|(1<<DDD3)|(1<<DDD4);
	//ESTABLECER PUERTO C1, C2 Y C3 COMO ENTRADA
	DDRC &= ~((1<<PORTC1)|(1<<PORTC2)|(1<<PORTC3));
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
	contador_valor_recibido ++;
	if(contador_valor_recibido==1){
		Rv1 = UDR0;
	} else if (contador_valor_recibido==2)
	{
		Rv2 = UDR0;
	} else if (contador_valor_recibido == 3){
		Rv3 = UDR0;	
	}
	else {
		Rv4 = UDR0;	
		contador_valor_recibido = 0;
	}
	}
	
ISR(PCINT1_vect)
{
	if(!(PINC&(1<<PINC3))) // Si PINC3 se encuentra apagado ejecutar instrucci�n
	{
		if(estado < 2){estado ++;}
			else{estado=0; }
	}
	else if(!(PINC&(1<<PINC2))) // Si PINC2 se encuentra apagado ejecutar instrucci�n
	{
		
		if (position < 3){
			position ++;	
		}
		else{
			position = 0;
		}
	}
	else if(!(PINC&(1<<PINC1))) // Si PINC1 se encuentra apagado ejecutar instrucci�n
	{
		save();
	}
	
	PCIFR |= (1<<PCIF1); // Apagar la bandera de interrupci�n
}	