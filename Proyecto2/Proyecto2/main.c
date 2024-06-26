/*
 * Proyecto2.c
 * Created: 4/26/2024 5:22:26 PM
 * Hardware: ATMEGA328P
 * Author : Giovanni Jimenez
 */ 
// Definir librer�as
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
#include "EEPROM/EEPROM.h"

//Definir variables
volatile uint8_t  bufferRX;
uint8_t estado;
uint8_t position;
volatile uint8_t memoria1, memoria2, memoria3, memoria4;
uint8_t contador_valor_recibido;
uint8_t v_mapped;
volatile char Rv1, Rv2, Rv3, Rv4;
volatile int digit1, digit2, digit3, digit4;
volatile uint8_t ValueReceived;

// Convertir una variable de tipo Char a una de tipo INT
int CharToInt(char num){return num - '0';}
	
// Convertir 3 digitos en un solo numero 
int MakeOneNumber(int digit1, int digit2, int digit3){return ((digit1*100) + (digit2*10) + digit3);}

void setup(void);

// Blink Leds
void tercer_led(void){
	PORTD |=  (1<<PORTD2);
	_delay_ms(150);
	PORTD &= ~ (1<<PORTD2);
	_delay_ms(150);
}

// Funcion para indicar Posicion con Leds
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
	// Inicializar Modulos UART, Pines y PWMn
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
		// Modo MANUAL --------------------------------------------------------
		if (estado == 0){
			PORTD &= ~(1<<PORTD2);
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
			PORTD |= (1<<PORTD3); }
			else if(position==3){
			PORTD |= (1<<PORTD3)|(1<<PORTD4); }
			
			digit1=CharToInt(Rv1);
			digit2=CharToInt(Rv2);
			digit3=CharToInt(Rv3);
			digit4=CharToInt(Rv4);
			if ((digit1 == 6)){
				if ((digit4==1)){
					estado = 0;
					//SendChain("Mode1\n");
				}
				else if ((digit4==2)){
					estado = 1;
					//SendChain("Mode2\n");
				}
				else if ((digit4==3)){
					estado = 2;
					//SendChain("Mode3\n");
				}
			}
			else if ((digit1 == 7)){
				if ((digit4==1)){
					if(position==0){
						initADC(7);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(0, ADCH);
						initADC(6);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(1, ADCH);
						initADC(5);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(2, ADCH);
						initADC(4);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(3, ADCH);
					}
					else if (position==1){
						initADC(7);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(4, ADCH);
						initADC(6);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(5, ADCH);
						initADC(5);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(6, ADCH);
						initADC(4);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(7, ADCH);
					}
					else if (position==2){
						initADC(7);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(8, ADCH);
						initADC(6);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(9, ADCH);
						initADC(5);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(10, ADCH);
						initADC(4);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(11, ADCH);
					}
					else if (position==3){
						initADC(7);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(12, ADCH);
						initADC(6);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(13, ADCH);
						initADC(5);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(14, ADCH);
						initADC(4);
						ADCSRA |= (1<< ADSC);				// Comenzar conversion
						while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
						EEPROM_write(15, ADCH);
					}
				}
				else{	}
			}
		
		}
		
		// Modo MEMORIA -------------------------------------------------------
		else if ( estado == 1)
		{
			PORTD |=  (1<<PORTD2);
			leds();
			if (position==0)
			{
				memoria1 = EEPROM_read(0) ;
				memoria2 = EEPROM_read(1) ;
				memoria3 = EEPROM_read(2) ;
				memoria4 = EEPROM_read(3) ;
				updateDutyCyclePWM2A(memoria1);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4);			// Actualizar el DutyCycle
			} else if (position==1){
				memoria1 = EEPROM_read(4) ;
				memoria2 = EEPROM_read(5) ;
				memoria3 = EEPROM_read(6) ;
				memoria4 = EEPROM_read(7) ;
				updateDutyCyclePWM2A(memoria1);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4);			// Actualizar el DutyCycle
			} else if (position==2){
				memoria1 = EEPROM_read(8) ;
				memoria2 = EEPROM_read(9) ;
				memoria3 = EEPROM_read(10) ;
				memoria4 = EEPROM_read(11) ;
				updateDutyCyclePWM2A(memoria1);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4);			// Actualizar el DutyCycle
			} else if (position==3){
				memoria1 = EEPROM_read(12) ;
				memoria2 = EEPROM_read(13) ;
				memoria3 = EEPROM_read(14) ;
				memoria4 = EEPROM_read(15) ;
				updateDutyCyclePWM2A(memoria1);			// Actualizar el DutyCycle
				updateDutyCyclePWM1A(memoria2);			// Actualizar el DutyCycle
				updateDutyCyclePWM0A(memoria3);			// Actualizar el DutyCycle
				updateDutyCyclePWM0B(memoria4);			// Actualizar el DutyCycle
			}
			
			// Convertir los digitos de Char a INT
			digit1=CharToInt(Rv1);
			digit2=CharToInt(Rv2);
			digit3=CharToInt(Rv3);
			digit4=CharToInt(Rv4);
			
			// Verificar si el digito 1 = 6 y digito 4 = 1,2 o 3
			if ((digit1 == 6)){
				if ((digit4==1)){
					estado = 0;
				}
				else if ((digit4==2)){
					estado = 1;
				}
				else if ((digit4==3)){
					estado = 2;
				}
			}
			
		}
			
		// MODO UART --------------------------------------------------------
		else if (estado == 2){
			
			tercer_led();
			leds();
			// Convertir las variables de tipo char una de tipo int
			digit1=CharToInt(Rv1); 
			digit2=CharToInt(Rv2);
			digit3=CharToInt(Rv3);
			digit4=CharToInt(Rv4);
			// Convertir los 3 digitos en un solo valor
			ValueReceived = MakeOneNumber(digit2,digit3, digit4);
			
			if (digit1 == 1)
			{
				ValueReceived = map(ValueReceived, 0, 255, 6, 20);
				OCR2A = ValueReceived;
				//updateDutyCyclePWM2A(ValueReceived);
			} else if (digit1 == 2)
			{
				ValueReceived = map(ValueReceived, 0, 255, 6, 22);
				OCR1A = ValueReceived;
				//updateDutyCyclePWM1A(ValueReceived);
			}
			else if (digit1 == 3)
			{
				ValueReceived = map(ValueReceived, 0, 255, 6, 20);
				OCR0A = ValueReceived;
				//updateDutyCyclePWM0A(ValueReceived);
			}
			else if (digit1 == 4)
			{
				ValueReceived = map(ValueReceived, 0, 255, 6, 20);
				OCR0B = ValueReceived;
				//updateDutyCyclePWM0B(ValueReceived);
			} 
			// Verificar si el digito 1 = 5 y digito 4 = 1, 2, 3, o 4
			else if ((digit1 == 5)){
				if ((digit4==1)){
					position = 0;
					SendChain("Pos1\n");
					_delay_ms(300);
					}
				else if ((digit4==2)){
					position = 1;
					SendChain("Pos2\n");
					_delay_ms(300);
					}
				else if ((digit4==3)){
					position = 2;
					SendChain("Pos3\n");
					_delay_ms(300);
					}
				else if ((digit4==4)){
					position = 3;
					SendChain("Pos4\n");
					_delay_ms(300);
					}
			} 
			// Verificar si el digito 1 = 6 y digito 4 = 1, 2 o 3
			else if ((digit1 == 6)){
				if ((digit4==1)){
					estado = 0;
					SendChain("st1\n");
					_delay_ms(300);
				}
				else if ((digit4==2)){
					estado = 1;
					SendChain("st2\n");
					_delay_ms(300);
				}
				else if ((digit4==3)){
					estado = 2;
					SendChain("st3\n");
					_delay_ms(300);
				}
			}
			
		}	
    }
}

void setup(void)
{
	// Asignar valor 0 a las siguientes variables:
	estado = 0;
	position = 0;
	contador_valor_recibido = 0;
	// Establecer es puerto pd2, pd3 y pd4 como salida
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
	// Aumentar dicho contador
	contador_valor_recibido ++;
	
	// Si es la primera recepciton almacenarlo en el Rv1, si es la segunda en Rv2.
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
	if(!(PINC&(1<<PINC3))) // Si PINC3 se encuentra apagado aumentar el contadro estado
	{
		// Si la posicion es < 2 aumentar estado, sino estado = 0
		if(estado < 2){estado ++;}
			else{estado=0; }
	}
	else if(!(PINC&(1<<PINC2))) // Si PINC2 se encuentra apagado aumentar el contador posicion
	{
		// Si la posicion es < 3 aumentar posicion, sino posicion = 0
		if (position < 3){
			position ++;	
		}
		else{
			position = 0;
		}
	}
	else if(!(PINC&(1<<PINC1))) // Si PINC1 se encuentra apagado ejecutar instrucci�n
	{
		if(position==0){
			initADC(7);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(0, ADCH);
			initADC(6);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(1, ADCH);
			initADC(5);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(2, ADCH);
			initADC(4);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(3, ADCH);
			} 
			else if (position==1){
			initADC(7);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(4, ADCH);
			initADC(6);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(5, ADCH);
			initADC(5);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(6, ADCH);
			initADC(4);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(7, ADCH);
			} 
			else if (position==2){
			initADC(7);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(8, ADCH);
			initADC(6);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(9, ADCH);
			initADC(5);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(10, ADCH);
			initADC(4);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(11, ADCH);
			} 
			else if (position==3){
			initADC(7);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(12, ADCH);
			initADC(6);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(13, ADCH);
			initADC(5);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(14, ADCH);
			initADC(4);
			ADCSRA |= (1<< ADSC);				// Comenzar conversion
			while(ADCSRA&(1<<ADSC));			// Revisar si la conversion ya termino
			EEPROM_write(15, ADCH);
		}
		
	}
	
	PCIFR |= (1<<PCIF1); // Apagar la bandera de interrupci�n
}	