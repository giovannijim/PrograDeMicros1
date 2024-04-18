/*
 * PWM2.h
 * Created: 4/12/2024 5:42:29 PM
 *  Author: Giovanni Jimenez
 */ 


#ifndef PWM2_H_
#define PWM2_H_

#include <avr/io.h>
#include <stdint.h>

#define invertido 1
#define no_invertido 0

// Funcion para configurar PWM2A Fast
void initPWM2FastA(uint8_t inverted, uint16_t prescaler);

// Funcion para actualizar el duty Cycle de PWM2A
void updateDutyCyclePWM2A(uint8_t duty2);



#endif /* PWM2_H_ */