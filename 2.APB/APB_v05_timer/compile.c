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
#define TIM0           ((TIM_TypeDef *) TIM_BASEADDR)



#define BUTTON_1 4
#define BUTTON_2 5
#define BUTTON_3 6
#define BUTTON_4 7




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

void Button_init (GPIO_TypeDef *GPIOx);
uint32_t Button_getState(GPIO_TypeDef *GPIOx);

void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);
void func1(uint32_t *prevTime, uint32_t *data);
void func2(uint32_t *prevTime, uint32_t *data);
void func3(uint32_t *prevTime, uint32_t *data);
void func4(uint32_t *prevTime, uint32_t *data);
void power(uint32_t *prevTime, uint32_t *data);

enum {FUNC1, FUNC2, FUNC3, FUNC4};

int main()
{   

    uint32_t func1PrevTime =0;
    uint32_t func1Data =0;
    uint32_t func2PrevTime =0;
    uint32_t func2Data =0;
    uint32_t func3PrevTime =0;
    uint32_t func3Data =0;
    uint32_t func4PrevTime =0;
    uint32_t func4Data =0;
    uint32_t powerPrevTime =0;
    uint32_t powerData =0;



    LED_init(GPIOC);
    Button_init(GPIOD);

    TIM_writePrescaler(TIM0, 100000-1);
    TIM_writeAutoReload(TIM0, 0xffffffff);
    TIM_start(TIM0);
    uint32_t state = FUNC1;
    
    while(1)
    {
        power(&powerPrevTime, &powerData);
        
        switch (state){
            case FUNC1:
                func1 (&func1PrevTime, &func1Data);
            break;
            case FUNC2:
                func2 (&func2PrevTime, &func2Data);
                break;
            case FUNC3:
                func3 (&func3PrevTime, &func3Data);
                break;
            case FUNC4:
                func4 (&func4PrevTime, &func4Data);
            break;
        }

        switch (state)
        {
        case FUNC1:
            if(Button_getState(GPIOD) & (1 << BUTTON_2)) state = FUNC2;
            else if (Button_getState(GPIOD) & (1 << BUTTON_3)) state = FUNC3;
            else if (Button_getState(GPIOD) & (1 << BUTTON_4)) state = FUNC4;
            else state = FUNC1;
        break;        
        case FUNC2:
            if(Button_getState(GPIOD) & (1 << BUTTON_1)) state = FUNC1;
            else if (Button_getState(GPIOD) & (1 << BUTTON_3)) state = FUNC3;
            else if (Button_getState(GPIOD) & (1 << BUTTON_4)) state = FUNC4;
            else state = FUNC2;
        break;        
        case FUNC3:
            if(Button_getState(GPIOD) & (1 << BUTTON_1)) state = FUNC1;
            else if (Button_getState(GPIOD) & (1 << BUTTON_2)) state = FUNC2;
            else if (Button_getState(GPIOD) & (1 << BUTTON_4)) state = FUNC4;
            else state = FUNC3;
        break;        
        case FUNC4:
            if(Button_getState(GPIOD) & (1 << BUTTON_1)) state = FUNC1;
            else if (Button_getState(GPIOD) & (1 << BUTTON_2)) state = FUNC2;
            else if (Button_getState(GPIOD) & (1 << BUTTON_3)) state = FUNC3;
            else state = FUNC4;
        break;        
        }
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


/*=============================
    button driver
  =============================  */

void Button_init (GPIO_TypeDef *GPIOx){
    GPIOx -> MODER &= 0x00;
}

uint32_t Button_getState(GPIO_TypeDef *GPIOx){
    return GPIOx -> IDR;
}

/*=============================
    LED Control
  =============================  */

void LED_init(GPIO_TypeDef *GPIOx)
{
    GPIOx->MODER =0xff;
}
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data)
{
    GPIOx->ODR = data;
}


void func1(uint32_t *prevTime, uint32_t *data){
    uint32_t curTime = TIM_readCount(TIM0);
    if (curTime - *prevTime < 200) return;
    *prevTime = curTime;
    
    *data ^= 1<<1;
    LED_write(GPIOD, *data);
}
void func2(uint32_t *prevTime, uint32_t *data){
    uint32_t curTime = TIM_readCount(TIM0);
    if (curTime - *prevTime < 500) return;
    *prevTime = curTime;
    

    *data ^= 1<<2;
    LED_write(GPIOD, *data);

}
void func3(uint32_t *prevTime, uint32_t *data){
    uint32_t curTime = TIM_readCount(TIM0);
    if (curTime - *prevTime < 1000) return;
    *prevTime = curTime;

    *data ^= 1<<3;
    LED_write(GPIOD, *data);

}
void func4(uint32_t *prevTime, uint32_t *data){    
    uint32_t curTime = TIM_readCount(TIM0);
    if (curTime - *prevTime < 1500) return;
    *prevTime = curTime;

    *data ^= 1<<4;
    LED_write(GPIOD, *data);
}
void power(uint32_t *prevTime, uint32_t *data){
    uint32_t curTime = TIM_readCount(TIM0);
    if (curTime - *prevTime < 500) return;
    *prevTime = curTime;

    *data ^= 1<<0;
    LED_write(GPIOD, *data);

}