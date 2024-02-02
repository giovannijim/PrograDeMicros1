;******************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de Microcontroladores 
; PreLab02.asm
; Created: 2/2/2024 8:19:37 AM
; Author : Giovanni Jimenez
; Hardware: ATMEGA328P
;******************************************************************************

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
	LDI R30, 0

	SBI DDRB, PB4	;Definiendo PB4 como salida
	CBI PORTB, PB4	; Colocar 0 en PB4

	SBI DDRB, PB3	;Definiendo PB3 como salida
	CBI PORTB, PB3	; Colocar 0 en PB3

	SBI DDRB, PB2	;Definiendo PB2 como salida
	CBI PORTB, PB2	; Colocar 0 en PB2

	SBI DDRB, PB1	;Definiendo PB1 como salida
	CBI PORTB, PB1	; Colocar 0 en PB1

	LDI R30, 0
//******************************************************************************

//******************************************************************************
// LOOP PRINCIPAL
//******************************************************************************
LOOP:
	; REALIZAMO' UN POLLING
	IN R16, TIFR0
	CPI R16, (1<<TOV0)
	BRNE LOOP ;Si no se encuentra seteada, continuar esperando

	LDI R16, 236 ;Cargar valor de desbordamiento
	OUT TCNT0, R16 ; Carga el valor inicial del contador

	SBI TIFR0, TOV0 ; Realiza un toggle en la bandera de oberflow del Timer0

	INC R20 ; Incrementa R20 por cada 10 ms
	CPI R20, 10 ; Compara si ya llego a los 100 ms
	BRNE LOOP ;Sino ha llegado se reincia el LOOP

	CLR R20 ; Se limpia el registro r20 0x00

	RJMP AUMENTONIBBLE ; Salta a la subrutina para aumentar 

	RJMP LOOP

//******************************************************************************

//******************************************************************************
// SUBRUTINA PARA INICIALIZAR TIMER 0
//******************************************************************************
Init_T0:
	
	LDI R16, (1<< CS02)|(1<<CS00) ; Carga el siguiente byte a R16 0x04
	OUT TCCR0B, R16 ; CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 2MHZ

	LDI R16, 236 ; CARGA VALOR DE DESBORDAMIENTO
	OUT TCNT0, R16 ; CARGA EL VALOR INICIAL DEL CONTADOR

	RET
//******************************************************************************

//******************************************************************************
// SUBRUTINA PARA INCREMENTAR EL CONTADOR BIANRIO
//******************************************************************************

; FORMA 1 PARA AUMENTAR EL CONTADOR*********************************************
AumentoNibble:
	INC R30 ; Incrementa R30
	MOV R29, R30 ; Copia el registro R30 a R29
	LSL R29 ; Shiftea el registro R29, 1 bit hacia la izquierda
	OUT PORTB, R29  ; Carga el registro R29 al puerto PortB
	RJMP LOOP ; Regresa al loop

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