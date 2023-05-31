# MongoDB
### why MongoDB
* Schema가 자유롭다.
* HA와 Scale-Out Solution을 자체적으로 지원해 확장이 쉽다.
* Secondary Index를 지원하는 NoSQL이다.
* 다양한 종류의 index를 제공한다.
* 응답 속도가 빠르다.
* 배우기 쉽고 간편하게 개발이 가능하다.

### Structure & Schema
####  장점
* 데이터 접근성과 가시성이 좋다.
* Join 없이 조회가 가능해서 응답 속도가 일반적으로 빠르다.
* 스키마 변경에 공수가 적다.
* 스키마가 유연해서 데이터 모델을 app의 요구사항에 맞게 데이터를 수용할 수 있다.

#### 단점
* 데이터의 중복이 발생한다.
* 스키마가 자유롭지만, 스키마 설계를 잘해야 성능 저하를 피할 수 있다.

![image](https://github.com/JayPark7821/TIL/assets/60100532/cb9db6a0-69ee-4678-af5a-ad7662c18bf4)


### Scaling
* HA와 Sharding에 대한 솔루션을 자체적으로 지원하고 있어 Scale-Out이 간편하다.
* 확장 시, Application의 변경사항이 없다.

### Terminology
| RDBMS    | MongoDB    |
|----------|------------|
| Cluster  | Cluster    | 
| Database | Database   |
| Table    | Collection |
| Row      | Document   |
| Column   | Field      |

### Collection
* Collection 특징
* 동적 스키마를 갖고 있어서 스키마를 수정하려면 필드 값을 추가/수정/삭제하면 된다.
* Collection 단위로 index를 생성할 수 있다.
* Collection 단위로 Shard를 나눌 수 있다.

### Document   
* Document 특징
* JSON형태로 표현하고 BSON(Binary JSON) 형태로 저장한다.
* 모든 Document는 _id 필드를 가지고 있고, 없이 생성하면 ObjectId타입의 고유한 값을 저장한다.
* 생성 시, 상위 구조인 Database나 Collection이 없다면 먼저 생성하고 Document를 생성해야 한다.
* Document의 최대 크기는 16MB이다.

### MongoDB 배포 형태
* Standalone    
  ![image](https://github.com/JayPark7821/TIL/assets/60100532/30c23978-e7f3-41a9-ac14-389fc468c777)

<br />   

* Replica Set
* Replica Set은 local database의 Oplog Collection을 통해 복제를 수행한다.

| status    | description                                                                                        |
|-----------|----------------------------------------------------------------------------------------------------|
| Primary   | * Read/Write 요청 모두 처리 가능<br/>* Write를 처리하는 유일한 멤버<br/>* Replica Set에 하나만 존재할 수 있다.                 |  
| Secondary | * Read에 대한 요청만 처리할 수 있다.<br/>* 복제를 통해 Primary와 동일한 데이터 셋을 유지한다.<br/> * Replica Set에 여러개가 존재할 수 있다. |
  

<br />   

  ![image](https://github.com/JayPark7821/TIL/assets/60100532/fd5949e1-36fd-4475-b46a-0d404595be75)

<br />

* Replica Set Election(Fail-Over)  

![image](https://github.com/JayPark7821/TIL/assets/60100532/d223c977-f913-4f73-8d8f-c5fd68df323f)

<br />

* Shard Cluster
* 모든 Shard는 Replica Set으로 구성되어 있다.
* Pros & Cons

| Pros                                                                                               | Cons                                             |
|----------------------------------------------------------------------------------------------------|--------------------------------------------------|
| * 용량의 한계를 극복할 수 있다.<br/>* 데이터 규모와 부하가 크더라도 처리량이 좋다.<br/>* 고가용성을 보장한다.<br/>* 하드웨어에 대한 제약을 해결할 수 있다. | * 관리가 비교적 복잡하다.<br/>* Replica Set과 비교해서 쿼리가 느리다. |


<br />

  ![image](https://github.com/JayPark7821/TIL/assets/60100532/1444f0f8-c6f6-4f3f-a7b1-caa16557b255)