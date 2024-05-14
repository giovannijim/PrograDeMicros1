/*
 * initADC.h
 * Created: 4/11/2024 9:58:19 AM
 *  Author: Giovanni Jimenez
 */ 


#ifndef INITADC_H_
#define INITADC_H_

#include <avr/io.h>
#include <stdint.h>

// Funcion para indicar que puerto ADC desea activar 
void initADC(uint8_t puerto);

//Funcion para mapear
long map(long x, long in_min, long in_max, long out_min, long out_max);

#endif /* INITADC_H_ */