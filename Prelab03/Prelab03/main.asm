; Universidad del Valle de Guatemala
; IE2023: PROGRAMACION DE MICROCONTROLADORES
; Prelab03.asm
; Created: 2/8/2024 4:14:01 PM
; Author : Giovanni Jimenez
; HARDWARE: ATMEGA328P
//*****************************************************************************
// Encabezado
//*****************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN
.org 0x0006     // Vector de ISR_INT0
	JMP ISR_PCINT0 
//.org 0x0008		// Vector de ISR_INT1
	//JMP ISR_INT1

MAIN:
//*****************************************************************************
// Stack
//*****************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//*****************************************************************************
// Configuracion
//*****************************************************************************
Setup:
	LDI R16, (1<<PC0)|(1<<PC1)|(1<<PC2)|(1<<PC3)
	OUT DDRC, R16 ; Establecer los bits PC0, PC1, PC2, PC3 como salidas
	LDI R16, 0x00
	OUT PORTC, R16 ; Apagar los pines

	LDI R16, (0<<PB4)|(0<<PB3)
	OUT DDRB, R16  ; Se establecen los pines PB4 Y PB3 como entradas
	LDI R16, (1<<PB4)|(1<<PB3)
	OUT PORTB, R16 ; Se les configura Pull-up a dichas entradas

	SBI DDRB, PB5 ; PB5 como salida
	CBI PORTB, PB5 ; Apagar PB5

	LDI R16, (1<<PCINT4)|(1<<PCINT3)
	STS PCMSK0, R16 ; Habilitando PCINT en los pines PCINT4 Y PCINT3

	LDI R16, (1<<PCIE0)
	STS PCICR, R16 ; Habilitando la ISR PCINT[7:0]

	SEI ; Se habilitan las interrupciones globales

	LDI R20, 0x00 ; Contador en 0
//*****************************************************************************
// LOOP
//*****************************************************************************
Loop:
	OUT PORTC, R20

	RJMP LOOP
//*****************************************************************************
// Subrutina de ISR INT0
//*****************************************************************************
ISR_PCINT0:
	PUSH R16 ; Guardamos en pila el registro R16
	IN R16, SREG
	PUSH R16 ; Guardamos en pila el registro SREG

	IN R18, PINB // Obtiene los valores de pinb, se almacenan en el registro R18

	SBRS R18, PB3 // Revisa si PB3 esta presionado
	RJMP CHECKPB2 // Si est� presionado, se dirige a la otra subrutina
	
	SBRS R18, PB4 // Revisa si PB4 esta presionado
	RJMP CHECKPB1  // Si est� presionado, se dirige a la otra subrutina
	
	JMP SALIR // Realiza un salto a la subrutina de salida

CHECKPB1:
	LDI R19, 255
	delay:
		DEC R19
		BRNE delay
	DEC R20 // Decrementa 1 en el valor del registro R20
	CPI R20, 0x00 // Compara si ya llego a 0 el registro 20
	BRNE SALIR // Si no son iguales se dirige a la subrutina de salida
	LDI R20, 0x00 // Carga el valor 0 en R20 en caso sean iguales

CHECKPB2:
	LDI R19, 255
	delay1:
		DEC R19
		BRNE delay1
	INC R20 // Incrementa 1 en el valor del registro R20
	CPI R20, 0x10 // Compara si ya llego a 16 el registro 20
	BRNE SALIR  // Si no son iguales se dirige a la subrutina de salida
	LDI R20, 0x0F // Carga el valor 00 en R20 en caso sean iguales

SALIR:
	SBI PINB, PB5 ; Toggle Pb5
	SBI PCIFR, PCIF0 ; Apagar la bandera de ISR PCINT0

	POP R16				; Obtener el valor de SREG
	OUT SREG, R16		; REstaurar los antiguos vlaores de SREG
	POP R16				; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR
//******************************************************************************