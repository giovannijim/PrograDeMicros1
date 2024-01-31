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

	SBI DDRC, PC6	;Definiendo PC6 como salida
	CBI PORTD, PC6 ; Colocar 0 en PC6

	SBI DDRB, PB5	;Definiendo PB5 como salida
	CBI PORTB, PB5 ; Colocar 0 en PB5

	LDI R31, 0xFF
//****************************************************
//Configuración LOOP
//****************************************************
LOOP: 
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC0 ; Salta si el bit PC0 se encuentra en 1
	RJMP AumentoNibbleA
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC5 ; Salta si el bit PC0 se encuentra en 1
	RJMP DecrementoNibbleA

	
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
AumentoNibbleA:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay:
		DEC R16
		BRNE delay

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC0 ; Salta si el bit de PC0 esta en 1
	RJMP AumentoNibbleA ; Repite la verificacion de antirrebote si el boton esta aun en 0

	; Realiza el toggle del puerto B5 (led)
	; SBI PINB, PB1
	
	; Realiza un aumento en el contador R30
	INC R30 ; Aumenta R30 R30<-R30+1
	
	; SE INICIA UN SWITCH AND CASE
	CPI R30, 0x01 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA1 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x02 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA2 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x03 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA3 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x04 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA4 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x05 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA5 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x06 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA6 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x07 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA7 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x08 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA8 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x09 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA9 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0A ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA10 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0B ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA11 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0C ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA12 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0D ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA13 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0E ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA14 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0F ; Si son iguales activar la bandera Z se coloca en 1
	BREQ ContadorA15 ; Si detecta bandera Z en 1 saltar hacia destino

	DEFAULT:
		LDI R30, 0
		SBI PINB, PB1 ; Toggle PB1 -> 0
		SBI PINB, PB2 ; Toggle PB2 -> 0
		SBI PINB, PB3 ; Toggle PB3 -> 0
		SBI PINB, PB4 ; Toggle PB4 -> 0
		RJMP DONE
	ContadorA1: ; PB4=0; PB3=0; PB2=0 PB1=1
		SBI PINB, PB1 ; Toggle PB1 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA2: ; PB4=0; PB3=0; PB2=1 PB1=0
		SBI PINB, PB1 ; Toggle PB1  -> 0
		SBI PINB, PB2 ; Toggle PB2  -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA3: ; PB4=0; PB3=0; PB2=1 PB1=1
		SBI PINB, PB1 ; Toggle PB1 ->1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA4: ; PB4=0; PB3=1; PB2=0 PB1=0
		SBI PINB, PB1 ; Toggle PB1 -> 0
		SBI PINB, PB2 ; Toggle PB2 -> 0
		SBI PINB, PB3 ; Toggle PB3 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA5: ; PB4=0; PB3=1; PB2=0 PB1=1
		SBI PINB, PB1  ; Toggle PB1 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA6: ; PB4=0; PB3=1; PB2=1 PB1=0
		SBI PINB, PB1 ; Toggle PB1 -> 0
		SBI PINB, PB2 ; Toggle PB2 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA7: ; PB4=0; PB3=1; PB2=1 PB1=1
		SBI PINB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA8: ; PB4=1; PB3=0; PB2=0 PB1=0
		SBI PINB, PB1 ; Toggle PB1 -> 0
		SBI PINB, PB2 ; Toggle PB2 -> 0
		SBI PINB, PB3 ; Toggle PB3 -> 0
		SBI PINB, PB4 ; Toggle PB4 -> 1
		RJMP DONE
	ContadorA9: ; PB4=1; PB3=0; PB2=0 PB1=1
		SBI PINB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA10: ; PB4=1; PB3=0; PB2=1 PB1=0
		SBI PINB, PB1 ; Toggle PB1 -> 0
		SBI PINB, PB2 ; Toggle PB2 -> 1
		RJMP DONE
	ContadorA11: ; PB4=1; PB3=0; PB2=1 PB1=1
		SBI PINB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA12: ; PB4=1; PB3=1; PB2=0 PB1=0
		SBI PINB, PB1 ; Toggle PB1 -> 0
		SBI PINB, PB2 ; Toggle PB2 -> 0
		SBI PINB, PB3 ; Toggle PB3 -> 1
		RJMP DONE
	ContadorA13: ; PB4=1; PB3=1; PB2=0 PB1=1
		SBI PINB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA14: ; PB4=1; PB3=1; PB2=1 PB1-0
		SBI PINB, PB1 ; Toggle PB1 -> 0
		SBI PINB, PB2 ; Toggle PB2 -> 1
		RJMP DONE
	ContadorA15: ; PB4=1; PB3=1; PB2=1 PB1=1
		SBI PINB, PB1 ; Toggle PB4 -> 1
		RJMP DONE
	DONE:
		RJMP LOOP

	DecrementoNibbleA:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay1:
		DEC R16
		BRNE delay1

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC5 ; Salta si el bit de PC5 esta en 1
	RJMP DecrementoNibbleA ; Repite la verificacion de antirrebote si el boton esta aun en 0

	; Realiza un aumento en el contador R30
	DEC R30 ; Aumenta R30 R30<-R30-1

	; SE INICIA UN SWITCH AND CASE
	CPI R30, 0x00 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA1 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x01 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA2 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x02 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA3 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x03 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA4 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x04 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA5 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x05 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA6 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x06 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA7 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x07 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA8 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x08 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA9 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x09 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA10 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0A ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA11 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0B ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA12 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0C ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA13 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0D ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA14 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R30, 0x0E ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoA15 ; Si detecta bandera Z en 1 saltar hacia destino

	DEFAULT1:
		LDI R30, 0
		CBI PINB, PB1 ; Dont Toggle PB1 
		CBI PINB, PB2 ; Dont Toggle PB2 
		CBI PINB, PB3 ; Dont Toggle PB3 
		CBI PINB, PB4 ; Dont Toggle PB4
		RJMP DONE1
	DecrementoA1: ; PB4=0; PB3=0; PB2=0 PB1=0
		LDI R16, 0b0000_0000
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA2: ; PB4=0; PB3=0; PB2=0 PB1=1
		LDI R16, 0b0000_0010
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1  -> 1
		;SBI PINB, PB2 ; Toggle PB2  -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA3: ; PB4=0; PB3=0; PB2=1 PB1=0
		LDI R16, 0b0000_0100
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 ->0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA4: ; PB4=0; PB3=0; PB2=1 PB1=1
		LDI R16, 0b0000_0110
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 1
		;SBI PINB, PB2 ; Toggle PB2 -> 1
		;SBI PINB, PB3 ; Toggle PB3 -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA5: ; PB4=0; PB3=1; PB2=0 PB1=0
		LDI R16, 0b0000_1000
		OUT PORTB, R16
		;SBI PINB, PB1  ; Toggle PB1 -> 0
		;SBI PINB, PB2  ; Toggle PB2 -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA6: ; PB4=0; PB3=1; PB2=0 PB1=1
		LDI R16, 0b0000_1010
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 1
		;SBI PINB, PB2 ; Toggle PB2 -> 0
		RJMP DONE ; Salta a la instruccion Done
	DecrementoA7: ; PB4=0; PB3=1; PB2=1 PB1=0
		LDI R16, 0b0000_1100
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 0
		RJMP DONE1
	DecrementoA8: ; PB4=0; PB3=1; PB2=1 PB1=1
		LDI R16, 0b0000_1110
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 1
		;SBI PINB, PB2 ; Toggle PB2 -> 1
		;SBI PINB, PB3 ; Toggle PB3 -> 1
		;SBI PINB, PB4 ; Toggle PB4 -> 0
		RJMP DONE1
	DecrementoA9: ; PB4=1; PB3=0; PB2=0 PB1=0
		LDI R16, 0b0001_0000
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 0
		RJMP DONE1
	DecrementoA10: ; PB4=1; PB3=0; PB2=0 PB1=1
		LDI R16, 0b0001_0010
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 1
		;SBI PINB, PB2 ; Toggle PB2 -> 0
		RJMP DONE1
	DecrementoA11: ; PB4=1; PB3=0; PB2=1 PB1=0
		LDI R16, 0b0001_0100
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 0
		RJMP DONE1
	DecrementoA12: ; PB4=1; PB3=0; PB2=1 PB1=1
		LDI R16, 0b0001_0110
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 1
		;SBI PINB, PB2 ; Toggle PB2 -> 1
		;SBI PINB, PB3 ; Toggle PB3 -> 0
		RJMP DONE1
	DecrementoA13: ; PB4=1; PB3=1; PB2=0 PB1=0
		LDI R16, 0b0001_1000
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 0
		RJMP DONE1
	DecrementoA14: ; PB4=1; PB3=1; PB2=0 PB1-01
		LDI R16, 0b0001_1010
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB1 -> 1
		;SBI PINB, PB2 ; Toggle PB2 -> 0
		RJMP DONE1
	DecrementoA15: ; PB4=1; PB3=1; PB2=1 PB1=0
		LDI R16, 0b0001_1100
		OUT PORTB, R16
		;SBI PINB, PB1 ; Toggle PB4 -> 0
		RJMP DONE1
	DONE1:
		RJMP LOOP

