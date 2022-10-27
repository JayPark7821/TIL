
## Apache Kafka
### Producer
* 메시지를 생산(Produce)해서 Kafka의 Topic으로 메시지를 보내는 어플리케이션
![image](https://user-images.githubusercontent.com/60100532/198251019-89791104-ecb4-4afd-8bf2-2d45f86ac865.png)
___

 
### Producer가 보내는 Record(Message)구조
* Header, Key, Value
  
![image](https://user-images.githubusercontent.com/60100532/198259304-80cd46b7-5433-461a-bc5a-f699f7689a86.png)

  
<br />    

### Serializer/Deserializer
* To/From Byte Array
* Kafka는 Record(데이터)를 Byte Array로 저장

![image](https://user-images.githubusercontent.com/60100532/198259635-cad681b2-728b-4395-8906-c95f24f97f28.png)


### Producer Sample Code
* Serializer
```java
private Properties props = new Properties();

props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, " broker101:9092,broker102:9092 "); 
props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, org.apache.kafka.common.serialization.StringSerializer.class); 
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, io.confluent.kafka.serializers.KafkaAvroSerializer.class);

KafkaProducer producer = new KafkaProducer(props);

```

### Producing to Kafka
* High-Level Architecture

![image](https://user-images.githubusercontent.com/60100532/198260352-d91b2793-57ed-41dc-8fd3-3e4104479490.png)


### Partitioner의 역할
* 메시지를 Topic의 어떤 Partition으로 보낼지 결정
* 단!!!!! key가 Null이 아닐때
![image](https://user-images.githubusercontent.com/60100532/198260846-ab24a320-0c75-4072-8111-b946cb7f13c1.png)

### Partitioner의 종류
* 서능, 작동 방식이 다양함 
![image](https://user-images.githubusercontent.com/60100532/198261320-04c7804b-fd71-4f7b-8485-9a4136264bc0.png)

## Summery
* Message == Record == Event == Data
* Message는 Header와 Key 그리고 Value 로 구성
* Kafka는 Record(데이터)를 Byte Array로 저장
* Producer는 Serializer, Consumer는 Deserializer를 사용
* Producer는 Message의 Key 존재 여부에 따라서 Partitioner를 통한 메시지 처리 방식이 다름