#include <stdint.h>

#define __IO    volatile

typedef struct {
    __IO uint32_t FCR;
    __IO uint32_t FMR;
    __IO uint32_t FDR;
}FND_TypeDef;




#define APB_BASEADDR  0x10000000
// #define GPOA_BASEADDR (APB_BASEADDR + 0x1000)
// #define GPIB_BASEADDR (APB_BASEADDR + 0x2000)
// #define GPIOC_BASEADDR (APB_BASEADDR + 0x3000)
#define FND_BASEADDR (APB_BASEADDR + 0x4000)

// #define GPIOC           ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define FND           ((FND_TypeDef *) FND_BASEADDR)




void delay(int n);
void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);
void Switch_init(GPIO_TypeDef *GPIOx);
uint32_t Switch_read(GPIO_TypeDef *GPIOx);

void fndEn(FND_TypeDef* FNDx, bool i){
    if(i) {
        FNDx -> FCR = 1;
    } else{
        FNDx -> FCR = 0;
    }
}

void fndCNT(FND_TypeDef* FNDx, uint32_t fndComm, uint32_t fndData){
    FNDx-> FMR = fndComm;
    FNDx-> FDR = fndData;
}

int main()
{   
    bool en = TRUE;
    fndEn(FND, en)
    uint32_t temp=0;
    uint32_t comm=0;
    while(1)
    {   
        for(i=0; i<10; i++){
            fndCNT(FND, 0x00, temp);
            temp ++;
            delay(500);
        }
        temp=0x03;
        for(i=0; i<4; i++){
            fndCNT(FND, comm, temp);
            comm ++
            delay(500);
        }
        delay(500);
    }
    return 0;
};


void delay(int n){
    uint32_t temp = 0;
    for (int i=0; i<n; i++) {
        for (int j=0; j<1000; j++) {
            temp++;
        }
    }
};