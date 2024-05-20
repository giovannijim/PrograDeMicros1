/*
 * PROBANDO_UNION_UART.c
 *
 * Created: 5/19/2024 11:40:45 AM
 * Author : GIOLESS
 */ 

#include <avr/io.h>
#include "UART/UART.h"
#include <stdint.h>


char Rv1, Rv2, Rv3;

int digit1, digit2, digit3, ValueReceived;

int CharToInt(char num){return num - '0';}

int MakeOneNumber(int digit1, int digit2, int digit3){return ((digit1*100) + (digit2*10) + digit3);}

int main(void)
{

	initUART9600();
	DDRB = 0xFF; 
    DDRC = 0x03;
	PORTB = 0;
	PORTC = 0;

    while (1) 
    {
		Menu("servo1");
		Rv1 = ValorRecibido();
		Rv2 = ValorRecibido();
		Rv3 = ValorRecibido();
		 
		digit1=CharToInt(Rv1);
		digit2=CharToInt(Rv2);
		digit3=CharToInt(Rv3);
		 
		ValueReceived = MakeOneNumber(digit1,digit2, digit3);
		 
		//writeUART(ValueReceived);
		PORTB = ValueReceived;
		PORTC = ValueReceived >> 6;
		
		Menu("servo2");
		Rv1 = ValorRecibido();
		Rv2 = ValorRecibido();
		Rv3 = ValorRecibido();
		
		digit1=CharToInt(Rv1);
		digit2=CharToInt(Rv2);
		digit3=CharToInt(Rv3);
		
		ValueReceived = MakeOneNumber(digit1,digit2, digit3);
		
		//writeUART(ValueReceived);
		PORTB = ValueReceived;
		PORTC = ValueReceived >> 6;
    }
}



