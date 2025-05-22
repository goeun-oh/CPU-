Master는 IP화, 따로.
SLave는 다른 basys3 모듈에 합성 후 IP화 한 Master 와 포트 연결 (이때 꼭 같은 GND에 연결되어 있어야함)

빵판이 필요할려나?? ...


___
기본적인 WRITE FLOW 완료
> slave 주소 주고 -> 주소 맞다면 write ㄱㄱ 하는 간단한 동작

이제 READ 고려해야함.
+ ACK? 신호 처리는?
ACK를 저장할 register를 하나더 만든 후, C언어에서 주소 전송 후 ACK를 받았다면 다음 DATA나 STOP 을 보내게 해야함

---

