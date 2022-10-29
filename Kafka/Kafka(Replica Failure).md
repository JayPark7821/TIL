
## Apache Kafka
### Replica Failure
### In-Sync Replicas 리스트 관리
* Leader가 관리함
* 메시지가 ISR 리스트의 모든 Replica(복제본)에서 수신되면 Commit된 것으로 간주 Kafka Cluster의 Controller가 모니터링하는 Zookeeper의 ISR 리스트에 대한 변경 사항은 Leader가 유지
* N개의 Replica가 있는 경우 N-1개의 장애를 허용할 수 있음  
  
  
  
> * Follower가 실패하는 경우
>   * Leader에 의해 ISR 리스트에서 삭제됨
>   * Leader는 새로운 ISR을 사용하여 Commit 함


> * Leader가 실패하는 경우
>   * Controller는 Follower 중에서 새로운 Leader를 선출
>   * Controller는 새 Leader와 ISR정보를 먼저 Zookeeper에 Push한 다음 로컬 캐싱을 위해 Broker에 Push함

___


<br />    

### ISR은 Leader가 관리
* Zookeeper에 ISR 업데이트, Contoller가 Zookeeper로 부터 수신
1. Follower가 너무 느리면 Leader는 ISR에서 Follower를 제거하고 Zookeeper에 ISR을 유지
2. Controller는 Partition Metadata에 대한 변경 사항에 대해서 Zookeeper로 부터 수신

![image](https://user-images.githubusercontent.com/60100532/198826942-3fe65983-043c-46b5-b446-f4235325ee90.png)

___

### Leader Failure
* Controller가 새로운 Leader선출
* Controller가 새로 선출한 Leader 및 ISR정보는, Controller 장애로부터 보호하기 위해,  
   Zookeeper에 기록된 다음 클라이언트 메타데이터 업데이트를 위해 모든 Broker에 전파.
   
![image](https://user-images.githubusercontent.com/60100532/198827030-cbc86a60-edad-42ec-bae7-6506af3b0280.png)
___

### Broker Failure
* Broker 4대, Partition 4, Replication Factor가 3일 경우를 가정
* Partition 생성시 Broker들 사이에서 Partition들이 분산하여 배치됨

![image](https://user-images.githubusercontent.com/60100532/198827198-4f7d087d-b3e2-4b5b-9a4f-f9f0c160a519.png)

![image](https://user-images.githubusercontent.com/60100532/198827237-c24906f5-4f9d-41b4-a9ef-e1774d2b6115.png)

### Partition Leader가 없으면
* Partition에 Leader가 없으면,
* Leader가 선출될 때까지 해당 Partition을 사용할 수 없게 됨
* Producer의 send()는 retries 파라미터가 설정되어 있으면 재시도함.
* 만약 retries=0 이면, NetworkException이 발생함.

## Summery
* Replica Failure
* Follower가 실패하는 경우, Leader에 의해 ISR리스트에서 삭제되고, Leader는 새로운 ISR을 사용하여 Commit함
* Leader가 실패하는 경우, Controller는 Follower중에서 새로운 Leader를 선출하고, Controller는 새 Leader와 ISR정보를 먼저 Zookeeper에 Push한 다음 로컬 캐싱을 위해 Broker에 Push함
* Leader가 선출될 때까지 해당 Partition을 사용할 수 없게 됨.
