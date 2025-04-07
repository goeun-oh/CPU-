### 설계 변경사항
- register를 register file로 대체하여 구조 개선
> 여러 개의 Register가 필요할 수 있다!

- out 값이 기존 값을 계속 유지하도록 outPort를 Buffer에 연결하지 않고 Register를 통해 값 출력하기! (outBuf신호를 en로 받음)

```verilog
    register outReg(
        .clk(clk),
        .rst(rst),
        .en(outBuf),
        .d(rData2),
        .q(outPort)
    );
```

### 코드
*** simulation 시 String 값으로 출력할 수 있는 code ***

```verilog
    typedef enum { S0, S1, S2, S3, S5, S6, S7} state_e;
    state_e state, state_next;
```