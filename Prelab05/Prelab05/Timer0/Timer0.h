/*
 * Timer0.h
 * Created: 4/14/2024 5:50:03 PM
 *  Author: alesa
 */ 

#ifndef TIMER0_H_
#define TIMER0_H_

#include <stdint.h>

//Inicializar Timer 0
void initTimer0(void);

//Realizar el toggle en ADCH con un periodo de 255uS
void manualPWM(uint8_t counter, uint8_t CounterADCH);


#endif /* TIMER0_H_ */