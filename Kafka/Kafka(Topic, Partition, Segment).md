
## Apache Kafka
### Topic, Partition, Segment

![image](https://user-images.githubusercontent.com/60100532/198237530-6d36a807-3904-4069-8a26-0939863b4d64.png)
___

#### Topic 
* Kafka 안에서 메시지가 저장되는 장소

#### Producer 
* 메시지를 생산(Produce)해서 Kafka의 Topic으로 메시지를 보내는 어플리케이션

#### Consumer
* Topic의 메시지를 가져와서 소비(Consume)하는 어플리케이션 
 
#### Consumer Group
* Topic의 메시지를 사용하기 위해 협력하는 Consumer들의 집합  
   
<br />  
  
* 하나의 Consumer는 하나의 Consumer Group에 포함되며, Consumer Group내의 Consumer들은 협력해서 Topic의 메시지를 분상 병렬 처리함.

___

### Producer와 Consumer의 기본 동작 방식
* Producer와 Consumer는 서로 알지 못하며, Producer와 Consumer는 각각 고유의 속도로 Commit Log에 Write 및 Read를 수행
* 다른 Consumer Group에 속한 Consumer들은 서로 관련이 없으며, Commit Log에 있는 Event(Message)를 동시에 다른 위치에서 Read할 수 있음

![image](https://user-images.githubusercontent.com/60100532/198239364-0a08425b-1c6a-4362-8bfa-599f42a3df92.png)  
   
<br />  
  

### commit log 
* 추가만 가능하고 변경 불가능한 데이터 스트럭처 데이터 (Event)는 항상 로그 끝에 추가되고 변경되지 않음
### offset
* Commit Log에서 Event의 위치 아래 그램에서는 0부터 10까지의 offset을 볼 수 있음
![image](https://user-images.githubusercontent.com/60100532/198239839-667316b1-0cef-48d2-bebd-9e6ea6ba9906.png)

___

### Consumer Lag

* Consumer와 Producer가 각각 고유의 속도로 Read와 Write하기 때문에   
Producer가 Write하는 `LOG-END-OFFSET`과   
Consumer Group의 Consumer가 Read하고 처리한 후에 Commit한 `CURRENT-OFFSET`과의   
`차이(Consumer Lag)`가 발생할 수 있음

![image](https://user-images.githubusercontent.com/60100532/198241962-1820fd13-f759-4cb7-a36c-be5c49af1eb1.png)

___
### Topic, Partition, Segment (Logical View)
* Topic : Kafka 안에서 메시지가 저장되는 장소, 논리적인 표현
* Partition : Commit Log, 하나의 Topic은 하나 이상의 Partition으로 구성 병렬처리(Throughput 향상)를 위해서 다수의 Partition 사용
* Segment : 메시지(데이터)가 저장되는 실제 물리 File Segment File이 지정된 크기보다 크거나 지정된 기간보다 오래되면 새 파일이 열리고 메시지는 새팔에 추가됨

![image](https://user-images.githubusercontent.com/60100532/198242700-96249595-c890-4d7b-ade6-2f558f2230e0.png)

___
### Topic, Partition, Segment (Physical View)
* Topic 생성시 Partition 개수를 지정하고, 각 Partition은 Broker들에 분산되며 Segment File들로 구성됨
* Rolling Strategy : log.segment.bytes(default 1GB), log.roll.hours(default 168 hours)

![image](https://user-images.githubusercontent.com/60100532/198243374-56ab0f57-ebe2-4fe2-a931-2af140b3bcc5.png)

* Partition당 오직 하나의 Segment가 활성화(Active)되어 있음   

![image](https://user-images.githubusercontent.com/60100532/198244086-8a8da4c9-8ccd-48e7-b688-d23765b3e82f.png)

## Summery
* Topic 생성시 Partition 개수를 지정, 개수 변경 가능하나 운영시에는 변경 권장하지 않음.
* Partition 번호는 0 부터 시작하고 오름차순
* Topic 내의 Partition들은 서로 독립적임
* Event(Message)의 위치를 나타내는 offset이 존재 
* Offset은 하나의 Partition에서만 의미를 가짐  
  Partition 0의 offset 1 != Partition 1 의 offset 1
* Offset값은 계속 증가하고 0으로 돌아가지 않음
* Event(Message)의 순서는 하나의 Partition내에서만 보장
* Partition에 저장된 데이터(Message)는 변경이 불가능(Immutable)
* Partition에 Write되는 데이터는 맨 끝에 추가되어 저장됨
* partition은 Segment File들로 구성됨  
  Rolling 정책 : log.segment.bytes(default 1GB), log.roll.hours(default 168 hours)

![image](https://user-images.githubusercontent.com/60100532/198245678-38c801ea-3a1d-45c3-b88b-26cdcc3f4c16.png)