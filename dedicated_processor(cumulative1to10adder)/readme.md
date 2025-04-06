# dedicated counter 설계

0부터 10까지 더하는 processor 설게하기

<img src = "https://github.com/goeun-oh/CPU-/blob/main/dedicated_processor(cumulative1to10adder)/blockdiagram.png" width=500px>

## 설계 과정

1. C 언어로 먼저 구현 (while문 활용)
2. datapath 구조 설계
3. C언어의 코드 순서를 ASM 차트로 만들어 control Unit 설계
4. top으로 묶어 마무리

<details>
<summary> 왜 if 문으로 간단하게 설계할 수 있는 것을 이렇게 로우레벨로 설계했을까? </summary>

로우레벨로 설계하는 이유는 하드웨어 설계의 기본 원리를 배우고, 향후 RISC-V CPU 설계를 위해 프로세서가 실제로 어떻게 동작하는지 알기 위함임. 고수준 언어로는 쉽게 처리할 수 있는 작업이라도, datapath와 control unit을 직접 설계해보는 과정에서 하드웨어를 더 잘 이해할 수 있음.

> RISC-V CPU 같은 프로세서는 정확하게 동작해야해서 hw로 설계된다.

</details>

### 1. C언어로 먼저 구현

```c
#include <stdio.h>

int main() {
    int sum = 0;
    int i = 0;

    while (i <= 10) {
        i++;
        sum += i;
    }
    return sum;
}
```

### datapath 구조 설계

<img src = "https://github.com/goeun-oh/CPU-/blob/main/dedicated_processor(cumulative1to10adder)/datapathBlockdiagram.png" width=300px>

### C언어 코드 순서를 ASM 차트로 만들어 control Unit 설계

<img src = "https://github.com/goeun-oh/CPU-/blob/main/dedicated_processor(cumulative1to10adder)/asm.png" width=300px>

- n 이 먼저 증가하고 그 다음 증가된 n 의 값을 피연산자로 가져와야하므로 state를 나누어 이를 분리했다.
- 먼저 `S1`에서 `adderMuxSel`을 0으로 변경하여 n+1이 연산되도록 한 다음, 다음 state인 `Nup`에서 이 값이 register에 반영되도록 `nEn`을 1로 변경했다.
- 이 다음 `SUMup` stage에서 sum 값 계산을 위해 `adderMuxSel`을 1로 변경하여 바뀐 n의 값을 피연산자로 가져왔고 해당 값을 n register가 반영하지 않게 하기 위해 `nEn`을 0으로 변경했다.
- 그 다음 stage 인 `S4`에서 sum 계산 값이 register에 반영되도록 하기위해 `sumEn`을 1로 변경하였다.

### top으로 묶어 마무리

- Schematic

<img src="https://github.com/goeun-oh/CPU-/blob/main/dedicated_processor(cumulative1to10adder)/schematic.png" width=300px>

- Simulation

<img src="https://github.com/goeun-oh/CPU-/blob/main/dedicated_processor(cumulative1to10adder)/simulation.png" width=300px>
