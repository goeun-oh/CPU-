![](image.png)


uart 를 loop 형식으로 붙임
!!!!!!!!!!!그림 !!!!!!!!
!!!!!!!!!!!전과 차이점!!!!!!!!!!!!!!! (UART와 uart INTF 간의)

(기존에는 we, re 가 자동으로 됐다면 이제는 pc에서 명령으로 조절)

해당 c 언어 부분
```c

int main()
{   
    uint32_t one = 1;
    uint32_t write =0;
    uint32_t read =0;

    while(1){
    //받은거 read
    //fsr_TX[1]이 full이 아니면
        if(((FIFO_RX_writeCheck(FIFO) & (one))) ==0){
            FIFO_writeData(FIFO);
            write = 0x01;
        }

        if((FIFO_TX_writeCheck(FIFO) & (one <<1)) == 0){
            if (write & (one <<0)){
                FIFO_readData(FIFO);
                write =0x00;
            }
        }

    }
    return 0;
    
};
```

application 통합을 위해 일단 이 부분 함수로 만들기
1. PC loop 함수
해당 함수는 그냥 pc 에서 받은게 있닫면 그대로 출력하는 함수임

2. PC loop 끊고 받은거만 내부 모듈의 정보만 내보내는 함수
-> 이거 새로 제작해야됨


해야할거
일단 1. PC loop 함수를 함수로 만들자!


**버전 관리**
[uart.c](uart.c) : pc loopback을 함수로 안만든 버전
[uart_function.c](uart_function.c) : pc loopback을 함수로 만든 버전
[uart_nonloop.c](uart_nonloop.c) : pc loop 끊는거 (기존 데이터 받기 위함) 만들기



---
pc loop 끊기 위해서 기존 FSR_TX 랑 FSR_RX 통합하기
현재 FSR은 `empty_RX`랑 `full_TX` 밖에 사용 안함
