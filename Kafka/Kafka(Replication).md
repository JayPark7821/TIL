
## Apache Kafka
### Replication
* Broker에 장애가 발생하면?
* 장애가 발생한 Broker의 Partition들은 모두 사용할 수 없게 되는 문제 발생  
  
![image](https://user-images.githubusercontent.com/60100532/198311495-dbf304e9-194c-460b-a734-173553961f6a.png)
___

<br />  

### 다른 Broker에서 Partition을 새로 만들 수 있으면 장애 해결???
* 메시지(데이터) 및 Offset 정보의 유실은?
* 다른 Broker에서 장애가 발생한 Partition을 대신해서 Partition을 새로 만들면 장애 해결?
* 기존 메시지는 버릴 것인가? 
* 기존 Offset 정보들을 버릴것인가?

![image](https://user-images.githubusercontent.com/60100532/198312760-4791e3c9-b0ec-4198-b70e-7c484e5b831c.png)

___
  
<br />  
  
### Replication of Partition
* 장애를 대비하기 위한 기술 
* Partition을 복제(Replication)하여 다른 Broker상에서 복제물(Replicas)을 만들어서 장애를 미리 대비함.
* Replicas = Leader Partition, Follower Partition

![image](https://user-images.githubusercontent.com/60100532/198313475-34498a66-bf0f-4814-a4b5-22221c3c3165.png)

### Producer/Consumer는 Leader랑만 통신
* Follower는 복제만
* Producer는 Leader에만 Write하고 Consumer는 Leader로부터만 Read함
* Follower는 Broker 장애시 안정성을 제공하기 위해서만 존재
* Follower는 Leader의 Commit Log에서 데이터를 가져오기 요청(Fetch Request)으로 복제

![image](https://user-images.githubusercontent.com/60100532/198314790-99f3350a-33be-4fb9-943a-b860f623d80b.png)

### Leader 장애
* 새로운 Leader를 선출
* Leader에 장애가 발생하면?
* Kafka 클러스터는 Follower중에서 새로운 Leader를 선출
* Client(Producer/Consumer)는 자동으로 새 Leader로 전환  
 
![image](https://user-images.githubusercontent.com/60100532/198315437-4b011e4f-d96a-45f0-bf29-6553c8a58246.png)

### Partition Leader에 대한 자동 분산
* Hot Spot 방지
* 하나의 Broker에만 Partition의 Leader들이 몰려 있다면?
* 특정 Broker에만 Client(Producer/Consumer)로 인해 부하 집중

![image](https://user-images.githubusercontent.com/60100532/198316210-267530ed-8276-40fa-b8a2-5ceef99f501c.png)

* Auto.leader.rebalance.enable: 기본값 enable
* leader.imbalance.check.interval.seconds : 기본값 300sec
* leader.imbalance.per.broker.percentage : 기본값 10  

![image](https://user-images.githubusercontent.com/60100532/198317647-76a7bad7-7863-4d19-ba6b-acdb9982ef8c.png)

### Rack Awareness
* Rack간 분산하여 Rack장애를 대비
* 동일한 혹은 Available Zone 상의 Broker들에 동일한 "rack name"지정
* 복제본(Replica-Leader/Follower)은 최대한 Rack 간에 균형을 유지하여 Rack 장애 대비
* Topic 생성시 또는 Auto Data Balancer/Self Balancing Cluster 동작 때만 실행
* 
![image](https://user-images.githubusercontent.com/60100532/198317789-9b477341-f47d-4525-abd1-1c5e536f3e99.png)

## Summery
* Partition을 복제(Replication)하여 다른 Broker상에서 복제물(Replicas)을 만들어 장애를 미리 대비함
* Replicas - Leader에만 Write하고 Consumer는 Leader로부터만 Read함
* Follower는 Leader의 Commit Log에서 데이터를 가져오기 요청 (Fetch Request)으로 복제
* 복제본(Replica-Leader/Follower)은 최대한 Rack간에 균형을 유지하여 Rack 장애 대비하는 Rack Awareness 기능이 있음
