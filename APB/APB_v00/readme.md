- schematic
![](image.png)

- APB Master
![](APB_Master.png)

- state diagram
![](state_diagram.png)


- 임시저장소를 사용하여 addr, wdata 저장
상태가 IDLE-> SETUP으로 바뀌기전에 신호가 바뀔 수 있다.
따라서 IDLE 상태에서 addr, wdata를 임시저장소에 저장해 준 후 SETUP에서 그 임시저장소에 저장된 데이터를 가져온다.
