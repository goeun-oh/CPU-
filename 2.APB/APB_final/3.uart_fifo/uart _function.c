#include <stdint.h>

#define __IO    volatile

typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
}GPIO_TypeDef;

typedef struct {
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t FPR;
}FND_TypeDef;

typedef struct {
    __IO uint32_t FSR_TX;
    __IO uint32_t FSR_RX;
    __IO uint32_t FWD;
    __IO uint32_t FRD;
}FIFO_TypeDef;




#define APB_BASEADDR  0x10000000
#define GPOA_BASEADDR   (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR   (APB_BASEADDR + 0x2000)
#define GPIOC_BASEADDR  (APB_BASEADDR + 0x3000)
#define GPIOD_BASEADDR  (APB_BASEADDR + 0x4000)
#define FND_BASEADDR    (APB_BASEADDR + 0x5000)
#define FIFO_BASEADDR   (APB_BASEADDR + 0x6000)


// #define GPOA            ((GPIO_TypeDef *) GPOA_BASEADDR)
// #define GPIB            ((GPIO_TypeDef *) GPOB_BASEADDR)
// #define GPIOC           ((GPIO_TypeDef *) GPIOC_BASEADDR)
// #define GPIOD           ((GPIO_TypeDef *) GPIOD_BASEADDR)
// #define FND             ((FND_TypeDef *) FND_BASEADDR)
#define FIFO            ((FIFO_TypeDef *) FIFO_BASEADDR)

#define FND_ON          1
#define FND_OFF         0


void delay(int n);
void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);
void Switch_init(GPIO_TypeDef *GPIOx);
uint32_t Switch_read(GPIO_TypeDef *GPIOx);

void FND_init(FND_TypeDef *fnd, uint32_t ON_OFF);
void FND_writeCom(FND_TypeDef *fnd, uint32_t comport);
void FND_writeData(FND_TypeDef *fnd, uint32_t data);
void FND_dotData(FND_TypeDef *fnd, uint32_t data);

uint32_t FIFO_RX_writeCheck(FIFO_TypeDef *fifo);
uint32_t FIFO_TX_writeCheck(FIFO_TypeDef *fifo);
void FIFO_writeData(FIFO_TypeDef *fifo);
uint32_t FIFO_readData(FIFO_TypeDef *fifo);
void PC_loopback(FIFO_TypeDef *fifo, uint32_t *write);

int main()
{   
    uint32_t one = 1;
    uint32_t write =0;

    while(1){
    //받은거 read
    //fsr_TX[1]이 full이 아니면
        PC_loopback(FIFO, &write);
    }
    return 0;
    
};

void PC_loopback(FIFO_TypeDef *fifo, uint32_t *write){
    uint32_t one = 1;
    if(((FIFO_RX_writeCheck(FIFO) & (one))) ==0){
        FIFO_writeData(FIFO);
        *write = 0x01;
    }

    if((FIFO_TX_writeCheck(FIFO) & (one <<1)) == 0){
        if (*write & (one <<0)){
            FIFO_readData(FIFO);
            *write =0x00;
        }
    }

}


uint32_t FIFO_RX_writeCheck(FIFO_TypeDef *fifo)
{
    return fifo->FSR_RX;
}
uint32_t FIFO_TX_writeCheck(FIFO_TypeDef *fifo)
{
    return fifo->FSR_TX;
}

void FIFO_writeData(FIFO_TypeDef *fifo)
{
    fifo->FWD = fifo -> FRD;
}
uint32_t FIFO_readData(FIFO_TypeDef *fifo)
{
    return fifo -> FRD;
}

void delay(int n){
    uint32_t temp = 0;
    for (int i=0; i<n; i++) {
        for (int j=0; j<1000; j++) {
            temp++;
        }
    }
};