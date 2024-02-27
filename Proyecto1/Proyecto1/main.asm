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

	SEI ; Se habilitan las interrupciones globales

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
	CLR CntHrsUnidades
	CLR CntHrsDecenas
	LDI CntMinDecenas, 5
	LDI CntMinUnidades, 9
	LDI Hrs, 23
	LDI CntHrsDecenas, 2
	LDI CntHrsUnidades, 3
//*****************************************************************************
// LOOP
//*****************************************************************************
LOOP:	
	/*AUMENTO_U_SEG:
	CPI R28, 1 // Contar si ya llego a 10ms
	BRNE AUMENTO_U_SEG // Salta a dicha subrutina (regresa), si no es igual
	CLR R28 // Limpia el registro 26
	SBI PORTC, PC2 // Activa display de unidades minutos
	CBI PORTC, PC3 // Desactiva display de decenas minutos
	CBI PORTC, PC4 // Activa display de decenas horas 
	CBI PORTC, PC5 // Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	LDI R16, 1
	SUB ZL, R16
	ADD ZL, CntSegUnidades	// Se desplaza el pointer
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D
	
	AUMENTO_D_SEG:
	CLR R16
	MOV R16, R1
	CPI R16, 2 // Contar si ya llego a 20ms
	BRNE AUMENTO_U_MINUTOS // Salta a dicha subrutina (regresa), si no es igual
	CLR R1 // limpia el registro 25
	CBI PORTC, PC2 // Activa display de unidades minutos
	SBI PORTC, PC3 // Desactiva display de decenas minutos
	CBI PORTC, PC4 // Activa display de decenas horas 
	CBI PORTC, PC5 // Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntSegDecenas // Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D
	*/
	AUMENTO_U_MINUTOS:
	CPI R28, 1 // Contar si ya llego a 10ms
	BRNE AUMENTO_D_MINUTOS // Salta a dicha subrutina (regresa), si no es igual
	CLR R28 // Limpia el registro 26
	CLR R1 // Limpia el registro 26
	CLR R2 // Limpia el registro 26
	CLR R3 // Limpia el registro 26
	SBI PORTC, PC2 // Activa display de unidades minutos
	CBI PORTC, PC3 // Desactiva display de decenas minutos
	CBI PORTC, PC4 // Activa display de decenas horas 
	CBI PORTC, PC5 // Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntMinUnidades	// Se desplaza el pointer
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D
	
	AUMENTO_D_MINUTOS:
	MOV R16, R1
	CPI R16, 1 // Contar si ya llego a 20ms
	BRNE AUMENTO_U_HORAS // Salta a dicha subrutina (regresa), si no es igual
	CLR R28 // Limpia el registro 26
	CLR R1 // Limpia el registro 26
	CLR R2 // Limpia el registro 26
	CLR R3 // Limpia el registro 26
	CBI PORTC, PC2 // Activa display de unidades minutos
	SBI PORTC, PC3 // Desactiva display de decenas minutos
	CBI PORTC, PC4 // Activa display de decenas horas 
	CBI PORTC, PC5 // Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntMinDecenas // Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D

	AUMENTO_U_HORAS:
	MOV R16, R2
	CPI R16, 1 // Contar si ya llego a 10ms
	BRNE AUMENTO_D_HORAS // Salta a dicha subrutina (regresa), si no es igual
	CLR R28 // Limpia el registro 26
	CLR R1 // Limpia el registro 26
	CLR R2 // Limpia el registro 26
	CLR R3 // Limpia el registro 26
	CBI PORTC, PC2 // Activa display de unidades minutos
	CBI PORTC, PC3 // Desactiva display de decenas minutos
	CBI PORTC, PC4 // Activa display de decenas horas 
	SBI PORTC, PC5 // Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntHrsUnidades	// Se desplaza el pointer
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D
	
	AUMENTO_D_HORAS:
	MOV R16, R3
	CPI R16, 1 // Contar si ya llego a 10ms
	BRNE AUMENTO // Salta a dicha subrutina (regresa), si no es igual
	CLR R28 // Limpia el registro 26
	CLR R1 // Limpia el registro 26
	CLR R2 // Limpia el registro 26
	CLR R3 // Limpia el registro 26
	CBI PORTC, PC2 // Activa display de unidades minutos
	CBI PORTC, PC3 // Desactiva display de decenas minutos
	SBI PORTC, PC4 // Activa display de decenas horas 
	CBI PORTC, PC5 // Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	ADD ZL, CntHrsDecenas // Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D
	
	AUMENTO:
	CPI R27, 100 ; Compara si ya llego a los 100 ms
	BRNE LOOP ; Sino ha llegado enviar a loop
	CLR R27 ; Se limpia el registro r21 0x00
	CALL AUMENTO_UNIDADES_SEGUNDOS ; Salta a la subrutina para aumentar

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
	CPI CntMinDecenas, 0x05		// Compara si el contador de decenas es 5
	BREQ AUMENTO_UNIDADES_HORAS	// Si el contador es cero salta al reset
	INC CntMinDecenas
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
	INC R1				; Incrementamos contador para toggle de display cada 10ms
	INC R2				; Incrementamos contador para toggle de display cada 10ms
	INC R3				; Incrementamos contador para toggle de display cada 10ms

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