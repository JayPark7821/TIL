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

### 5. NoSQL로서의 Redis
* #### Redis는 DBMS인가?
  * 데이터를 다루는 인터페이스를 제공하므로 DBMS의 성격이 있음
  * 기본적으로 영속성을 위한 DB는 아님
  * 영속성을 지원(백업)
  * DBMS보다는 빠른 캐시의 성격으로 대표됨
  
* #### Redis의 다양한 특성
  * 기본적으로 NoSQL DB로 분류되는 key-value store
  * 다양한 자료구조를 지원(String, Hash, Set, List 등)

* #### External Heap(외부 메모리)로서의 Redis
  * Application이 장애가 나도 Redis의 데이터는 보존(단기)
  * Application이 여러 머신에서 돌아도 같은 데이터를 접근 가능
  
* #### DBMS로서의 Redis
  * Redis의 영속화 수단을 이용해 DBMS처럼 이용
  * 일반 RDB 수준의 안정성을 얻기 위해선 속도를 희생해야 함.
  
![image](https://user-images.githubusercontent.com/60100532/204804934-7561686f-b229-47df-a1ab-cf823e0dc033.png)

* #### Middleware로서의 Redis
  * Redis가 제공하는 자료구조를 활용해 복잡한 로직을 쉽게 구현 (ex : Sorted Set)

![image](https://user-images.githubusercontent.com/60100532/204805204-31362da2-f256-44c2-8669-c33cbe706120.png)

* #### NoSQL DB로서의 Redis 특징 정리
  * Key-value store
  * 다양한 자료구조를 지원한다는 점에서 차별화됨
  * 원하는 수준의 영속성을 구성할 수 있음
  * In-memory 솔루션이라는 점에서 오는 특징을 활용할 떄 가장 효율적

### 6. Redis Data Type의 이해
* #### Strings 요약
  * 가장 기본적인 데이터 타입으로 제일 많이 사용됨
  * 바이트 배열을 저장(binary-safe)
  * 바이너리로 변환할 수 있는 모든 데이터를 저장 가능(JPG와 같은 파일 등)
  * 최대 크기는 512MB
* #### Strings 주요 명령어
|명령어|기능| 예제                          |
|----|----|-----------------------------|
|SET| 특정 키에 문자열 값을 저장한다.| SET say hello               |
|GET| 특정 키의 문자열 값을 얻어온다.| GET say                     |
|INCR| 특정 키의 값을 Integer로 취급하여 1 증가시킨다.| INCR mycount                |
|DECR| 특정 키의 값을 Integer로 취급하여 1 감소시킨다.| DECR mycount                |
|MSET| 여러 키에 대한 값을 한번에 저장한다.| MSET mine milk yours coffee |
|MGET| 여러 키에 대한 값을 한번에 얻어온다. | MGET mine yours|

* #### List 요약
  * Linked-list 형태의 자료구조(인덱스 접근은 느리지만 데이터 추가/삭제가 빠름)
  * Queue와 Stack으로 사용할 수 있음
* #### List 주요 명령어
| 명령어    | 기능                             | 예제                  |
|--------|--------------------------------|---------------------|
| LPUSH  | 리스트의 왼쪽(head)에 새로운 값을 추가한다.    | LPUSH mylist apple  |
| RPUSH  | 리스트의 오른쪽(tail)에 새로운 값을 추가한다.   | RPUSH mylist banana |
| LLEN   | 리스트에 들어있는 아이템 개수를 반환한다.        | LLEN mylist         |
| LRANGE | 리스트의 왼쪽(head)에서 값을 삭제하고 반환한다.  | LPOP mylist 0 -1    |
| RPOP   | 리스트의 오른쪽(tail)에서 값을 삭제하고 반환한다. | RPOP mylist         |

* #### Set 요약
  * 순서가 없는 유니크한 값의 집합
  * 검색이 빠름
  * 개별 접근을 위한 인덱스가 존재하지 않고, 집합 연산이 가능(교집합, 합집합 등)
* #### Set 주요 명령어
| 명령어       | 기능                         | 예제                    |
|-----------|----------------------------|-----------------------|
| SADD      | Set에 데이터를 추가한다.            | SADD myset apple      |
| SREM      | Set에서 데이터를 삭제한다.           | SREM myset apple      |
| SCARD     | Set에 저장된 아이템 개수를 반환한다.     | SCARD myset           |
| SMEMBERS  | Set에 저장된 아이템들을 반환한다.       | SMEMBERS myset        |
| SISMEMBER | 특정 값이 Set에 포함되어 있는지를 반환한다. | SISMEMBER myset apple |


### Redis 성능 튜닝
* 적절한 Eviction 정책 설정하기

#### Eviction 정책 이란?
* 메모리가 한계에 도달했을 때 어떤 조치가 일어날지 결정
* 처음부터 메모리가 부족한 상황을 만들지 않는 것이 중요함.
* 캐시로 사용할 때는 적절한 eviction policy가 사용될 수 있음

#### maxmemory-policy 옵션
* noeviction : eviction없음. 추가 데이터는 저장되지 않고 에러 발생(replication 사용시 master에 적용됨)
* allkeys-lru : 가장 최근에 사용된 키들을 남기고 나머지를 삭제(LRU: Least Recently Used)
* allkeys-lfu : 가장 빈번하게 사용된 키들을 남기고 나머지를 삭제(LFU: Least Frequently Used)
* allkeys-random : 랜덤하게 키를 삭제
* volatile-lru : LRU를 사용하되 expire field가 true로 설정된 항목들 중에서만 삭제
* volatile-lfu : LFU를 사용하되 expire field가 true로 설정된 항목들 중에서만 삭제
* volatile-random : expire field가 true로 설정된 항목들 중에서 랜덤하게 삭제
* volatile-ttl : expire field가 true로 설정된 항목들 중에서 짧은 TTL순으로 삭제

#### SLOWLOG 설정
* 수행시간이 설정한 기준 시간 이상인 쿼리의 로그를 보여줌
* 측정 기준인 수행시간은 I/O동작을 제외함.
* 로깅되는 기준 시간(microseconds)
```redis
slowlog-log-slower-than 10000
```
* 로그 최대 길이
```redis
slowlog-max-len 128
```
* slowlog 개수 확인
```redis
slowlog len
```
* slowlog 조회
```redis
slowlog get [count]
```