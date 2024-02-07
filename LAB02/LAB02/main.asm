;
; LAB02.asm
;
; Created: 2/2/2024 5:29:14 PM
; Author : Giovanni Jimenez
;

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
//Tabla de valores
//******************************************************************************
	
//******************************************************************************

//******************************************************************************
// CONFIGURACION
//******************************************************************************

MAIN:
	LDI ZL, LOW(table << 1)
	LDI ZH, HIGH(table << 1)
	MOV R23, ZL

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

	LDI R20, 0

	SBI DDRC, PC0	;Definiendo PC0 como salida
	CBI PORTC, PC0	; Colocar 0 en PC0

	SBI DDRC, PC1	;Definiendo PC1 como salida
	CBI PORTC, PC1	; Colocar 0 en PC1

	SBI DDRC, PC2	;Definiendo PC2 como salida
	CBI PORTC, PC2	; Colocar 0 en PC2

	SBI DDRC, PC3	;Definiendo PC3 como salida
	CBI PORTC, PC3	; Colocar 0 en PC3

	SBI DDRB, PB5	;Definiendo PB4 como salida
	CBI PORTB, PB5	; Colocar 0 en PB4
	
	SBI PORTC, PC4	; Colocar 1 en PC3 pullup
	CBI DDRC, PC4	;Definiendo PC3 como enntrada

	SBI PORTC, PC5	; Colocar 1 en PC5 pullup
	CBI DDRC, PC5	;Definiendo PC5 como entrada

	LDI R16, 0xFF
	OUT DDRD, R16
	ldi R16, 0xFC
	OUT PORTD, R16
	LDI R24, 0
	LDI R18, 0
//******************************************************************************

//******************************************************************************
// LOOP PRINCIPAL
//******************************************************************************
LOOP:
	;Se llama para hacer incremento en el nibble A
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC4 ; Salta si el bit PC0 se encuentra en 1
	CALL AumentoSevSeg
	
	IN R16, PINC ; Se obtiene la info de PINC en R16
	SBRS R16, PC5 ; Salta si el bit PC0 se encuentra en 1
	CALL DecrementoSevSeg
	
	; REALIZAMOS UN POLLING
	IN R16, TIFR0
	CPI R16, (1<<TOV0)
	BRNE LOOP;Si no se encuentra seteada, continuar esperando
	
	
	LDI R16, 60 ;Cargar valor de desbordamiento
	OUT TCNT0, R16 ; Carga el valor inicial del contador

	SBI TIFR0, TOV0 ; Realiza un toggle en la bandera de overflow del Timer0

	INC R20 ; Incrementa R20 por cada 100 ms
	CPI R20, 10 ; Compara si ya llego a los 1000 ms
	BRNE LOOP ; Sino ha llegado se reincia el LOOP

	CLR R20 ; Se limpia el registro r20 0x00

	//LDI R16, 0xC0
	//OUT PIND, R16
	//CALL LOAD

	CALL AUMENTONIBBLE ; Salta a la subrutina para aumentar */

	//CALL LOAD

	RJMP LOOP

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
	//CLR R24
	
	CPI R24, 0x0F
	OUT PORTC, R24  ; Carga el registro R29 al puerto PortB
	INC R24 ; Incrementa R25
	BREQ RESET1
	//MOV R24, R25 ; Copia el registro R25 a R24
	;LSL R29 ; Shiftea el registro R29, 1 bit hacia la izquierda
	RET ; Regresa al loop

AumentoSevSeg:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay:
		DEC R16
		BRNE delay

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC4 ; Salta si el bit de PC0 esta en 1
	RJMP AumentoSevSeg ; Repite la verificacion de antirrebote si el boton esta aun en 0

	SBI PINB, PB5

	LDI R16, 1
	ADD ZL, R16
	LPM R16, Z
	OUT PORTD, R16
	RET
	
DecrementoSevSeg:
	; Espera un tiempo breve para el antirrebote
	LDI R16, 255
	delay1:
		DEC R16
		BRNE delay1

	; Lee nuevamente el estado del boton despues de antirrebote

	SBIS PINC, PC5 ; Salta si el bit de PC0 esta en 1
	RJMP AumentoSevSeg ; Repite la verificacion de antirrebote si el boton esta aun en 0

	LDI R16, 1
	SUB ZL, R16
	LPM R16, Z
	OUT PORTD, R16
	RET

LOAD:
	
	LDI R16, 1
	ADD ZL, R16

	INC R18
	CPI R18, 0x11
	BREQ RESET

	LPM R16, Z
	OUT PORTD, R16
	
	RET

RESET:
	CLR R18
	MOV ZL, R23
	LDI R16, 1
	SUB ZL, R16
	RJMP LOAD

RESET1:
	CLR R24
	RJMP AUMENTONIBBLE

TABLE: .DB 0xFC, 0xC0, 0x6E, 0xEA, 0xD2, 0xBA, 0xBE, 0xE2, 0xFE, 0xF2, 0xF6, 0x9E, 0x3C, 0xCE, 0x3E, 0x36

//******************************************************************************
// SUBRUTINA PARA INCREMENTAR EL CONTADOR BIANRIO
//******************************************************************************

; FORMA 1 PARA AUMENTAR EL CONTADOR*********************************************

; FORMA 2 PARA AUMENTAR EL CONTADOR BINARIO**************************************


; Realiza un aumento en el contador R30
	/*INC R30 ; Aumenta R30 R30<-R30+1
	
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
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		CBI PORTB, PB3 ; Toggle PB3 -> 0
		CBI PORTB, PB4 ; Toggle PB4 -> 0
		RJMP DONE
	ContadorA1: ; PB4=0; PB3=0; PB2=0 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA2: ; PB4=0; PB3=0; PB2=1 PB1=0
		CBI PORTB, PB1 ; Toggle PB1  -> 0
		SBI PORTB, PB2 ; Toggle PB2  -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA3: ; PB4=0; PB3=0; PB2=1 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 ->1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA4: ; PB4=0; PB3=1; PB2=0 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		SBI PORTB, PB3 ; Toggle PB3 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA5: ; PB4=0; PB3=1; PB2=0 PB1=1
		SBI PORTB, PB1  ; Toggle PB1 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA6: ; PB4=0; PB3=1; PB2=1 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		RJMP DONE ; Salta a la instruccion Done
	ContadorA7: ; PB4=0; PB3=1; PB2=1 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA8: ; PB4=1; PB3=0; PB2=0 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		CBI PORTB, PB3 ; Toggle PB3 -> 0
		SBI PORTB, PB4 ; Toggle PB4 -> 1
		RJMP DONE
	ContadorA9: ; PB4=1; PB3=0; PB2=0 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA10: ; PB4=1; PB3=0; PB2=1 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		RJMP DONE
	ContadorA11: ; PB4=1; PB3=0; PB2=1 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA12: ; PB4=1; PB3=1; PB2=0 PB1=0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		CBI PORTB, PB2 ; Toggle PB2 -> 0
		SBI PORTB, PB3 ; Toggle PB3 -> 1
		RJMP DONE
	ContadorA13: ; PB4=1; PB3=1; PB2=0 PB1=1
		SBI PORTB, PB1 ; Toggle PB1 -> 1
		RJMP DONE
	ContadorA14: ; PB4=1; PB3=1; PB2=1 PB1-0
		CBI PORTB, PB1 ; Toggle PB1 -> 0
		SBI PORTB, PB2 ; Toggle PB2 -> 1
		RJMP DONE
	ContadorA15: ; PB4=1; PB3=1; PB2=1 PB1=1
		SBI PORTB, PB1 ; Toggle PB4 -> 1
		RJMP DONE
	DONE:
		RJMP LOOP*/
//******************************************************************************