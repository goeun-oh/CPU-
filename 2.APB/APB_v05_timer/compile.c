#include <stdint.h>

#define __IO    volatile

typedef struct {
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t FPR;
}FND_TypeDef;


typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
}GPIO_TypeDef;


typedef struct{
    __IO uint32_t TCR;
    __IO uint32_t TCNT;
    __IO uint32_t PSC;
    __IO uint32_t ARR;
} TIM_TypeDef;




#define APB_BASEADDR  0x10000000
#define GPOA_BASEADDR (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR (APB_BASEADDR + 0x2000)
#define GPIOC_BASEADDR (APB_BASEADDR + 0x3000)
#define GPIOD_BASEADDR (APB_BASEADDR + 0x4000)
#define FND_BASEADDR (APB_BASEADDR + 0x5000)
#define TIM_BASEADDR (APB_BASEADDR + 0x6000)

#define GPIOC           ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define GPIOD           ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define FND           ((FND_TypeDef *) FND_BASEADDR)
#define TIM           ((TIM_TypeDef *) TIM_BASEADDR)


//////////// Timer/////////////
void TIM_start(TIM_TypeDef *tim);
void TIM_stop(TIM_TypeDef *tim);
uint32_t TIM_readCount(TIM_TypeDef *tim);
void TIM_writePrescaler(TIM_TypeDef *tim, uint32_t psc);
void TIM_writeAutoReload(TIM_TypeDef *tim, uint32_t arr);
void TIM_clear(TIM_TypeDef *tim);
/////////////////////////////////


void delay(int n);
void fndEn(FND_TypeDef* FNDx, uint32_t n);
void fndfont(FND_TypeDef* FNDx, uint32_t fndFont);
void fndDot(FND_TypeDef* FNDx, uint32_t Dot);


int main()
{   
    uint32_t count = 0;
    uint32_t temp = 0;
    while(1)
    {   
        fndEn(FND, 0x01);

        for (int i=0; i<10000; i++){
            fndfont(FND, i);
            fndDot(FND, temp);
            temp++;
            delay(100);
        }
        count=0;
        temp=0;
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

void fndEn(FND_TypeDef* FNDx, uint32_t n){
    if(n == 1) {
        FNDx -> FCR = 0x01;
    } else{
        FNDx -> FCR = 0x00;
    }
}


void fndfont(FND_TypeDef* FNDx, uint32_t fndFont){
    FNDx-> FDR = fndFont;
}

void fndDot(FND_TypeDef* FNDx, uint32_t Dot){
    FNDx-> FPR = Dot;
}

/*==============================
    timer_function
*/

void TIM_start(TIM_TypeDef *tim){
    tim -> TCR |= (1<<0); //set enable bit
}

void TIM_stop(TIM_TypeDef *tim){
    tim -> TCR &= ~(1<<0); //reset enable bit
}

uint32_t TIM_readCount(TIM_TypeDef *tim){
    return tim -> TCNT;
}

void TIM_writePrescaler(TIM_TypeDef *tim, uint32_t psc){
    tim -> PSC = psc;
}

void TIM_writeAutoReload(TIM_TypeDef *tim, uint32_t arr){
    tim -> ARR = arr;
}

void TIM_clear(TIM_TypeDef *tim){
    tim -> TCR |= (1<<1); //set clear bit
    tim -> TCR &= ~(1<<1); //reset clear bit
}