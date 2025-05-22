
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "sleep.h"

typedef struct{
    volatile uint32_t MODER;
    volatile uint32_t ODR;
    volatile uint32_t IDR;
 }GPIOB_TypeDef;

typedef struct{
    volatile uint32_t CR;
    volatile uint32_t DATA;
    volatile uint32_t SR;
}I2C_Typedef;

#define I2C_BASEADDR 0x44A00000u
//#define GPIOB_BASEADDR 0x44A00000u

//#define GPIOB ((GPIOB_TypeDef *) GPIOB_BASEADDR)
#define I2C ((I2C_Typedef *) I2C_BASEADDR)

void start_I2C(I2C_Typedef *I2Cx);
void stop_I2C(I2C_Typedef *I2Cx);
void data_I2C(I2C_Typedef *I2Cx, uint32_t data);
void set_I2C(I2C_Typedef *I2Cx);
void set_en(I2C_Typedef *I2Cx);


uint32_t is_ready(I2C_Typedef *I2Cx);
uint32_t is_txDone(I2C_Typedef *I2Cx);
void SW_INIT(GPIOB_TypeDef *GPIOx);
uint32_t Switch_read(GPIOB_TypeDef *GPIOx);

enum {IDLE, START, SET_EN_0, DATA, DATA_EN, STOP};

int main()
{
//    SW_INIT(GPIOB);
    set_I2C(I2C);
    while(is_ready(I2C) == 0);

    xil_printf("send start: Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));
    I2C->CR = (1 << 2) | (1 << 0);  // start + en
    xil_printf("Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));

    while(is_ready(I2C) ==0);
    usleep(1);
   // I2C->CR &= ~(1 << 2);

    //I2C -> DATA = 0xaa;
    //xil_printf("Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));

    //    data_I2C(I2C, 0xaa);
    /*xil_printf("complete: Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));
    while(is_ready(I2C) ==0);
    xil_printf("ready: Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));
    xil_printf("Data send: Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));
    data_I2C(I2C, 0xaa);
    xil_printf("complete: Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));
    xil_printf("DATA=%d\n", (I2C->DATA));

    while(is_ready(I2C) ==0);
    xil_printf("txDone: Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));
    xil_printf("Data send\n");
    data_I2C(I2C, 0x01);
    xil_printf("complete: Start=%d, STOP=%d, EN=%d\n", (I2C->CR)& (1<<2),(I2C->CR)& (1<<1),(I2C->CR)& (1<<0));
    xil_printf("DATA=%d\n", (I2C->DATA));

    while(is_ready(I2C) ==0);
    xil_printf("txDone\n");
    stop_I2C(I2C);
    xil_printf("STOP\n");
    while(is_ready(I2C) ==0);
    xil_printf("End\n");

*/


/**
   while(1){
        switch(state){
        	case IDLE:
                set_I2C(I2C);
        		break;
        	case START:
        		start_I2C(I2C);
                break;
            case SET_EN_0:
                set_en(I2C);
                break;
        	case DATA:
                data_I2C(I2C, 0xaa);
                break;
            case DATA_EN:
                set_en(I2C);
                break;
            case STOP:
                stop_I2C(I2C);
                break;
        }
        switch(state){
            case IDLE:
                while(Switch_read(GPIOB) ==0);
                state = START;
                break;
            case START:
                while(is_ready(I2C) ==0);
                state = SET_EN_0;
                break;
            case SET_EN_0:
                while(is_ready(I2C) ==0);
                state = DATA;
                break;
            case DATA:
                state = DATA_EN;
                break;
            case DATA_EN:
                while(is_txDone(I2C) ==0);
                state = STOP;
            case STOP:
                if(is_ready(I2C)==0) state= IDLE;
                break;
        }
        usleep(1);
    }*/
    return 0;
}

void set_I2C(I2C_Typedef *I2Cx){
    I2Cx->CR = 0x00;
}
void set_en(I2C_Typedef *I2Cx){
	I2Cx -> CR &= ~(1<<0);
}

void start_I2C(I2C_Typedef *I2Cx){
    I2Cx->CR |= (1 << 0);    // Enable
    I2Cx->CR &= ~(1 << 1);   // Clear STOP
    I2Cx->CR |= (1 << 2);    // Set START
}


void stop_I2C(I2C_Typedef *I2Cx){
    I2Cx->CR |= (1 << 0);     // enable
    I2Cx->CR |= (1 << 1);     // stop bit set
    I2Cx->CR &= ~(1 << 2);    // start bit clear ← 이 부분 고쳐야 됨!
}

void data_I2C(I2C_Typedef *I2Cx, uint32_t data){
    I2Cx->CR |= (1 << 0);     // enable
    I2Cx->CR &= ~(1 << 1);    // stop bit clear ← 수정 필요
    I2Cx->CR &= ~(1 << 2);    // start bit clear ← 수정 필요
    I2Cx->DATA = data;
}

uint32_t is_ready(I2C_Typedef *I2Cx){
    return (I2Cx->SR) & (1 <<0);
}

uint32_t is_txDone(I2C_Typedef *I2Cx){
    return (I2Cx -> SR) & (1 << 1);
}


void SW_INIT(GPIOB_TypeDef *GPIOx) {
    GPIOx -> MODER = 0x00;
}
uint32_t Switch_read(GPIOB_TypeDef *GPIOx)
{
    return GPIOx->IDR;
}
