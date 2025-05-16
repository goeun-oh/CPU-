## SPI (Serial Peripheral Interface)
serial 통신 
### 신호선 구성 (4개)
![](image.png)
- SCLK (CLK)
- MOSI (Master Out Slave In)
- MISO (Master In Slave Out)
- CS (Chip Select)

### 특징
- synchronous 통신 방식 (master가 clk 생성)
- Master <-> Slave 구조
- 고속 통신 지원 (UART, I2C 에 비해 속도가 빠르다.)
- 다중 장치 지원 
    - 하나의 Master가 여러 Slave와 통신 가능 (BUS)
    - data broadcasting, chip select


![](image-1.png)

![](image-2.png)

![](image-3.png)