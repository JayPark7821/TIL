
## Apache Kafka
### In-Sync-Replicas
* Leader 장애시 Leader를 선출하는데 사용
* In-Sync-Replicas(ISR)는 High water Mark라고 하는 지점까지 동일한 Replicas(Leader와 Follower 모두)의 목록
* Leader에 장애가 발생하면, ISR중에서 새 Leader를 선출

![image](https://user-images.githubusercontent.com/60100532/198411574-46dc1b5d-2587-4221-9fcd-1bb5422cd31b.png)
___

<br />  

### Replica.lag.max.messages 사용시 문제점
* 메시지 유입량이 갑자기 늘어날 경우
* **replica.lag.max.messages로 ISR판단시 나타날 수 있는 문제점!!!**
  * 메시지가 항상 일정한 비율(초당 유입되는 메시지, 3msg/sec이하)로 kafka로 들어올때,  
    replica.lag.max.messages=5로 하면 5개 이상으로 지연되는 경우가 없으므로 ISR들이 정상적으로 동작
  * 메시지 유입량이 갑자기 늘어날 경우(예, 초당 10msg/sec), 지연으로 판단하고 OSR(Out-of-Sync-Replica)로 상태를 변경시킴
  * 실제 Follower는 정상적으로 동작하고 단지 잠깐 지연만 발생했을 뿐인데,  
    replica.lag.max.messages옵션을 이용하면 OSR로 판단하게 되는 문제가 발생(운영중에 불필요한 error 발생 및 그로 인한 불필요한 retry 유발)
  
* replica.lag.time.max.ms으로 판단해야 함
  * Follower가 Leader로 Fetch 요청을 보내는 Interval을 체크
  * 예) replica.lag.time.max.ms = 10000 이라면 Follower가 Leader로 Fetch 요청을 10000ms 내에만 요청하면 정상으로 판단
  * Confluent에서는 replica.lag.time.max.ms 옵션만 제공 (복잡성 제거)


___

<br />  

### ISR은 Leader가 관리
* Zookeeper에 ISR업데이트, Controller가 Zookeeper로부터 수신
* Follower가 너무 느리면 Leader는 ISR에서 Follower를 제거하고 Zookeeper에 ISR을 유지
* Controller는 Partition Metadata에 대한 변경 사항에 대해서 Zookeeper로부터 수신

![image](https://user-images.githubusercontent.com/60100532/198412467-3007d2f9-2077-4db9-bd6f-4bd5649d8482.png)


___

<br />  

### Controller
* Kafka Cluster 내의 Broker중 하나가 Controller가 됨
* Controller는 Zookeeper를 통해 Broker Liveness를 모니터링
* Controller는 Leader와 Replica 정보를 Cluster내의 다른 Broker들에게 전달.
* `Controller는 Zookeeper에 Replicas 정보의 복사본을 유지한 다음 더 빠른 액세스를 위해 클러스터의 모든 Broker들에게 동일한 정보를 캐시함.`
* `Controller가 Leader 장애시 Leader Election을 수행`
* Controller가 장애가 나면 다른 Active Broker들 중에서 재선출됨

___

<br />  

  
### Consumer 관련 Position들
* Last Committed , Current Position, High Water Mark, Log End Offset
* Last Committed Offset(Current Offset) : Consumer가 최종 Commit한 Offset
* Current Position : Consumer가 읽어간 위치 (처리중, Commit 전)
* High Water Mark(Committed) : ISR(Leader-Follower)간에 복제된 Offset
* Log End Offset : Producer가 메시지를 보내서 저장된, 로그의 맨 끝 Offset

![image](https://user-images.githubusercontent.com/60100532/198413476-b4b17e85-087d-400e-9ad0-f534eba65ede.png)