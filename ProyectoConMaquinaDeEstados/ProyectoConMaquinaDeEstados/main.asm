; Universidad del Valle de Guatemala
; IE2023: Programacion de microcontroladores
; Proyecto1ConMaquinaDeEstados.asm
; Author : Giovanni Jimenez
; Hardware: ATMEGA328P
;*****************************************************************************
; Encabezado
;*****************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN

; Se definen Labels para los registros asociados a la Fecha
.DEF PointerMES = R3
.DEF CntDiaUnidad = R4
.DEF CntDiaDecena = R5
.DEF CntMesUnidad = R6
.DEF CntMesDecena = R7

; Se definen Labels para los registros asociados a la Hora
.def CntSegUnidades = R18
.def CntSegDecenas = R19
.def CntMinUnidades = R20
.def CntMinDecenas = R21
.def CntHrsUnidades = R22
.def CntHrsDecenas = R23

; Se definen Labels para los registros asociados a la Alarma
.def AlarmaMinUnidad = R24
.def AlarmaMinDecena = R27
.def AlarmaHrsUnidad= R28
.def AlarmaHrsDecena = R29

; Se definen Labels para los registros asociados al Estado
.def MODO = R25
.def ESTADO = R26

; Se definen los vectores de interrupcion

.org 0x0006		; Vector de ISR_PCINT0
	JMP ISR_PCINT0 
.org 0x0012		; Vector de TIMER2_OVF
	JMP ISR_TIMER2_OVF
.org 0x001A 	; Vector de TIMER1_OVF
	JMP ISR_TIMER1_OVF
.org 0x0020		; Vector de TIMER0_OVF
	JMP ISR_TIMER0_OVF

MAIN:
;*****************************************************************************
; Stack
;*****************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
;*****************************************************************************
; Configuracion
;*****************************************************************************
	LDI ZL, LOW(TABLE << 1)	; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1); Se obtiene la dirección más significativa del registro Z

	LDI R16, (1 << CLKPCE)	; Se coloca un uno en el bit de CLKPCE
	STS CLKPR, R16			; Se habilita el prescaler

	LDI R16, 0b0000_0011
	STS CLKPR, R16		; Se define un prescaler de 8, por lo tanto la FCPU = 2MHz

	LDI R16, 0
	OUT TCCR0A, R16		; Se indica al Timer 0 que opere de manera normal

	CALL Init_T0		; Inicializar Timer 0

	LDI R16, 0
	STS TCCR1A, R16		; Se indica al Timer 1 que opere de manera normal

	CALL Init_T1		; Inicializar Timer 1

	LDI R16, 0
	STS TCCR2A, R16		; Se indica al Timer 2 que opere de manera normal

	CALL Init_T2		; Inicializar Timer 2

	SEI					; Se habilitan las interrupciones globales

	CLR R18				; Limpia el registoo 18
	
	STS UCSR0B, R18		;Desactiva los puertos TX y RX

	LDI R16, 0xFF
	OUT DDRD, R16		; Se establece el puerto D como salida
	LDI R17, 0x00		
	OUT PORTD, R17		; Se limpia el puerto D, para que se encuentre en 0

	OUT DDRC, R16		; Se establece el puerto C como salida
	OUT PORTC, R17		; Se limpia el puerto C, para que se encuentre en 0

	LDI R16, 0x00
	OUT DDRB, R16			; Se establece el puerto B como entrada 
	LDI R16, (1<<PB4)|(1<<PB3)|(1<<PB2)|(1<<PB1)|(1<<PB0)
	OUT PORTB, R16			; Se colocan pull ups en la entrada del puerto B

	LDI R16, (1 << PCINT4)|(1 << PCINT3)|(1 << PCINT2)|(1 << PCINT1)|(1 << PCINT0)
	STS PCMSK0, R16			; Habilitando PCINT en los pines PCINT0, PCINT1, PCINT2, PCINT3, PCINT4

	LDI R16, (1 << PCIE0)
	STS PCICR, R16			; Habilitando la ISR PCINT  [7:0]

	LDI R16, (1<<PB5)		
	OUT DDRB, R16			; Se establece PB5 como salida
	LDI R16, 0x00
	OUT PORTC, R16			; Se limpia el puerto B, para que se encuentre en 0

	CLR CntSegDecenas		; Limpia el registro 
	CLR CntSegUnidades		; Limpia el registro 
	CLR CntMinUnidades		; Limpia el registro 
	CLR CntMinDecenas		; Limpia el registro 
	CLR CntHrsUnidades		; Limpia el registro 
	CLR CntHrsDecenas		; Limpia el registro 
	CLR ESTADO		; Limpia el registro 

	CLR CntMesDecena		; Limpiar el registro
	CLR CntDiaDecena		; Limpiar el registro
	CLR CntDiaUnidad		; Limpiar el registro
	CLR CntMesUnidad		; Limpiar el registro
	CLR R16					; Limpiar el registro

	CLR AlarmaMinUnidad		; Limpiar el registro
	CLR AlarmaMinDecena		; Limpiar el registro
	CLR AlarmaHrsUnidad		; Limpiar el registro
	CLR AlarmaHrsDecena		; Limpiar el registro
	LDI R16, 0x05
	MOV AlarmaMinUnidad, R16
	MOV AlarmaHrsUnidad , R16

	CLR R1					; Limpiar el registro
	CLR R0					; Limpiar el registro
	CLR R2					; Limpiar el registro
	
	CLR PointerMes			; Limpiar el registro

	LDI CntMinDecenas, 4	; Cargar valor inicial en el reloj
	LDI CntMinUnidades, 0	; Cargar valor inicial en el reloj
	LDI CntHrsDecenas, 1	; Cargar valor inicial en el reloj
	LDI CntHrsUnidades, 5	; Cargar valor inicial en el reloj

	
	CBI PORTB, PB5		; Apagar PB5
	CBI PORTC, PC0		; Apagar PC0
	CBI PORTC, PC1		; Apagar PC1
	CLR R16
;*****************************************************************************
; LOOP
;*****************************************************************************
LOOP:	
; ----------------------------SUBRUTINA PARA AUMENTAR EL RELOJ CADA SEGUNDO-----------------------
	AUMENTO:
	MOV R16, R1			; Copia el registro1 a r16
	CPI R16, 10		; Compara si ya llego a los 1000 ms
	BRNE COMPARACION	; Sino ha llegado enviar a loop
	CLR R1				; Se limpia el registro r1 0x00
	CALL AUMENTO_UNIDADES_SEGUNDOS	; Salta a la subrutina para aumentar
;---------------------------------------MAQUINA DE ESTADOS-----------------------------------------	
	COMPARACION:
		SBRS ESTADO, 0 ;ESTADO 0 = 1?
		JMP ESTADOXX0  ;ESTADO 0 = 0
		JMP ESTADOXX1  ;ESTADO 0 = 1

	ESTADOXX0:
		SBRS ESTADO, 1 ;ESTADO 1 = 1?
		JMP ESTADOX00  ;ESTADO 1 = 0
		JMP ESTADOX10  ;ESTADO 1 = 1
	
	ESTADOX00:
		SBRS ESTADO, 2 ;ESTADO 2 = 1?
		JMP ESTADO000	;ESTADO 2 = 0
		JMP ESTADO100	;ESTADO 2 = 1
	 
	ESTADOX10:
		SBRS ESTADO, 2 ;ESTADO 2 = 1?
		JMP ESTADO010	;ESTADO 2 = 0
		JMP ESTADO110	;ESTADO 2 = 1
	
	ESTADOXX1:
		SBRS ESTADO, 1 ;ESTADO 1 = 1?
		JMP ESTADOX01	;ESTADO 1 = 0
		JMP ESTADOX11	;ESTADO 1 = 1
	
	ESTADOX01:
		SBRS ESTADO, 2 ;ESTADO 2 = 1?
		JMP ESTADO001	;ESTADO 2 = 0
		JMP ESTADO101	;ESTADO 2 = 1
	
	ESTADOX11:
		SBRS ESTADO, 2 ;ESTADO 2 = 1?
		JMP ESTADO011	;ESTADO 2 = 0
		JMP ESTADO111	;ESTADO 2 = 1

;*****************************************************************************	

; ----------------------------------------MOSTRAR HORA----------------------------------------

ESTADO000:
	; Prende LEDS para indicar el estado
	SBIC PINB, PB5
	CBI PORTB, PB5	; Apagar PB5
	;CBI PORTC, PC0	; Apagar PC0	
	;CBI PORTC, PC1	; Apagar PC1
	CLR R2			; Limpia el registro 2
	
; ---------------------------------------MULTIPLEXACION--------------------------------------------
	U_MINUTOS_000:
	SBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntMinUnidades		; Se desplaza el pointer
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ORI R16, 0x01			; Si No se encuentra en 0 incrementar R16
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX0:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5				; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX0	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	D_MINUTOS_000:
	CBI PORTC, PC2			; Activa display de unidades minutos
	SBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntMinDecenas		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ORI R16, 0x01			; Si No se encuentra en 0 incrementar R16
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX1:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5			; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX1	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	U_HORAS_000:
	CBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	SBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)		; Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntHrsUnidades			; Se desplaza el pointer
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ORI R16, 0x01			; Si No se encuentra en 0 incrementar R16
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX2:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5				; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX2	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	D_HORAS_000:
	CBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	SBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
	ADD ZL, CntHrsDecenas			; Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ORI R16, 0x01			; Si No se encuentra en 0 incrementar R16
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX3:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5				; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX3	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	; -------------------------------------COMPARAR RELOJ CON ALARMA------------------------------
	COMPARACION_CON_ALARMA:
			CP CntMinUnidades, AlarmaMinUnidad		; Comparar el registro CntMinUnidades con AlarmaMinUnidad
			BREQ EQUAL_DECENA_MINUTO				; Si hay igualdad saltar a dicha subrutina
			RJMP LOOP								; Si no es igual regresar al LOOP

		EQUAL_DECENA_MINUTO:
			CP CntMinDecenas, AlarmaMinDecena		; Comparar el registro CntMinDecenas con AlarmaMinDecenas
			BREQ EQUAL_UNIDAD_HORA					; Si hay igualdad saltar a dicha subrutina
			RJMP LOOP								; Si no es igual regresar al LOOP
			
		EQUAL_UNIDAD_HORA:
			CP CntHrsUnidades, AlarmaHrsUnidad
			BREQ EQUAL_DECENA_HORA					; Si hay igualdad saltar a dicha subrutina
			RJMP LOOP								; Si no es igual regresar al LOOP

		EQUAL_DECENA_HORA:
			CP CntHrsDecenas, AlarmaHrsDecena
			BREQ PRENDER_ALARMA						; Si hay igualdad saltar a dicha subrutina
			RJMP LOOP								; Si no es igual regresar al LOOP
	
		PRENDER_ALARMA:
			SBI PORTC, PC1							; Prender la alarma

	RJMP LOOP				; Salta de regreso al LOOP

; ------------------------------------------ CONFIGURAR HORA --------------------------------------

ESTADO001:
; Prende LEDS para indicar el estado
	CBI PORTB, PB5
	CBI PORTC, PC0
	SBI PORTC, PC1
	CLR R2			; Limpia el registro 2

; Multiplexacion para mostrar la configuracion de hora
	U_MINUTOS:
	SBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntMinUnidades		; Se desplaza el pointer
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX4:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5			; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX4	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	D_MINUTOS:
	CBI PORTC, PC2			; Activa display de unidades minutos
	SBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntMinDecenas		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX5:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5			; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX5	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	U_HORAS:
	CBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	SBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)		; Se obtiene la dirección más significativa del registro Z
	ADD ZL, CntHrsUnidades			; Se desplaza el pointer
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX6:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5				; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX6	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	D_HORAS:
	CBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	SBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
	ADD ZL, CntHrsDecenas			; Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX7:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5				; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX7	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

;COMPARACION DE CONFIGURACION DISPLAYS DE MINUTOS EN HORA
	U_MIN_CONF_HORA:
		CPI CntMinUnidades, 0x0A			; Compara si el contador es 10
		BREQ D_MIN_CONF_HORA				; Si el contador es cero salta 
		CPI CntMinUnidades, -1				; Compara si el registro es -1
		BREQ DEC_D_MIN_CONF_HORA			; Si si lo es, saltar a la subrutina
		CPI CntMinUnidades, -2				; Compara si el registro es -1
		BREQ DEC_D_MIN_CONF_HORA			; Si si lo es, saltar a la subrutina
		RJMP U_HRS_CONF_HORA

	DEC_D_MIN_CONF_HORA:
		DEC CntMinDecenas					; Decrementar las decenas en el display de los minutos
		CPI CntMinDecenas, -1				; Compara si las decenas de minuto es igual a -1
		BREQ UNDERFLOW_MINUTOS				; Si son iguales saltar a la subrutina
		LDI CntMinUnidades, 0x09			; Carga el valor 9 en el registro de las unidades de minuto
		RJMP U_MIN_CONF_HORA				; Salta de regreso a la subrutina principal
		
	D_MIN_CONF_HORA:
		CPI CntMinDecenas, 0x05		; Compara si el contador de decenas es 5
		BREQ RESET_CONF_HORA_MINS		; Si el contador es cero salta 
		INC CntMinDecenas				; Aumenta las decenas de los minutos
		CLR CntMinUnidades				; Limpia el registro 
		RJMP U_MIN_CONF_HORA			; Regresa a la subrutina principal

	UNDERFLOW_MINUTOS:				; Cuando exista Underflow lo que va a hacer es cargar 59
		LDI CntMinUnidades, 0x09	; Cargar 9 en CntMinUnidades
		LDI CntMinDecenas, 0x05		; Cargar 5 en CntMinDecenas
		RJMP U_MIN_CONF_HORA		; Regresa a la subrutina principal

	 RESET_CONF_HORA_MINS:			
		CLR CntMinDecenas			; Limpiar registro
		CLR CntMinUnidades			; Limpiar registro
		RJMP U_MIN_CONF_HORA		; Regresa a la subrutina principal

;COMPARACION DE CONFIGURACION DISPLAYS DE HORAS EN HORA
	U_HRS_CONF_HORA:

		CPI CntHrsUnidades, 0x0A			; Compara si el contador es 10
		BREQ D_HRS_CONF_HORA				; Si el contador es cero salta 
		CPI CntHrsUnidades, 0x04			; Compara si CntHrsUnidades es 4
		BREQ RESET_2359_TO_0				; Si lo es, saltar a dicha subruitna
		CPI CntHrsUnidades, -1				; Compara si el registro es -1
		BREQ DEC_D_HRS_CONF_HORA			; Si si lo es, saltar a la subrutina
		CPI CntHrsUnidades, -2				; Compara si el registro es -1
		BREQ DEC_D_HRS_CONF_HORA			; Si si lo es, saltar a la subrutina
		RJMP LOOP							; Regresa al loop

	DEC_D_HRS_CONF_HORA:
		DEC CntHrsDecenas			; Decrementar el registro CntHrsDecenas
		CPI CntHrsDecenas, -1		; Comparar el registro CntHrsDecenas -1
		BREQ UNDERFLOW_HORAS		; Saltar a dicho registro en caso exista igualdad arriba
		LDI CntHrsUnidades, 0x09	; Cargar 9 en el registro CntHrsUnidades
		RJMP U_HRS_CONF_HORA		; Regresar a la subrutina principal
		
	D_HRS_CONF_HORA:
		INC CntHrsDecenas			; Incrementar el registro CntHrsDecenas
		CLR CntHrsUnidades			; Limpiar el registro
		RJMP U_HRS_CONF_HORA		; Regresar a la subrutina principal

	UNDERFLOW_HORAS:
		LDI CntHrsUnidades, 0x03	; Cargar 3 en el registro CntHrsUnidades
		LDI CntHrsDecenas, 0x02		; Cargar 2 en el registro CntHrsDecenas
		RJMP U_HRS_CONF_HORA		; Regresar a la subrutina principal

	RESET_2359_TO_0:	
		CPI CntHrsDecenas, 0x02			; Compara si el contador es 2
		BREQ RESET_CONF_HORA_HRS		; Si el contador es cero salta	
		RJMP ESTADO001					; Saltar de vuelta al inicio del estado

	 RESET_CONF_HORA_HRS:
		CLR CntHrsDecenas		; Limpiar el registro
		CLR CntHrsUnidades		; Limpiar el registro

	RJMP LOOP	; Regresar al Loop

; -------------------------------------------MOSTRAR FECHA-----------------------------------------

ESTADO010:
	CBI PORTB, PB5		; Apagar PB5
	SBI PORTC, PC0		; Prender PC0
	CBI PORTC, PC1		; Apagar PC1
	CLR R2				; Limpiar el registro
	
	U_MES:
		SBI PORTC, PC2			; Activa display de unidades minutos
		CBI PORTC, PC3			; Desactiva display de decenas minutos
		CBI PORTC, PC4			; Activa display de decenas horas 
		CBI PORTC, PC5			; Desactiva display de unidade horas
		LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(TABLE << 1)		; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntMesUnidad			; Se desplaza el pointer
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Salta la siguiente linea si esta en cero 
		ORI R16, 0x01			; Realiza un or para activar pd0 siempre
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX8:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX8	; Si no es igual Regresar a dicha subrutina
		CLR R2					; Limpiar el registro R2

	D_MES:
		CBI PORTC, PC2			; Activa display de unidades minutos
		SBI PORTC, PC3			; Desactiva display de decenas minutos
		CBI PORTC, PC4			; Activa display de decenas horas 
		CBI PORTC, PC5			; Desactiva display de unidade horas
		LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
		ADD ZL, CntMesDecena			; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Salta la siguiente linea si esta en cero 
		ORI R16, 0x01			; Realiza un or para activar pd0 siempre
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX9:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX9	; Si no es igual Regresar a dicha subrutina
		CLR R2					; Limpiar el registro R2

	U_DIA:
		CBI PORTC, PC2			; Activa display de unidades minutos
		CBI PORTC, PC3			; Desactiva display de decenas minutos
		CBI PORTC, PC4			; Activa display de decenas horas 
		SBI PORTC, PC5			; Desactiva display de unidade horas
		LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntDiaUnidad		; Se desplaza el pointer
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Salta la siguiente linea si esta en cero 
		ORI R16, 0x01			; Realiza un or para activar pd0 siempre
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX10:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX10	; Si no es igual Regresar a dicha subrutina
		CLR R2					; Limpiar el registro R2

	D_DIA:
		CBI PORTC, PC2			; Activa display de unidades minutos
		CBI PORTC, PC3			; Desactiva display de decenas minutos
		SBI PORTC, PC4			; Activa display de decenas horas 
		CBI PORTC, PC5			; Desactiva display de unidade horas
		LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntDiaDecena		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Salta la siguiente linea si esta en cero 
		ORI R16, 0x01			; Realiza un or para activar pd0 siempre
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX11:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX11	; Si no es igual Regresar a dicha subrutina
		CLR R2					; Limpiar el registro R2
	
	;------------------------------COMPARACION DE CONFIGURACION DISPLAYS DE DIA------------------------ 

	SHOW_UNIDAD_DIA:
		MOV R16, CntDiaUnidad	; Copiar el registro CntDiaunidad en R16
		CPI R16, 0x0A			; Compara si el contador es 10
		BREQ D_DIA_SHOW			; Si el contador es cero salta 

		MOV R16, CntMesDecena		; Copiar el registro CntMesDecena en R16
		CPI R16, 0x01				; Compara R16 con 1
		BREQ AUMENTO_POINTER_POR_DECENA_SHOW  ;Se dirigie a una subrutina para aumentar al pointer más alla de 0

		; MOV PointerMes, CntMesUnidad	; Copia el registro CntMes Unidad en PointerMes
		LDI ZL, LOW(DIASxMesU << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesU << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntMesUnidad		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		LDI R29, 0x01			; Carga 1 en R29
		ADD R16, R29			; Suma el registro 16 con el 19
		MOV R17, CntDiaUnidad	; Copia el registro CntDiaUnidad R17
		CP R16, R17				;	Compara el registro R16 con el R17
		BREQ COMPROBAR_DECENA_MES_SHOW	; Se dirige a la subruita si ambos registros de arriba son iguales

		MOV R16, CntDiaUnidad	; Copia el registro CntDiaUnidad en R16
		CPI R16, -1				; Compara si el registro es -1
		BREQ DEC_D_DIA_SHOW_FECHA			; Si si lo es, saltar a la subrutina
		MOV R16, PointerMes	; Copia el registro CntDiaUnidad en R16
		CPI R16, -2				; Compara si el registro es -2
		BREQ DEC_D_DIA_SHOW_FECHA			; Si si lo es, saltar a la subrutina
		RJMP U_MES_CONF_FECHA	; Regresa a la subrutina principal

	AUMENTO_POINTER_POR_DECENA_SHOW:		; Subrutina para 
		LDI R16, 0x0A				; cargar 10 a r16
		ADD R16, CntMesUnidad		; Sumar ambos registros R16 y CntMesUnidad
		MOV PointerMes, R16			; Copiar el registro R16 a PointerMes
		CPI R16, 0x0D				; Comparar si el registro es 13
		BREQ RESET_FECHA_LUEGO_DE_365_DIAS_SHOW	; Si hay igualdad saltar a dicha subrutina

		LDI ZL, LOW(DIASxMesU << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesU << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		LDI R29, 0x01			; Carga 1 en R29
		ADD R16, R29			; Suma el registro 16 con el 19
		MOV R17, CntDiaUnidad	; Copia el registro CntDiaUnidad R17
		CP R16, R17				;	Compara el registro R16 con el R17
		BREQ COMPROBAR_DECENA_MES_SHOW

		MOV R16, CntDiaUnidad		; Copiar el registro CntDiaUnidad en R16
		CPI R16, -1					; Compara si el registro es -1
		BREQ DEC_D_DIA_SHOW_FECHA			; Si si lo es, saltar a la subrutina
		MOV R16, CntDiaUnidad		; Copiar el registro CntDiaUnidad en R16
		CPI R16, -2					; Compara si el registro es -2
		BREQ DEC_D_DIA_SHOW_FECHA			; Si si lo es, saltar a la subrutina
		
		RJMP U_MES_CONF_FECHA		; Saltar a la subrutina Pincipal

	RESET_FECHA_LUEGO_DE_365_DIAS_SHOW:	; Si pasaron los 12 meses empezar desde el 01/01
		CLR CntDiaUnidad			; Limpia el registro
		CLR CntDiaDecena			; Limpia el registro
		CLR CntMesUnidad			; Limpia el registro
		CLR CntMesDecena			; Limpia el registro
		CLR PointerMes				; Limpia el registro
		LDI R16, 0x01				; Carga 1 al registro R16
		ADD CntDiaUnidad, R16		; Al registro CntDiaUnidad se le suma 1
		ADD CntMesUnidad, R16		; Al registro CntMesUnidad se le suma 1
		RJMP SHOW_UNIDAD_DIA		; Regresa a la subrutina principal

	DEC_D_DIA_SHOW_FECHA:	; Decrementar Decena Dia
		DEC CntDiaDecena		; Decrementar registro CntDiaDecena
		MOV R17, CntDiaDecena	; Copiar el registro CntDiaDecena en R17
		CPI R17, -1				; Compararar el registro R17 con -1
		BREQ UNDERFLOW_DIAS_SHOW		; Si hay igualdad dirigirse a dicha subrutina
		LDI R16, 0x09			; Cargar el registro 9 con r16
		CLR CntDiaUnidad		; Limpiar el registro
		ADD CntDiaUnidad, R16	; Sumar CntDiaUnidad con R16
		RJMP SHOW_UNIDAD_DIA		; Saltar de vuelta a la subrutina principal
		
	D_DIA_SHOW:				; Incrementar Decena Dia
		LDI ZL, LOW(DIASxMesD << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesD << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		MOV R17, CntDiaDecena	; Copiar el registro CntDiaDecena en R17
		CP R16, R17				; Comparar R16 con R17
		BREQ RESET_CONF_FECHA_SHOW	; Si hay igualdad dirigirse a dicha subrutina

		INC CntDiaDecena				; Aumenta las decenas de los dias
		CLR CntDiaUnidad				; Limpia el registro 
		RJMP SHOW_UNIDAD_DIA
	
	COMPROBAR_DECENA_MES_SHOW:
		LDI ZL, LOW(DIASxMesD << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesD << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBI PORTB, PB5			; Prender PB5
		MOV R17, CntDiaDecena	; Copiar el registro cntdiadecena en r17
		CP R16, R17				; Comparar R16 con R17
		BREQ RESET_CONF_FECHA_SHOW	; Si hay igualdad dirigirse a dicha subrutina
		RJMP SHOW_UNIDAD_DIA	; Saltar de vuelta a la subrutina principal

	UNDERFLOW_DIAS_SHOW:
		LDI ZL, LOW(DIASxMesU << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesU << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes				; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z						; Carga el valor que existe en Z en el registro R 16
		MOV CntDiaUnidad, R16
		LDI ZL, LOW(DIASxMesD << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesD << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes				; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z						; Carga el valor que existe en Z en el registro R 16
		MOV CntDiaDecena, R16
		RJMP SHOW_UNIDAD_DIA

	 RESET_CONF_FECHA_SHOW:					; Realizar reset de ambos registros del Dia
		INC CntMesUnidad
		CLR CntDiaDecena				; Limpia el registro CntDiaDecena
		CLR CntDiaUnidad				; Limpia el registor CntDiaUnidad
		LDI R16, 0x01
		ADD CntDiaUnidad, R16
		RJMP SHOW_UNIDAD_DIA			; Salta a la subrutina general123

; ----------------COMPARACION DE CONFIGURACION DISPLAYS DE MES EN FECHA----------------------------
	U_MES_CONF_FECHA_SHOW:
		MOV PointerMes, CntMesUnidad
		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, 0x0A			; Compara si el contador es 10
		BREQ D_MES_SHOW				; Si el contador es cero salta
		 
		MOV R16, CntMesUnidad   ; Copia el registro CntMesUnidad en R16
		CPI R16, 0x03			; Compara si el contador es 3
		BREQ VERIFICACION_MES_SHOW	; Si el contador es cero salta a la subrutina de verificacion

		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, -1				; Compara si el registro es -1
		BREQ DEC_D_MES_SHOW_FECHA		; Si si lo es, saltar a la subrutina

		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, -2				; Compara si el registro es -2
		BREQ DEC_D_MES_SHOW_FECHA		; Si si lo es, saltar a la subrutina

		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, -1				; Compara si el registro es -1
		BREQ DEC_D_MES_SHOW_FECHA		; Si si lo es, saltar a la subrutina

		RJMP LOOP ; Saltar de vuelta  loop


	DEC_D_MES_SHOW_FECHA:	; Decremento
		DEC CntMesDecena	; Decrementar el registro cntmesdecena
		MOV R17, CntMesDecena	; Copiar cntmesdecena a r17
		CPI R17, -1				; comparar r17 con -1
		BREQ UNDERFLOW_MES_SHOW		; Saltar a dicha subrutina
		LDI R16, 0x09			; Cargar 9 en R16
		CLR CntMesUnidad		; Limpiar el registro
		ADD CntMesUnidad, R16	; Sumar CntMesUnidad con R16
		RJMP U_MES_CONF_FECHA_SHOW	; Saltar de vuelta  a la subrutina principal	
		
	D_MES_SHOW:  ; INCREMENTO
		INC CntMesDecena			; Incrementar el contador
		CLR CntMesUnidad			; Limpiar el registro
		RJMP U_MES_CONF_FECHA_SHOW		; Saltar de vuelta  a la subrutina principal	

	VERIFICACION_MES_SHOW:	; Verifica el mes para reiniciar
		MOV R16, CntMesDecena			; Copiar el registro r16 a CntMesDecena
		CPI R16, 0x01					; Compara si el contador es 1
		BREQ RESET_CONF_MES_FECHA_SHOW		; Si resultado es cero salta 
		RJMP U_MES_CONF_FECHA_SHOW			; Saltar a la subrutina principal

	UNDERFLOW_MES_SHOW:		; Realizar underflow en los display de mes
		LDI R16, 0x02			; Cargar el valor 0x02 en R16
		CLR CntMesUnidad		; Limpiar el registro
		ADD CntMesUnidad, R16	; Sumar R 16 con el registro CntMesUnidad
		LDI R16, 0x01			; Cargar 1 en R16
		CLR CntMesDecena		; Limpiar el registro
		ADD CntMesDecena, R16	; Sumar CntMesDecena con R16
		RJMP U_MES_CONF_FECHA_SHOW	; Saltar de vuelta  a la subrutina principal

	 RESET_CONF_MES_FECHA_SHOW:
		CLR CntMesDecena		; Limpiar registro
		CLR CntMesUnidad		; Limpiar registro

	RJMP LOOP		; Saltar de vuelta al loop

; ----------------------------------CONFIGURAR FECHA-----------------------------------------------

ESTADO011:
	CBI PORTB, PB5		; Prender el PB5
	SBI PORTC, PC0		; Apagar PC0
	SBI PORTC, PC1		; Apagar PC1
	CLR R2				; Limpiar R2
	CBI PORTD, PD0		; Apagar PD0

	U_MES_C:
		SBI PORTC, PC2			; Activa display de unidades mes
		CBI PORTC, PC3			; Desactiva display de decenas mes
		CBI PORTC, PC4			; Activa display de decenas dia 
		CBI PORTC, PC5			; Desactiva display de unidade dia
		LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(TABLE << 1)		; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntMesUnidad			; Se desplaza el pointer
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
		ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX12:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX12	; Si no es igual Regresar a dicha subrutina
		CLR R2					; Limpiar el registro R2

	D_MES_C:
		CBI PORTC, PC2			; Activa display de unidades mes
		SBI PORTC, PC3			; Desactiva display de decenas mes
		CBI PORTC, PC4			; Activa display de decenas dia 
		CBI PORTC, PC5			; Desactiva display de unidade dia
		LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
		ADD ZL, CntMesDecena			; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
		ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX13:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX13	; Si no es igual Regresar a dicha subrutina
		CLR R2					; Limpiar el registro R2

	U_DIA_C:
		CBI PORTC, PC2			; Activa display de unidades mes
		CBI PORTC, PC3			; Desactiva display de decenas mes
		CBI PORTC, PC4			; Activa display de decenas dia 
		SBI PORTC, PC5			; Desactiva display de unidades dia
		LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntDiaUnidad		; Se desplaza el pointer
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
		ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX14:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX14	; Si no es igual Regresar a dicha subrutina
		CLR R2					; Limpiar el registro R2

	D_DIA_C:
		CBI PORTC, PC2			; Desactiva display de unidades mes
		CBI PORTC, PC3			; Desactiva display de decenas mes
		SBI PORTC, PC4			; Activa display de decenas dias 
		CBI PORTC, PC5			; Desactiva display de unidade dias
		LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntDiaDecena		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
		ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
		OUT PORTD, R16			; Carga el registro R16 al puerto D
		DELAY_MULTIPLEX15:		; Delay de multiplexeo
		MOV R16, R2				; Copia el registro 2 en el 16
		CPI R16, 5				; Compara el registro 16 con 10
		BRNE DELAY_MULTIPLEX15	; Si no es igual Regresar a dicha subrutina
		CLR R2	

	
;------------------------------COMPARACION DE CONFIGURACION DISPLAYS DE DIA------------------------ 

	CONF_UNIDAD_DIA:
		MOV R16, CntDiaUnidad	; Copiar el registro CntDiaunidad en R16
		CPI R16, 0x0A			; Compara si el contador es 10
		BREQ D_DIA_CONF			; Si el contador es cero salta 

		MOV R16, CntMesDecena		; Copiar el registro CntMesDecena en R16
		CPI R16, 0x01				; Compara R16 con 1
		BREQ AUMENTO_POINTER_POR_DECENA  ;Se dirigie a una subrutina para aumentar al pointer más alla de 0

		; MOV PointerMes, CntMesUnidad	; Copia el registro CntMes Unidad en PointerMes
		LDI ZL, LOW(DIASxMesU << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesU << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, CntMesUnidad		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		LDI R29, 0x01			; Carga 1 en R29
		ADD R16, R29			; Suma el registro 16 con el 19
		MOV R17, CntDiaUnidad	; Copia el registro CntDiaUnidad R17
		CP R16, R17				;	Compara el registro R16 con el R17
		BREQ COMPROBAR_DECENA_MES	; Se dirige a la subruita si ambos registros de arriba son iguales

		MOV R16, CntDiaUnidad	; Copia el registro CntDiaUnidad en R16
		CPI R16, -1				; Compara si el registro es -1
		BREQ DEC_D_DIA_CONF_FECHA			; Si si lo es, saltar a la subrutina
		MOV R16, PointerMes	; Copia el registro CntDiaUnidad en R16
		CPI R16, -2				; Compara si el registro es -2
		BREQ DEC_D_DIA_CONF_FECHA			; Si si lo es, saltar a la subrutina
		RJMP U_MES_CONF_FECHA	; Regresa a la subrutina principal

	AUMENTO_POINTER_POR_DECENA:		; Subrutina para 
		LDI R16, 0x0A				; cargar 10 a r16
		ADD R16, CntMesUnidad		; Sumar ambos registros R16 y CntMesUnidad
		MOV PointerMes, R16			; Copiar el registro R16 a PointerMes
		CPI R16, 0x0D				; Comparar si el registro es 13
		BREQ RESET_FECHA_LUEGO_DE_365_DIAS	; Si hay igualdad saltar a dicha subrutina

		LDI ZL, LOW(DIASxMesU << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesU << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		LDI R29, 0x01			; Carga 1 en R29
		ADD R16, R29			; Suma el registro 16 con el 19
		MOV R17, CntDiaUnidad	; Copia el registro CntDiaUnidad R17
		CP R16, R17				;	Compara el registro R16 con el R17
		BREQ COMPROBAR_DECENA_MES

		MOV R16, CntDiaUnidad		; Copiar el registro CntDiaUnidad en R16
		CPI R16, -1					; Compara si el registro es -1
		BREQ DEC_D_DIA_CONF_FECHA			; Si si lo es, saltar a la subrutina
		MOV R16, CntDiaUnidad		; Copiar el registro CntDiaUnidad en R16
		CPI R16, -2					; Compara si el registro es -2
		BREQ DEC_D_DIA_CONF_FECHA			; Si si lo es, saltar a la subrutina
		
		RJMP U_MES_CONF_FECHA		; Saltar a la subrutina Pincipal

	RESET_FECHA_LUEGO_DE_365_DIAS:	; Si pasaron los 12 meses empezar desde el 01/01
		CLR CntDiaUnidad			; Limpia el registro
		CLR CntDiaDecena			; Limpia el registro
		CLR CntMesUnidad			; Limpia el registro
		CLR CntMesDecena			; Limpia el registro
		CLR PointerMes				; Limpia el registro
		LDI R16, 0x01				; Carga 1 al registro R16
		ADD CntDiaUnidad, R16		; Al registro CntDiaUnidad se le suma 1
		ADD CntMesUnidad, R16		; Al registro CntMesUnidad se le suma 1
		RJMP CONF_UNIDAD_DIA		; Regresa a la subrutina principal

	DEC_D_DIA_CONF_FECHA:	; Decrementar Decena Dia
		DEC CntDiaDecena		; Decrementar registro CntDiaDecena
		MOV R17, CntDiaDecena	; Copiar el registro CntDiaDecena en R17
		CPI R17, -1				; Compararar el registro R17 con -1
		BREQ UNDERFLOW_DIAS		; Si hay igualdad dirigirse a dicha subrutina
		LDI R16, 0x09			; Cargar el registro 9 con r16
		CLR CntDiaUnidad		; Limpiar el registro
		ADD CntDiaUnidad, R16	; Sumar CntDiaUnidad con R16
		RJMP CONF_UNIDAD_DIA		; Saltar de vuelta a la subrutina principal
		
	D_DIA_CONF:				; Incrementar Decena Dia
		LDI ZL, LOW(DIASxMesD << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesD << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		MOV R17, CntDiaDecena	; Copiar el registro CntDiaDecena en R17
		CP R16, R17				; Comparar R16 con R17
		BREQ RESET_CONF_FECHA	; Si hay igualdad dirigirse a dicha subrutina

		INC CntDiaDecena				; Aumenta las decenas de los dias
		CLR CntDiaUnidad				; Limpia el registro 
		RJMP CONF_UNIDAD_DIA
	
	COMPROBAR_DECENA_MES:
		LDI ZL, LOW(DIASxMesD << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesD << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
		SBI PORTB, PB5			; Prender PB5
		MOV R17, CntDiaDecena	; Copiar el registro cntdiadecena en r17
		CP R16, R17				; Comparar R16 con R17
		BREQ RESET_CONF_FECHA	; Si hay igualdad dirigirse a dicha subrutina
		RJMP CONF_UNIDAD_DIA	; Saltar de vuelta a la subrutina principal

	UNDERFLOW_DIAS:
		LDI ZL, LOW(DIASxMesU << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesU << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes				; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z						; Carga el valor que existe en Z en el registro R 16
		MOV CntDiaUnidad, R16
		LDI ZL, LOW(DIASxMesD << 1)		; Se obtiene la dirección menos significativa del registro Z
		LDI ZH, HIGH(DIASxMesD << 1)	; Se obtiene la dirección más significativa del registro Z
		ADD ZL, PointerMes				; Mueve ZL a donde se encuentra el pointer (la posición de R17)
		LPM R16, Z						; Carga el valor que existe en Z en el registro R 16
		MOV CntDiaDecena, R16
		RJMP CONF_UNIDAD_DIA

	 RESET_CONF_FECHA:					; Realizar reset de ambos registros del Dia
		INC CntMesUnidad
		CLR CntDiaDecena				; Limpia el registro CntDiaDecena
		CLR CntDiaUnidad				; Limpia el registor CntDiaUnidad
		LDI R16, 0x01
		ADD CntDiaUnidad, R16
		RJMP CONF_UNIDAD_DIA			; Salta a la subrutina general123

; ----------------COMPARACION DE CONFIGURACION DISPLAYS DE MES EN FECHA----------------------------
	U_MES_CONF_FECHA:
		MOV PointerMes, CntMesUnidad
		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, 0x0A			; Compara si el contador es 10
		BREQ D_MES_CONF				; Si el contador es cero salta
		 
		MOV R16, CntMesUnidad   ; Copia el registro CntMesUnidad en R16
		CPI R16, 0x03			; Compara si el contador es 3
		BREQ VERIFICACION_MES	; Si el contador es cero salta a la subrutina de verificacion

		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, -1				; Compara si el registro es -1
		BREQ DEC_D_MES_CONF_FECHA		; Si si lo es, saltar a la subrutina

		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, -2				; Compara si el registro es -2
		BREQ DEC_D_MES_CONF_FECHA		; Si si lo es, saltar a la subrutina

		MOV R16, CntMesUnidad	; Copia el registro CntMesUnidad en R16
		CPI R16, -1				; Compara si el registro es -1
		BREQ DEC_D_MES_CONF_FECHA		; Si si lo es, saltar a la subrutina

		RJMP LOOP ; Saltar de vuelta  loop


	DEC_D_MES_CONF_FECHA:	; Decremento
		DEC CntMesDecena	; Decrementar el registro cntmesdecena
		MOV R17, CntMesDecena	; Copiar cntmesdecena a r17
		CPI R17, -1				; comparar r17 con -1
		BREQ UNDERFLOW_MES		; Saltar a dicha subrutina
		LDI R16, 0x09			; Cargar 9 en R16
		CLR CntMesUnidad		; Limpiar el registro
		ADD CntMesUnidad, R16	; Sumar CntMesUnidad con R16
		RJMP U_MES_CONF_FECHA	; Saltar de vuelta  a la subrutina principal	
		
	D_MES_CONF:  ; INCREMENTO
		INC CntMesDecena			; Incrementar el contador
		CLR CntMesUnidad			; Limpiar el registro
		RJMP U_MES_CONF_FECHA		; Saltar de vuelta  a la subrutina principal	

	VERIFICACION_MES:	; Verifica el mes para reiniciar
		MOV R16, CntMesDecena			; Copiar el registro r16 a CntMesDecena
		CPI R16, 0x01					; Compara si el contador es 1
		BREQ RESET_CONF_MES_FECHA		; Si resultado es cero salta 
		RJMP U_MES_CONF_FECHA			; Saltar a la subrutina principal

	UNDERFLOW_MES:		; Realizar underflow en los display de mes
		LDI R16, 0x02			; Cargar el valor 0x02 en R16
		CLR CntMesUnidad		; Limpiar el registro
		ADD CntMesUnidad, R16	; Sumar R 16 con el registro CntMesUnidad
		LDI R16, 0x01			; Cargar 1 en R16
		CLR CntMesDecena		; Limpiar el registro
		ADD CntMesDecena, R16	; Sumar CntMesDecena con R16
		RJMP U_MES_CONF_FECHA	; Saltar de vuelta  a la subrutina principal

	 RESET_CONF_MES_FECHA:
		CLR CntMesDecena		; Limpiar registro
		CLR CntMesUnidad		; Limpiar registro

	RJMP LOOP		; Saltar de vuelta a loop

; -----------------------------------------Configuración alarma--------------------------------------------
ESTADO100:
	SBI PORTB, PB5	; Prender PB5
	CBI PORTC, PC0	; Apagar PC0
	CBI PORTC, PC1	; Apagar PC1
	CLR R2			; Limpia el registro 2

; Multiplexacion para mostrar la configuracion de alarma
	ALARMA_U_MINUTOS:
	SBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
	ADD ZL, AlarmaMinUnidad		; Se desplaza el pointer
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX16:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5			; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX16	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	ALARMA_D_MINUTOS:
	CBI PORTC, PC2			; Activa display de unidades minutos
	SBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)		; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)	; Se obtiene la dirección más significativa del registro Z
	ADD ZL, AlarmaMinDecena		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX17:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5			; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX17	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	ALARMA_U_HORAS:
	CBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	CBI PORTC, PC4			; Activa display de decenas horas 
	SBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
	LDI ZH, HIGH(TABLE << 1)		; Se obtiene la dirección más significativa del registro Z
	ADD ZL, AlarmaHrsUnidad			; Se desplaza el pointer
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX18:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5				; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX18	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

	ALARMA_D_HORAS:
	CBI PORTC, PC2			; Activa display de unidades minutos
	CBI PORTC, PC3			; Desactiva display de decenas minutos
	SBI PORTC, PC4			; Activa display de decenas horas 
	CBI PORTC, PC5			; Desactiva display de unidade horas
	LDI ZL, LOW(TABLE << 1)			; Se obtiene la dirección menos significativa del registro Z
	ADD ZL, AlarmaHrsDecena		; Mueve ZL a donde se encuentra el pointer (la posición de R17)
	LPM R16, Z				; Carga el valor que existe en Z en el registro R 16
	SBIC PIND, PD0			; Saltar si PD0 se encuentra apagado (en 0)
	ANDI R16, 0xFE			; Si No se encuentra en 0, apagar el bit 0
	OUT PORTD, R16			; Carga el registro R16 al puerto D
	DELAY_MULTIPLEX19:		; Delay de multiplexeo
	MOV R16, R2				; Copia el registro 2 en el 16
	CPI R16, 5				; Compara el registro 16 con 10
	BRNE DELAY_MULTIPLEX19	; Si no es igual Regresar a dicha subrutina
	CLR R2					; Limpiar el registro R2

;COMPARACION DE CONFIGURACION DISPLAYS DE MINUTOS EN HORA
	U_MIN_CONF_ALARMA:
		CPI AlarmaMinUnidad, 0x0A			; Compara si el contador es 10
		BREQ D_MIN_CONF_ALARMA				; Si el contador es cero salta 
		CPI AlarmaMinUnidad, -1				; Compara si el registro es -1
		BREQ DEC_D_MIN_ALM_HORA			; Si si lo es, saltar a la subrutina
		CPI AlarmaMinUnidad, -2				; Compara si el registro es -1
		BREQ DEC_D_MIN_ALM_HORA			; Si si lo es, saltar a la subrutina
		RJMP U_HRS_CONF_ALARMA

	DEC_D_MIN_ALM_HORA:
		DEC AlarmaMinDecena					; Decrementar las decenas en el display de los minutos
		CPI AlarmaMinDecena, -1				; Compara si las decenas de minuto es igual a -1
		BREQ UNDERFLOW_MINUTOS_ALARMA				; Si son iguales saltar a la subrutina
		LDI AlarmaMinUnidad, 0x09			; Carga el valor 9 en el registro de las unidades de minuto
		RJMP U_MIN_CONF_ALARMA				; Salta de regreso a la subrutina principal
		
	D_MIN_CONF_ALARMA:	; Incrementar la decena del minuto
		CPI AlarmaMinDecena, 0x05		; Compara si el contador de decenas es 5
		BREQ RESET_CONF_ALM_MINS		; Si el contador es cero salta 
		INC AlarmaMinDecena				; Aumenta las decenas de los minutos
		CLR AlarmaMinUnidad				; Limpia el registro 
		RJMP U_MIN_CONF_ALARMA			; Regresa a la subrutina principal

	UNDERFLOW_MINUTOS_ALARMA:				; Cuando exista Underflow lo que va a hacer es cargar 59
		LDI AlarmaMinUnidad, 0x09	; Cargar 9 en CntMinUnidades
		LDI AlarmaMinDecena, 0x05		; Cargar 5 en CntMinDecenas
		RJMP U_MIN_CONF_ALARMA		; Regresa a la subrutina principal

	 RESET_CONF_ALM_MINS:			
		CLR AlarmaMinUnidad			; Limpiar registro
		CLR AlarmaMinDecena			; Limpiar registro
		RJMP U_MIN_CONF_ALARMA		; Regresa a la subrutina principal

;COMPARACION DE CONFIGURACION DISPLAYS DE HORAS EN HORA
	U_HRS_CONF_ALARMA:
		CPI AlarmaHrsUnidad, 0x0A			; Compara si el contador es 10
		BREQ D_HRS_ALARMA_HORA				; Si el contador es cero salta 
		CPI AlarmaHrsUnidad, 0x04			; Compara si CntHrsUnidades es 4
		BREQ RESET_2359_TO_0_ALARMA				; Si lo es, saltar a dicha subruitna
		CPI AlarmaHrsUnidad, -1				; Compara si el registro es -1
		BREQ DEC_D_HRS_ALM_HORA			; Si si lo es, saltar a la subrutina
		CPI AlarmaHrsUnidad, -2				; Compara si el registro es -1
		BREQ DEC_D_HRS_ALM_HORA			; Si si lo es, saltar a la subrutina
		RJMP LOOP							; Regresa al loop

	DEC_D_HRS_ALM_HORA:
		DEC AlarmaHrsDecena			; Decrementar el registro CntHrsDecenas
		CPI AlarmaHrsDecena, -1		; Comparar el registro CntHrsDecenas -1
		BREQ UNDERFLOW_HORAS_ALARMA		; Saltar a dicho registro en caso exista igualdad arriba
		LDI AlarmaHrsUnidad, 0x09	; Cargar 9 en el registro CntHrsUnidades
		RJMP U_HRS_CONF_ALARMA		; Regresar a la subrutina principal
		
	D_HRS_ALARMA_HORA:
		INC AlarmaHrsDecena			; Incrementar el registro CntHrsDecenas
		CLR AlarmaHrsUnidad			; Limpiar el registro
		RJMP U_HRS_CONF_ALARMA		; Regresar a la subrutina principal

	UNDERFLOW_HORAS_ALARMA:
		LDI AlarmaHrsUnidad, 0x03	; Cargar 3 en el registro CntHrsUnidades
		LDI AlarmaHrsDecena, 0x02		; Cargar 2 en el registro CntHrsDecenas
		RJMP U_HRS_CONF_ALARMA		; Regresar a la subrutina principal

	RESET_2359_TO_0_ALARMA:	
		CPI AlarmaHrsDecena, 0x02			; Compara si el contador es 2
		BREQ RESET_CONF_ALM_HRS		; Si el contador es cero salta	
		RJMP ESTADO100					; Saltar de vuelta al inicio del estado

	 RESET_CONF_ALM_HRS:
		CLR AlarmaHrsUnidad		; Limpiar el registro
		CLR AlarmaHrsDecena		; Limpiar el registro

	RJMP LOOP ; Regresar al loop

ESTADO101:
	


	RJMP LOOP

ESTADO110: 
	; ESTE ESTADO NO SE UTILIZA
	RJMP LOOP

ESTADO111:
	; ESTE ESTADO NO SE UTILIZA
	RJMP LOOP

;******************************************************************************
; SUBRUTINA PARA INICIALIZAR TIMER 0
;******************************************************************************
Init_T0:
	LDI R16, (1<< CS02)|(1<<CS00) ; Carga el siguiente byte a R16 0x04
	OUT TCCR0B, R16 ; CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 2MHZ
    LDI R16, 236 ; CARGA VALOR DE DESBORDAMIENTO
	OUT TCNT0, R16 ; CARGA EL VALOR INICIAL DEL CONTADOR
	LDI	R16, (1 << TOIE0)	; Habilita la interrupción del overflow - timer 1
	STS	TIMSK0, R16
	RET
;******************************************************************************
; SUBRUTINA PARA INICIALIZAR TIMER 1
;******************************************************************************
Init_T1:
	LDI R16, (0<< CS12)|(1<< CS11)|(1<<CS10) ; Carga el siguiente byte a R16 0x04
	STS TCCR1B, R16			; CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 2MHZ
    LDI R16, 0xC2			; CARGA VALOR DE DESBORDAMIENTO
	LDI R17, 0xF7			; CARGA VALOR DE DESBORDAMIENTO
	STS TCNT1H, R16			; CARGA EL VALOR INICIAL DEL CONTADOR
	STS TCNT1L, R17			; CARGA EL VALOR INICIAL DEL CONTADOR		
	LDI	R16, (1 << TOIE1)	; Habilita la interrupción del overflow en el timer 2
	STS	TIMSK1, R16
	RET
;******************************************************************************
; SUBRUTINA PARA INICIALIZAR TIMER 2
;******************************************************************************
Init_T2:
	LDI R16, (1<< CS22)|(1<< CS21)|(1<<CS20) ; Carga el siguiente byte a R16 0x04
	STS TCCR2B, R16			; CONFIGURA EL PRESCALER A 1024 PARA UN RELOJ DE 2MHZ
    LDI R16, 255			; CARGA VALOR DE DESBORDAMIENTO
	STS TCNT2, R16			; CARGA EL VALOR INICIAL DEL CONTADOR
	LDI	R16, (1 << TOIE2)	; Habilita la interrupción del overflow en el timer 2
	STS	TIMSK2, R16
	RET
;******************************************************************************
; SUBRUTINA PARA INICIALIZAR AUMENTAR EL CONTADOR HEXADECIMAL COMO RELOJ
;******************************************************************************
AUMENTO_UNIDADES_SEGUNDOS:
	CPI CntSegUnidades, 0x0A		; Compara si el contador es 10
	BREQ AUMENTO_DECENAS_SEGUNDOS		; Si el contador es cero salta 
	INC CntSegUnidades				; Incrementa 
	RET

AUMENTO_DECENAS_SEGUNDOS:
	CPI CntSegDecenas, 0x05			; Compara si el contador de decenas es 5
	BREQ AUMENTO_UNIDADES_MINUTOS		; Si el contador es cero salta 
	INC CntSegDecenas				; Incrementa Contador de decenas
	CLR CntSegUnidades				; Limpia el registro 
	RJMP AUMENTO_UNIDADES_SEGUNDOS

AUMENTO_UNIDADES_MINUTOS:
	CLR CntSegDecenas			; Limpia el registro 
	CLR CntSegUnidades			; Limpia el registro 
	INC CntMinUnidades			; Incrementa el registro
	CPI CntMinUnidades, 0x0A		; Compara si el contador de unidades es 9
	BREQ AUMENTO_DECENAS_MINUTOS		; Si el contador es cero salta al reset
	RJMP AUMENTO_UNIDADES_SEGUNDOS

AUMENTO_DECENAS_MINUTOS:
	CLR CntMinUnidades			; Limpia el registro 
	CPI CntMinDecenas, 0x05		; Compara si el contador de decenas es 5
	BREQ AUMENTO_UNIDADES_HORAS	; Si el contador es cero salta al reset
	INC CntMinDecenas			; Incrementa el registro
	RJMP AUMENTO_UNIDADES_SEGUNDOS

AUMENTO_UNIDADES_HORAS:
	CLR CntMinDecenas			; Limpia el registro 
	CLR CntMinUnidades			; Limpia el registro
	INC CntHrsUnidades
	CPI CntHrsUnidades, 0x04		; Compara si el contador de unidades es 9
	BREQ RESET_AFTER23				; Si el contador es cero salta al reset
	CPI CntHrsUnidades, 0x0A		; Compara si el contador de unidades es 9
	BREQ AUMENTO_DECENAS_HORAS		; Si el contador es cero salta al reset
	RJMP AUMENTO_UNIDADES_SEGUNDOS

AUMENTO_DECENAS_HORAS:
	CLR CntHrsUnidades				; Limpiar el registro
	INC CntHrsDecenas				; Incrementar el registro
	RJMP AUMENTO_UNIDADES_SEGUNDOS

RESET_AFTER23:
	INC CntDiaUnidad				; Incrementar el registro	
	CPI CntHrsDecenas, 2			; Comparar el registro CntHrsDecenas
	BREQ RESET_ALL					; Limpiar todos los registros
	RJMP AUMENTO_UNIDADES_SEGUNDOS

RESET_ALL:
	CLR CntSegUnidades			; Limpia el registro 
	CLR CntSegDecenas			; Limpia el registro 
	CLR CntMinUnidades			; Limpia el registro
	CLR CntMinDecenas			; Limpia el registro 
	CLR CntHrsUnidades			; Limpia el registro
	CLR CntHrsDecenas			; Limpia el registro
	RJMP AUMENTO_UNIDADES_SEGUNDOS

;*****************************************************************************
; Subrutina de ISR_TIMER0_OVF
;*****************************************************************************
ISR_TIMER0_OVF:
	PUSH R17 ; Guardamos en pila el registro R16
	IN R17, SREG
	PUSH R17 ; Guardamos en pila el registro SREG

	LDI R16, 236		; Cargar el valor de desbordamiento
	OUT TCNT0, R16		; Cargar el valor inicial al contador
	SBI TIFR0, TOV0		; Borramos la bandera de TOV0

	INC R0				; Incrementamos contador de 10 ms
	INC R1 				; Incrementamos contador de 10 ms

	POP R17				; Obtener el valor de SREG
	OUT SREG, R17		; REstaurar los antiguos vlaores de SREG
	POP R17				; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR
;******************************************************************************
;*****************************************************************************
; Subrutina de ISR_TIMER1_OVF
;*****************************************************************************
ISR_TIMER1_OVF:
	PUSH R17 ; Guardamos en pila el registro R16
	IN R17, SREG
	PUSH R17 ; Guardamos en pila el registro SREG

	LDI R16, 0xC2			; CARGA VALOR DE DESBORDAMIENTO
	LDI R17, 0xF7			; CARGA VALOR DE DESBORDAMIENTO
	STS TCNT1H, R16			; CARGA EL VALOR INICIAL DEL CONTADOR
	STS TCNT1L, R17			; CARGA EL VALOR INICIAL DEL CONTADOR	
	SBI TIFR1, TOV1		; Borramos la bandera de TOV0

	SBI PIND, PD0		; Hacer toggle en PD0

	POP R17				; Obtener el valor de SREG
	OUT SREG, R17		; REstaurar los antiguos vlaores de SREG
	POP R17				; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR
;******************************************************************************
;*****************************************************************************
; Subrutina de ISR_TIMER2_OVF
;*****************************************************************************
ISR_TIMER2_OVF:
	PUSH R17 ; Guardamos en pila el registro R16
	IN R17, SREG
	PUSH R17 ; Guardamos en pila el registro SREG

	LDI R16, 255		; Cargar el valor de desbordamiento
	STS TCNT2, R16		; Cargar el valor inicial al contador
	SBI TIFR2, TOV2		; Borramos la bandera de TOV2

	INC R2				; Incrementamos contador para toggle de display cada 1ms
	INC R10

	POP R17				; Obtener el valor de SREG
	OUT SREG, R17		; REstaurar los antiguos vlaores de SREG
	POP R17				; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR
;******************************************************************************

;*****************************************************************************
; Subrutina de ISR_TIMER0_OVF
;*****************************************************************************
ISR_PCINT0:
	PUSH R16 ; Guardamos en pila el registro R16
	IN R16, SREG
	PUSH R16 ; Guardamos en pila el registro SREG

	SBRS ESTADO, 0		;ESTADO 0 = 1?
	JMP ESTADOXX0_ISR	;ESTADO 0 = 0
	JMP ESTADOXX1_ISR	;ESTADO 0 = 1

ESTADOXX0_ISR:
	SBRS ESTADO, 1		;ESTADO 1 = 1?
	JMP ESTADOX00_ISR	;ESTADO 1 = 0
	JMP ESTADOX10_ISR	;ESTADO 1 = 1

ESTADOX00_ISR:
	SBRS ESTADO, 2		;ESTADO 2 = 1?
	JMP ESTADO000_ISR	;ESTADO 2 = 0
	JMP ESTADO100_ISR	;ESTADO 2 = 1

ESTADOX10_ISR:
	SBRS ESTADO, 2		;ESTADO 2 = 1?
	JMP ESTADO010_ISR	;ESTADO 2 = 0
	JMP ESTADO110_ISR	;ESTADO 2 = 1

ESTADOXX1_ISR:
	SBRS ESTADO, 1		;ESTADO 1 = 1?
	JMP ESTADOX01_ISR	;ESTADO 1 = 0
	JMP ESTADOX11_ISR	;ESTADO	1 = 1

ESTADOX01_ISR:
	SBRS ESTADO, 2		;ESTADO 2 = 1?
	JMP ESTADO001_ISR	;ESTADO 2 = 0
	JMP ESTADO111_ISR	;ESTADO 2 = 1

ESTADOX11_ISR:
	SBRS ESTADO, 2		;ESTADO 2 = 1?
	JMP ESTADO011_ISR	;ESTADO 2 = 0
	JMP ESTADO111_ISR   ;ESTADO 2 = 1
	
ESTADO000_ISR:
	IN R16, PINB		; Obtener los valores de PINB
	SBRS R16, PB0		; PB0 = 1?
	INC ESTADO			; PB0 = 0
						; PB0 = 1
	SBRS R16, PB1	; PB1 = 1?
	CBI PORTB, PB5		; PB1 = 0, Incrementa registro
						; PB1 = 1
	RJMP ISR_POP_PCINT0

ESTADO001_ISR:
	IN R16, PINB	; Obtiene la informacion de PINB
	SBRS R16, PB0	; PB0 = 1?
	INC ESTADO		; PB0 = 0, Incrementa registro
					; PB0 = 1
	SBRS R16, PB1	; PB1 = 1?
	INC CntMinUnidades		; PB1 = 0, Incrementa registro
							; PB1 = 1
	SBRS R16, PB2	; PB2 = 1?
	DEC CntMinUnidades		; PB2 = 0, Decrementa registro
							; PB2 = 1
	SBRS R16, PB3	; PB3 = 1?
	INC CntHrsUnidades		; PB3 = 0, Incrementa registro
							; PB3 = 1
	SBRS R16, PB4	; PB4 = 1?
	DEC CntHrsUnidades		; PB4 = 0, Decrementa registro
							; PB4 = 1
	RJMP ISR_POP_PCINT0

ESTADO010_ISR:
	IN R16, PINB	; Obtiene la informacion de PINB
	SBRS R16, PB0	; PB0 = 1?
	INC ESTADO		; PB0 = 0, Incrementa registro
					; PB0 = 1
	RJMP ISR_POP_PCINT0

ESTADO011_ISR:
	IN R16, PINB	; Obtiene la informacion de PINB
	SBRS R16, PB0	; PB0 = 1?
	INC ESTADO		; PB0 = 0, Incrementa registro
					; PB0 = 1
	SBRS R16, PB1	; PB1 = 1?
	INC CntMesUnidad		; PB1 = 0, Incrementa registro
							; PB1 = 1
	SBRS R16, PB2	; PB2 = 1?
	DEC CntMesUnidad		; PB2 = 0, Decrementa registro
							; PB2 = 1
	SBRS R16, PB3	; PB3 = 1?
	INC CntDiaUnidad		; PB3 = 0, Incrementa registro
							; PB3 = 1
	SBRS R16, PB4	; PB4 = 1?
	DEC CntDiaUnidad		; PB4 = 0, Decrementa registro
							; PB4 = 1
	RJMP ISR_POP_PCINT0

ESTADO100_ISR:
	IN R16, PINB	; Obtiene la informacion de PINB
	SBRS R16, PB0	; PB0 = 1?
	INC ESTADO		; PB0 = 0
					; PB0 = 1
	SBRS R16, PB1	; PB1 = 1?
	INC AlarmaMinUnidad		; PB1 = 0, Incrementa registro
							; PB1 = 1
	SBRS R16, PB2	; PB2 = 1?
	DEC AlarmaMinUnidad		; PB2 = 0, Decrementa registro
							; PB2 = 1
	SBRS R16, PB3	; PB3 = 1?
	INC AlarmaHrsUnidad		; PB3 = 0, Incrementa registro
							; PB3 = 1
	SBRS R16, PB4	; PB4 = 1?
	DEC AlarmaHrsUnidad		; PB4 = 0, Decrementa registro
							; PB4 = 1
	RJMP ISR_POP_PCINT0

ESTADO101_ISR:
	IN R16, PINB	; Obtiene la informacion de PINB
	SBRS R16, PB0	; PB0 = 1?
	INC ESTADO		; PB0 = 0
					; PB0 = 1
	RJMP ISR_POP_PCINT0

ESTADO110_ISR:		; Este registro no se utiliza, puesto que solo se necesito 6
	IN R16, PINB	; Obtiene la informacion de PINB
	SBRS R16, PB0	; PB0 = 1?
	INC ESTADO		; PB0 = 0
					; PB0 = 1
	RJMP ISR_POP_PCINT0

ESTADO111_ISR:		; Este registro no se utiliza, puesto que solo se necesito 6
	IN R16, PINB 
	SBRS R16, PB0	; PB0 = 1?
	INC ESTADO		; PB0 = 0
					; PB0 = 1

ISR_POP_PCINT0:
	CPI ESTADO, 5		; Compara el estado con 6
	BRNE ISRPOPPCINT0	; Si no es igual, saltar a la siguiente subrutina
	CLR ESTADO			; Limpiar el estado si es igual
ISRPOPPCINT0:
	SBI PCIFR, PCIF0    ; Apagar la bandera de ISR PCINT0  
	POP R16 			; Obtener el valor de SREG
	OUT SREG, R16		; REstaurar los antiguos vlaores de SREG
	POP R16 			; OBTENER EL VALOR DE r16
	RETI				; Retornamos a la ISR

;******************************************************************************
;Tabla de valores
;******************************************************************************
	TABLADOS: .DB 0x20, 0x10
	TABLE: .DB  0xFC, 0xC0, 0x6E, 0xEA, 0xD2, 0xBA, 0xBE, 0xE2, 0xFE, 0xF2, 0xF6, 0x9E, 0x3C, 0xCE, 0x3E, 0x36
	DIASxMesU: .DB 0, 1, 9, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0
	DIASxMesD: .DB 0, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0
;******************************************************************************