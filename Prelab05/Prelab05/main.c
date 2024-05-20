/*
 * Prelab05.c
 * Created: 4/10/2024 10:15:47 PM
 * Author : Giovanni Jimenez
 */ 

// Incluyendo librerias
#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <util/delay.h>
#include "ADC/initADC.h"
#include "PWM1/PWM1.h"
#include "PWM2/PWM2.h"
#include "Timer0/Timer0.h"
#include "UART/UART.h"

// Prototipo de setup
void setup(void);

//Variables
uint8_t contador;
uint8_t varADCH;
volatile uint8_t bufferRX;


uint8_t valorADC;

char recibido1;
char recibido2;
char recibido3;

int n1;
int n2;
int n3;

int num;

int CharToInt(char num){
	return num - '0';
}

int unir(int n1, int n2, int n3){
	return n1*100+ n2*10 + n3;
}


int main(void)
{
	
    cli();								// Deshabilitar interrupciones globales
    setup();	
	initUART9600();						// Dirigirse a la subrutina setup
	//initPWM1FastA(no_invertido, 1024);	// Se llama la funcion de la libreria y se envian datos
	//initPWM2FastA(no_invertido, 1024);	// Se llama la funcion de la libreria y se envian datos
	//initTimer0();						// Se llama la funcion de la libreria
    sei();								// Habilitar interrupciones globales
	
    while (1)
    {
	    recibido1=ValorRecibido();
	    recibido2=ValorRecibido();
	    recibido3=ValorRecibido();
	    
	    n1=CharToInt(recibido1);
	    n2=CharToInt(recibido2);
	    n3=CharToInt(recibido3);
	    
	    num= unir(n1,n2,n3);
	    
	    PORTB = 0xFF;
	    PORTC |= 255>>6;
		//initADC(5);				// Se comienza la conversion en ADC5
		//ADCSRA |= (1<< ADSC);	// Comenzar conversion
		//while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
		//updateDutyCyclePWM2A(UDR0);		// Se llama la funcion de la libreria
		/*
		initADC(6);				// Se comienza la conversion en ADC6
	    ADCSRA |= (1<< ADSC);	// Comenzar conversion
	    while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
		updateDutyCyclePWM1A(55);		// Se llama la funcion de la libreria
		
		initADC(7);				// Se comienza la conversion en ADC7
		ADCSRA |= (1<< ADSC);	// Comenzar conversion
		while(ADCSRA&(1<<ADSC));// Revisar si la conversion ya termino
		varADCH = ADCH;			// Guarda el valor de ADCH en la variable varADCH
		manualPWM(contador, varADCH);	// Se llama la funcion de la libreria
		*/
    }
}

// Subrutina setup ------------------------------------------------------------
void setup(void){
	// Se apaga tx y rx
	//UCSR0B = 0;
	// Establece el contado en 0
	DDRB = 0xFF;
	DDRC = 0x03;
	PORTB = 0;
	PORTC =0;
	contador = 0;
}

// Vector de interrupcion ADC -------------------------------------------------
ISR(ADC_vect)
{
	// Se escribe con un 1 lógico la bandera para apagarla
	ADCSRA |= (1<<ADIF);
}

// Vector de interrupcion TIMER0 -------------------------------------------------
ISR(TIMER0_OVF_vect)
{
	// Aumenta el valor del contador
	contador ++;
	// Se carga el valor inicial
	TCNT0 = 240;
	// Se escribe con un 1 lógico la bandera para apagarla
	TIFR0 |= (1<<TOV0);
}
/*
ISR(USART_RX_vect){
	//Se almacena en la variable lo que se recibe de UDR0
	bufferRX = UDR0;
	PORTB = bufferRX;
	PORTC |= bufferRX >> 6	;
	writeUART(bufferRX);
	//updateDutyCyclePWM2A(bufferRX);
	//writeUART(bufferRX);
}
*/