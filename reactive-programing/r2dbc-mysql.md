# R2dbc 
## Spring data
* 데이터저장소의특성을유지하면서
* Spring 기반의 프로그래밍 모델을 제공 
* 다양한 데이터 접근 기술을 지원
  * 관계형db, 비관계형db
  * map-reduce 프레임워크
  * 클라우드 기반의 data서비스

## Spring data reactive
* Reactive streams, Reactor, Netty client, Java NIO, Selector를 사용하여 비동기 non- blocking을 지원
* Reactive client를 제공하고 이를 기반으로 ReactiveTemplate 혹은 ReactiveRepository를 구현
* 데이터베이스에대한대한작업의결과로대부 분 Publisher를 반환

## 왜 JDBC, JPA는 non-blocking을 지원할 수 없나
### JDBC, JPA
* JDBC는 동기 blocking I/O 기반으로 설계
* Socket에 대한 연결과 쿼리 실행 모두 동기 blocking 으로 동작
* 이미 널리 사용되고 있기 때문에 JDBC를 수정 하는 것은 사실상 불가능
* JPA 또한 jdbc 기반이기 때문에 비동기 non-blocking 지원 불가능
* ->비동기 non-blocking 기반의 API,드라이 버를 새로 만들자!

![img.png](img.png)

## spring data r2dbc 스택 

![img_1.png](img_1.png)

## R2dbc
* Reactive Relational Database Connectivity
* 2017년 Pivotal사에서 개발이 시작되어 2018년부터 공식 프로젝트로 후원
* 비동기, non-blocking 관계형 데이터베이스 드라이버
* Reactive streams 스펙을 제공하며 Project reactor 기반으로 구현