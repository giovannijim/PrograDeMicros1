; Universidad del Valle de Guatemala
; IE2023: Programacion de microcontroladores
; Proyecto1.asm
; Created: 2/16/2024 5:20:45 PM
; Author : Giovanni Jimenez
; Hardware: ATMEGA328P
//*****************************************************************************
// Encabezado
//*****************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN

.def CntSegUnidades = R18
.def CntSegDecenas = R19
.def CntMinUnidades = R20
.def CntMinDecenas = R21
.def CntHrsUnidades = R22
.def CntHrsDecenas = R23
.def HRS = R24

.org 0x0006     // Vector de ISR_PCINT0
	JMP ISR_PCINT0 
.org 0x0020		// Vector de TIMER0_OVF
	JMP ISR_TIMER0_OVF

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
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z

	LDI R16, (1 << CLKPCE) ; Se coloca un uno en el bit de CLKPCE
	STS CLKPR, R16 ; Se habilita el prescaler

	LDI R16, 0b0000_0011
	STS CLKPR, R16 ; Se define un prescaler de 8, por lo tanto la FCPU = 2MHz

	LDI R16, 0X00
	OUT TCCR0A, R16 ;Se indica al Timer que opere de manera normal

	CALL Init_T0 ; Inicializar Timer 0

	STS UCSR0B, R18		//Desactiva los puertos TX y RX

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

	CLR CntSegDecenas			// Limpia el registro 
	CLR CntSegUnidades			// Limpia el registro 
	CLR CntMinUnidades
	CLR CntMinDecenas
//*****************************************************************************
// LOOP
//*****************************************************************************
LOOP:	

RJMP LOOP
//******************************************************************************
// SUBRUTINA PARA INICIALIZAR TIMER 0
//******************************************************************************
Init_T0:
	LDI R16, (1<< CS02)|(1<<CS00) ; Carga el siguiente byte a R16 0x04
	OUT TCCR0B, R16 ; CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 2MHZ
    LDI R16, 236 ; CARGA VALOR DE DESBORDAMIENTO
	OUT TCNT0, R16 ; CARGA EL VALOR INICIAL DEL CONTADOR
	LDI	R16, (1 << TOIE0)	// Habilita la interrupción del overflow
	STS	TIMSK0, R16
	RET
//******************************************************************************
// SUBRUTINA PARA INICIALIZAR AUMENTAR EL CONTADOR HEXADECIMAL
//******************************************************************************
AUMENTO_UNIDADES_SEGUNDOS:
	CPI CntSegUnidades, 0x0A		// Compara si el contador es 10
	BREQ AUMENTO_DECENAS_SEGUNDOS		// Si el contador es cero salta 
	INC CntSegUnidades				// Incrementa 
	RET
AUMENTO_DECENAS_SEGUNDOS:
	CPI CntSegDecenas, 0x05		// Compara si el contador de decenas es 5
	BREQ AUMENTO_UNIDADES_MINUTOS		// Si el contador es cero salta 
	INC CntSegDecenas				// Incrementa Contador de decenas
	CLR CntSegUnidades				// Limpia el registro 
	RJMP AUMENTO_UNIDADES_SEGUNDOS
AUMENTO_UNIDADES_MINUTOS:
	CLR CntSegDecenas			// Limpia el registro 
	CLR CntSegUnidades			// Limpia el registro 
	INC CntMinUnidades
	CPI CntMinUnidades, 0x0A		// Compara si el contador de unidades es 9
	BREQ AUMENTO_DECENAS_MINUTOS		// Si el contador es cero salta al reset
	RJMP AUMENTO_UNIDADES_SEGUNDOS
AUMENTO_DECENAS_MINUTOS:
	CLR CntMinUnidades			// Limpia el registro 
	INC CntMinDecenas
	CPI CntMinDecenas, 0x05		// Compara si el contador de decenas es 5
	BREQ AUMENTO_UNIDADES_HORAS	// Si el contador es cero salta al reset
	RJMP AUMENTO_UNIDADES_SEGUNDOS
AUMENTO_UNIDADES_HORAS:
	CLR CntMinDecenas			// Limpia el registro 
	CLR CntMinUnidades			// Limpia el registro
	INC HRS 
	CPI HRS, 24
	BREQ RESET_ALL
	INC CntHrsUnidades
	CPI CntHrsUnidades, 0x0A		// Compara si el contador de unidades es 9
	BREQ AUMENTO_DECENAS_HORAS	// Si el contador es cero salta al reset
	RJMP AUMENTO_UNIDADES_SEGUNDOS
AUMENTO_DECENAS_HORAS:
	CLR CntHrsUnidades
	INC CntHrsDecenas
	RJMP AUMENTO_UNIDADES_SEGUNDOS
RESET_ALL:
	CLR CntSegUnidades			// Limpia el registro 
	CLR CntSegDecenas			// Limpia el registro 
	CLR CntMinUnidades			// Limpia el registro
	CLR CntMinDecenas			// Limpia el registro 
	CLR CntHrsUnidades
	CLR CntHrsDecenas
	CLR HRS
	RJMP AUMENTO_UNIDADES_SEGUNDOS
//*****************************************************************************
// Subrutina de ISR_TIMER0_OVF
//*****************************************************************************
ISR_TIMER0_OVF:
	PUSH R17 ; Guardamos en pila el registro R16
	IN R17, SREG
	PUSH R17 ; Guardamos en pila el registro SREG

	LDI R16, 236		; Cargar el valor de desbordamiento
	OUT TCNT0, R16		; Cargar el valor inicial al contador
	SBI TIFR0, TOV0		; Borramos la bandera de TOV0
	INC R27 			; Incrementamos contador de 10 ms
	INC R28				; Incrementamos contador para toggle de display cada 20ms
	INC R29				; Incrementamos contador para toggle de display cada 10ms

SALIR2:
	POP R17				; Obtener el valor de SREG
	OUT SREG, R17		; REstaurar los antiguos vlaores de SREG
	POP R17				; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR
//******************************************************************************
//Tabla de valores
//******************************************************************************
	TABLADOS: .DB 0x20, 0x10
	TABLE: .DB  0xFC, 0xC0, 0x6E, 0xEA, 0xD2, 0xBA, 0xBE, 0xE2, 0xFE, 0xF2, 0xF6, 0x9E, 0x3C, 0xCE, 0x3E, 0x36
//******************************************************************************