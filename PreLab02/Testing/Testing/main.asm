;******************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de Microcontroladores 
; PreLab02.asm
; Created: 2/2/2024 8:19:37 AM
; Author : Giovanni Jimenez
; Hardware: ATMEGA328P
;******************************************************************************

//******************************************************************************
// Encabezado 
//******************************************************************************
	.include "M328PDEF.inc"

	.cseg
	.org 0x00

//******************************************************************************
//Configuración de la Pila STACK POINTER
//******************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//******************************************************************************

//******************************************************************************
//Configuración MCU
//******************************************************************************
SETUP:
	LDI R16, (1 << CLKPCE) ; Se coloca un uno en el bit de CLKPCE
	STS CLKPR, R16 ; Se habilita el prescaler

	LDI R16, 0b0000_0011
	STS CLKPR, R16 ; Se define un prescaler de 8, por lo tanto la FCPU = 2MHz

	LDI R16, 0X00
	OUT TCCR0A, R16 ;Se indica al Timer que opere de manera normal

	LDI R16, 0xFF
	OUT DDRD, R16		// Se establece el puerto D como salida
	LDI R17, 0x00		
	OUT PORTD, R17		// Se limpia el puerto D, para que se encuentre en 0

	OUT DDRC, R16		// Se establece el puerto C como salida
	OUT PORTC, R17		// Se limpia el puerto C, para que se encuentre en 0

	LDI R16, 0x00
	OUT DDRB, R16			// Se establece el puerto B como entrada 
	LDI R16, (1<<PB4)|(1<<PB3)|(1<<PB2)|(1<<PB1)|(1<<PB0)
	OUT PORTB, R16			// Se colocan pull ups en la entrada del puerto B

	LDI R16, (1<<PB5)		
	OUT DDRB, R16			// Se establece PB5 como salida
	LDI R16, 0x00
	OUT PORTC, R16			// Se limpia el puerto B, para que se encuentre en 0
	STS UCSR0B, R18		//Desactiva los puertos TX y RX

//******************************************************************************

//******************************************************************************
// LOOP PRINCIPAL
//******************************************************************************
LOOP:
	LDI R16, 0xfc
	OUT PORTD, R16

	RJMP LOOP

//******************************************************************************