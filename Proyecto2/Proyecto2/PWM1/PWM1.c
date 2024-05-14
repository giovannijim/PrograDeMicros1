/*
 * PWM1.c
 * Created: 4/11/2024 11:11:36 AM
 *  Author: Giovanni Jimenez
 */ 

// Incluyir librerias
#include <avr/io.h>
#include <stdint.h>

// Se definen las variables
#define invertido 1
#define no_invertido 0


void initPWM1FastA(uint8_t inverted, uint16_t prescaler){
	//Configurando el pin PD6 como salida (OC1A)
	DDRB |= (1<<DDB1);
	
	// Se limpian los registros TCCR1A Y TCCR1B
	TCCR1A = 0;
	TCCR1B = 0;
	
	if (inverted){
		//Configurando OC0A como invertido
		TCCR1A |= (1<<COM1A1)|(1<<COM1A0);
	}
	else{
		//Configurando OC0A como no invertido
		TCCR1A |= (1<<COM1A1);
	}
	
	// Configurando modo FAST PWM1 16-bit TOP OCR1A
	//TCCR1A |= (1<<WGM10);
	TCCR1A |= (1<<WGM11);
	TCCR1B |= (1<<WGM12)|(1<<WGM13);
	
	// Configurando prescaler de 1024
	TCCR1B |= (1<<CS12)|(1<<CS10);
	
}

void initPWM1FastB(uint8_t inverted, uint16_t prescaler){
	//Configurando el pin PD6 como salida (OC1B)
	DDRB |= (1<<DDB2);
	
	TCCR1B = 0;
	
	if (inverted){
		//Configurando OC1B como invertido
		TCCR1A |= (1<<COM1B1)|(1<<COM1B0);
	}
	else if (no_invertido) {
		//Configurando OC1B como no invertido
		TCCR1A |= (1<<COM1B1);             
	}
	// Configurando modo FAST PWM1 8-bit TOP 0X00FF
	TCCR1A |= (1<<WGM11)|(1<<WGM10);
	
	// Configurando prescaler de 1024
	if (prescaler==1024){
		TCCR1B |= (1<<CS12)|(1<<CS10);
	}
}

void updateDutyCyclePWM1A(uint8_t duty){
	// Se carga el valor a ICR1, para configurar el periodo
	ICR1H = 0x01;
	ICR1L= 0x58;
	// Se carga el valor de OCR1A
	OCR1A = 0.139 * duty;
}

void updateDutyCyclePWM1b(uint8_t duty){
	//Se carga el valor de OCR1B
	OCR1BH = 0;
	OCR1BL = duty;
}
