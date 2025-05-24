
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
    volatile uint32_t DATA1;
    volatile uint32_t DATA2;
    volatile uint32_t DATA3;
    volatile uint32_t DATA4;
}I2C_Typedef;

typedef struct{
    volatile uint32_t FDR;
}FND_Typedef;


#define I2C_BASEADDR 0x44A00000u
#define FND_BASEADDR 0x44A10000u
#define GPIOB_BASEADDR 0x44A20000u

#define GPIOB ((GPIOB_TypeDef *) GPIOB_BASEADDR)
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

void GPI_INIT(GPIOB_TypeDef *GPIOx);

uint32_t GPI_read(GPIOB_TypeDef *GPIOx);


void WRITE_I2C(I2C_Typedef *I2Cx);
void READ_I2C(I2C_Typedef *I2Cx, uint32_t *DATA1, uint32_t *DATA2, uint32_t *DATA3, uint32_t *DATA4);



int main()
{
	uint32_t fndData1;
	uint32_t fndData2;
	uint32_t fndData3;
	uint32_t fndData4;

	uint32_t temp_sw;
    uint32_t sw0 =0;
    uint32_t sw1 =0;
    uint32_t sw2 =0;
    uint32_t sw3 =0;

    while ((GPI_read(GPIOB) & (1 << 0)) == 0);  // 0번 버튼이 눌릴 때까지 기다림
    WRITE_I2C(I2C);
    while ((GPI_read(GPIOB) & (1 << 0)) == 1);  // 0번 버튼이 눌릴 때까지 기다림

    sleep(1);


    while ((GPI_read(GPIOB) & (1 << 1)) == 0);  // 버튼 1번이 눌릴 때까지 기다림 (0이 되어야 하니까)

    READ_I2C(I2C, &fndData1, &fndData2, &fndData3, &fndData4);

    while(1){
        temp_sw = GPI_read(GPIOB);
        sw0 = temp_sw & (1 << 4);
        sw1 = temp_sw & (1 << 5);
        sw2 = temp_sw & (1 << 6);
        sw3 = temp_sw & (1 << 7);

        if (sw0) {
            write_fndFont(FND, fndData1);
        } else if(sw1){
            write_fndFont(FND, fndData2);
        } else if(sw2){
            write_fndFont(FND, fndData3);
        }else if(sw3){
            write_fndFont(FND, fndData4);
        }else{
        	write_fndFont(FND, 0x00);
        }
    }

    sleep(1);

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


void GPI_INIT(GPIOB_TypeDef *GPIOx) {
    GPIOx -> MODER = 0x00;
}

uint32_t GPI_read(GPIOB_TypeDef *GPIOx)
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

void WRITE_I2C(I2C_Typedef *I2Cx){
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
    I2C -> WDATA =23;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********data1*************/
    delay(5);
    I2C -> WDATA =44;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********data2*************/
    delay(5);
    I2C -> WDATA =122;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********data3*************/
    delay(5);
    I2C -> WDATA =37;
    data_I2C(I2C);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);

    /***********stop*************/
    delay(5);
    stop_I2C(I2C);
    delay(5);
    I2C -> CR =0x00;
    while(is_ready(I2C) ==0);
}

void READ_I2C(I2C_Typedef *I2Cx, uint32_t *DATA1, uint32_t *DATA2, uint32_t *DATA3, uint32_t *DATA4){
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
    while(is_ready(I2C) ==0);
    stop_I2C(I2C);

    *DATA1 = I2C ->DATA1;
    *DATA2 = I2C ->DATA2;
    *DATA3 = I2C ->DATA3;
    *DATA4 = I2C ->DATA4;
}
