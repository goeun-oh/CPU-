## 설계 방법론
### SCLK 생성 logic
![](img.png)
CPHA가 0일 때와 1일 때 차이점은 1일 때가 0일때의 반주기 delay 인것 밖에 없음


![](tim.png)
SPI mode 1은 SCLK이 low 일때 까지 delay 유지
SPI mode 3은 SCLK이 high 일때 까지 delay 유지

기본적으로 `CPOL == 0` 을 기준으로 `r_sclk`의 값을 정의하고, `CPOL == 1`이면 기존 `r_sclk` 값을 반전한다.

### SPI master simulation 결과
**CPOL = 0, CPHA = 0, Mode =0**
![](case1.png)
state 1이 존재하지 않고 바로 CP0 CP1 상태가 나오는 것을 확인할 수 있다.
delay X, CP1일 때 High.

**CPOL = 0, CPHA = 1, Mode = 1**
![](case2.png)
state 1이 존재하여 delay가 된 후 CP0 CP1 상태가 번갈아 나가는 것을 확인할 수 있다.
delay 존재, CP0일 때 High.

**CPOL = 1, CPHA = 0, Mode = 2**
![](case3.png)
delay X, CP0 일 때 High

**CPOL = 1, CPHA = 1, Mode = 3**
![](case4.png)
delay 존재, CP1 일 때 High.



### SPI Slave mode 설정하기
slave에 따라 mode 설정이 다르고 정해져있다.
Slave에서 CPHA, CPOL을 설정하는 경우는 없다(고정되어서 나온다.) 
slave에 따라서 master가 알맞는 CPHA, CPOL을 설정해야 한다.

- ex 1) mt41t93의 경우 CPOL=0, CPHA=0으로 설정하는 slave임
![](mt41t93.png)



### 상용 spi doc 참고하여 spi slave 설계
![](readmode.png)

![](writemode.png)