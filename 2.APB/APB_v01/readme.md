### RAM 연동하기
=========================

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


---
GPO Test code 
1. 8 led 동시 점멸
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

2. shift
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


### GPI 연동하기
Mode Register, inputData Register
GPI input에 sw 연결
![](img3.png)

mode Reg가 0이어야 IDR에 write이 가능
