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
	JMP ISR_INT0 
.org 0x0008		// Vector de ISR_INT1
	JMP ISR_INT1

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
Setup