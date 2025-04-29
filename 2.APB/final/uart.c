#include <stdint.h>

// __IO: volatile 키워드 (최적화 방지)
#define __IO volatile

// GPOA: 출력용 레지스터 구조체
typedef struct {
    __IO uint32_t MODER; // 모드 설정 (출력 여부)
    __IO uint32_t ODR;   // 출력 데이터
} GPOA_TypeDef;

// GPIB: 입력용 레지스터 구조체
typedef struct {
    __IO uint32_t MODER; // 모드 설정 (입력 여부)
    __IO uint32_t IDR;   // 입력 데이터
} GPIB_TypeDef;

// GPIO 구조체 정의
typedef struct {
    __IO uint32_t MODER;  // 모드 설정 (출력/입력)
    __IO uint32_t IDR;    
    __IO uint32_t ODR;    
} GPIOC_TypeDef;

typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
} GPIOD_TypeDef;

typedef struct {
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t FPR;
} FND_TypeDef;

typedef struct {
    __IO uint32_t FWD;
    __IO uint32_t FRD;
    __IO uint32_t FSR_tx;
    __IO uint32_t FSR_rx;
} UART_TypeDef;

typedef struct{
    __IO uint32_t TCR;
    __IO uint32_t TCNT;
    __IO uint32_t PSC;
    __IO uint32_t ARR;

} TIMER_TypeDef;



// 각 장치의 주소 정의
#define APB_BASEADDR  0x10000000
#define GPOA_BASEADDR 0x10001000
#define GPIB_BASEADDR 0x10002000
#define GPIOC_BASEADDR 0x10003000
#define GPIOD_BASEADDR 0x10004000
#define FND_BASEADDR   0x10005000
#define UART_BASEADDR   0x10006000
#define TIMER0_BASEADDR   0x10007000

// 주소를 구조체 포인터에 매핑
#define GPOA ((GPOA_TypeDef *) GPOA_BASEADDR)
#define GPIB ((GPIB_TypeDef *) GPIB_BASEADDR)
#define GPIOC ((GPIOC_TypeDef *) GPIOC_BASEADDR)
#define GPIOD ((GPIOD_TypeDef *) GPIOD_BASEADDR)
#define FND ((FND_TypeDef *) FND_BASEADDR)
#define UART ((UART_TypeDef *) UART_BASEADDR)
#define TIMER0 ((TIMER_TypeDef *) TIMER_BASEADDR)

// 함수 프로토타입
void delay(int n);

//LED 관련 함수
void LED_init(GPIOC_TypeDef *GPIOx);
void LED_write(GPIOC_TypeDef *GPIOx, uint32_t data);

// SW 관련 함수
void Switch_init(GPIOD_TypeDef *GPIOx);
uint32_t Switch_read(GPIOD_TypeDef *GPIOx);

//FND 관련 함수
void FND_en(FND_TypeDef *FNDx);
void FND_FDR_write(FND_TypeDef *FNDx, uint32_t data);
void FND_FPR_write(FND_TypeDef *FNDx, uint32_t data);

// UART 관련 함수
void UART_tx_write(UART_TypeDef *UARTx, uint32_t data);
uint32_t UART_rx_read(UART_TypeDef *UARTx);
uint32_t UART_FSR_rx(UART_TypeDef *UARTx);
uint32_t UART_FSR_tx(UART_TypeDef *UARTx);
uint32_t UART_receive(UART_TypeDef *UARTx);

//TIMER 관련 함수
void TIM_start(TIMER_TypeDef *TIMERx);
void TIM_stop(TIMER_TypeDef *TIMERx);
void TIM_clear(TIMER_TypeDef *TIMERx);
uint32_t TIM_readCounter(TIMER_TypeDef *TIMERx);
void TIM_writePrescaler(TIMER_TypeDef *TIMERx, uint32_t psc);
void TIM_writeAutoReload(TIMER_TypeDef *TIMERx, uint32_t arr);




// 메인 함수
int main() {
    delay(3000);
    Switch_init(GPIOD);   // GPIOD: 입력 설정
    LED_init(GPIOC);      // GPIOC: 출력 설정
    FND_en(FND);

    uint32_t temp_sw;
    uint32_t temp_stopwatch = 0;
    uint32_t temp_dot =1;
    uint32_t one = 1;
    FND_FDR_write(FND, temp_stopwatch);
    FND_FPR_write(FND,temp_dot);

    uint32_t temp_uart='y';
    uint32_t temp_FSR_rx;
    uint32_t temp_FSR_tx;
    uint32_t run_flag=0;
    uint32_t received =0;


    while (1) {
        temp_sw = Switch_read(GPIOD);
        
        received = UART_receive(UART);
        if (received != 0xFFFFFFFF) {
        
            temp_uart = received;
        }

    if (temp_uart == 'r' || temp_uart == 'R') {
        run_flag = 1;
    }
    else if (temp_uart == 's' || temp_uart == 'S') {
        run_flag = 0;
    }


        if(run_flag || temp_sw & (1<<2)) {
            // LED_write(GPIOC, one);
            if(temp_stopwatch == 9999){
                temp_stopwatch = 0;
            } else {
                delay(100);
                temp_stopwatch = temp_stopwatch+1;
            }
            FND_FDR_write(FND, temp_stopwatch);
            // UART_send_stopwatch(UART, temp_stopwatch);
            delay(1000);
            temp_dot <<= 1;
            if (temp_dot > 0x8) temp_dot = 1; 
            FND_FPR_write(FND,temp_dot);
        } else {
            temp_stopwatch =0;
            temp_dot =1;
            FND_FDR_write(FND, temp_stopwatch);
            FND_FPR_write(FND,temp_dot);
        }

        if (temp_sw & (1<<0)) {
        if (!(UART_FSR_tx(UART) & (1<<1))) {   // fresh하게 읽기
            UART_tx_write(UART, temp_uart);
        }
    }

    }

    return 0;
}

// 지연 함수 (busy-wait)
void delay(int n) {
    volatile uint32_t temp = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < 1000; j++) {
            temp++;
        }
    }
}

// LED 출력용 GPIO 초기화 (출력 모드)
void LED_init(GPIOC_TypeDef *GPIOx) {
    GPIOx->MODER = 0xFF;  // 8비트 모두 출력
}

// LED 데이터 출력
void LED_write(GPIOC_TypeDef *GPIOx, uint32_t data) {
    GPIOx->ODR = data;
}

// 스위치 입력용 GPIO 초기화 (입력 모드)
void Switch_init(GPIOD_TypeDef *GPIOx) {
    GPIOx->MODER = 0x00;  // 8비트 모두 입력
}

// 스위치 입력값 읽기
uint32_t Switch_read(GPIOD_TypeDef *GPIOx) {
    return GPIOx->IDR;
}

// FND 관련 함수

void FND_en(FND_TypeDef *FNDx){
    FNDx->FCR = 0x01;
}


void FND_FDR_write(FND_TypeDef *FNDx, uint32_t data){
    FNDx->FDR = data;
}

void FND_FPR_write(FND_TypeDef *FNDx, uint32_t data){
    FNDx->FPR = data;
}

//UART 관련 함수

void UART_tx_write(UART_TypeDef *UARTx, uint32_t data){
    UARTx->FWD = data;
}

uint32_t UART_rx_read(UART_TypeDef *UARTx){
    return UARTx->FRD;
}

uint32_t UART_FSR_rx(UART_TypeDef *UARTx){
    return UARTx->FSR_rx;
}

uint32_t UART_FSR_tx(UART_TypeDef *UARTx){
    return UARTx->FSR_tx;
}

uint32_t UART_receive(UART_TypeDef *UARTx) {
    if (!(UART_FSR_rx(UARTx) & (1 << 1))) {
        delay(10);
        if (!(UART_FSR_rx(UARTx) & (1 << 1))) {
            return UART_rx_read(UARTx);
        }
    }
    return 0xFFFFFFFF; // 수신 실패 표시 (or 다른 에러 값)
}


// Timer 관련 함수

void TIM_start(TIMER_TypeDef *TIMERx){
    TIMERx->TCR |= (1 << 0); 
    TIMERx->TCR &= ~(1 << 1); 
}

void TIM_stop(TIMER_TypeDef *TIMERx){
    TIMERx->TCR &= ~(1 << 0); 
    TIMERx->TCR &= ~(1 << 1);
}

void TIM_clear(TIMER_TypeDef *TIMERx){
    TIMERx->TCR &= ~(1 << 0); 
    TIMERx->TCR |= (1 << 1);
    TIMERx->TCR &= ~(1 << 1); 

}

uint32_t TIM_readCounter(TIMER_TypeDef *TIMERx){
    return TIMERx->TCNT;
}

void TIM_writePrescaler(TIMER_TypeDef *TIMERx, uint32_t psc){
    TIMERx->PSC = psc;
}

void TIM_writeAutoReload(TIMER_TypeDef *TIMERx, uint32_t arr){
    TIMERx->ARR = arr;
}
