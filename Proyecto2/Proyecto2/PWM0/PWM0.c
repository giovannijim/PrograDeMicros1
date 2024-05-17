/*
 * PWM0.c
 * Created: 4/11/2024 10:34:32 AM
 *  Author: Giovanni Jimenez
 */ 

#include <avr/io.h>
#include <stdint.h>

#define invertido 1
#define no_invertido 0

void initPWM0FastA(uint8_t inverted, uint16_t prescaler){
	//Configurando el pin PD6 como salida (OC0A)
	DDRD |= (1<<DDD6);
	
	//TCCR0A = 0;
	//TCCR0B = 0;
	
	if (inverted){
		//Configurando OC0A como invertido
		TCCR0A |= (1<<COM0A1)|(1<<COM0A0);
	}
	else {
		//Configurando OC0A como no invertido
		TCCR0A |= (1<<COM0A1);
	}
	// Configurando modo FAST PWM0 TOP 0XFF
	TCCR0A |= (1<<WGM01)|(1<<WGM00);
	// Configurando prescaler de 1024
	if (prescaler==1024){
		TCCR0B |= (1<<CS02)|(1<<CS00);
	}
	
}

void initPWM0FastB(uint8_t inverted, uint16_t prescaler){
	//Configurando el pin PD5 como salida (OC0B)
	DDRD |= (1<<DDD5);
	
	// TCCR0B = 0;
	
	if (inverted){
		//Configurando OC0A como invertido
		TCCR0A |= (1<<COM0B1)|(1<<COM0B0);
	}
	else {
		//Configurando OC0A como no invertido
		TCCR0A |= (1<<COM0B1);
	}
	// Configurando modo FAST PWM0 TOP 0XFF
	TCCR0A |= (1<<WGM01)|(1<<WGM00);
	// Configurando prescaler de 1024
	if (prescaler==1024){
		TCCR0B |= (1<<CS02)|(1<<CS00);
	}
}

void updateDutyCyclePWM0A(uint8_t duty){
	OCR0A = duty * 0.15 ;
}

void updateDutyCyclePWM0B(uint8_t duty){
	OCR0B = duty * 0.15;
}