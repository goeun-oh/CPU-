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

## 2. FIFO systemVerilog simulation
![](image.png)

### interface 모듈 구성
![](image-1.png)
clk에 딱 맞춰서 data가 변경된다면 data 값이 변경 전 data인지 변경 후 data인지 애매할 때가 있다. (따라서 보통 표준 timing diagram을 보면 clk에 맞춰서 data를 변경시키지 않고 약간의 delay 후 data가 변경되도록 그린다)

**system verilog 에서 delay를 주는 방법**
clocking block, modport 사용

- modport
DUT에서는 `input`, `output` 방향이 명확하지만,
interface로 묶으면 신호들이 전부 다 `logic`이 되어 방향이 사라지게됨

> modport를 이용하여 `input`, `output`을 구분하여 interface에 접근하는 방향을 명시적으로 구분할 수 있음

- clocking block
특정 clk event에 동기화되며, 입출력 신호에 대해 skew를 정의할 수 있음
(race condition 방지 가능)


**다음과 같이 clocking block과 modport를 함께 사용하는 것이 일반적이다**
```systemVerilog
    interface fifo_interface (
        input logic clk,
        input logic reset
    );
    ....
    ....
    //driver용 clocking block
    clocking drv_cb @(posedge clk); 
        default input #1 output #1;
        // write side
        output wdata;
        output wr_en;
        input full;
        // read side
        input rdata;
        output rd_en;
        input empty;
    endclocking

    //monitor용 clocking block
    clocking mon_cb @(posedge clk); 
        default input #1 output #1;
        // write side
        input wdata;
        input wr_en;
        input full;
        // read side
        input rdata;
        input rd_en;
        input empty;
    endclocking

    modport drv_mport(clocking drv_cb, input reset);
    modport mon_mport(clocking mon_cb, input reset);

```
만일 clocking block 만 사용했을 경우 clocking  모듈 안에 정의된 in/output 신호들은 clocking block 안에서만 적용되므로, 다른 class에서 interface를 불러오고 clocking block의 output에 write하는 것이 가능하다.

```systemVerilog
    modport drv_mport(clocking drv_cb, input reset);
```
이런식으로 modport와 함께 사용하면 `clk`을 기준으로 input output에 skew를 줄 수 있고, clocking block에 정의된 signal의 방향이 그 modport의 signal direction(ex) driver, monitor)의 direction이 된다.


**interface에서 괄호 안에 정의한 신호와 밖의 신호들의 차이?**

```systemVerilog
interface fifo_interface (
    input logic clk,
    input logic reset
);
    // write side
    logic [7:0] wdata;
    logic       wr_en;
    logic       full;
```

- 괄호 안에 잇는 신호들은 interface를 인스턴스화할 때 전달받는 외부 입력 (testbench의 initial 값들을 넘겨 받는 것)

- 괄호 밖에 선언들은 interface와 DUT간에 연결되는 I/O 신호들
