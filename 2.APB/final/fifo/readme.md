## 1. FIFO 설계

FIFO 는 RAM과 FIFO CU로 구성됨

[Block Diagram]
????????????????????????????????????/

###  (1) RAM
왜 보통 RAM 설계 시 reset 신호를 쓰지 않을까?
-> RAM은 보통 내부적으로 수천 개의 저장 셀을 갖고 있어 모든 셀의 reset을 연결하면 회로 복잡도가 급증하기에 reset을 생략하고 초기화를 따로 진행한다.


**4개의 cell을 가지는 RAM 설계**
- addr 2 bit 필요 (0, 1, 2, 3)
- data width는 8bit

### (2) FIFO_CU
FIFO는 기본적으로 선입 선출 queue.

RAM 에 저장된 data를 write or read 하기 위해 
- write, read pointer가 필요 (`wptr`, `rptr`)
- 메모리 공간이 가득 찼는지/ 비었는지 알려주는 control 신호 필요 (`empty`, `full`)

**상태**
상태는 다음과 같은 3가지 상태가 존재

- Read 만 수행
- Write 만 수행
- Read Write 동시에 수행

각 상태 별로 `wtpr` `rptr` `empty` `full` 을 정의하고 RAM 에 연결한다.

### 2. FIFO systemVerilog simulation

