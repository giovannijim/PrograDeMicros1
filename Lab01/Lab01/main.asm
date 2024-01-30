;******************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de Microcontroladores 
; lab01.asm
; Autor: Giovanni Jimenez
; Hardware: ATMEGA328P
; 
;******************************************************************************

//****************************************************
// Encabezado 
//****************************************************
.include "M328PDEF.inc"

.cseg
.org 0x00
//****************************************************
//Configuración de la Pila
//****************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17
//****************************************************

//****************************************************
//Configuración MCU
//****************************************************
SETUP:
	LDI R16, 0b1000_0000
	LDI R16, (1 << CLKPCE) ; Se coloca un uno en el bit de CLKPCE
	STS CLKPR, R16 ; Se habilita el prescaler

	LDI R16, 0b0000_0011
	STS CLKPR, R16 ; Se define un prescaler de 8, por lo tanto la FCPU = 2MHz

	;LDI R16, (1 << PC0) ; Configura el pin PC0 como entrada con pullup
	SBI PORTC, PC0 ; Habilita el pullup en el pin PC0
	CBI DDRC, PC0 ; Configuracion PC0 como entrada

	;LDI R16, (1 << PC1) ; Configura el pin PC1 como entrada con pullup
	SBI PORTC, PC1 ; Habilita el pullup en el pin PC1
	CBI DDRC, PC1 ; Configuracion PC1 como entrada

	;LDI R16, (1 << PC5) ; Configura el pin PC5 como entrada con pullup
	SBI PORTC, PC5 ; Habilita el pullup en el pin PC5
	CBI DDRC, PC5 ; Configuracion PC5 como entrada

	;LDI R16, (1 << PC3) ; Configura el pin PC3 como entrada con pullup
	SBI PORTC, PC3 ; Habilita el pullup en el pin PC3
	CBI DDRC, PC3 ; Configuracion PC3como entrada

	;LDI R16, (1 << PC4) ; Configura el pin PC4 como entrada con pullup
	SBI PORTC, PC4 ; Habilita el pullup en el pin PC4
	CBI DDRC, PC4 ; Configuracion PC4 como entrada


	SBI DDRB, PB4	;Definiendo PB4 como salida
	CBI PORTB, PB4	; Colocar 0 en PB4

	SBI DDRB, PB3	;Definiendo PB3 como salida
	CBI PORTB, PB3	; Colocar 0 en PB3

	SBI DDRB, PB2	;Definiendo PB2 como salida
	CBI PORTB, PB2	; Colocar 0 en PB2

	SBI DDRB, PB1	;Definiendo PB1 como salida
	CBI PORTB, PB1	; Colocar 0 en PB1

	SBI DDRB, PB0	;Definiendo PB0 como salida
	CBI PORTB, PB0	; Colocar 0 en PB0

	SBI DDRD, PD7	;Definiendo PD7 como salida
	CBI PORTD, PD7 ; Colocar 0 en PD7

	SBI DDRD, PD6	;Definiendo PD6 como salida
	CBI PORTD, PD6 ; Colocar 0 en PD6

	SBI DDRD, PD5	;Definiendo PD5 como salida
	CBI PORTD, PD5 ; Colocar 0 en PD5

	SBI DDRD, PD4	;Definiendo PD4 como salida
	CBI PORTD, PD4 ; Colocar 0 en PD4

	SBI DDRD, PD3	;Definiendo PD3 como salida
	CBI PORTD, PD3 ; Colocar 0 en PD3

	SBI DDRD, PD2	;Definiendo PD2 como salida
	CBI PORTD, PD2 ; Colocar 0 en PD2

	SBI DDRD, PD0	;Definiendo PD0 como salida
	CBI PORTD, PD0 ; Colocar 0 en PD0

	SBI DDRD, PD1	;Definiendo PD1 como salida
	CBI PORTD, PD1 ; Colocar 0 en PD1

	LDI R31, 0xFF
//****************************************************
//Configuración LOOP
//****************************************************
LOOP: 
	IN R16, PINC
	SBRS R16, PC0
	RJMP DelayBounce

	
	;IN R16, PIND
	;SBRS R16, PD2 ; Salta si el bit PD2 se encuentra en 1

	;RJMP DelayBounce ; Realiza la verificacion de antirrebote

	;SBI PORTB, PB4

	/*SBI PORTB, PB5
	CALL DELAY
	CBI PORTB, PB5
	CALL DELAY*/

	RJMP LOOP
//****************************************************
//Subrutina 
//****************************************************
DelayBounce:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 100
	delay:
		DEC R16
		BRNE delay

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC0 ; Salta si el bit de PD2 esta en 1
	RJMP DelayBounce ; Repite la verificacion de antirrebote si el boton esta aun en 0

	; Realiza el toggle del puerto B5 (led)
	SBI PINB, PB4

	RJMP LOOP

/*Delay: 
	LDI R18, 0
INCR18: 
	INC R18
	CPI R18, 100
	BRNE INCR18
	Ret*/
//****************************************************