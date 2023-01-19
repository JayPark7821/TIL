## 데이터베이스 성능 핵심!!!
* 데이터베이스의 데이터는 결국 디스크에 저장되어야한다.
* 디스크는 메모리에 비해 속도가 훨씬 느리다.
* 결국 데이터베이스 성능의 핵심은 디스크 I/O(접근)을 최소화 하는 것이다.    
  

* 디스크 접근을 줄일수 있는 방법
  * 메모리에 올라온 데이터로 최대한 요청을 처리한다. -> 메모리 캐시 히트율을 높인다.
    * 쓰기도 곧 바로 디스크에 쓰지 않고 메모리에 먼저 쓴다.
    * 메모리에 데이터 유실을 고려해 WAL(Write Ahead Log)를 사용
      * 대부분의 트랜잭션은 무작위하게 Write가 발생함.
      * 이를 지연시켜 랜덤 I/O 횟수를 줄이는 대신 순차적 I/O를 발생시켜 정합성 유지  
  
___
* 결국 데이터베이스 성능에 핵심은 디스크의 랜덤I/O을 최소화 하는 것
 ___

## 인덱스
> 인덱스는 정렬된 자료구조, 이를 통해 탐색범위를 최소화 
> (인덱스도 결국 테이블 이다.)
> 

* 인덱스의 핵심은 탐색(검색) 범위를 최소화 하는 것
* 그렇다면 검색이 빠른 자료구조들은 어떤 것이 있을까?!!!
* Hash Map, List, Binary Search Tree...
  * Hash Map
    * Key, Value 형태
    * 단건 검색 속도 O(1)
    * 그러나 범위 탐색은 O(N)
    * 전방 일치 탐색 불가 ex) like 'AB%'
  * List
    * 정렬되지 않은 리스트의 탐색은 O(N)
    * 정렬된 리스트의 탐색은 O(logN)
    * 정렬되지 않은 리스트의 정렬 시간 복잡도는 O(N) ~ O(N * logN)
    * 삽입 / 삭제 비용이 매우 높음
  * Tree
    * 트리 높이에 따라 시간 복잡도가 결정됨
    * 트리의 높이를 최소화하는 것이 중요!
    * 한쪽으로 노드가 치우치지 않도록 균형을 잡아주는 트리 사용  
      ex) Red-Black Tree, B+Tree
      * B + Tree 
        * 삽입 / 삭제시 항상 균형을 이룸
        * 하나의 노드가 여러 개의 자식 노드를 가질 수 있음
        * 리프노드에만 데이터 존재
          * 연속적인 데이터 접근 시 유리

## 클러스터 인덱스
> * 클러스터 인덱스는 데이터 위치를 결정한는 키 값이다. 
> * MySQL의 PK는 클러스터 인덱스다.
> * MySQL에서 PK를 제외한 모든 인덱스는 PK를 가지고 있다.

1. 클러스터 인덱스는 정렬되어 있고, 정렬된 순서에 따라서 데이터의 주소가 결정됨.
   * 클러스터 키 순서에 따라서 데이터 저장 위치가 변경된다.!!!  
    -> 클러스터 키 삽입/갱신시에 성능 이슈 발생
2. PK(클러스터 키) 순서에 따라 데이터 저장 위치가 변경된다.
   * PK 키 삽입/갱신시에 성능 이슈 발생 
3. PK의 사이즈가 인덱스(테이블)의 사이즈를 결정
  * 세컨더리 인덱스만으로는 데이터를 찾아갈 수 없다.  
    -> PK 인덱스를 항상 검색해야함.

### 클러스터 인덱스의 장점
1. PK를 활용한 검색이 빠름. 특히 범위 검색!
2. 세컨더리 인덱스들이 PK를 가지고 있어 커버링에 유리

![image](https://user-images.githubusercontent.com/60100532/202878554-9a15c020-543b-44b3-9694-9c3c32d74d50.png)

![image](https://user-images.githubusercontent.com/60100532/202878614-7cac8cb4-2861-4a86-966b-4abac1567767.png)

### 인덱스를 다룰 때 주의 해야할 점
1. 인덱스 필드 가공
   * 인덱스 필드를 가공하면 인덱스를 활용할 수 없다.
    ```sql
     -- AGE는 INT 타입
    SELECT *
    FROM member 
    WHERE age * 10 = 100
    WHERE age = '1'
    ```
2. 복합 인덱스
   * 복합 인덱스의 선두 컬럼이 중요하다!! 먼저 선두 인덱스 컬럼을 탄다.
3. 하나의 쿼리에는 하나의 인덱스만
   * 하나의 쿼리에는 하나의 인덱스만 탄다. 여러 인덱스 테이블을 동시에 탐색하지 않음
   * index merge hint를 사용하면 가능
   * 따라서 WHERE, ORDER BY, GROUP BY 혼합해서 사용할 때에는 인덱스를 잘 고려해야함!!

> 마지막으로 
> * 의도대로 인덱스가 동작하지 않을 수 있음 (explain으로 확인)
> * 인덱스도 비용이다. 쓰기를 희생하고 조회를 얻는 것
> * 꼭 인덱스로만 해결할 수 있는 문제인가?
> 

### 커버링 인덱스 
* 검색조건이 인덱스에 부합하다면, 테이블에 바로 접근 하는 것보다 
* 인덱스를 통해 접근하는 것이 매우 빠르다.
* 그렇다면 테이블에 접근하지 않고
* 인덱스로만 데이터 응답을 내려줄 순 없을까?!!!!!!

```sql
select 나이,id
from  회원
where 나이 < 30
```
![image](https://user-images.githubusercontent.com/60100532/203555958-a80a947d-9e09-4a20-8dd7-410fdbce5c40.png)

* MySql에서는 PK가 클러스터 인덱스이기때문에 `커버링 인덱스`에 유리
* 그렇다면 커버링 인덱스로 페이지네이션 최적화를 어떻게 할 수 있을까?  
  

<br />  

* 나이가 30 이하인 회원의 이름을 2개만 조회해야 한다 가정하자!
![image](https://user-images.githubusercontent.com/60100532/203555958-a80a947d-9e09-4a20-8dd7-410fdbce5c40.png)
* 예제에선 30 이하인 회원의 데이터가 2개 뿐이지만 1000개 라고 다시 가정하고 그증에 2건을 가져와야한다면 
* 1000개의 데이터블럭 access가 모두 일어난 후 2개를 가져온다. 
* 성능 down

* 위 문제점을 커버링 인덱스를 통해 해결해 보자.

```sql
with 커버링 as (
    select id 
    from 회원
    where 나이 < 30
    limit 2
)

select 이름 
from 회원 inner join 커버링 on 회원.id = 커버링.id
```

* order by, offset, limit 절로 인한 불필요한 데이터블록 접근을 커버링 인덱스를 통해 최소화 할 수 있다.


### 트랜잭션 ACID 
* 원자성(Atomicity) : 트랜잭션과 관련된 작업들이 부분적으로 실행되다가 중단되지 않는 것을 보장하는 능력
* 일관성(Consistency) : 트랜잭션이 실행을 성공적으로 완료하면 언제나 일관성 있는 데이터베이스 상태로 유지하는 것을 의미한다.
* 독립성(Isolation) : 트랜잭션을 수행 시 다른 트랜잭션의 연산 작업이 끼어들지 못하도록 보장하는 것을 의미한다.
* 지속성(Durability) : 성공적으로 수행된 트랜잭션은 영원히 반영되어야 함을 의미한다.   

#### 원자성(Atomicity)
* ALL or Nothing ( 무조건 성공 or 무조건 실패)
* MySql에서 어떻게 원자성을 보장하나 -> MVCC를 통해 보장

![image](https://user-images.githubusercontent.com/60100532/203794129-d01325f5-0834-4d6e-ba0e-2d8e8fa431ba.png)

![image](https://user-images.githubusercontent.com/60100532/203794200-89d09295-9064-43fa-aa78-ac65142c3ee9.png)
* undoLog에 원본 데이터 저장.  

### 트랜잭션 실패시
![image](https://user-images.githubusercontent.com/60100532/203794363-c540d03f-8806-4d1b-b5c3-94a55dc2f169.png)
* 트랜잭션 실패시 undoLog의 데이터로 원복

### 커밋시
![image](https://user-images.githubusercontent.com/60100532/203794710-aebc15e8-c725-483f-91ee-4c76707da37c.png)
* 김국밥의 잔액은 1400으로 반영됨
* 커밋이 완료되어도 undoLog의 데이터는 바로 삭제하지 않는다.
* 김국밥의 잔액을 +900하는 트랜잭션보다 먼저 시작했지만 아직 끝나지 않아 undoLog의 데이터를 바라봐야 하는 트랜잭션이 있을 수 있다

> 트랜잭션이 Atomicity한 단위가 된다!
> 

#### 일관성(Consistency)
* 트랜잭션이 종료되었을 때 데이터 무결성이 보장된다.
* 제약조건을 통해 일관성을 보장해준다.(유니크 제약, 외래키 제약 등.)

#### 독립성(Isolation)
* 트랜잭션은 서로 간섭하지 않고 독립적으로 동작한다. 
* 하지만 많은 성능을 포기해야 하므로 개발자가 제어가 가능 (트랜잭션 격리레벨을 통하여 via MVCC)

#### 지속성(Durability) 
* 완료된 트랜잭션을 유실되지 않는다.
* WAL을 통해!! 

 
### 트랜잭션 격리 레벨
* ISOLATION - 트랜잭션은 서로 간섭하지 않고 독립적으로 동작한다. 
* 격리 레벨 (innoDB)
  * READ UNCOMMITTED
  * READ COMMITTED
  * REPEATABLE READ
  * SERIALIZABLE READ

### * Dirty Read 커밋되지 않은 데이터를 읽은 경우
> ![image](https://user-images.githubusercontent.com/60100532/203985931-a1e793ec-da2a-43d8-9727-511f1eff86cb.png)  
> 
> ___
> ![image](https://user-images.githubusercontent.com/60100532/203986005-4665272b-8e73-4eb3-af6c-52d837715a4f.png)  
> 
> ___
> ![image](https://user-images.githubusercontent.com/60100532/203986123-d182e6e9-b36f-4287-afe6-e272b95ae49a.png)  
> 
> ---
> TX1의 update가 rollback되기 전에 TX2에서 김국밥의 잔액 1400원을 읽어옴 (커밋되지 않은 데이터를 읽어옴 (dirty read))
> ![image](https://user-images.githubusercontent.com/60100532/203986173-f5b3f9de-aca4-4c59-96c9-746b5450ff4f.png)
___  
<br />  

### * Non Repeatable Read 같은 트랜잭션에서 같은 데이터를 조회했지만 결과가 달라지는 경우
> ![image](https://user-images.githubusercontent.com/60100532/203986401-6caa3218-1af1-4ccd-bd97-05a624e41ffe.png)  
> 
> ---
> ![image](https://user-images.githubusercontent.com/60100532/203986593-f7df3afb-1740-4dcd-9515-883f3e92b095.png)  
> 
> ---
> ![image](https://user-images.githubusercontent.com/60100532/203986803-470b9317-4057-4271-825d-f5683386a8f8.png)
> 
> ---
>  TX1의 트랜잭션이 끝나기전 같은 트랜잭션에서 같은 홍길동의 잔액을 조회했지만 그 결과가 달라졌다.
> ![image](https://user-images.githubusercontent.com/60100532/203986874-36983792-0e87-4662-abe3-3d4157a2c3d5.png)
___    
<br />    

### * Phantom READ 같은 트랜잭션에서 같은 조건으로 데이터를 조회했지만 결과가 달라지는 경우
>![image](https://user-images.githubusercontent.com/60100532/203987148-3e188e34-aec5-417f-a0de-2010e489b85a.png)   
> 
> ---
> ![image](https://user-images.githubusercontent.com/60100532/203987183-c9b667b9-b35a-4ea1-83d3-7f7438ee329f.png)  
> 
> ---
> TX1의 트랜잭션이 끝나기전에 같은 조건으로 데이터를 조회했지만 결과과 달라짐
>  ![image](https://user-images.githubusercontent.com/60100532/203987251-b7acb3be-6c2d-44b0-ad39-b6d4f35faaa3.png)
> 

  
<br />  

![image](https://user-images.githubusercontent.com/60100532/203985016-cc5a749e-15b8-4fc1-87b0-a309dee08abc.png)


## 동시성 제어하기
* 대부분 하나의 웹 서버는 여러 개의 요청을 동시에 수행할 수 있다.
* 작성한 코드 한 줄은 동시에 수행 될 수 있다.
* 하나의 자우너을 두고 여러 개의 연산들이 경합 -> 데이터 정합성을 깨뜨릴 수 있다.

![image](https://user-images.githubusercontent.com/60100532/213468378-f92fb217-e2a1-4caa-bb44-1411321ee509.png)


![image](https://user-images.githubusercontent.com/60100532/213468779-710edf36-38ea-43f2-9b01-a1d98477067f.png)

* 데이터베이스에서 동시성 이슈가 발생하는 일반적인 패턴
  * 공유자원 조회 -> 홍길동 잔고 조회 
  * 공유자원 갱신 -> 홍길동 잔고 갱신
  * 대표적인 동시성 이슈 해결방법은 
    * 공유 자원에 대한 잠금을 획득하여 줄 세우기

<br />  

* 동시성 이슈가 어려운 이유
  1. 로컬에서는 대부분 하나의 스레드로 테스트
  2. 이슈가 발생하더라도 오류가 발생하지 않는다.
  3. 코드에서 잘 보이지 않는다.
  4. 항상 발생하지 않고 비결정적으로 발생한다.

> 작성한 코드 한 줄은 동시에 수행 될 수 있다!!!!!