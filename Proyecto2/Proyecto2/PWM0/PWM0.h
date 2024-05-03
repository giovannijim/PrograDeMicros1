/*
 * PWM0.h
 * Created: 4/11/2024 10:34:21 AM
 *  Author: Giovanni Jimenez
 */ 

#ifndef PWM0_H_
#define PWM0_H_

#include <avr/io.h>
#include <stdint.h>

#define invertido 1
#define no_invertido 0

// Funcion para configurar PWM0A Fast
void initPWM0FastA(uint8_t inverted, uint16_t prescaler);

// Funcion para configurar PWM0B Fast
void initPWM0FastB(uint8_t inverted, uint16_t prescaler);

// Funcion para actualizar el duty Cycle de PWM0A
void updateDutyCyclePWM0A(uint8_t duty);

// Funcion para actualizar el duty Cycle de PWM0b
void updateDutyCyclePWM0B(uint8_t duty);

#endif /* PWM0_H_ */