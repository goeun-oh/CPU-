## SPI Slave module schematic
![](schematic.png)

### Synchronizer 만들기
SCLK의 rising edge와 falling edge를 detect하기 위해 synchronizer를 만든다.
이를 위해 system clk을 받아 동기화 한다.
![](synchronizer.png)