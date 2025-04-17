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

- multi cycle
> stage를 5단계로 나눈다. (기존 동작 clk을 5로 쪼갠다)
Fetch-> Decode-> Execute-> MemAccess-> WriteBack
clk을 5로 나눈다

<details>
<summary> 개별 단계 설명 </summary>

1. Fetch: 명령어 인출 (PC <-> ROM)
2. Decode: 명령어 해독(분석) (Controlunit signal 생성)
3. Execute: ALU 연산
4. MemAccess: 메모리(RAM) 접근
5. WriteBack: 결과 레지스터에 기록 (RAM -> 레지스터로 Read data 이동)

</details>

<details>
<summary> multi cycle이라고 모두 signle cycle보다 짧진 않다</summary>

![](single_multi비교.png)
ff 자체의 dealy가 있기 때문에 L-type의 경우 single cycle보다 더 긴 사이클을 가질 수 있다.

![](img.png)
</details>

---

<details>
<summary> stage 별 ff 배치를 위해 기존 single cycle 회로 분석 </summary>

![](img3.png)
multi-cycle에 맞춰 회로를 재배치하자
<details>
<summary> 회로 재구성 </summary>
![](img3.png)
수정된 회로 + 각 단계에 register 추가

**PC**
- PC는 이미 flip-flop이므로 추가할 필요 없음 -> but enable 신호 추가가 필요하다
- 이유: 한 명령어가 다 끝나기 전에 다른 명령어가 fetch 되서는 안된다.
- CU에 PCEn 신호가 추가되어야 한다

> FSM이 필요하다!
FSM은 CU에 구성하자


</details>

</details>

