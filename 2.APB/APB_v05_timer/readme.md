### Timer
![](module.png)
![](top.png)


32 bit Counter
1ms(주파수 1kHz) 간격으로 counter 1 증가 
enable 신호가 들어오면 카운트 시작(1: run, 0: stop)
0~4,294,967,295(2^32-1)까지 카운트 가능

**APB Bus**
- TCR: Timer Control Register
    - TCR[0] : enable 신호 (1: run, 0: stop)
    - TCR[1] : clear 신호 (1: counter<=0)
- TCNT: Timer Counter Register (counter 값)


**Timer Controlelr**
- CLK Divder (enable, clk, reset, clear)

- Counter (clk, reset, clear)



