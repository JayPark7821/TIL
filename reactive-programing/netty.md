# Netty
* 비동기 이벤트 기반의 네트워크 어플리케이션 프레임워크
* HTTP 분만 아니라 다양한 프로토콜 지원
* Java IO, NIO, selector 기반으로 적은 리소스로 높은 성능 보장
* 불필요한 메모리 copy를 최소한으로
* 유연하며 확장 가능한 이벤트 모델 기반
* 서버와 클라이언트 모두 지원

## NIOEventLoop
* EventExecutor. TaskQueue, Selector를 포함
* EventExecutor : task를 실행하는 쓰레드풀
* TaskQueue : task를 저장하는 큐, eventExecutor가 즉시 task를 수행하지 않고 taskQueue에 넣은 후, 나중에 꺼내서 처리 가능
* Selector : I/O Multiplexing을 지원

## NIOEventLoop의 task
* I/O task와 Non-I/O task로 구분
* I/O task : register를 통해서 내부의 selector에 channel을 등록하고 I/O 준비 완료 이벤트가 발생하면 channel의 pipeline 실행
* Non-I/O task : task queue에서 Runnable 등 실행 가능한 모든 종류의 task를 꺼내서 실행

## NIOEventLoop의 ioRatio
* ioRatio를 설정하여 각각 task 수행에 얼마나 시간을 사용할지 설정 가능
* 기본값은 50
  * I/O task와 Non-I/O task를 1:1로 처리 동일한 시간을 사용
  * 100이면 시간을 측정하지 않고 task 수행

## NIOEventLoop의 I/O task
* NIOEventLoop를 직접 생성할 수 없기 때문에 NIOEventLoopGroup 사용
* NIO를 수행하는 ServerSocketChannel을 생성하고 accept network I/O 이벤트를 eventLoop에 등록
* 하나의 eventLoopGroup에 여러 개의 channel등록 가능
* I/O 이벤트 완료시 channel의 pipeline 실행

```java
var channel = new NioServerSocketChannel();
var eventLoopGroup = new NioEventLoopGroup(1); // 1개의 eventLoop를 가진 eventLoopGroup 생성
eventLoopGroup.register(channel); // 위에서 생성한 channel의 accept network I/O 이벤트를 eventLoop에 등록

channel.bind(new InetSocketAddress(8080))
        .addListener((ChannelFutureListener) future -> {
          if (future.isSuccess()) {
            System.out.println("Server bound");
          } else {
            System.out.println("Bound attempt failed");
            eventLoopGroup.shutdownGracefully();
          }
        });
```

## NIOEventLoop의 Non I/O task
* 일반적인 Executor처럼 Non I/O task 수행
* 하나의 쓰레드에서 돌기 때문에 순서 보장
* NioEventLoopGroup은 별도의 쓰레드풀을 가지고 있음
* execute()를 실행하는 쓰레드와 NioEventLoopGroup의 쓰레드가 다른 경우 execute를 즉각 적으로 실행하지 않고 taskQueue에 저장 후 NioEventLoopGroup의 쓰레드가 taskQueue에서 꺼내서 실행
```java
EventLoopGroup eventLoopGroup = new NioEventLoopGroup(1);

for (int i = 0; i < 10; i++) {
  final int idx = i;
  eventLoopGroup.execute(() -> {
    System.out.println(idx);
  });
}

eventLoopGroup.shutdownGracefully();
```

## EventLoopGroup
* EventLoop를 가지고 있는 group
* 생성자를 통해서 내부에 몇 개의 eventLoop를 포함할지 설정 가능
* group에서 execute는 eventLoopGroup내의 eventLoop를 순회하면서 execute 실행
* 각각의 eventLoop에 순차적으로 task가 추가되고 실행하기 때문에 eventExecutor 단위로 놓고 보면 순서가 보장.
```java
EventLoopGroup eventLoopGroup = new NioEventLoopGroup(5);
        
for (int i = 0; i < 12; i++) {
  final int idx = i;
  eventLoopGroup.execute(() -> {
    System.out.println(idx);
  });
}

eventLoopGroup.shutdownGracefully();
```  

---
