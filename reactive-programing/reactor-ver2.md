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


## Subscribe
* Publisher에 subscribe하지 않으면 아무 일도 생기지 않는다.
* 컵 속의 빨대에 비유
* consumer를 넘기지 않는 subscribe
  * 별도로 consume을 하지 않고 최대한으로 요청
* 함수형 인터페이스 기반의 subscribe
  * Disposable을 반환하고 disposable을 통해서 언제든지 연결 종료 가능
* Subscriber 기반의 subscribe
  * subscriber는 subscription을 받기 때문에 request와 cancel을 통해서 backpressure조절과 연결 종료 가능.  

<br />  

```java
Flux.fromIterable(List.of(1,2,3,4,5))
        .doOnNext(value ->{
			log.info("value : {}", value);
        })
        .subscribe();
```
* 위 코드와 같이 subscribe만 하고 별도의 consume을 하지않는 경우 결과를 이용하기 보단. 
* Publisher에서 아이템을 만드는 것이 중요한 경우.
* 결과 확인위해 doOnNext를 이용
* doOnNext : 파이프 라인에 영향을 주지 않고 지나가는 값을 확인
 

### Subscribe - 함수형 인터페이스
* 함수형 인터페이스를 subscribe에 제공
* 각각의 consumer는 null 가능

* consumer :  값을 인자로 받아야 하기 때문에 Consumer 함수형 인터페이스 구현
* errorConsumer : 에러를 인자로 받아야 하기 때문에 Consumer 구현
* completeConsumer : 받을 인자가 없기 때문에 Runnable 구현
* ititialContext : upstream에 전달할 context


### Subscribe - Subscriber
* Subscriber 구현체를 subscribe에 전달
* onSUbscribe를 통해서 subscription을 받고 즉시 Long.MAX_VALUE개 만큼 request
* unbounded request: Publisher에서 제공 할 수 있는 데이터를 최대한 요청

### Subscribe - BaseSubscriber
* reactor에서 BaseSubscriber를 제공
* onNext, onComplete, onError, onSubscribe를 직접 호출하는 대신
* hookOnNext, hookOnComplete, hookOnError, hookOnSubscribe를 구현
* subscriber 외부에서 request와 cancel을 호출 가능
* 기본적으로 unbounded request
 

### Subscribe - backPressure
* unbounded request는 Publisher에게 가능한 빠르게 아이템을 전달해달라는 요청
* request(Long.MAX_VALUE)로 실행
* backPressure를 비 활성화
* 아무것도 넘기지 않는 그리고 lambda 기반의 subscribe()
* BaseSubscriber의 hookOnSubscribe를 그대로 사용
* block(), blockFirest(), blockLast()등의 blocking 연산자 
* tolterable(), toStream()등의 toCollect 연산자

```java
var subscriber = new BaseSubscriber<Integer>(){
    @Override
    protected void hookOnSubscribe(Subscription subscription) {
        request(1);
    }
	
	@Override
    protected void hookOnNext(Integer value) {
        log.info("value : {}", value);
        request(1);
    }
	
	@Override
    protected void hookOnComplete() {
        log.info("complete");
    }
};

Flux.fromIterable(List.of(1,2,3,4,5))
        .subscribe(subscriber);
```

* hookOnSubscribe을 override해서 1개만 request
* onNext 이벤트가 발생하면 cancel을 실행

### Subscribe - buffer
```java
var subscriber = new BaseSubscriber<List<Integer>>(){
	private Integer count = 0;
	
	@Override
    protected void hookOnSubscribe(Subscription subscription) {
        request(2);
	}
	
	@Override
    protected void hookOnNext(List<Integer> value) {
        log.info("value : {}", value);
		if(++count == 2) cancel();
    }
	@Override
    protected void hookOnComplete() {
        log.info("complete");
    }
}

Flux.fromStream(IntStream.range(0,10).boxed())
        .buffer(3)
        .subscribe(subscriber);
```

* buffer(N) 호출시 N개 만큼 모아서 Listfh wjsekf
* buffer(3) 호출 후 request(2)를 하는 경우, 3개가 담긴 List 2개가 Subscriber에게 전달 
* 즉 6개의 item을 전달

### Subscribe - take(n, limitRequest)
* subscriber 외부에서 연산자를 통해서 최대 개수를 제한.
* limitRequest가 true인 경우, 정확히 n개 만큼 요청후 complete 이벤트를 전달.
* BaseSubscriber의 기본 전략이 unbounded request이지만 take(5,true)로 인해서 5개 전달 후 complete 이벤트  

```java
var subscriber = new BaseSubscriber<Integer>(){
    @Override
    protected void hookOnNext(Integer value){
        log.info("value : {}", value);
	}
	@Override
    protected void hookOnComplete() {
        log.info("complete");
    }
};

Flux.fromStream(IntStream.range(0,10).boxed())
        .take(5,true)
        .subscribe(subscriber);
```