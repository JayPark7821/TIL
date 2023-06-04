# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 책임 연쇄 (Chain-Of-Responsibility) 패턴
* 요청을 보내는 쪽(Sender)과 요청을 처리하는 쪽(receiver)을 분리하는 패턴
  * 핸들러 체인을 사용해서 요청을 처리한다.

![image](https://user-images.githubusercontent.com/60100532/201524860-3c8f5947-f8e3-4a7b-882a-db1c6746b888.png)


### 코드로 책임 연쇄 패턴을 알아보자.

#### 책임연쇄 패턴 적용전의 코드를 살펴보자.
#### Client
```java
public class Client {

  public static void main(String[] args) {
    Request request = new Request("무궁화 꽃이 피었습니다.");
    RequestHandler requestHandler = new RequestHandler();
    requestHandler.handler(request);
  }
}
```

#### Request
```java
public class Request {

  private String body;

  public Request(String body) {
    this.body = body;
  }

  public String getBody() {
    return body;
  }

  public void setBody(String body) {
    this.body = body;
  }
}

```
#### RequestHandler
```java

public class RequestHandler {

    public void handler(Request request) {
        System.out.println(request.getBody());
    }
}

```

#### AuthRequestHandler

```java

public class AuthRequestHandler extends RequestHandler {

    public void handler(Request request) {
        System.out.println("인증이 되었나?");
        System.out.println("이 핸들러를 사용할 수 있는 유저인가?");
        super.handler(request);
    }
}
```
#### LoggingRequestHandler
```java
public class LoggingRequestHandler extends RequestHandler {

    @Override
    public void handler(Request request) {
        System.out.println("로깅");
        super.handler(request);
    }
}

```

> 위와 같이 코드를 분리해 단일 책임원칙은 지켜냈지만. 클라이언트 코드가 구체적으로 어떤 코드르를 호출할지 알아야 한다....  
> RequestHandler requestHandler = new LoggingRequestHandler();   
> RequestHandler requestHandler = new AuthRequestHandler();  
> RequestHandler requestHandler = new RequestHandler();  


위 문제를 책임 연쇄 패턴을 적용하여 해결해보자.

#### abstract RequestHandler
```java
public abstract class RequestHandler {

    private RequestHandler nextHandler;

    public RequestHandler(RequestHandler nextHandler) {
        this.nextHandler = nextHandler;
    }

    public void handle(Request request) {
        if (nextHandler != null) {
            nextHandler.handle(request);
        }
    }
}
```

#### RequestHandler( 기존에 출력만 담당했던 핸들러)
```java

public class PrintRequestHandler extends RequestHandler {

    public PrintRequestHandler(RequestHandler nextHandler) {
        super(nextHandler);
    }

    @Override
    public void handle(Request request) {
        System.out.println(request.getBody());
        super.handle(request);
    }
}

```

#### AuthHandler
```java
public class AuthRequestHandler extends RequestHandler {

    public AuthRequestHandler(RequestHandler nextHandler) {
        super(nextHandler);
    }

    @Override
    public void handle(Request request) {
        System.out.println("인증이 되었는가?");
        super.handle(request);
    }
}
```
#### LoggingRequesthandler

```java
public class LoggingRequestHandler extends RequestHandler {

    public LoggingRequestHandler(RequestHandler nextHandler) {
        super(nextHandler);
    }

    @Override
    public void handle(Request request) {
        System.out.println("로깅");
        super.handle(request);
    }
}

```


#### Client
```java
public class Client {

    private RequestHandler requestHandler;

    public Client(RequestHandler requestHandler) {
        this.requestHandler = requestHandler;
    }

    public void doWork() {
        Request request = new Request("이번 놀이는 뽑기입니다.");
        requestHandler.handle(request);
    }

    public static void main(String[] args) {
        RequestHandler chain = new AuthRequestHandler(new LoggingRequestHandler(new PrintRequestHandler(null)));
        Client client = new Client(chain);
        client.doWork();
    }
}

```
![image](https://user-images.githubusercontent.com/60100532/201525849-15dd6224-f4da-4ce4-9f11-2f6e1b35ecae.png)
___
___

<br/> 

<br/> 

### 책임 연쇄 (Chain-Of-Responsibility) 패턴 장단점
* 장점
  * 클라이언트 코드를 변경하지 않고 새로운 핸들러를 체인에 추가할 수 있다.
  * 각각의 체인은 자신이 해야하는 일만 한다.
  * 체인을 다양한 방법으로 구성할 수 있다.
* 단점
  * 디버깅이 조금 어렵다.

___
___

<br/> 

<br/> 

### 책임 연쇄 (Chain-Of-Responsibility) 패턴 

* 자바
  * 서블릿 필터
```java
    public static void main(String[] args) {
        Filter filter = new Filter() {
            @Override
            public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
                // TODO 전처리
                chain.doFilter(request, response);
                // TODO 후처리
            }
        };
    }
```
* 스프링
  * 스프링 시큐리티 필터 
  
 