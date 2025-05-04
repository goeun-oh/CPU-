#include <stdint.h>

#define __IO volatile

/********************************************************
 * 레지스터 구조체 정의
 ********************************************************/

// GPO 출력 포트
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t ODR;
} GPO_TypeDef;

// GPI 입력 포트
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
} GPI_TypeDef;

// FND 제어용 구조체
typedef struct {
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t FPR;
} FND_TypeDef;

// GPIO 공통 포트 구조체
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
} GPIO_TypeDef;

// 타이머
typedef struct {
    __IO uint32_t TCR;
    __IO uint32_t TCNT;
    __IO uint32_t PSC;
    __IO uint32_t ARR;
} TIM_TypeDef;

// 초음파 센서 구조체
typedef struct {
    __IO uint32_t UCR;
    __IO uint32_t USR;
    __IO uint32_t UDR;
} US_TypeDef;

// UART FIFO 구조체
typedef struct {
    __IO uint32_t FSR_TX;
    __IO uint32_t FSR_RX;
    __IO uint32_t FWD;
    __IO uint32_t FRD;
} FIFO_TypeDef;

// DHT11 센서 구조체
typedef struct {
    __IO uint32_t TRIG;
    __IO uint32_t HMD;
    __IO uint32_t TMP;
    __IO uint32_t SUM;
} DHT_TypeDef;

/********************************************************
 * 주소 매핑 (APB 기준)
 ********************************************************/
#define APB_BASEADDR      0x10000000
#define GPOA_BASEADDR     (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR     (APB_BASEADDR + 0x2000)
#define GPIOC_BASEADDR    (APB_BASEADDR + 0x3000)
#define GPIOD_BASEADDR    (APB_BASEADDR + 0x4000)
#define FND_BASEADDR      (APB_BASEADDR + 0x5000)
#define FIFO_BASEADDR     (APB_BASEADDR + 0x6000)
#define TIM_BASEADDR      (APB_BASEADDR + 0x7000)
#define US_BASEADDR       (APB_BASEADDR + 0x8000)
#define DHT_BASEADDR      (APB_BASEADDR + 0x9000)

#define GPOA   ((GPO_TypeDef *) GPOA_BASEADDR)
#define GPIB   ((GPI_TypeDef *) GPIB_BASEADDR)
#define GPIOC  ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define GPIOD  ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define FND    ((FND_TypeDef *) FND_BASEADDR)
#define FIFO   ((FIFO_TypeDef *) FIFO_BASEADDR)
#define TIM   ((TIM_TypeDef *) TIM_BASEADDR)
#define US     ((US_TypeDef  *) US_BASEADDR)
#define DHT    ((DHT_TypeDef *) DHT_BASEADDR)

/********************************************************
 * 함수 선언
 ********************************************************/
void delay(int n);

// GPO/GPI 제어 함수
void GPO_init(GPO_TypeDef* GPOx);
void GPO_write(GPO_TypeDef* GPOx, uint32_t data);

// FND 제어 함수
void fndEn(FND_TypeDef* FNDx, uint32_t n);
void fndfont(FND_TypeDef* FNDx, uint32_t fndFont);
void fndDot(FND_TypeDef* FNDx, uint32_t Dot);

// 버튼 및 LED 제어 함수
void Button_init(GPIO_TypeDef *GPIOx);
uint32_t Button_getState(GPIO_TypeDef *GPIOx);
void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);

// Switch 제어 함수
void sw_init(GPI_TypeDef *GPIx);
uint32_t sw_read(GPI_TypeDef *GPIx);

// 타이머 제어 함수
void TIM_start(TIM_TypeDef *tim);
void TIM_stop(TIM_TypeDef *tim);
uint32_t TIM_readCount(TIM_TypeDef *tim);
void TIM_writePrescaler(TIM_TypeDef *tim, uint32_t psc);
void TIM_writeAutoReload(TIM_TypeDef *tim, uint32_t arr);
void TIM_clear(TIM_TypeDef *tim);

// UART 제어 함수
uint32_t FIFO_RX_writeCheck(FIFO_TypeDef *fifo);
uint32_t FIFO_TX_writeCheck(FIFO_TypeDef *fifo);
void FIFO_writeData(FIFO_TypeDef *fifo);
uint32_t FIFO_readData(FIFO_TypeDef *fifo);

// 초음파 제어 함수
void US_start(US_TypeDef *USx, uint32_t data);
uint32_t US_dist_read(US_TypeDef *USx);
uint32_t US_check_vaild(US_TypeDef *USx);

// DHT 온습도 함수
void DHTinit(DHT_TypeDef *DHTx, uint32_t dht);
uint32_t DHTreadSUM(DHT_TypeDef* DHTx);
uint32_t DHTreadHMD(DHT_TypeDef* DHTx);
uint32_t DHTreadTMP(DHT_TypeDef* DHTx);
uint32_t Productfunc(uint32_t x, int n);
void Show_HMD();
void Show_TMP();
void Show_SUM();



// 초음파 측정 함수
uint32_t us_measure(uint32_t *autoMeasure);

// 온습도 측정 함수
void dht_measure(uint32_t *autoMeasure, uint32_t *temp, uint32_t *hmd, uint32_t *sum);




int main() {
    Button_init(GPIOD); // 버튼 기능 on
    sw_init(GPIB); // sw 기능 on
    fndEn(FND,1); //  fnd 기능 on

    uint32_t temp_sw = 0;
    uint32_t us_dist = 0; // 초음파 거리 측정값 
    uint32_t dht_t = 0;   // 온습도 온도 측정값
    uint32_t dht_h = 0;   // 온습도 습도 측정값
    uint32_t dht_c = 0;   // 온습도 체크섬 측정값

    uint32_t us_autoMeasure =0;
    uint32_t dht_autoMeasure =0;

    while (1) {
        temp_sw = sw_read(GPIB);
        uint32_t sw0_US_or_DHT = temp_sw & (1<<0); // FND 출력 선택을 위한 SW
        uint32_t sw1_DHT_Choose = temp_sw & (1<<1); // FND 출력 선택을 위한 SW

        us_dist = us_measure(&us_autoMeasure);  // 초음파 측정 함수
        dht_measure(&dht_t, &dht_h, &dht_c, &dht_autoMeasure); // 온습도 측정 함수

        // FND 출력 파트
        if (!sw0_US_or_DHT){   // SW0 == 0 (FND 초음파 출력)
            fndfont(FND, us_dist);
            fndDot(FND, 0x00);
        } 
        else if (sw0_US_or_DHT){    // SW0 == 1 (FND 온습도 출력)
            if(!sw1_DHT_Choose) {
                fndDot(FND, 0x04);
                fndfont(FND, dht_t); // 온도 출력
            } else {
                fndDot(FND, 0x04);
                fndfont(FND, dht_h); // 습도 출력
            }
        }

        delay(100);
        }

    return 0;
}


/********************************************************
 * 기본 유틸리티 함수
 ********************************************************/

// 루프 기반 딜레이 함수
void delay(int n) {
    volatile uint32_t temp = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < 1000; j++) {
            temp++;
        }
    }
}

/********************************************************
 * GPO/GPI 함수 (LED) / (switch) 
 ********************************************************/

// GPO 포트를 출력 모드로 초기화
void GPO_init(GPO_TypeDef* GPOx) {
    GPOx->MODER = 0xFF;
}

// GPO 포트에 값 출력
void GPO_write(GPO_TypeDef* GPOx, uint32_t data) {
    GPOx->ODR = data;
}

// GPI 포트를 입력 모드로 초기화 (switch)
void sw_init(GPI_TypeDef* GPIx) {
    GPIx->MODER = 0x00;
}

// GPI 포트의 입력 값 읽기 (switch)
uint32_t sw_read(GPI_TypeDef* GPIx) {
    return GPIx->IDR;
}

/********************************************************
 * FND 제어 함수
 ********************************************************/

// FND 출력 활성화 또는 비활성화
void fndEn(FND_TypeDef* FNDx, uint32_t n) {
    FNDx->FCR = (n == 1) ? 0x01 : 0x00;
}

// FND에 숫자 출력
void fndfont(FND_TypeDef* FNDx, uint32_t fndFont) {
    FNDx->FDR = fndFont;
}

// FND 소수점(dot) 위치 설정
void fndDot(FND_TypeDef* FNDx, uint32_t Dot) {
    FNDx->FPR = Dot;
}

/********************************************************
 * 버튼 및 LED 함수 (GPIO)
 ********************************************************/

// 버튼 입력 포트 초기화
void Button_init(GPIO_TypeDef *GPIOx) {
    GPIOx->MODER = 0x00000000;
}

// 버튼 입력 상태 읽기
uint32_t Button_getState(GPIO_TypeDef *GPIOx) {
    return GPIOx->IDR;
}

// LED 출력 포트 초기화
void LED_init(GPIO_TypeDef *GPIOx) {
    GPIOx->MODER = 0xff;
}

// LED 값 출력
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data) {
    GPIOx->ODR = data;
}

/********************************************************
 * 타이머 함수
 ********************************************************/

// 타이머 시작
void TIM_start(TIM_TypeDef *tim) {
    tim->TCR |= (1 << 0);
}

// 타이머 정지
void TIM_stop(TIM_TypeDef *tim) {
    tim->TCR &= ~(1 << 0);
}

// 현재 타이머 카운터 값 읽기
uint32_t TIM_readCount(TIM_TypeDef *tim) {
    return tim->TCNT;
}

// 타이머 프리스케일러 설정
void TIM_writePrescaler(TIM_TypeDef *tim, uint32_t psc) {
    tim->PSC = psc;
}

// 타이머 자동 리로드 값 설정
void TIM_writeAutoReload(TIM_TypeDef *tim, uint32_t arr) {
    tim->ARR = arr;
}

// 타이머 카운터 클리어
void TIM_clear(TIM_TypeDef *tim) {
    tim->TCR |= (1 << 1);
    tim->TCR &= ~(1 << 1);
}

/********************************************************
 * UART FIFO 함수
 ********************************************************/

// RX FIFO 상태 확인
uint32_t FIFO_RX_writeCheck(FIFO_TypeDef *fifo) {
    return fifo->FSR_RX;
}

// TX FIFO 상태 확인
uint32_t FIFO_TX_writeCheck(FIFO_TypeDef *fifo) {
    return fifo->FSR_TX;
}

// FIFO에 데이터 쓰기 (Loopback 테스트용)
void FIFO_writeData(FIFO_TypeDef *fifo) {
    fifo->FWD = fifo->FRD;
}

// FIFO에서 데이터 읽기
uint32_t FIFO_readData(FIFO_TypeDef *fifo) {
    return fifo->FRD;
}

/********************************************************
 * 초음파 센서 함수
 ********************************************************/

// 초음파 센서 트리거 시작
void US_start(US_TypeDef *USx, uint32_t data) {
    USx->UCR = data;
}

// 측정된 거리 값 읽기
uint32_t US_dist_read(US_TypeDef *USx) {
    return USx->UDR;
}

// 거리 데이터 유효성 확인
uint32_t US_check_vaild(US_TypeDef *USx) {
    return USx->USR;
}

/********************************************************
 * DHT11 온습도 함수
 ********************************************************/

// DHT 센서 트리거 (1: 시작, 0: 정지)
void DHTinit(DHT_TypeDef *DHTx, uint32_t dht) {
    DHTx->TRIG = (dht == 1) ? 0x01 : 0x00;
}

// DHT Checksum 값 읽기
uint32_t DHTreadSUM(DHT_TypeDef* DHTx) {
    return DHTx->SUM;
}

// DHT 습도값 읽기 및 정수+소수 합산
uint32_t DHTreadHMD(DHT_TypeDef* DHTx) {
    uint32_t frac = DHTx->HMD & 0x7F;
    uint32_t intg = (DHTx->HMD >> 8) & 0xFF;
    return Productfunc(intg, 100) + frac;
}

// DHT 온도값 읽기 및 정수+소수 합산
uint32_t DHTreadTMP(DHT_TypeDef* DHTx) {
    uint32_t frac = DHTx->TMP & 0x7F;
    uint32_t intg = (DHTx->TMP >> 8) & 0xFF;
    return Productfunc(intg, 100) + frac;
}

// 곱셈기 없이 x * n 구현
uint32_t Productfunc(uint32_t x, int n) {
    uint32_t y = 0;
    for (int i = 0; i < n; i++) {
        y += x;
    }
    return y;
}


/********************************************************
 * 초음파/ 온습도 측정 함수 (자동/ 수동 트리거 합친)
 ********************************************************/

// 초음파 수동 측정 함수 (거리 값 반환)
uint32_t us_measure(uint32_t *autoMeasure) {
    US_start(US, 0);  // 측정 준비

    if (Button_getState(GPIOD) & (1 << 5)) { // 수동 측정 트리거 부분 (버튼 입력)
        while (Button_getState(GPIOD) & (1 << 5));  
        US_start(US, 1);  
    } else if(*autoMeasure){
        US_start(US, 1);
    }


    uint32_t valid = US_check_vaild(US);
    uint32_t dist = US_dist_read(US);

    if (!(valid & 0x01)) { // 유효한지 확인, 유효할때만 dist값 내보내기
        return dist;
    } else {
        return 0xFFFFFFFF;       // 에러 값
    }
}


// 온습도 수동 측정 함수 (온도, 습도, 체크섬을 포인터로 반환)
void dht_measure(uint32_t *autoMeasure, uint32_t *temp, uint32_t *hmd, uint32_t *sum) {
    DHTinit(DHT, 0);

    if (Button_getState(GPIOD) & (1 << 6)) { // 수동 측정 트리거 부분 (버튼 입력)
        while (Button_getState(GPIOD) & (1 << 6));
        DHTinit(DHT, 1);
        delay(500);
    } else if(*autoMeasure){
        DHTinit(DHT, 1);
    }

    *temp = DHTreadTMP(DHT);
    *hmd  = DHTreadHMD(DHT);
    *sum  = DHTreadSUM(DHT);
}
