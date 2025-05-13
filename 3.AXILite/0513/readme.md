AXI4에 GPIO IP 붙이기

![alt text](schematic.png)

![alt text](schematic2.png)


state machine
![alt text](state_machine.png)


testbench 결과
[](tb_AXI4_Lite_GPIO.sv)
![alt text]({99A77735-0088-42C1-8721-8EFD6C1A10F4}.png)



vivado에서 제공하는 ip
![alt text]({59F700C8-56F4-4C1E-995A-CD74644E5FC6}.png)
![alt text]({65CAFC5B-4511-41B7-896D-61DB4EE25BFC}.png)
![alt text]({BCD7AA27-D2CD-4670-9C5D-B9FF814BA75E}.png)
AXI4 Lite, Peripheral 이니까 slave
![alt text]({0EE33B10-92BD-40BA-8C4C-5AB56CD29B76}.png)

저장경로
![alt text]({9E46D1B5-6791-405B-A27B-2028F1D2D642}.png)


![alt text]({8C46DA40-8379-4875-A637-FA6276C53A34}.png)
top : [](GPIO_v1_0.v)
intf: [](GPIO_v1_0_S00_AXI.v)