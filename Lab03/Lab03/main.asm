; Universidad del Valle de Guatemala
; IE2023: PROGRAMACION DE MICROCONTROLADORES
; Prelab03.asm
; Created: 2/9/2024 4:45:10 PM
; Author : Giovanni Jimenez
; HARDWARE: ATMEGA328P
//*****************************************************************************
// Encabezado
//*****************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN
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
Setup:
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	MOV R23, ZL // Se hace una copia del valor en el registro ZL al registro R23

	LDI R16, (1 << CLKPCE) ; Se coloca un uno en el bit de CLKPCE
	STS CLKPR, R16 ; Se habilita el prescaler

	LDI R16, 0b0000_0011
	STS CLKPR, R16 ; Se define un prescaler de 8, por lo tanto la FCPU = 2MHz

	LDI R16, 0X00
	OUT TCCR0A, R16 ;Se indica al Timer que opere de manera normal

	CALL Init_T0 ; Inicializar Timer 0

	LDI R16, (1<<PC0)|(1<<PC1)|(1<<PC2)|(1<<PC3)
	OUT DDRC, R16 ; Establecer los bits PC0, PC1, PC2, PC3 como salidas
	LDI R16, 0x00
	OUT PORTC, R16 ; Apagar los pines

	LDI	R16, 0xFF // Establece todo el puerto D como salida
	OUT	DDRD, R16 // carga el registro 16 en puerto DDRD

	LDI R16, (0<<PB4)|(0<<PB3)
	OUT DDRB, R16  ; Se establecen los pines PB4 Y PB3 como entradas
	LDI R16, (1<<PB4)|(1<<PB3)
	OUT PORTB, R16 ; Se les configura Pull-up a dichas entradas

	LDI R16, (1<<PB5)|(1<<PB2)|(1<<PB1)
	OUT DDRB, R16 // Se establece como salida PB5, PB2, PB1
	CBI PORTB, PB5 ; Apagar PB5
	//CBI PORTB, PB2 ; Apagar PB2 // UNIDADES
	//CBI PORTB, PB1 ; APAGAR PB1 // DECADAS
	
	LDI R16, (1<<PCINT4)|(1<<PCINT3)
	STS PCMSK0, R16 ; Habilitando PCINT en los pines PCINT4 Y PCINT3

	LDI R16, (1<<PCIE0)
	STS PCICR, R16 ; Habilitando la ISR PCINT[7:0]

	SEI ; Se habilitan las interrupciones globales
	
	LDI R24, 0x00 ; Contador en 0, UNIDADES
	LDI R20, 0x00 ; Contador en 0, BITS, LEDS
	LDI R21, 0x00 ; Contador en 0, C. DE 1 S

	LDI R17, 0xFC // Carga el digito 0 en los displays
	OUT PORTD, R17 // Carga el registro hacia el portD
	
	STS UCSR0B, R18 //Desactiva los puertos TX y RX

	LDI R17, 0x00 // Contador en 0
	SBI PORTB, PB1 //decenas
	CBI PORTB, PB2 //unidades
//*****************************************************************************
// LOOP
//*****************************************************************************
Loop:		
	OUT PORTC, R20 // Carga el valor de R20 a PortC

	AUMENTO_UNIDADES:
	CPI R26, 1 // Contar si ya llego a 10ms
	BRNE AUMENTO_UNIDADES // Salta a dicha subrutina (regresa), si no es igual
	CLR R26 // Limpia el registro 26
	CBI PORTB, PB1 // Desactiva display de decenas
	SBI PORTB, PB2 // Activa display de unidades
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	LDI R16, 1 //Se carga 1 en el registro 16
	SUB ZL, R16 // A zl se le resta 1
	ADD ZL, R24	// Se desplaza el pointer
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D

	AUMENTO_DECENAS:
	CPI R25, 2 // Contar si ya llego a 20ms
	BRNE AUMENTO // Salta a dicha subrutina (regresa), si no es igual
	CLR R25 // limpia el registro 25
	SBI PORTB, PB1 // Activa display de decenas
	CBI PORTB, PB2 // Desactiva display de unidades
	LDI ZL, LOW(TABLE << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1) // Se obtiene la dirección más significativa del registro Z
	ADD ZL, R17 // Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D

	AUMENTO:
	CPI R21, 100 ; Compara si ya llego a los 1000 ms
	BRNE LOOP ; Sino ha lelgado enviar a Check b1
	CLR R21 ; Se limpia el registro r21 0x00
	CALL AUMENTO_HEX ; Salta a la subrutina para aumentar

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
AUMENTO_HEX:
	CPI R24, 0x0A		// Compara si el contador es 10
	BREQ RESET_HEX		// Si el contador es cero salta al reset
	INC R24				// Incrementa R24
	RET
RESET_HEX:	
	CPI R17, 0x05		// Compara si el contador es 10
	BREQ RESET_BOTH		// Si el contador es cero salta al reset
	INC R17				// Incrementa Contador de decenas
	CLR R24				// Limpia el registro 24
	RJMP AUMENTO_HEX
RESET_BOTH:
	CLR R17				// Limpia el registro 17
	CLR R24				// Limpia el registro 24
	RJMP AUMENTO_HEX
//*****************************************************************************
// Subrutina de ISR INT0
//*****************************************************************************
ISR_PCINT0:
	PUSH R16 ; Guardamos en pila el registro R16
	IN R16, SREG
	PUSH R16 ; Guardamos en pila el registro SREG

	IN R18, PINB // Obtiene los valores de pinb, se almacenan en el registro R18
	/*
	Inicio:
	SBRC R18, PB3
	RJMP CHECKPB4
	DEC R20
	RJMP SALIR

	CHECKPB4:
	IN R18, PINB 
	SBRC R18, PB4
	RJMP SALIR
	INC R20
	RJMP SALIR
	*/

	SBRS R18, PB3	// Revisa si PB3 esta presionado
	RJMP CHECKPB2	// Si está presionado, se dirige a la otra subrutina
	
	SBRS R18, PB4	// Revisa si PB4 esta presionado
	RJMP CHECKPB1	// Si está presionado, se dirige a la otra subrutina
	
	JMP SALIR		// Realiza un salto a la subrutina de salida

CHECKPB1:
	LDI R19, 255
	delay1:
		DEC R19
		BRNE delay1
	DEC R20			// Decrementa 1 en el valor del registro R20
	BRNE SALIR		// Si no son iguales se dirige a la subrutina de salida

CHECKPB2:
	LDI R19, 255
	delay2:
		DEC R19
		BRNE delay2
	INC R20				// Incrementa 1 en el valor del registro R20
	CPI R20, 0x10		// Compara si ya llego a 16 el registro 20
	BRNE SALIR			// Si no son iguales se dirige a la subrutina de salida
	LDI R20, 0x0F		// Carga el valor 00 en R20 en caso sean iguales

SALIR:
	SBI PINB, PB5 ; Toggle Pb5
	SBI PCIFR, PCIF0 ; Apagar la bandera de ISR PCINT0

	POP R16				; Obtener el valor de SREG
	OUT SREG, R16		; REstaurar los antiguos vlaores de SREG
	POP R16				; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR
//*****************************************************************************
// Subrutina de ISR_TIMER0_OVF
//*****************************************************************************
ISR_TIMER0_OVF:
	PUSH R22 ; Guardamos en pila el registro R16
	IN R22, SREG
	PUSH R22 ; Guardamos en pila el registro SREG

	LDI R16, 236		; Cargar el valor de desbordamiento
	OUT TCNT0, R16		; Cargar el valor inicial al contador
	SBI TIFR0, TOV0		; Borramos la bandera de TOV0
	INC R21				; Incrementamos contador de 10 ms
	INC R25				; Incrementamos contador para toggle de display cada 20ms
	INC R26				; Incrementamos contador para toggle de display cada 10ms

SALIR2:
	POP R22				; Obtener el valor de SREG
	OUT SREG, R22		; REstaurar los antiguos vlaores de SREG
	POP R22				; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR
//******************************************************************************
//******************************************************************************
//Tabla de valores
//******************************************************************************
	TABLADOS: .DB 0x20, 0x10
	TABLE: .DB  0xFC, 0xC0, 0x6E, 0xEA, 0xD2, 0xBA, 0xBE, 0xE2, 0xFE, 0xF2, 0xF6, 0x9E, 0x3C, 0xCE, 0x3E, 0x36
//******************************************************************************