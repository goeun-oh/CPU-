[GPIO 만들기 (GPI+GPO 합치기)]

APB_SlaveInf에 IDR, ODR, MODER 이 있어야 한다.
& inout buffer 만들기 (input과 output을 동시에 사용하기 위해서)

MODER: 0x00
IDR : 0x04
ODR: 0x08

이렇게 register 3개 쓰기!!


c언어 코드: GPIO typdef 만들기
![](img.png)

