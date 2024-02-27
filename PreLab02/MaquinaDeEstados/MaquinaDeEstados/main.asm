
; MaquinaDeEstados.asm


//*****************************************************************************
// Encabezado
//*****************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN

.def MODO = R20
.def ESTADO = R21
.def CONTADOR = R22

.org 0x0006	
	JMP ISR_PCINT0

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
	LDI R16, (1 << CLKPCE) ; Se coloca un uno en el bit de CLKPCE
	STS CLKPR, R16 ; Se habilita el prescaler

	LDI R16, 0b0000_0011
	STS CLKPR, R16 ; Se define un prescaler de 8, por lo tanto la FCPU = 2MHz

	LDI R16, (1<<PD2)|(1<<PD3)
	OUT DDRD, R16

	SBI PORTB, PB0
	CBI DDRB, PB0

	SBI PORTB, PB1
	CBI DDRB, PB1

	CBI PORTB, PB5
	SBI PORTB, PB5

	LDI R16, 0b0000_1111
	OUT DDRC, R16

	CLR R16
	OUT PORTC, R16

	LDI R16, (1 << PCINT0)|(1 << PCINT1)
	STS PCMSK0, R16						;Habilitando PCINT en los pines PCINT0 y PCINT1

	LDI R16, (1 << PCIE0)
	STS PCICR, R16						;Habilitando la ISR PCINT  [7:0]

	SEI
	CLR MODO
	CLR ESTADO
	CLR CONTADOR

LOOP:
	OUT PORTC, CONTADOR
	SBRS ESTADO, 0
	JMP ESTADO0
	JMP ESTADO1

ESTADO0:
	SBI PORTD, PD2
	CBI PORTD, PD3
	JMP LOOP

ESTADO1:
	CBI PORTD, PD2
	SBI PORTD, PD3
	JMP LOOP

RJMP LOOP

ISR_PCINT0:
	PUSH R16		; Guardamos en pila el registro R16
	IN R16, SREG
	PUSH R16		; Guardamos en pila el registro SREG

	SBRS ESTADO, 0 ;ESTADO 0 = 1?
	JMP ESTADO0_ISR
	JMP ESTADO1_ISR


ESTADO0_ISR:
	IN R16, PINB
	SBRS R16, 1			; RB1 = 1? Boton de accion
	INC CONTADOR		; Incrementamos contador
	SBRS R16, 0			; PB0 = 1? Boton de modo
	SBR ESTADO, 1		; Seteamos el bit 0 de estado
	RJMP ISR_POP

ESTADO1_ISR:
	IN R16, PINB
	SBRS R16, 1			; RB1 = 1? Boton de accion
	DEC CONTADOR		; Incrementamos contador
	SBRS R16, 0			; PB0 = 1? Boton de modo
	CBR ESTADO, 1		; Seteamos el bit 0 de estado
	RJMP ISR_POP

	
ISR_POP:
	SBI PCIFR, PCIF0	; Apagar la bandera de ISR PCINT0

	POP R16				; Obtener el valor de SREG
	OUT SREG, R16		; Restaurar los antiguos valores de Sreg
	POP R16				; Obtener el valor de R16
	RETI				; Se retorna de la ISR

