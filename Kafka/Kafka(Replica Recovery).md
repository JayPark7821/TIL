
## Apache Kafka
### Replica Recovery
* acks=all의 중요성
> * 3개의Replica로 구성된 하나의 Partition  
> Producer가 4개의 메시지 (M1,M2,M3,M4)를 보냈음  

![image](https://user-images.githubusercontent.com/60100532/198878527-a1c499bd-e6a2-4b40-b629-ed88b8c506ff.png)
___

> * Broker X가 장애가 나면, 새로운 Leader가 선출됨  
> Controller가 Y를 Leader로 선출했다고 가정

![image](https://user-images.githubusercontent.com/60100532/198878631-d7da0d14-73e7-4f19-9c8b-57d628013db8.png)

___

> * Broker X는 M3,M4에 대한 ack를 Producer에게 보내지 못했음  
> Producer는 재시도에 의해 M3,M4를 다시 보냄

![image](https://user-images.githubusercontent.com/60100532/198878762-9f4f1110-593e-4fcf-b960-01ad1116253b.png)

___
### 만약 acks=1이 었다면?
> * 만약 acks=1 이었다면?  
>  Y,Z가 복제를 못했던 M4는 어떻게 될까?

![image](https://user-images.githubusercontent.com/60100532/198878899-8aed398a-ef40-4e0c-adb0-741244db5301.png)
 
---

### 장애가 발생했던 X가 복구되면?
> * 장애가 발생했던 X가 복구되면?  
> X는 Follower가 되어서 Y로 부터 복제함.

![image](https://user-images.githubusercontent.com/60100532/198879006-f6eb4f9e-2c95-43ba-9db4-e6d9f6cfc4db.png)
![image](https://user-images.githubusercontent.com/60100532/198879060-676b3490-c23b-4fd1-b27e-a6f70b6bd6c1.png)

___

<br />  

### Availability와 Durability
* 가용성과 내구성 중 선택?
* Topic 파라미터 - unclean.leader.election.enable
  * ISR 리스트에 없는 Replica를 Leader로 선출할 것인지에 대한 옵션 (default : false)
  * ISR 리스트에 Replica가 하나도 없으면 Leader 선출을 안 함 - 서비스 중단.
  * ISR 리스트에 없는 Replica를 Leader로 선출함 - 데이터 유실

* Topic 파라미터 - min.insync.replicas
  * 최소 요구되는 ISR의 개수에 대한 옵션 (default:1)
  * ISR 이 min.insync.replicas 보다 적은 경우,  
    Producer는 NotEnoughReplicas 예외를 수신
  * Producer에서 acks=all과 함께 사용할 때 더 강력한 보장 + min.insync.replicas=2
  * n개의 Replica가 있고, min.insync.replicas=2 인 경우 n-2개의 장애를 허용할 수 있음

* 데이터 유실이 없게 하려면?
  * Topic : replication.factor 는 2 보다 커야 함(최소 3이상)
  * Producer : acks 는 all 이어야 함
  * Topic : min.insync.replicas 는 1 보다 커야 함(최소 2 이상)

* 데이터 유실이 다소 있더라도 가용성을 높게 하려면?
  * Topic : unclean.leader.election.enable 를 true 로 설정


## Summery
* 가용성과 내구성 관련 파라미터
* replication.factor
* acks
* min.insync.replicas
* unclean.leader.election.enable
