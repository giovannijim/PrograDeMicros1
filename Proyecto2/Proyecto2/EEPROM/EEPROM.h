/*
 * EEPROM.h
 *
 * Created: 5/22/2024 9:19:20 AM
 *  Author: GIOLESS
 */ 


#ifndef EEPROM_H_
#define EEPROM_H_

//Para leer desde la eeprom
uint8_t EEPROM_read(uint16_t uiAdress);

//Para escribir en la eeprom
void EEPROM_write(uint16_t uiAdress, uint8_t ucData);

#endif /* EEPROM_H_ */