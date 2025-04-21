RAM 연동하기
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

