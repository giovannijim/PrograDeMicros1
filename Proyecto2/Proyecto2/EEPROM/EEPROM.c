/*
 * EEPROM.c
 * Created: 5/22/2024 9:19:29 AM
 *  Author: GIOLESS
 */ 

#include <avr/io.h>
#include <stdint.h>

uint8_t EEPROM_read(uint16_t uiAdress){
	// Esperar que se complete la escritura anterior
	while (EECR & (1<<EEPE));
	
	// Configurar la dirección de registro
	EEAR = uiAdress;
	
	// Comenzar la lectura leyendo EERE
	
	EECR |= (1<<EERE);
	
	
	// Regresar el dato de la lectura
	
	return EEDR;
}

void EEPROM_write(uint16_t uiAdress, uint8_t ucData){
	// Esperar que se complete la escritura anterior
	while (EECR & (1<<EEPE));
	// Configurar la dirección de registro
	EEAR = uiAdress;
	EEDR = ucData;
	// Escribir 1 logico a EEMPE	
	EECR |= (1<<EEMPE);
	// Comenzar la escritura
	EECR |= (1<<EEPE);
}
