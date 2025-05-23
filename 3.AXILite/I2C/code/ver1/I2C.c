
#include <stdio.h>
#include <stdint.h>
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
    volatile uint32_t WDATA;
    volatile uint32_t SR;
    volatile uint32_t RDATA;
}I2C_Typedef;

typedef struct{
    volatile uint32_t FDR;
}FND_Typedef;


#define I2C_BASEADDR 0x44A00000u
#define FND_BASEADDR 0x~~~u
//#define GPIOB_BASEADDR 0x44A00000u

//#define GPIOB ((GPIOB_TypeDef *) GPIOB_BASEADDR)
#define I2C ((I2C_Typedef *) I2C_BASEADDR)
#define FND ((FND_Typedef *) FND_BASEADDR)

//I2C//
void start_I2C(I2C_Typedef *I2Cx);
void stop_I2C(I2C_Typedef *I2Cx);
void data_I2C(I2C_Typedef *I2Cx, uint32_t data);
uint32_t read_I2C(I2C_Typedef *I2Cx);

void set_I2C(I2C_Typedef *I2Cx);
void set_en(I2C_Typedef *I2Cx);


//FND//
void write_fndFont(FND_Typedef *FNDx, uint32_t fndFont);

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

    I2C->CR = (1 << 2) | (1 << 0);  // start + en
    I2C -> CR &= ~(1<<0); //not en
    while(is_ready(I2C) ==0);
    usleep(1);
    I2C -> DATA = 0xaa; //주소 데이터를 줬어
    I2C->CR = (I2C->CR & ~(1 << 2)) | (1 << 0); // 001 data+en
    I2C -> WDATA= 0x01;

    while(is_txDone(I2C) ==0);
    usleep(50);
    I2C -> CR = (1<<1) | (1<<0); //stop +en



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
void write_fndFont(FND_Typedef *FNDx, uint32_t fndFont){
    FNDx -> FDR = fndFont;
}

//I2C//
void start_I2C(I2C_Typedef *I2Cx){
    I2Cx -> CR = 0x05; //101
}
void stop_I2C(I2C_Typedef *I2Cx){
    I2Cx -> CR = 0x03; //011
}
void data_I2C(I2C_Typedef *I2Cx, uint32_t data){
    I2Cx -> WDATA = data;
    I2Cx -> CR = 0x01;
}

uint32_t read_I2C(I2C_Typedef *I2Cx){
    return I2Cx -> RDATA;
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
