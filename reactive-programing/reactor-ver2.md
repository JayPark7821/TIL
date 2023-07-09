# Reactor
## recap
* Reactive streams
* 비동기 데이터 스트림 처리를 위한 표준
* publisher는 subscriber에게 비동기 적으로 이벤트 전달.
* onSubscribe: subscriber가 publisher 사이에 연결이 시작될때 호출, Subscription 객체를 전달.
* onNext: publisher가 데이터를 생성하고 Subscriber에게 전달. Subscriber는 데이터를 받고 처리  

<br />

* Subscription
* request : subscriber가 publisher에게 n개의 데이터 요청. Subscriber가 처리 가능한 만큼만 요청
* cancel : Subscriber가 데이터 요청을 취소하고 연결을 종료. Subscriber가 더이상 데이터를 받지 않거나 에러가 발생한 경우 호출

# Reactor
* Reactive Streams를 구현한 비동기 데이터 스트림 처리를 지원
* Spring webflux에서 메인으로 사용
* backpressure를 제공하여 안정성을 높이고
* 다양한 메소드로 다양한 연산을 조합하여 가독성 증대

## Reactor와 컨베이어 벨트
* 컨베이어 벨트에 비유
* 데이터는 소스(Publisher)에서 나와서 소비자(Subscriber)에게 전달
* 원재료는 다양한 변형과 중간 단계를 거치고 중간 부품을 모으는 더 큰 조립 라인의 일부가 되기도.
* 한 지점에서 결함이 발생하거나 벨트가 막히게 되면 업스트림에 신호를 보내서 흐름을 제한. 

## Reactor Publisher
* Reactor에서 Mono와 Flux 제공
* CorePublisher는 reactive streams의 Publisher를 구현
* reactive streams와 호환

## Flux
* 0...n개의 item을 subscriber에게 전달
* subscriber에게 onComplete, onError signal을 전달하면 연결 종료
* 모든 event가 optional하기 때문에 다양한 flux정의 가능. 심지어 onComplete도 optional
* onComplete를 호출하지 않으면 infinite한 sequence 생성 가능

## Mono
* 0...1개의 item을 subscriber에게 전달
* subscriber에게 onComplete, onError signal을 전달하면 연결 종료
* 모든 event가 optional
* onNext가 호출되면 곧바로 onComplete가 이벤트 전달.
* Mono<Void>를 통해서 특정 사전의 완료를 전달 가능

## Mono는 언제 사용할까?
* 반드시 하나의 값 혹은 객체를 필요로 하는 경우
  * 유저가 작성한 게시글의 숫자.
  * http 응답 객체
* 있거나 혹은 없거나 둘 중 하나인 경우
  * 특정 id를 갖는 유저 객체
* 완료된 시점을 전달해야 하는 경우
  * 유저에게 알림을 보내고 완료된 시점을 전달.  

<br />  

* Publisher에서는 onNext 이후 바로 onComplete를 호출하면 되기 때문에 구현이 더 간단.
* Subscriber의 경우도 최대 1개의 item이 전달된다는 사실을 알고 있기 때문에 더 간결한 코드 작성 가능

* Mono like Optional & Flux like List