# Redis
### 1. Redis의 정의
  * Remote Dictionary Server
  * Storage : 데이터 저장소 (데이터 관점)
  * Database : 전통적인 DBMS의 역할을 수행 (영속성 관점)
  * Middleware : 어플리케이션이 이용할 수 있는 유용한 기능을 제공하는 소프트웨어

### 2. Redis로 할 수 있는 것?
* 아주 빠른 데이터 저장소로 활용
* 분산된 서버들간의 커뮤니케이션(동기화, 작업 분할 등)
* 내장된 자료구조 활용한 기능 구현

### 3. In-memory DB로서의 Redis
* #### DB, Database, DBMS???
  * 데이터를 읽고 쓸 수 있는 기능을 제공하는 소프트웨어
  * 어플리케이션이 데이터 저장을 간단히 처리할 수 있도록 해줌
  * 관심사의 분리, 계층화
* #### In-memory DB?
  * 데이터를 디스크에 저장하지 않음.
  * 휘발성인 RAM에 저장
  * 빠른 속도

![image](https://user-images.githubusercontent.com/60100532/204530996-34630d99-fdd8-4bd2-86f9-a1102ee56bb1.png)

* #### 빠른 속도와 휘발성의 절충
  * 용도에 맞게 DB와 Redis를 사용
  * 혼합해서 사용(Cache)
  * Redis의 영속성 확보 (백업 등)

![image](https://user-images.githubusercontent.com/60100532/204531355-761e414f-969f-4ca9-88ec-2975774218ab.png)

### 4. Key-value store로서의 Redis
* #### 데이터 저장소의 구조
  * 프로그램 언어에서의 데이터 구조(Array, List, Map, ...)
  * DB의 데이터 모델 관점에서의 구조  
    (네트워크 모델, 계층형 모델(Tree), 관계형 모델, ...)
* #### Key-value store?
  * 특정 값을 key로 해서 그와 연관된 데이터를 value로 저장(Map과 같음)
  * 가장 단순한 데이터 저장 방식
  * 단순한 만큼 빠르고 성능이 좋음  
  
![image](https://user-images.githubusercontent.com/60100532/204532594-18d35930-8ee8-4985-965e-154c3331f72d.png)

* #### Key-value 구조의 장점
  * 단순성에서 오는 쉬운 구현과 사용성
  * Hash를 이용해 값을 바로 읽으므로 속도가 빠름(추가 연산이 필요 없음)
  * 분산 환경에서의 수평적 확장성
* #### Key-value 구조의 단점
  * Key를 통해서만 값을 읽을 수 있음
  * 범위 검색 등의 복잡한 질의가 불가능

* #### Key-value 스토어의 활용
  * 언어의 자료구조(Java의 HashMap 등)
  * NoSQL DB(Redis, Riak, AWS DynamoDB)
  * 단순한 구조의 데이터로 높은 성능과 확장성이 필요할 때 사용