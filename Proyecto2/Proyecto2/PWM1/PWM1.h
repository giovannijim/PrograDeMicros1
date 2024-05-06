/*
 * PWM1.h
 *
 * Created: 4/11/2024 11:11:15 AM
 *  Author: GIOLESS
 */ 


#ifndef PWM1_H_
#define PWM1_H_

#define invertido 1
#define no_invertido 0

// Funcion para configurar PWM1A Fast
void initPWM1FastA(uint8_t inverted, uint16_t prescaler);

// Funcion para configurar PWM1B Fast
void initPWM1FastB(uint8_t inverted, uint16_t prescaler);

// Funcion para actualizar el duty Cycle de PWM1A
void updateDutyCyclePWM1A(uint16_t duty);

// Funcion para actualizar el duty Cycle de PWM1b
void updateDutyCyclePWM1B(uint16_t duty);


#endif /* PWM1_H_ */