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

	SBI DDRB, PB5	;Definiendo PB5 como salida
	CBI PORTB, PB5 ; Colocar 0 en PB5

	SBI DDRC, PC2	;Definiendo PC2 como salida
	CBI PORTC, PC2 ; Colocar 0 en PC2

//****************************************************
//Configuración LOOP
//****************************************************
LOOP: 
	;Se llama para hacer incremento en el nibble A
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC0 ; Salta si el bit PC0 se encuentra en 1
	RJMP AumentoNibbleA

	;Se llama para hacer decremento en el nibble A
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC5 ; Salta si el bit PC0 se encuentra en 1
	RJMP DecrementoNibbleA

	;Se llama para hacer incremento en el nibble B
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC1 ; Salta si el bit PC0 se encuentra en 1
	RJMP IncrementoNibbleB

	;Se llama para hacer decremento en el nibble B
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC4 ; Salta si el bit PC4 se encuentra en 1
	RJMP DecrementoNibbleB

	;Se llama la subrutina para sumar
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC3 ; Salta si el bit PC3 se encuentra en 1
	RJMP SUMA


	RJMP LOOP
//****************************************************
//Subrutinas
//****************************************************
/*SUBRUTINA PARA INCREMENTO DE NIBBLE A---------------------------------------------------*/
AumentoNibbleA:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay:
		DEC R16
		BRNE delay

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC0 ; Salta si el bit de PC0 esta en 1
	RJMP AumentoNibbleA ; Repite la verificacion de antirrebote si el boton esta aun en 0
	
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

	/*SUBRUTINA PARA DECREMENTO DE NIBBLE A---------------------------------------------------*/

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
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA2: ; PB4=0; PB3=0; PB2=0 PB1=1
		SBI PORTB, PB1 ; Toggle PB1  -> 1
		CBI PORTB, PB2 ; Toggle PB2  -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA3: ; PB4=0; PB3=0; PB2=1 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 ->0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA4: ; PB4=0; PB3=0; PB2=1 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		CBI PORTB, PB3 ; Toggle PB3 -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA5: ; PB4=0; PB3=1; PB2=0 PB1=0
		CBI PORTB, PB1  ; Toggle PB1 -> 0
		CBI PORTB, PB2  ; Toggle PB2 -> 0
		SBI PORTB, PB3 ; Toggle PB3 -> 0
		RJMP DONE1 ; Salta a la instruccion Done
	DecrementoA6: ; PB4=0; PB3=1; PB2=0 PB1=1
		SBI PORTB, PB3 ; Toggle PB3 -> 1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		RJMP DONE ; Salta a la instruccion Done
	DecrementoA7: ; PB4=0; PB3=1; PB2=1 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		SBI PORTB, PB2 ; Toggle PB1 -> 1
		SBI PORTB, PB3 ; Toggle PB1 -> 1
		RJMP DONE1
	DecrementoA8: ; PB4=0; PB3=1; PB2=1 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		SBI PORTB, PB3 ; Toggle PB3 -> 1
		CBI PORTB, PB4 ; Toggle PB4 -> 0
		RJMP DONE1
	DecrementoA9: ; PB4=1; PB3=0; PB2=0 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		CBI PORTB, PB3 ; Toggle PB3 -> 0
		SBI PORTB, PB4 ; Toggle PB4 -> 1
		RJMP DONE1
	DecrementoA10: ; PB4=1; PB3=0; PB2=0 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		CBI PORTB, PB3 ; Toggle PB3 -> 0
		RJMP DONE1
	DecrementoA11: ; PB4=1; PB3=0; PB2=1 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		CBI PORTB, PB3 ; Toggle PB3 -> 0
		RJMP DONE1
	DecrementoA12: ; PB4=1; PB3=0; PB2=1 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		CBI PORTB, PB3 ; Toggle PB3 -> 0
		RJMP DONE1
	DecrementoA13: ; PB4=1; PB3=1; PB2=0 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		SBI PORTB, PB3 ; Toggle PB3 -> 1
		SBI PORTB, PB4 ; Toggle PB4 -> 1
		RJMP DONE1
	DecrementoA14: ; PB4=1; PB3=1; PB2=0 PB1-01
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		RJMP DONE1
	DecrementoA15: ; PB4=1; PB3=1; PB2=1 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		RJMP DONE1
	DONE1:
		RJMP LOOP

	/*SUBRUTINA PARA INCREMENTO DE NIBBLE B---------------------------------------------------*/

	IncrementoNibbleB:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay2:
		DEC R16
		BRNE delay2

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC1 ; Salta si el bit de PC1 esta en 1
	RJMP IncrementoNibbleB ; Repite la verificacion de antirrebote si el boton esta aun en 0
	
	; Realiza un aumento en el contador R24
	INC R24 ; Aumenta R24 R24<-R24+1
	
	; SE INICIA UN SWITCH AND CASE
	CPI R24, 0x01 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB1 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x02 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB2 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x03 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB3 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x04 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB4 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x05 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB5 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x06 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB6 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x07 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB7 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x08 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB8 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x09 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB9 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0A ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB10 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0B ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB11 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0C ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB12 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0D ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB13 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0E ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB14 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0F ; Si son iguales activar la bandera Z se coloca en 1
	BREQ IncrementoB15 ; Si detecta bandera Z en 1 saltar hacia destino 

	DEFAULT2:
		LDI R24, 0 ;Coloca el contador R24 en 0
		CBI PORTB, PB0 ;Coloca 0 en PB0 en PORTB
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		RJMP DONE2
	IncrementoB1: ; PB0=0; PD7=0; PD6=0 PD5=1
		SBI PORTD, PD5  ; Coloca 1 en posicion PD5 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB2: ; PB0=0; PD7=0; PD6=1 PD5=0
		CBI PORTD, PD5  ; Coloca 0 en posicion PD5 a PORTD
		SBI PORTD, PD6  ; Coloca 1 en posicion PD6 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB3: ; PB0=0; PD7=0; PD6=1 PD5=1
		SBI PORTD, PD5  ; Pone 1 en posicion PD5 a PORTD
		SBI PORTD, PD6  ; Coloca 1 en posicion PD6 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB4: ; PB0=0; PD7=1; PD6=0 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB5: ; PB0=0; PD7=1; PD6=0 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB6: ; PB0=0; PD7=1; PD6=1 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB7: ; PB0=0; PD7=1; PD6=1 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB8: ; PB0=1; PD7=0; PD6=0 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicion PB0 a PORTB
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB9: ; PB0=1; PD7=0; PD6=0 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicion PB0 a PORTB
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB10: ; PB0=1; PD7=0; PD6=1 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicion PB0 a PORTB
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB11: ; PB0=1; PD7=0; PD6=1 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicion PB0 a PORTB
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB12: ; PB0=1; PD7=1; PD6=0 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicion PB0 a PORTB
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB13: ; PB0=1; PD7=1; PD6=0 PD5=0
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB14: ; PB0=1; PD7=1; PD6=1 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	IncrementoB15: ; PB0=1; PD7=1; PD6=1 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	DONE2:
		RJMP LOOP

	/*SUBRUTINA PARA DECREMENTO DE NIBBLE B---------------------------------------------------*/
	DecrementoNibbleB:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay3:
		DEC R16
		BRNE delay3

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC4 ; Salta si el bit de PC1 esta en 1
	RJMP DecrementoNibbleB ; Repite la verificacion de antirrebote si el boton esta aun en 0
	
	; Realiza un aumento en el contador R24
	DEC R24 ; Aumenta R24 R24<-R24+1
	
	; SE INICIA UN SWITCH AND CASE
	CPI R24, 0x00 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB1 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x01 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB2 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x02 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB3 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x03 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB4 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x04 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB5 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x05 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB6 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x06 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB7 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x07 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB8 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x08 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB9 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x09 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB10 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0A ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB11 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0B ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB12 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0C ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB13 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0D ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB14 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R24, 0x0E ; Si son iguales activar la bandera Z se coloca en 1
	BREQ DecrementoB15 ; Si detecta bandera Z en 1 saltar hacia destino 

	DEFAULT3:
		LDI R24, 0
		CBI PORTB, PB0
		CBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		RJMP DONE3
	DecrementoB1: ; PB0=0; PD7=0; PD6=0 PD5=0
		CBI PORTD, PD5  ; Coloca 0 en posicion PD5 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB2: ; PB0=0; PD7=0; PD6=0 PD5=1
		SBI PORTD, PD5  ; Coloca 1 en posicion PD5 a PORTD
		CBI PORTD, PD6  ; Coloca 0 en posicion PD6 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB3: ; PB0=0; PD7=0; PD6=1 PD5=0
		CBI PORTD, PD5  ; Pone 0 en posicion PD5 a PORTD
		SBI PORTD, PD6  ; Coloca 1 en posicion PD6 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB4: ; PB0=0; PD7=0; PD6=1 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB5: ; PB0=0; PD7=1; PD6=0 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB6: ; PB0=0; PD7=1; PD6=0 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a portD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB7: ; PB0=0; PD7=1; PD6=1 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB8: ; PB0=0; PD7=1; PD6=1 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		CBI PORTB, PB0 ; Coloca 0 en posicion PB0 a PORTB
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB9: ; PB0=1; PD7=0; PD6=0 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicio PB0 a PORTB
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB10: ; PB0=1; PD7=0; PD6=0 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB11: ; PB0=1; PD7=0; PD6=1 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB12: ; PB0=1; PD7=0; PD6=1 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		CBI PORTD, PD7 ; Coloca 0 en posicion PD7 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB13: ; PB0=1; PD7=1; PD6=0 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB14: ; PB0=1; PD7=1; PD6=0 PD5=1
		SBI PORTD, PD5 ; Coloca 1 en posicion PD5 a PORTD
		CBI PORTD, PD6 ; Coloca 0 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicion PB0 a PORTB
		RJMP DONE3 ; Salta a la instruccion Done
	DecrementoB15: ; PB0=1; PD7=1; PD6=1 PD5=0
		CBI PORTD, PD5 ; Coloca 0 en posicion PD5 a PORTD
		SBI PORTD, PD6 ; Coloca 1 en posicion PD6 a PORTD
		SBI PORTD, PD7 ; Coloca 1 en posicion PD7 a PORTD
		SBI PORTB, PB0 ; Coloca 1 en posicion PB0 a PORTB
		RJMP DONE3 ; Salta a la instruccion Done 
	DONE3:
		RJMP LOOP
	
	/*SUBRUTINA PARA LA SUMA---------------------------------------------------*/	
	SUMA:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay4:
		DEC R16
		BRNE delay4

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC3 ; Salta si el bit de PC1 esta en 1
	RJMP SUMA ; Repite la verificacion de antirrebote si el boton esta aun en 0
	
	CBI PORTB, PB5 ; Limpia lo que haya en PB5
	MOV R23, R24 ; Copia el registro R24  a R23
	ADC R23, R30 ; Suma el registro R23 y R30, y se almacena en R23
	MOV R22, R23 ; Copia el registro R23 en R22
	LDI R21, 0b0001_0000 ;Carga el byte 0x10
	AND R22, R21 ; Apaga todos los bits excepto el bit 4 en R22
	MOV R18, R23 ; Copia R23 en R18
	LDI R19, 0b0000_1111 ; Carga el byte 0x0F
	AND R18, R19 ; Apaga el bit 4 en el registro R18
	CPI R22, 0x10 ; Compara si el bit 4 en R22 esta prendido, si esta prendido prende la banera flag
	BREQ PrenderCarry ; Se dirige a la sub rutina prender carry
	
	
	; SE INICIA UN SWITCH AND CASE
	Comparacion:
	CPI R18, 0x01 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes1 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x02 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes2 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x03 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes3 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x04 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes4 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x05 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes5 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x06 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes6 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x07 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes7 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x08 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes8 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x09 ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes9 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x0A ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes10 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x0B ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes11 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x0C ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes12 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x0D ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes13 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x0E ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes14 ; Si detecta bandera Z en 1 saltar hacia destino
	CPI R18, 0x0F ; Si son iguales activar la bandera Z se coloca en 1
	BREQ MostrarRes15 ; Si detecta bandera Z en 1 saltar hacia destino 
	CPI R18, 0x10 ; Si son iguales activar la bandera Z se coloca en 1
	
	DEFAULT4:
		;LDI R23, 0 ;Coloca el contador R24 en 0
		SBI PORTC, PC2 ;Coloca 0 en PC2 en PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (1<<PD2) ; Carga 1 en PD4, PD3 Y PD2
		OUT PORTD, R16 ; Carga R16 a PortD
		RJMP DONE4
	PrenderCarry:
		SBI PORTB, PB5 ; Prende el bit PB5 en el registro PORTB
		RJMP Comparacion ; Regresa a la subrutina Comparacion
	MostrarRes1: ; PD4=0; PD3=0; PD2=0 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (0<<PD3)|(0<<PD2) ; carga 0 en todo PORTD
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes2: ; PD4=0; PD3=0; PD2=1 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes3: ; PD4=0; PD3=0; PD2=1 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes4: ; PD4=0 PD3=1 PD2=0 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes5: ; PD4=0 PD3=1 PD2=0 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes6: ; PD4=0 PD3=1 PD2=1 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 y PD3 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes7: ; PD4=0 PD3=1 PD2=1 PC2=1
		SBI PORTC, PC2 ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 Y PD3
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes8: ; PD4=1 PD3=0 PD2=0 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (0<<PD2) ;carga 1 en PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes9: ; PD4=1 PD3=0 PD2=0 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (0<<PD2) ;carga 1 en PD4 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes10: ;  PD4=1 PD3=0 PD2=1 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 Y PD4 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	MostrarRes11: ; PD4=1 PD3=0 PD2=1 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes12: ; PD4=1 PD3=1 PD2=0 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes13:  ; PD4=1 PD3=1 PD2=0 PC2=1
		SBI PORTC, PC2 ; COLOCA EN 1 EN POSICION PC2 EN PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes14: ; PD4=1 PD3=1 PD2=1 PC2=0
		CBI PORTC, PC2 ; COLOCA EN 0 EN POSICION PC2 EN PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 , PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes15: ;PD4=1 PD3=1 PD2=1 PC2=1
		SBI PORTC, PC2 ; COLOCA EN 1 EN POSICION PC2 EN PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 , PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes16: ; PD4=0; PD3=0; PD2=0 PC2=0
		CBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (0<<PD3)|(0<<PD2) ; carga 0 en todo PORTD
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes17: ; PD4=0; PD3=0; PD2=0 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (0<<PD3)|(0<<PD2) ; carga 0 en todo PORTD
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes18: ; PD4=0; PD3=0; PD2=1 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes19: ; PD4=0; PD3=0; PD2=1 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes20: ; PD4=0 PD3=1 PD2=0 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes21: ; PD4=0 PD3=1 PD2=0 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes22: ; PD4=0 PD3=1 PD2=1 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 y PD3 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes23: ; PD4=0 PD3=1 PD2=1 PC2=1
		SBI PORTC, PC2 ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (0<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 Y PD3
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes24: ; PD4=1 PD3=0 PD2=0 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (0<<PD2) ;carga 1 en PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes25: ; PD4=1 PD3=0 PD2=0 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (0<<PD2) ;carga 1 en PD4 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes26: ;  PD4=1 PD3=0 PD2=1 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 Y PD4 
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE2 ; Salta a la instruccion Done
	MostrarRes27: ; PD4=1 PD3=0 PD2=1 PC2=1
		SBI PORTC, PC2  ; Coloca 1 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (0<<PD3)| (1<<PD2) ;carga 1 en PD2 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes28: ; PD4=1 PD3=1 PD2=0 PC2=0
		CBI PORTC, PC2  ; Coloca 0 en posicion PC2 a PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes29:  ; PD4=1 PD3=1 PD2=0 PC2=1
		SBI PORTC, PC2 ; COLOCA EN 1 EN POSICION PC2 EN PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (0<<PD2) ;carga 1 en PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes30: ; PD4=1 PD3=1 PD2=1 PC2=0
		CBI PORTC, PC2 ; COLOCA EN 0 EN POSICION PC2 EN PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 , PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	MostrarRes31: ;PD4=1 PD3=1 PD2=1 PC2=1
		SBI PORTC, PC2 ; COLOCA EN 1 EN POSICION PC2 EN PORTC
		LDI R16, (1<<PD4)| (1<<PD3)| (1<<PD2) ;carga 1 en PD2 , PD3 Y PD4
		OUT PORTD, R16 ; Carga R16 en PORTD
		RJMP DONE4 ; Salta a la instruccion Done
	DONE4:
		RJMP LOOP

