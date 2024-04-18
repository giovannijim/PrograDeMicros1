/*
 * PWM2.c
 * Created: 4/12/2024 5:42:43 PM
 *  Author: Giovanni Jimenez
 */ 

// Se incluyen librerias
#include <avr/io.h>
#include <stdint.h>

// Se definen variables
#define invertido 1
#define no_invertido 0

void initPWM2FastA(uint8_t inverted, uint16_t prescaler){
	//Configurando el pin PD6 como salida (OC2A)
	DDRB |= (1<<DDB3);
	
	// Limpiar los registros TCC2A Y TCCR2B
	TCCR2A = 0;
	TCCR2B = 0;
	
	if (inverted){
		//Configurando OC2A como invertido
		TCCR2A |= (1<<COM2A1)|(1<<COM2A0);
	}
	else {
		//Configurando OC2A como no invertido
		TCCR2A |= (1<<COM2A1);
	}
	// Configurando modo FAST PWM2 TOP 0XFF
	TCCR2A |= (1<<WGM21)|(1<<WGM20);
	
	// Configurando prescaler de 1024
	if (prescaler==1024){
		TCCR2B |= (1<<CS22)|(1<<CS21)|(1<<CS20);
	}
	
}

void updateDutyCyclePWM2A(uint8_t duty2){
	// Se carga el valor de OCR2A con un factor de mapeado
	OCR2A = duty2 * 0.15;
}
