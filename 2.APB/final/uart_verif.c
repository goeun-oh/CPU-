#include <stdint.h>

#define __IO    volatile

typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
}GPIO_TypeDef;


typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
}GPI_TypeDef;

typedef struct {
    __IO uint32_t FWD;
    __IO uint32_t FRD;
    __IO uint32_t FSR_tx;
    __IO uint32_t FSR_rx;
}UART_TypeDef;


#define APB_BASEADDR  0x10000000
#define GPOA_BASEADDR (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR (APB_BASEADDR + 0x2000)
#define GPIOC_BASEADDR (APB_BASEADDR + 0x3000)
#define GPIOD_BASEADDR (APB_BASEADDR + 0x4000)
#define UART_BASEADDR (APB_BASEADDR + 0x6000)

#define GPIB             ((GPI_TypeDef *) GPIB_BASEADDR)
#define GPIOC           ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define GPIOD           ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define UART           ((UART_TypeDef *) UART_BASEADDR)




void delay(int n);
void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);
void Button_init(GPI_TypeDef *GPIx);
uint32_t Button_read(GPI_TypeDef *GPIx);
void Button_func(GPI_TypeDef *button, GPIO_TypeDef *led);

int main()
{   
    LED_init(GPIOC);
    Button_init(GPIB);
    uint32_t temp;
    uint32_t led;
    uint32_t flag;
    led =0x01;
    LED_write(GPIOC, 0x00);
    while(1)
    {   
        Button_func(GPIB, GPIOC, &led);
        delay(500);
    }
    return 0;
};

void Button_func(GPI_TypeDef *button, GPIO_TypeDef *led, uint32_t *led_value){

    uint32_t temp;
    uint32_t flag;

    temp = Button_read(GPIB);

    if(temp & (1<<0)) {
        flag =0x01;
    }
    if(flag) {
        if(!(Button_read(GPIB)) & (1<<0)){
            LED_write(GPIOC, led);
            *led_value ^= (1<<0);
            flag =0x00;
        }
    }

}




void LED_init(GPIO_TypeDef *GPIOx)
{
    GPIOx->MODER = 0xff;
}
void Button_init(GPI_TypeDef *GPIx)
{
    GPIx->MODER = 0x00;
}
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data)
{
    GPIOx->ODR = data;
}

uint32_t Button_read(GPI_TypeDef *GPIx)
{
    return GPIx->IDR;
}

void delay(int n){
    uint32_t temp = 0;
    for (int i=0; i<n; i++) {
        for (int j=0; j<1000; j++) {
            temp++;
        }
    }
};