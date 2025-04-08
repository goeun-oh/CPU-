**RISC-V CPU 설계**

명령어 RV32I 이용

- single-cycle Architecture
모든 명령어가 한 clk에서 끝난다.
<details>
    <summary> 장단점</summary>    
- 장점: 매우 simple
- 단점: 매우 느리다.
</details>


- multi-cycle Architecture
명령어마다 동작 CLK 수가 다르다.
<details>
    <summary> 장단점</summary>    
- 장점: single-cycle architecture 보다 조금 빠르다.
- 단점: single-cycle 보다 (조금) 복잡하다.
</details>

- pipeline (X) 
고려해야할 사항이 많아서 진행하지 않을 예정
개인적으로 구현
<details>
    <summary> 장단점</summary>    
- 장점: 매우 빠르다.
- 단점: 매우 복잡하다.
</details>

우리나라 어떤 팹리스 업체도 CPU를 만들지는 않음
업체 대부분 페리페러럴을 만든다
대부분 업체에서 ARM CORE(검증된 CPU) 갖다 쓰고 여기다가 페리페러럴 갖다 붙임

