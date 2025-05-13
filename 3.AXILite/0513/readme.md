### AXI4에 GPIO IP 붙이기

![alt text](schematic.png)

![alt text](schematic2.png)


state machine
![alt text](state_machine.png)


testbench 결과
[](tb_AXI4_Lite_GPIO.sv)
![alt text]({99A77735-0088-42C1-8721-8EFD6C1A10F4}.png)



### vivado에서 제공하는 AXI4-Lite intf ip
![alt text]({59F700C8-56F4-4C1E-995A-CD74644E5FC6}.png)
![alt text]({65CAFC5B-4511-41B7-896D-61DB4EE25BFC}.png)
![alt text]({BCD7AA27-D2CD-4670-9C5D-B9FF814BA75E}.png)
AXI4 Lite, Peripheral 이니까 slave
![alt text]({0EE33B10-92BD-40BA-8C4C-5AB56CD29B76}.png)

저장경로
![alt text]({9E46D1B5-6791-405B-A27B-2028F1D2D642}.png)


![alt text]({8C46DA40-8379-4875-A637-FA6276C53A34}.png)
top : [](GPIO_v1_0.v)
intf: [](GPIO_v1_0_S00_AXI.v)

### cpu 붙이기
xilinx에서 제공하는 ip
![alt text]({AC6EE4D5-47FC-428A-8003-9C9BFEB3C2FD}.png)
add ip 클릭 & microblaze 선택
![alt text]({A400E5FA-F5B0-4497-9A69-1A7B90EB082E}.png)

![alt text]({D50DEE93-AB5E-4FE5-833C-261847F6F2EB}.png)
-> "microblaze" 얘가 cpu임

run block automation 설정
![alt text]({B0EEDECC-F89E-4B69-9DA5-B0F3A78E2AAD}.png)
-> memory 최대 사이즈로

clocking wizard 더블클릭
![alt text]({0F8308F1-E49C-455A-A7EE-4CE1E894E6C9}.png)
sys clock -> board oscilator에 자동연결

run connection automation
![alt text]({2DD75AF0-C50E-43F5-A642-A8D411845B3A}.png)
전체 선택후 ok

uart 추가
![alt text]({1DFCA13C-D152-4EFA-B045-88C7324CA62E}.png)
xilinx ip

microblaze와 연결 - run connection automation
![alt text]({E8EF980A-513D-4B8D-978B-E8F4F37DDE9E}.png)

최종 schematic
![alt text]({01F41E83-545E-4371-A181-DC2071F893E6}.png)


AXI interconnect가 pheripheral 을 자동으로 연결해준다.
![alt text]({9FFD48F5-6BFE-4F7C-94A9-79814B309B40}.png)

address editor에서 address map 수정가능
![alt text]({506549AC-6738-432C-BB68-37CB5522CFE7}.png)

address map
![alt text]({C891B146-D60E-401D-A2C1-387840402387}.png)

gpio 추가
![alt text]({51CBE4DA-DAD3-4EC5-9E1B-DA83DB8A3C76}.png)

![alt text]({1B100CD0-93B7-4285-89DE-465BE7F6CC58}.png)

다했으면 validate Design 클릭

-> 이렇게 다 구성한 Ip들을 hdl 코드로 한데 묶고 싶음 (create hdl wrapper)
![alt text]({7BB3DCEA-8B88-46B6-B8FF-A757F8065AEF}.png)
![alt text]({D49FB85E-4E14-44C2-826F-315650B70E58}.png)




bitstream 만들고나서
![alt text]({50860256-6DE6-4D55-A490-BD93E4E5F3AF}.png)
![alt text]({8FD920D4-BB25-4C1B-A172-B963087309D9}.png)

"platform file"(`.xsa`) 파일 만들기
![alt text]({9054031F-6F49-41CD-A40F-DDD3256362D8}.png)

vitis 실행
![alt text]({7A4AB045-CB50-40F0-AAAB-CCAD90C02E8B}.png)

application project 선택
![alt text]({DABFD66E-ED4F-46A1-93E9-A251D5F01D23}.png)


platform project에 processor 존재, 이 위에 system project (application)
![alt text]({181F97EE-B306-4668-99C6-300B46FCB0D4}.png)


![alt text]({6066130D-D3F3-4773-92EF-41EF9AC99456}.png)


![alt text]({25555B34-DADC-43E5-9E91-AFB852E1CDB4}.png)