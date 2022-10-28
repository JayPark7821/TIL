## Apache Kafka

### Producer Acks, Batch, Page Cache, Flush

### Producer Acks

* Producer Parameter 중 하나
* acks 설정은 요청이 성공할 때를 정의하는 데 사용되는 Producer에 설정하는 Parameter   
  `acks = 0` : ack가 필요하지 않음. 이 수준은 자주 사용되지 않음. 메시지 손실이 다소 있더라도 빠르게 메시지를 보내야 하는 경우에 사용
  ![image](https://user-images.githubusercontent.com/60100532/198651878-aaa59894-fe0f-4dfd-a289-dcf025afc504.png)

___

* `acks=1` : (default값) Leader가 메시지를 수신하면 ack를 보냄. Leader가 Producer에게 ACK를 보낸후,
  Follower가 복제하기 전에 Leader에 장애가 발생하면 메시지가 손실. "At most once(최대 한 번)" 전송을 보장
  ![image](https://user-images.githubusercontent.com/60100532/198654194-1000c9ee-6b26-4edc-9f44-1f76710ec647.png)

___

* `acks=-1, acks=all`두 값 모두 동일, 메시지가 Leader가 `모든 Replica까지 Commit되면 ack를 보냄`.  
  Leader를 읽어도 데이터가 살아남을 수 있도록 보장. 그러나 대기 시간이 더 길고 특정 실패 사례에서 반복된느 데이터 발생 가능성 있음.  
  "`At least once(최소 한번)`" 전송 보장

![image](https://user-images.githubusercontent.com/60100532/198657925-e62d207c-44e4-46e9-9be3-bd29ed00a320.png)


___

<br />  

### Producer Retry

* 재전송을 위한 Parameters
* 재시도(retry)는 네트워크 또는 시스템의 일시적인 오류를 보완하기 위해 모든 환경에서 중요

| Parameter | 설명                      | Default 값     | 
|-----------|-------------------------|---------------|
| retries   | 메시지를 send하기 위해 재시도하는 횟수 | MAX_INT       |
|retry.backoff.ms|재시도 사이에 추가되는 대기 시간| 100|
|request.timeout.ms| Producer가 응답을 기다리는 최대 시간| 30,000(30초)|
|delivery.timeout.ms|send() 후 성공 또는 실패를 보고하는 시간의 상한| 120,000(2분)|

> * `acks=0` 에서 retry는 무의미
> * retries를 조정하는 대신에 `delivery.timeout.ms 조정으로 재시도 동작을 제어`
___

<br />  

### Producer Batch 처리
* 메시지를 모아서 한번에 전송
* Batch 처리는 RPC(Remote Procedure Call)수를 줄여서 Broker가 처리한는 작업이 줄어들기 떄문에 더 나은 처리량을 제공

![image](https://user-images.githubusercontent.com/60100532/198663347-0109ef4f-4bfa-4c01-a6b3-56afbdddeff7.png)

|linger.ms(default : 0, 즉시 보냄) | batch.size(default : 16kb)|
|------|-----|
|메시지가 함꼐 Batch 처리될때까지 대기 시간 | 보내기 전 Batch의 최대 크기|
> Batch 처리의 일반적인 설정은 linger.ms=100 및 batch.size=1000000
> 보통 실무에서는 linger.ms를 사용한다!!! batch.size를 사용하면 메시지가 안들어 온다면... 하염없이......기다리게된다.

___

<br />  

### Producer Delivery Timeout
* send()후 성공 또는 실패를 보고하는 시간의 상한.
* Producer가 생성한 Record를 send()할 때의 Life Cycle
![image](https://user-images.githubusercontent.com/60100532/198666222-377826b2-6d3b-412e-9eaa-de2c6e22bace.png)


___

<br />  

### Message Send 순서 보장
* enable.idempotence
* 진행 중(in-flight)인 여러 요청(request)을 재시도하면 순서가 변경될 수 있음
* 메시지 순서를 보장하려면 Producer에서 enable.idempotence를 true로 설정

![image](https://user-images.githubusercontent.com/60100532/198668720-76181dbd-60cc-49a6-ae65-026686e6023d.png)
___

<br />  

### Page Cache와 Flush
* 메시지는 Partition에 기록됨
* Partition은 Log Segment file로 구성 (기본값 : 1GB마다 새로운 Segment 생성)
* 성능을 위해 Log Segment는 OS Page Cache에 기록됨
* 로그 파일에 저장된 메시지의 데이터 형식은 Broker가 Produver로부터 수신한 것, 그리고 Consumer에게 보내는 것과 정확히 동일하므로, Zero-Copy가 가능
* Page Cache는 다음과 같은 경우 디스크로 Flush됨
  * Broker가 완전히 종료
  * OS background "Flusher Thread" 실행

![image](https://user-images.githubusercontent.com/60100532/198671553-16ca21fd-cd03-4102-93ba-caf323384368.png)
___

<br />  

### Flush 되기 전에 Broker 장애가 발생하면?
* 이를 대비하기 위해서 Replication 하는 것
* OS가 데이터를 디스크로 Flush하기 전에 Broker의 시스템에 장애가 발생하면 해당 데이터가 손실됨
* Partition이 Replication(복제)되어 있다면, Broker가 다시 온라인 상태가 되면 필요시 Leader Replica(복제본)에서 데이터가 복구됨
* Replication이 없다면, 데이터는 영구적으로 손실될 수 있음.

___

<br />  

### Kafka 자체 Flush 정책
* 마지막 Flush이후의 메시지 수(log.flush.interval.messages)또는   
  시간(log.flush.interval.ms)으로 flush(fsync)를 트리거하도록 설정할 수 있음
* Kafka는 운영 체제의 background Flush 기능(예:pdflush)을 더 효율적으로 허용하는 것을 선호하기 때문에  
  이러한 설정은 기본적으로 무한(기본적으로 fsync 비활성화)으로 설정
* 이러한 설정을 `기본값으로 유지하는 것을 권장`
* *.log파일을 보면 디스크로 Flush된 데이터와 아직 Flush되지 않은 Page Cache(OS Buffer)에 있는 데이터가 모두 표시됨
* Flush된 항목과 Flush되지 않은 항목을 표시하는 Linux도구 (예:vmtouch)도 있음

___

<br />  

## Summery
* Producer Acks : 0, 1, all(-1)
* Batch 처리를 위한 옵션 : linger.ms, batch.size
* 메시지 순서를 보장하려면 Producer에서 enable.idempotence를 true로 설정
* 성능을 위해 Log Segment는 OS Page Cache에 기록됨