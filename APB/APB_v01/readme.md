RAM 연동하기
=========================

RISC-V CPU<->APB Master <-> APB Slave (RAM)

![](schematic.png)


CPU 붙이니까 생각해야될것
- Mem Stage
CPU -> APB Master: wData, we
APB Master -> APB Slave: Sel