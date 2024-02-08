; LAB02.asm
; Created: 2/2/2024 5:29:14 PM
; Author : Giovanni Jimenez
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
// CONFIGURACION
//******************************************************************************
MAIN:
	LDI ZL, LOW(table << 1) // Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(table << 1) // Se obtiene la dirección más significativa del registro Z
	MOV R23, ZL // Se hace una copia del valor en el registro ZL al registro R23
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

	CALL Init_T0 ; Inicializar Timer 0

	LDI R20, 0x00 // Carga cero en el registro R20

	LDI R16, (1<<PC0)|(1<<PC1)|(1<<PC2)|(1<<PC3) // Se definen dichos bits como salidas 
	OUT DDRC, R16 // se cargan los bits seteado para establecerlos como salidas
	CLR R16 // Limpia el registro R16
	OUT PORTC, R16 // Carga el registro vación en portc, para establecerlos en 0

	LDI R16, (0<<PB4)|(0<<PB3) // Se definen dichos bits como entradas 
	OUT DDRB, R16 // se cargan los bits en 0 para establecerlos como entradas
	LDI R16, (1<<PB4)|(1<<PB3) // Se definen dichos bits con pullups 
	OUT PORTB, R16 // se cargan los bits en 1 para establecerlos con pullups

	SBI DDRB, PB5	;Definiendo PB5 como salida
	CBI PORTB, PB5	; Colocar 0 en PB5

	LDI R16, 0xFF // Carga un byte seteado, en el registro R16
	OUT DDRD, R16 // Carga el registro R16 en DDRD, para que estos sean salidas
	LPM R16, Z // Carga inicialmente el valor que contiene la dirección Z en R16
	OUT PORTD, R16 // Carga el valor en R16 al puerto D
	LDI R24, 0x00 // Carga cero en el registro R24, contador del nibble
	LDI R18, 0x00 // Carga cero en el registro R18, contador del sevseg
	STS UCSR0B, R18 //Desactiva los puertos TX y RX
//******************************************************************************
//******************************************************************************
// LOOP PRINCIPAL
//******************************************************************************
LOOP:
	; REALIZAMOS UN POLLING
	IN R16, TIFR0 ; Carga los valores del registro Tifr0 en R16
	CPI R16, (1<<TOV0)
	;BREQ Timer ; Si se encuentra seteada, ir a Timer
	BRNE CheckB1 ; Si no se encuentra seteada, ir a CheckB1
	
	Timer:
		LDI R16, 60 ;Cargar valor de desbordamiento
		OUT TCNT0, R16 ; Carga el valor inicial del contador
		SBI TIFR0, TOV0 ; Realiza un toggle en la bandera de overflow del Timer0
		INC R20 ; Incrementa R20 por cada 100 ms
		CPI R20, 10 ; Compara si ya llego a los 1000 ms
		BRNE CheckB1 ; Sino ha lelgado enviar a Check b1
		CLR R20 ; Se limpia el registro r20 0x00
		CALL AUMENTONIBBLE ; Salta a la subrutina para aumentar

	CheckB1:
		;Se llama para hacer incremento
		IN R16, PINB ; Se obtiene la info de PINB en R16
		SBRS R16, PB4 ; Salta si el bit PB4 se encuentra en 1
		CALL AumentoSevSeg // Se hace un llamado a dicha subrutina
		LDI R16, (1<<CS02)|(1<<CS00) // Carga 1 en los bits CS02 y CS00
		OUT TCCR0B, R16 // Se activa de nuevo una señal fuente de reloj con prescaler de 1024
	CheckB2:
		;Se llama para hacer decremento
		IN R16, PINB ; Se obtiene la info de PINB en R16
		SBRS R16, PB3 ; Salta si el bit PB3 se encuentra en 1
		CALL DecrementoSevSeg // Se hace un llamado a dicha subrutina
		LDI R16, (1<<CS02)|(1<<CS00) // Carga 1 en los bits CS02 y CS00
		OUT TCCR0B, R16 // Se activa de nuevo una señal fuente de reloj con prescaler de 1024
RJMP LOOP ; regresar al loop para continuar verificando
//******************************************************************************
//******************************************************************************
// SUBRUTINA PARA INICIALIZAR TIMER 0
//******************************************************************************
Init_T0:
	LDI R16, (1<< CS02)|(1<<CS00) ; Carga el siguiente byte a R16 0x04
	OUT TCCR0B, R16 ; CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 2MHZ
    LDI R16, 60 ; CARGA VALOR DE DESBORDAMIENTO
	OUT TCNT0, R16 ; CARGA EL VALOR INICIAL DEL CONTADOR
	RET
//*****************************************************************************
AumentoNibble:
	MOV R21, R24 // Copia el contador R24 dentro del registro R21
	LDI R16, 0x01 // Carga un 1 en el registro R16
	SUB R21, R16 // Se le resta 1 al registro R21, para igual los contadores
	OUT PORTC, R24  ; Carga el registro R29 al puerto PortB
	CP R18, R21 //Compara el contador del sevseg y el contador del nibble
	BREQ ResetWithLimit // Si son iguales saltar a la subrutina de reseteo del contador	
	INC R24 ; Incrementa R24
	CPI R24, 0x11 ; Compara el registro 24 con el byte 0x11
	BREQ RESET1 ; Si son iguales saltar al reset1
	RET ; Regresa al loop
//Subrutina para DecrementoSevSeg ***********************************************	
AumentoSevSeg:
	LDI R16, (0<<CS02)|(0<<CS01)|(0<<CS00)
	OUT TCCR0B, R16 // Se desactiva una señal fuente de reloj en el registro TCCR0B
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay:
		DEC R16
		BRNE delay
	; Lee nuevamente el estado del boton despues de antirrebote
	SBIS PINB, PB4 ; Salta si el bit de PB4 esta en 1
	RJMP AumentoSevSeg ; Repite la verificacion de antirrebote si el boton esta aun en 0
	CPI R18, 0x0F // Compara si el contador es 15 = F
	BREQ RESET // Si el contador es cero salta a Reset
	INC R18 // Incrementa R18
	MOV ZL, R23 // Copia R23 en ZL
	ADD ZL, R18 // Suma ZL y R18
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D
	RET //Regresa al punto donde lo llamaron
//Subrutina para DecrementoSevSeg ***********************************************	
DecrementoSevSeg:
	LDI R16, (0<<CS02)|(0<<CS01)|(0<<CS00) 
	OUT TCCR0B, R16 // Se desactiva una señal fuente de reloj en el registro TCCR0B
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay1:
		DEC R16
		BRNE delay1
	; Lee nuevamente el estado del boton despues de antirrebote
	SBIS PINB, PB3 ; Salta si el bit de PB3 esta en 1
	RJMP DecrementoSevSeg ; Repite la verificacion de antirrebote si el boton esta aun en 0
	CPI R18, 0x00 // Compara si el contador es 0
	BREQ RESET2 // Si el contador es cero salta a Reset 2
	DEC R18 // Decrementa R18
	MOV ZL, R23 // Copia R23 en ZL
	ADD ZL, R18 // Suma ZL y R18
	LPM R16, Z // Carga el valor que existe en Z en el registro R 16
	OUT PORTD, R16 // Carga el registro R16 al puerto D
	RET //Regresa al punto donde lo llamaron
// Reset para el AumentoSevSeg ***********************************************
RESET:
	LDI R18, 0x0e // Carga el byte 0x0E en R18
	RJMP AumentoSevSeg // Salta de regreso a la rutina de aumento
// Reset para el DecrementoSevSeg ***********************************************
RESET2:
	LDI R18, 0x01 // Carga el byte 0x01 en R18
	RJMP DecrementoSevSeg // Salta de regreso a la rutina de decremento
// Reset para el Aumento Niblle ***********************************************
RESET1:
	CLR R24 ; Limpia el registro R24
	SBI PINB, PB5 ; toggle en el pin PB5 en port B
	RJMP AUMENTONIBBLE ; Saltar a AumentoNibble de vuelta
// Subrutina de Reset cuando ha alcanzado el limite ****************************
ResetWithLimit:
	CLR R24 ; limpia el registro R24
	SBI PINB, PB5 ; toggle en el pin PB5 en port B
	RJMP AUMENTONIBBLE // Saltar a AumentoNibble de vuelta
//******************************************************************************
//******************************************************************************
//Tabla de valores
//******************************************************************************
	TABLE: .DB 0xFC, 0xC0, 0x6E, 0xEA, 0xD2, 0xBA, 0xBE, 0xE2, 0xFE, 0xF2, 0xF6, 0x9E, 0x3C, 0xCE, 0x3E, 0x36 
//******************************************************************************