# Reactor
## Selector
## Java NIO non-blocking의 문제점
* main 쓰레드에서 accept 완료되었는지 주기적으로 확인 해야함.  

```java
while(true) {
    SocketChannel client = serverChannel.accept();
    if(client == null) {
		Thread.sleep(100);
		continue;
    }
}
```
* 각각의 쓰레드에서 read 가능한지 주기적으로 확인
* 채널 상태를 수종으로 관리해야 하고 코드 복잡성이 증가.
* 동시에 발생하는 요청이 증가하는 경우, 연결 처리가 순차적으로 발생하여 성능 감소

#### Busy-wait
* 동기 non-blocking에서 주로 발생
* 루프를 이용해서 원하는 자원을 얻을 떄까지 확인
* 지속적으로 cpu를 점유하기 때문에 cpu 자원이 낭비
* 확인하는 주기에 따라서 응답 시간 지연이 발생

## 동기 non-blocking의 원인
* I/O와 관련된 이벤트를 각각의 쓰레드가 확인해야 한다.
* 채널의 상태를 수동으로 관리해야 한다.

## 한 번에 여러 이벤트를 추적할 수 있는 방법은???
### SelectableChannel
* configureBlocking과 register 함수 제공
* register: Selector에 channel을 등록할 수 있다.

### Selector
* java.nio.channels 패키지
* 여러 channel의 이벤트를 등록하고 준비된 이벤트를 모아서 조회 가능
* select와 selectedKeys 함수 제공

#### Selector 생성
* Selector.open() 메소드를 이용해서 생성
* Closable을 구현했기 때문에 직접 close하거나 try-with-resources 사용 가능

#### Selector 등록
* channel에 selector와 관심있는 이벤트를 등록
* channel의 register 내부 함수에서 다시 selector의 register 호출

#### Selector 이벤트 타입
* OP_READ: channel의 읽기 준비가 완료
* OP_WRITE: channel의 쓰기 준비가 완료
* OP_CONNECT: socketChannel에서 connect 준비가 완료
* OP_ACCEPT: serverSocketChannel에서 accept 준비가 완료

#### Selector에 Accept 작업 등록
* bind, configureBlocking 까지는 동일
* register를 통해서 serverSocketChannel의 Accept 이벤트를 selector에 등록
* register에서 별도의 blocking 없이 바로 패스


#### Selector 대기
* select : 등록한 채널들 중 준비된 이벤트가 없다면 계속 쓰레드 blocking
* 준비가 완료된 작업들이 발견되면, 다음 line으로 이동
* selectKeys : 준비가 완료된 이벤트 목록을 Set으로 제공
* iterator로 변경하여 하나씩 순회하며, 조회 이후에 remove를 통해서 제거
* 제거하지 않으면 계속해서 처리하려고 시도.

```java
while(true){
    selector.select(); // 준비된 이벤트가 없다면 계속 쓰레드 blocking
    
    var selectedKeys = selector.selectedKeys().iterator();
	
	while(selectedKeys.hasNext()){
        var key = selectedKeys.next();
		// 준비가 완료된 작업 목록에서 제외
        selectedKeys.remove();
    }
}
	
```
#### SelectionKey
* 등록했던 channel과 selector 이벤트 타입을 포함.
* isReadable, isWritable, isConnectable, isAcceptable 을 통해서 channel에 어떤 이벤트가 준비되었는지 체크 가능
  
---  

### file descriptor
* 유닉스 계열의 os에서는 일반적인 파일, 네트워크 소켓, 파이프, 블록 디바이스 등 모든 객체를 파일로 관리
* 열려있는 파일에 접근할 때, fd(file descriptor)를 이용해서 파일을 지정
* fd는 음이 아닌 정수를 사용, file descriptor table의 index로 사용
* 파일을 open하면, fd로 사용하지 않은 가장 작은 값을 할당
* 표준 입력, 표준 출력, 표준 에러에 각각 0,1,2 fd 할당 ( 0, 1, 2는 예약된 fd)

### select system call
* 대부분의 os에서 지원. 범용적으로 사용가능
* fd_set에 fd를 등록하고 이 fd_set을 system call을 통해서 체크
* fd를 하나씩 체크하므로 시간이 선형적으로 증가 O(n)
* fd는 최대 1024 혹은 2048개 까지만 등록 가능

### epoll
* os가 fd 세트를 관찰하고 I/O가 준비된 fd가 있다면 application에 전달

#### epoll_create
* epoll 인스턴스를 생성하고 epoll 인스턴스의 fd(epfd)를 반환 
* epoll 인스턴스는 관심 목록과 준비 목록 포함
* 관심 목록 : 감시하기 위해서 등록된 fd 세트
* 준비 목록 : I/O 준비 상태인 fd 세트. 준비 목록은 관심 목록의 부분 집합.

#### epoll_ctl
* epoll 인스턴스에 fd의 이벤트를 등록/삭제/수정 가능
* epoll_create로 얻었던 epfd를 인자로 전달.
* 관심있는 fd와 이벤트 종류는 fd와 event를 인자로 전달.
* fd의 이벤트를 등록/삭제/수정 할 것인지를 op인자로 전달
  * op는 EPOLL_CTL_ADD, EPOLL_CTL_DEL, EPOLL_CTL_MOD
    * EPOLL_CTL_ADD : event 인자에 지정한 설정으로 epfd의 관심 목록에 fd를 추가
    * EPOLL_CTL_DEL : 관심 목록에서 fd를 제거
    * EPOLL_CTL_MOD : 관심 목록에 있는 fd의 설정을 event 인자에 지정한 설정으로 수정
  * event
    * epoll_ctl에 적용할 설정
    * fd와 어떤 I/O 이벤트를 관찰할지 설정
    * events는 이벤트 상수들을 0개 이상 or 해서 구성한 비트 마스 
      * EPOLLIN : fd에 데이터가 존재하고 읽기가 가능한 상태 ServerSocketChannel의 accept
      * EPOLLOUT : fd에 데이터를 쓸 수 있는 상태

#### epoll_wait
* epoll 인스턴스에서 이벤트를 대기
* events에 준비가 완료된 fd 목록을 최대 maxevents개 만큼 반환
* timeout 시간동안 block 되며, -1로 지정하면 하나의 fd라도 준비될 때까지 무한정 대기

## epoll을 selector에 대입
### selector 생성
* selector의 생성은 epoll_create를 사용  
```java
var selector = Selector.open();
```
```cpp
int epfd = epoll_create(1);
```
### channel 등록
* epoll_ctl에 EPOLL_CTL_ADD를 사용해서 관심 목록에 추가.

```java
serverChannel.register(selector, SelectionKey.OP_ACCEPT);
```
```cpp
struct epoll_event event;
event.data.fd = server_channel_fd;
event.events = EPOLLIN;
epoll_ctl(epfd, EPOLL_CTL_ADD, server_channel_fd, &event);
```
### select
* epoll_wait를 통해서 대기하고 events에 담긴 정보들을 반환
* timeout을 -1로 제공해서 채널이 하나라도 준비 되지 않는다면 무한정 대기
* 이를 통해서 selector.select()에서 busy-wait제거 가능
```java
selector.select(); // 준비될때까지 blocking
var selectedKeys = selector.selectedKeys().iterator();
```
```cpp
#define EPOLL_SIZE 100
struct epoll_event events[EPOLL_SIZE];
int event_count = epoll_wait(epfd, events, EPOLL_SIZE, -1);
```


## Reactor Pattern
* 동시에 들어오는 요청을 처리하는 이벤트 핸들링 패턴
* service handler는 들어오는 요청들을 demultiplexing해서 request handler에게 동기적으로 전달
* accept, read, write 이벤트들을 한 곳에 등록하여 관찰하고, 준비 완료된 이벤트들을 request handler에게 전달 한다.
* -> selector를 이용한 java nio 처리와 비슷하다.

### Reactor pattern 구성 요소
* Reactor : 별도의 쓰레드에서 실행. 여러 요청의 이벤트를 등록하고 감시하며, 이벤트가 준비되면 dispatch 한다.
* Handler : Reactor로 부터 이벤트를 받아서 처리한다.

### Reactor 구현
* 별도의 쓰레드에서 동작해야 한다. -> Runnable을 구현하고 별도의 쓰레드에서 Run 
* 여러 요청의 이벤트를 등록하고 감시한다. -> Selector를 사용
* 이벤트가 준비되면 dispatch 한다 -> EventHandler 인터페이스를 만들고 call

### EventHandler 구현
* Reactor로 부터 이벤트를 받아서 처리 -> accept 이벤트와 read 이벤트 각각을 처리할 수 있는 EventHandler를 만든다.
* EventHandler의 처리가 Reactor에 영향을 주지 않아야 한다. -> EventHandler에 별도의 쓰레드 실행



