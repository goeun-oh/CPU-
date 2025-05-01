### RAM 연동하기

RISC-V CPU<->APB Master <-> APB Slave (RAM)

![](schematic.png)


CPU 붙이니까 생각해야될것
- Mem Stage
![](image.png)
CPU -> APB Master: wData, we
APB Master -> APB Slave: Sel

Mem stage 에서 다음 stage로 넘어 가기 위한 조건은 Ready 신호가 High 여야 한다.


---

1. RISC-V CPU <-> APB Master 연결하기
2. APB Master <-> APB Slave(RAM) 연결하기
3. 주소 따라서 특정 peri에 잘 읽고 써지는지 확인하기 (simulation)

---

### GPO 연동하기기
![](img.png)
CPU <-> APB_Slave <-> GPO

[APB Slave -> GPO] : Mode Register, outData Register

GPO (3 -stage buffer) output 에 led 연결

mode의 offset: 0x00,
outData의 offset: 0x04

![](img2.png)
P1: GPO!
Mode offset: 0x1000_1000 + 0x00
outData offset: 0x1000_1000 + 0x04

(Memory Map base address: 0x1000_0000, peripheral offset: 0xxx)

결과는 CPU가 내보낸 data가 led로 출력되게 된다.

> 내가 만든 IP는 "GPO", 통신을 하기위해 APB Slave를 거친다.


**GPO Test code** 
1. 8 led 동시 점멸

<details>
<summary>GPO Test code</summary>

```c
#include <stdint.h>
#define GPOA_BASEADDR 0x10001000
#define GPOA_MODEREG *(uint32_t *)(GPOA_BASEADDR + 0x00)
#define GPOA_ODREG *(uint32_t *)(GPOA_BASEADDR + 0x04)
void delay(int n);

int main(){
    GPOA_MODEREG  = 0xff;

    while (1){
        GPOA_ODREG = 0xff;
        delay(500);
        GPOA_ODREG = 0x00;
        delay(500);
    }
    return 0;
}


void delay(int n)
{
    uint32_t temp = 0;
    for(int i=0; i<n; i++){
        for (int j=0; j< 1000; j++){
            temp++;
        }
    }
}
```
</details>

<details>
<summary>code 설명</summary>

```c
uint32_t : unsigned int 자료형
* : casting, 수식하는 값이 주소임을 알려줌
*(uint32_t *)(GPOA_BASEADDR + 0x00) : GPOA_BASEADDR + 0x00 주소에 있는 값을 읽어옴 (주소에 *이 붙었으니까 값임)
```
</details>

2. shift

<details>
<summary>GPO Test code</summary>

```c
#include <stdint.h>
#define GPOA_BASEADDR 0x10001000
#define GPOA_MODEREG *(uint32_t *)(GPOA_BASEADDR + 0x00)
#define GPOA_ODREG *(uint32_t *)(GPOA_BASEADDR + 0x04)
void delay(int n);

int main(){
    GPOA_MODEREG  = 0xff;

    while (1){
        GPOA_ODREG = (GPOA_ODREG<<1) | (GPOA_ODREG >>7);
        delay(500);
    }
    return 0;
}


void delay(int n)
{
    uint32_t temp = 0;
    for(int i=0; i<n; i++){
        for (int j=0; j< 1000; j++){
            temp++;
        }
    }
}
```
</details>


### GPI 연동하기
Mode Register, inputData Register
GPI input에 sw 연결
![](img3.png)

mode Reg가 0이어야 IDR에 write이 가능

1. switch를 눌렀을 때 led가 켜지게 하기

<details>
<summary>GPI Test code</summary>

```c
#include <stdint.h>
#define APB_BASEADDR 0x10000000
#define GPOA_BASEADDR (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR (APB_BASEADDR + 0x2000)

#define GPOA_MODEREG *(uint32_t *)(GPOA_BASEADDR + 0x00)
#define GPOA_ODREG *(uint32_t *)(GPOA_BASEADDR + 0x04)
#define GPIB_MODEREG *(uint32_t *)(GPIB_BASEADDR + 0x00)
#define GPIB_IDREG *(uint32_t *)(GPIB_BASEADDR + 0x04)


void delay(int n);

int main(){
    GPOA_MODEREG  = 0xff;
    GPIB_MODEREG = 0x00;
    while (1){
        GPOA_ODREG = GPIB_IDREG;
        delay(500);
    }
    return 0;
}


void delay(int n)
{
    uint32_t temp = 0;
    for(int i=0; i<n; i++){
        for (int j=0; j< 1000; j++){
            temp++;
        }
    }
}
```

</details>


------
c 언어 코드 설명

```c
#define __IO volatile

typedef struct {
    __IO uint32_t MODEREG; // mode register
    __IO uint32_t ODREG; // output data register
} GPO_TypeDef;

typedef struct {
    __IO uint32_t MODEREG; // mode register
    __IO uint32_t IDREG; // input data register
} GPI_TypeDef;
// 4 byte 자료형 2개, 따라서 총 8 byte의 크기를 가진 자료형
#define APB_BASEADDR 0x10000000
#define GPOA_BASEADDR (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR (APB_BASEADDR + 0x2000)

#define GPIB ((GPI_TypeDef *) GPIB_BASEADDR)

```

```c
unint32_t : 4byte unsigned int 자료형
volatile : 하드웨어 레지스터를 읽어올 때 사용 (하드웨어 레지스터는 CPU가 아닌 다른 장치에서 값을 바꿀 수 있음)
```

```lua
-------- 0x10001008  
ODREG  
-------- 0x10001004  
MODE Reg  
-------- 0x10001000  
```

------

<details>
<summary>더 고오급진 c 언어 test code</summary>

```c
#include <stdint.h>
#define __IO volatile 
// volatile: 컴파일러한테 최적화하지 말아라는 뜻

//사용자 정의 자료형
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t ODR;
}GPO_TypeDef;

typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
}GPI_TypeDef;

#define APB_BASEADDR 0x10000000
#define GPOA_BASEADDR (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR (APB_BASEADDR + 0x2000)

#define GPOA ((GPO_TypeDef *) GPOA_BASEADDR)
//GPOA_BASEADDR은 그냥 쓰면 숫자에 불과, 
//casting(*) 해줌으로써 주소를 의미하는 숫자임을 알려줌
//(GPO_TypeDef)는 자료형

#define GPIB ((GPI_TypeDef *) GPOA_BASEADDR)

#define GPOA_MODER *(uint32_t *)(GPOA_BASEADDR + 0x00)
#define GPOA_ODR *(uint32_t *)(GPOA_BASEADDR + 0x04)
#define GPIB_MODER *(uint32_t *)(GPIB_BASEADDR + 0x00)
#define GPIB_IDR *(uint32_t *)(GPIB_BASEADDR + 0x04)

void LED_init(GPO_TypeDef *GPOx);
void LED_write(GPO_TypeDef *GPOx, uint32_t data);
void Switch_init(GPI_TypeDef *GPIx);
uint32_t Switch_read(GPI_TypeDef *GPIx);


void delay(int n);

int main(){
    GPOA -> MODER = 0xff;
    GPIB -> MODER = 0x00;
//    GPOA_MODEREG  = 0xff;
//    GPIB_MODEREG = 0x00;
    while (1){
        GPOA -> ODR = GPIB -> IDR;
//        GPOA_ODREG = GPIB_IDREG;
//        delay(500);
    }
    return 0;
}


void delay(int n)
{
    uint32_t temp = 0;
    for(int i=0; i<n; i++){
        for (int j=0; j< 1000; j++){
            temp++;
        }
    }
}


void LED_init(GPO_TypeDef *GPOx){
    GPOx -> MODER = 0xff;
}


void LED_write(GPO_TypeDef *GPOx, uint32_t data){
    GPOx -> ODR = data;
}

void Switch_init(GPI_TypeDef *GPIx){
    GPIx-> MODER = 0x00;
}
uint32_t Switch_read(GPI_TypeDef *GPIx){
    return GPIx -> IDR;
}
```
</details>

만든거 main에 집어넣기

<details>
<summary> switch 에 따라 led 점등 방식이 달라지는 code </summary>

```c
#include <stdint.h>
#define __IO volatile 
// volatile: 컴파일러한테 최적화하지 말아라는 뜻

//사용자 정의 자료형
typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t ODR;
}GPO_TypeDef;

typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
}GPI_TypeDef;

#define APB_BASEADDR 0x10000000
#define GPOA_BASEADDR (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR (APB_BASEADDR + 0x2000)

#define GPOA ((GPO_TypeDef *) GPOA_BASEADDR)
//GPOA_BASEADDR은 그냥 쓰면 숫자에 불과, 
//casting(*) 해줌으로써 주소를 의미하는 숫자임을 알려줌
//(GPO_TypeDef)는 자료형

#define GPIB ((GPI_TypeDef *) GPOA_BASEADDR)

#define GPOA_MODER *(uint32_t *)(GPOA_BASEADDR + 0x00)
#define GPOA_ODR *(uint32_t *)(GPOA_BASEADDR + 0x04)
#define GPIB_MODER *(uint32_t *)(GPIB_BASEADDR + 0x00)
#define GPIB_IDR *(uint32_t *)(GPIB_BASEADDR + 0x04)

void LED_init(GPO_TypeDef *GPOx);
void LED_write(GPO_TypeDef *GPOx, uint32_t data);
void Switch_init(GPI_TypeDef *GPIx);
uint32_t Switch_read(GPI_TypeDef *GPIx);


void delay(int n);

int main(){
    LED_init(GPOA);
    Switch_init(GPIB);

    uint32_t temp;
    uint32_t one =1;

    while (1){
        temp=Switch_read(GPIB);
        if (temp & (1 <<0)){
            LED_write(GPOA,temp);
        }
        else if (temp & (1<<1)){
            LED_write(GPOA, one);
            one = (one <<1) | (one >> 7);
            delay(500);
        }else if (temp & (1 <<2)){
            LED_write(GPOA, one);
            one = (one >>1) | (one << 7);
            delay(500);
        } else {
            LED_write(GPOA, 0xff);
            delay(500);
            LED_write(GPOA, 0x00);
            delay(500);
        }
//        delay(500);
    }
    return 0;
}


void delay(int n)
{
    uint32_t temp = 0;
    for(int i=0; i<n; i++){
        for (int j=0; j< 1000; j++){
            temp++;
        }
    }
}


void LED_init(GPO_TypeDef *GPOx){
    GPOx -> MODER = 0xff;
}


void LED_write(GPO_TypeDef *GPOx, uint32_t data){
    GPOx -> ODR = data;
}

void Switch_init(GPI_TypeDef *GPIx){
    GPIx-> MODER = 0x00;
}
uint32_t Switch_read(GPI_TypeDef *GPIx){
    return GPIx -> IDR;
}
```

</details>