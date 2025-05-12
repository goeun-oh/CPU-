**AXI와 APB 차이** (면접)
APB는 half-duplex (전송 or 수신만 가능 (동시 불가))
AXI는 full-duplex (전송 수신 **동시에** 가능)

APB 는 bus (broadcasting -> address, data line이 모든 peripheral에 연결되어 select 신호로 동작시킴)
AXI는 point to point (bus X, channel이 각각 따로 존재. 따라서 wirte와 read 동시에가능하나 bandwidth가 더 늘어날 수 있다.)


"Valid-Ready handshake"

**AMBA protocol 의 역사**
![](img.png)
AXI4, AXI-Lite를 가장 많이 쓴다.


### AXI document
![](img2.png)

AXI Master - interconnect - AXI Slave


[multi-master system]
![](img3.png)
master가 여러개가 될 수 있다.

"The AXI protocol defines the signals and timing of the point-to-point connections between masters and slaves"
"The AXI protocol is a point-to-point specification, not a bus specification." 
-> bus spec이 아니고 point-to-point spec이다. 

[AXI channels]
![](img4.png)
각 pheripheral 마다 각각의 독립적인 channel(port)가 따로 존재한다.

![](img5.png)
이렇게 AW, W, B, AR, R 이 pheripheral마다 따로 존재한다. (공유 X)

APB 에서도 AXI 에서도 master가 slave를 바라볼 때 mem 처럼 바라본다.

각 channel은 unidirectional 이다.(방향이 정해져있다)

"There is no timing relationship between the groups of read and write channels." -> write, read 동시 가능

### channel handshake
모든 channel에 valid와 ready signal이 존재한다.
source가 valid, destination이 ready
![](img6.png)

valid : source -> destination
ready: destination -> source

비동기 handshake가 아니고, clk 신호에 맞춰서 동작해야한다.

### transfer와 transaction의 차이점
transfer는 channel에 대한 신호를 주고 받는다.
transaction은 모든 transfer을 의미한다.
![](img7.png)

"valid-ready handshake"

### channel transfer example
timing diagram을 참고하여 구현해보자
- info, valid 띄우고 Ready 띄우는 경우
![](tim1.png)
This example has the following sequence of events:
1. In clock cycle 2, the VALID signal is asserted, indicating that the data on the information channel is valid.
2. In clock cycle 3, the following clock cycle, the READY signal is asserted.
3. The handshake completes on the rising edge of clock cycle 4, because both READY and VALID signals are asserted.
The following diagram shows another example:


- Ready를 먼저 띄우고 info, valid 띄우는 경우
![](tim2.png)
This example has the following sequence of events:
1. In clock cycle 1, the READY signal is asserted.
2. The VALID signal is not asserted until clock cycle 3.
3. The handshake completes on the rising edge of clock cycle 4, when both VALID and READY are asserted

![](tim3.png)
The final example shows both VALID and READY signals being asserted during the clock cycle 3, as seen in the following diagram:

Again, the handshake completes on the rising edge of clock cycle 4, when both VALID and READY are asserted.
In all three examples, information is passed down the channel when READY and VALID are asserted on the rising edge of the clock signal.
Read and write handshakes must adhere to the following rules:
• A source cannot wait for READY to be asserted before asserting VALID.
• A destination can wait for VALID to be asserted before asserting READY.
These rules mean that READY can be asserted before or after VALID, or even at the same time