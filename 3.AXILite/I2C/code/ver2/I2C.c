
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
#define FND_BASEADDR 0x44A10000u
//#define GPIOB_BASEADDR 0x44A00000u

//#define GPIOB ((GPIOB_TypeDef *) GPIOB_BASEADDR)
#define I2C ((I2C_Typedef *) I2C_BASEADDR)
#define FND ((FND_Typedef *) FND_BASEADDR)

//I2C//
void start_I2C(I2C_Typedef *I2Cx);
void stop_I2C(I2C_Typedef *I2Cx);
void data_I2C(I2C_Typedef *I2Cx);
void read_I2C(I2C_Typedef *I2Cx);
void delay(int n);
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
    //초기 변수//
	uint32_t fndData1;
	uint32_t fndData2;
	uint32_t fndData3;
	uint32_t fndData4;
	I2C -> CR =0x00;

    //초기 IDLE
    while(is_ready(I2C) == 0);

    /***********start*************/
    delay(5);
    start_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********address*************/
    delay(5);
    I2C -> WDATA =0xaa;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);


    /***********data0*************/
    delay(5);
    I2C -> WDATA =0x01;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********data1*************/
    delay(5);
    I2C -> WDATA =0x02;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********data2*************/
    delay(5);
    I2C -> WDATA =0x03;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********data3*************/
    delay(5);
    I2C -> WDATA =0x04;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********stop*************/
    delay(5);
    stop_I2C(I2C);
    delay(5);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********start*************/
    delay(5);
    start_I2C(I2C);
    delay(5);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********address*************/
    delay(5);
    I2C -> WDATA =0xab;
    data_I2C(I2C);
    I2C -> CR =0x00;


    /***********read*************/
    while(is_ready(I2C) ==0);
    read_I2C(I2C);
    I2C -> CR = 0x00;
    usleep(70);

    xil_printf("%d\n", I2C->RDATA);

    while(is_ready(I2C) ==0);

    xil_printf("%d\n", I2C->RDATA);


    stop_I2C(I2C);
    xil_printf("%d\n", I2C->RDATA);

    sleep(1);
    /*    I2C->CR=0x00;
    while(is_ready(I2C) == 1); //ready가 0 될때까지 대기
    xil_printf("%d\n", (I2C->RDATA));

    read_I2C(I2C); //read 신호 줌
    I2C->CR=0x00;
    while(is_ready(I2C) == 0);
    xil_printf("%d\n", I2C->RDATA);

    read_I2C(I2C); //read 신호 줌
    I2C->CR=0x00;
    while(is_ready(I2C) == 1); //ready가 0 될때까지 대기
    xil_printf("%d\n", I2C->RDATA);

    read_I2C(I2C); //read 신호 줌
    I2C->CR=0x00;
    while(is_ready(I2C) == 0);
    xil_printf("%d\n", I2C->RDATA);

    stop_I2C(I2C);
    I2C->CR=0x00;
    sleep(1);
*/
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
void data_I2C(I2C_Typedef *I2Cx){
    I2Cx -> CR = 0x01;
}
void read_I2C(I2C_Typedef *I2Cx){
	I2Cx -> CR = 0x07;
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
void delay(int n) {
    volatile uint32_t temp = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < 1000; j++) {
            temp++;
        }
    }
}
