/*
 * UART.h
 *
 * Created: 4/19/2024 10:32:07 AM
 *  Author: alesa
 */ 


#ifndef UART_H_
#define UART_H_

// Inicializar el protocolo UART

void initUART9600(void);

// Escribir UART
void writeUART(char Caracter);

//Enviar una cadena
void cadena (unsigned char* texto);

//Menu de trabajo
void Menu (char* text);

//Menu de trabajo
void Respuesta (uint8_t response);

uint8_t ValorRecibido(void);

#endif /* UART_H_ */