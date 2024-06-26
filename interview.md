### BiocoreDx
* 모니터링 시스템 & 알림 도입 
  * MDC 활용 request마다 request id 부여하여 요청의 흐름을 추적할 수 있도록 함.
* 비동기 파일 생성 큐 시스템 개발
  * 기존 Sync/Blocking 방식의 파일( 검사 결과 파일 ) 생성 프로세스를 Async/non-blocking으로 처리할 수 있는 큐 시스템을 기존에 사용 중인 database를 활용해 개발 고객 경험 개선
  * 파일 생성 요청을 큐(DB)에 넣고, 스케줄러를 사용해 일정 시간마다 큐에서 데이터를 읽어 파일 생성 후 고객 이메일로 전송 
  * scale out 대비해 파일 생성 큐 데이터에 상태값(ready, processing, complete)과 version을 부여하여 중복 생성을 방지 
* 검사 결과 생성 쿼리 개선 
  * 검사 결과 특성상 특정 코드의 코드명을 조회하는 쿼리가 많이 사용되는데, 이를 개선하기 위해 커버링 인덱스를 활용하도록 인덱스 추가.
    * 해당 데이터들은 변경이 거의 없고, 조회가 많은 특성을 가지고 있어 커버링 인덱스를 활용하기 좋다고 판단
  * 또한 TAT(임상시험 품질 관리 지표)를 계산하는 로직이 DB 함수로 정의되어 매 검사 조회 시점마다 계산되는데, 해당 함수가 성능상 병목을 일으키는 것을 확인 
  * 이를 개선하기 위해 프로세스를 개선하여 TAT를 계산하여 저장하는 컬럼을 추가하여 조회시점에 계산하지 않도록 함.
 
### 비법 거래소
* 간단한 유저의 요청 한 번에 수백명의 유저에게 푸쉬 알림을 보내야 하는 요구사항 발생, 해당 알림 전송기능은 비동기로 처리해야할 필요성이 있다고 판단
* 이를 해결하기 위해 DataBase와 ApplicationEventPublisher를 활용해서 eventQueue 구현 
  * 모든 인프라가 aws에 올라가 있었기 때문에 저렴한 aws sqs를 활용 할 수도 있었지만 사이드 프로젝트 특성상 비용을 최소화하고 또      
    당시 팀원들이 해당 기술에 익숙하지 않아 ApplicationEventPublisher와 DataBase를 활용하여 비동기 처리를 구현하였다.
  * 이벤트 발행 시 db에 이벤트 발생 이력을 저장 후 이벤트 발행 (Dead Letter Queue 구현을 위해)
  * 각 이벤트 리스너에서 처리할 비즈니스 로직을 supplier로 받아서 db에 저장된 이벤트 이력의 상태 값을 변경하고 비즈니스 로직을 수행하도록 구현

* 선착순 게시글 상장 이벤트 구현 & 개선 
  * 선착순 게시글 상장 이벤트를 구현하기 위해 redis를 활용하여 분산락을 사용해 구현 ( 게시글 상장은 해당 게시글의 좋아요 숫자에 의해 결정)
  * 로컬 환경 테스트시 대략 700rps 처리 가능, 또한 테스트시 종종 lock을 획득하는데 실패하는 상황 발생  
  * 하지만 일반적으로 사용자는 좋아요를 누를 때 해당 요청이 처리되기 위해서 기다려야 하는 경험을 한다거나 좋아요를 실패하는 경험은 좋지 않다고 판단, 분산락을 가져오는 로직에서 병목이 발생하는 것을 확인
  * 해당 문제를 해결하기 위해 Redis의 EVAL이란 커맨드에 script를 활용하여 해결, 더 나아가 좀더 성능을 개선하기 위해 실제 상장 로직은 비동기로 처리하도록 개선
  * 스크립트에서 이벤트가 존재하는지, 이벤트로 상장 가능한 게시글 갯수가 남아 있는지, 잔여 이벤트 카운트 증가, 실제 이벤트 상장 로직 수행을 위한 데이터를 큐에 적제의 로직을 한번에 처리하도록 개선
  * 기존 700rps에서 6500rps로 성능 개선 및 락획득 실패에 따른 요청 실패 개선