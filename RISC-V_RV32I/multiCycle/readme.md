- single cycle의 한계
<details>
<summary> 가장 긴 cycle은 SW/LW(L-type)<</summary>
PC-> ROM으로 addr 전송
ROM이 instruction을 regfile과 cu에 전달
CU가 instruction을 decoding하여 controlSignal 생성
sw일 경우 alu 연산 후 ram에 저장
</details>

> 1 clk을 쪼개면 어떨까? 
더 빨라질 수 있으나 명령어에 따라 다르다
L-type의 경우 가장 긴 사이클을 갖고, R-type이 가장 짧은 사이클을 갖는다.

> single cycle의 경우 모든 명령어가 같은 사이클을 갖는다.
명령어에 따라 CLK 수를 다르게 하자

<details>
<summary> multi cycle이라고 모두 signle cycle보다 짧진 않다</summary>

![](single_multi비교.png)
ff 자체의 dealy가 있기 때문에 L-type의 경우 single cycle보다 더 긴 사이클을 가질 수 있다.

</details>

> stage 
Fetch-> Decode-> Execute-> MemAccess-> WriteBack
clk을 5로 나눈다
