
## Apache Kafka
### Consumer
* Partition으로 부터 Record를 가져옴(Poll)
* Consumer는 각각 고유의 속도로 Commit Log로부터 순서대로 Read(Poll)를 수행
* 다른 Consumer Group에 속한 Consumer들은 서로 관련이 없으며, Commit Log에 있는 Event(Message)를 동시에 다른 위치에서 Read할 수 있음
![image](https://user-images.githubusercontent.com/60100532/198262669-bfbb31b1-7285-4a87-b924-577c951cdca9.png)

___

 
### Consumer Offset
* Consumer Group이 읽은 위치를 표시
* Consumer가 자동이나 수동으로 데이터를 읽은 위치를 Commit 하여 다시 읽음을 방지 
* __consumer_offsets라는 Internal Topic에서 Consumer Offset을 저장하여 관리

![image](https://user-images.githubusercontent.com/60100532/198263312-727dc91c-1fe2-4108-8585-b69f5c6787b1.png)


<br />    

___
### Multi-Partitions with Single Consumer
* 모든 Partition에서 Consume
* 4개의 Partition으로 구성된 Topic의 데이터를 사용하는 Single Consumer가 있는 경우, 이 Consumer는 Topic의 모든 Partition에서 모든 Record를 Consume함


![image](https://user-images.githubusercontent.com/60100532/198263929-b059ead4-afe8-41ed-8532-54282db64b63.png)

> 하나의 Consumer는 각 Partition에서의 Consumer Offset을 별도로 유지(기록) 하면서 모든 Partition에서 Consume 함



<br />    

___
### Consuming as a Group
* 동일한 group.id로 구성된 모든 Consumer들은 하나의 Consumer Group을 형성
* 4개의 파티션이 있는 Topic을 consume하는 4개의 Consumer가 하나의 Consumer Group에 있다면, 각 Consumer는 정확히 하나의 Partition에서 Record를 Consume함
* Partition은 항상 Consumer Group내의 하나의 Consumer에 의해서만 사용됨
* Consumer는 주어진 Topic에서 0개 이상의 많은 Partition을 사용할 수 있음

![image](https://user-images.githubusercontent.com/60100532/198264860-8bc9300e-25ea-41db-97e0-4fcffc653025.png)

### Multi Consumer Group
* Partition을 분배하여 Consume
* 동일한 group.id로 구성된 모든 Consumer들은 하나의 Consumer Group을 형성
* Consumer Group의 Consumer들은 작업량을 어느 정도 귱등하게 분할함
* 동일한 Topic에서 consum하는 여러 Consumer Group이 있을 수 있음

![image](https://user-images.githubusercontent.com/60100532/198265931-3a114632-fed9-43b8-961e-fd1f4cbb1b94.png)


### Key를 사용하면 Partition별로 동일한 Key를 가지는 메시지 저장.
![image](https://user-images.githubusercontent.com/60100532/198266638-245bd3f2-6b23-4e11-8efb-148d4f93ac28.png)



<br />    

___
### Message Ordering(순서)
* Partition이 2개 이상인 경우 모든 메시지에 대한 전체 순서 보장 불가능
* Partition을 1개로 구성하면 모든 메시지에서 전체 순서 보장 가능 - 처리량 저하
* Partition을 1개로 구성해서 모든 메시지에서 전체 순서 보장을 해야하는 경우가 얼마나 많을까?

![image](https://user-images.githubusercontent.com/60100532/198267092-eb3f28de-37f6-4eef-958f-5307c099112c.png)

### Message Ordering(순서)
* Partition을 1개로 구성해서 모든 메시지에서 전체 순서 보장을 해야 하는 경우가 얼마나 많을까?
* 대부분의 경우, Key로 구분할 수 있는 메시지들의 순서 보장이 필요한 경우가 많음.
  
![image](https://user-images.githubusercontent.com/60100532/198267937-3dbf08fa-802b-453b-aa69-b5f946b94636.png)

### Message Ordering(순서)
* Key를 사용하여 Partition별 메시지 순서 보장
* 동일한 Key를 사진 메시지는 동일한 Partition에만 전달되어 Key 레벨의 순서 보장 가능   
  - 멀티 Partition 사용가능 = 처리량 증가.
* 운영중에 Partition 개수를 변경하면 어떻게 될까? 순서 보장 불가.

![image](https://user-images.githubusercontent.com/60100532/198268414-ebacbe40-3e14-4250-9c50-69358cdd0f14.png)