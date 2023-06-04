# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 옵저버 (Observer) 패턴
* 다수의 객체가 특정 객체 상태 변화를 감지하고 알림을 받는 패턴.
* 발행(Publish)-구독(Subscribe) 패턴을 구현할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/204134993-194c24d4-5bb7-42e1-97c0-0c6873744509.png)

### 코드로 옵져버 패턴을 알아보자.
 
### Client code

```java
public class Client {

  public static void main(String[] args) {
    ChatServer chatServer = new ChatServer();

    User user1 = new User(chatServer);
    user1.sendMessage("디자인패턴", "이번엔 옵저버 패턴입니다.");
    user1.sendMessage("롤드컵2021", "LCK 화이팅!");

    User user2 = new User(chatServer);
    System.out.println(user2.getMessage("디자인패턴"));

    user1.sendMessage("디자인패턴", "예제 코드 보는 중..");
    System.out.println(user2.getMessage("디자인패턴"));
  }
}

```
### ChatServer
```java

public class ChatServer {

  private Map<String, List<String>> messages;

  public ChatServer() {
    this.messages = new HashMap<>();
  }


  public void add(String subject, String message) {
    if (messages.containsKey(subject)) {
      messages.get(subject).add(message);
    } else {
      List<String> messageList = new ArrayList<>();
      messageList.add(message);
      messages.put(subject, messageList);
    }
  }

  public List<String> getMessage(String subject) {
    return messages.get(subject);
  }
}
```

 
### User
```java
public class User {

    private ChatServer chatServer;

    public User(ChatServer chatServer) {
        this.chatServer = chatServer;
    }


    public void sendMessage(String subject, String message) {
        chatServer.add(subject, message);
    }

    public List<String> getMessage(String subject) {
        return chatServer.getMessage(subject);
    }
}

```
### 옵져버 패턴을 적용.
#### Client
```java

public class Client {

  public static void main(String[] args) {
    ChatServer chatServer = new ChatServer();
    User user1 = new User("keesun");
    User user2 = new User("whiteship");

    chatServer.register("오징어게임", user1);
    chatServer.register("오징어게임", user2);

    chatServer.register("디자인패턴", user1);

    chatServer.sendMessage(user1, "오징어게임", "아.. 이름이 기억났어.. 일남이야.. 오일남");
    chatServer.sendMessage(user2, "디자인패턴", "옵저버 패턴으로 만든 채팅");

    chatServer.unregister("디자인패턴", user2);

    chatServer.sendMessage(user2, "디자인패턴", "옵저버 패턴 장, 단점 보는 중");
  }
}

``` 
#### ChatServer
```java

public class ChatServer {

  private Map<String, List<Subscriber>> subscribers = new HashMap<>();

  public void register(String subject, Subscriber subscriber) {
    if (this.subscribers.containsKey(subject)) {
      this.subscribers.get(subject).add(subscriber);
    } else {
      List<Subscriber> list = new ArrayList<>();
      list.add(subscriber);
      this.subscribers.put(subject, list);
    }
  }

  public void unregister(String subject, Subscriber subscriber) {
    if (this.subscribers.containsKey(subject)) {
      this.subscribers.get(subject).remove(subscriber);
    }
  }

  public void sendMessage(User user, String subject, String message) {
    if (this.subscribers.containsKey(subject)) {
      String userMessage = user.getName() + ": " + message;
      this.subscribers.get(subject).forEach(s -> s.handleMessage(userMessage));
    }
  }

}

```

#### Subscriber
```java

public interface Subscriber {

  void handleMessage(String message);
}

```
#### User
```java

public class User implements Subscriber {

  private String name;

  public User(String name) {
    this.name = name;
  }

  public String getName() {
    return name;
  }

  @Override
  public void handleMessage(String message) {
    System.out.println(message);
  }
}

```
---
![image](https://user-images.githubusercontent.com/60100532/204136624-db7c29b9-29cd-41d5-bee3-ada72ebb4e58.png)
___
___

<br/> 

<br/> 

### 옵저버 (Observer) 패턴 장단점
* 장점
    * 상태를 변경하는 객체(publisher)와 변경을 감지하는 객체(subscriber)의 관계를 느슨하게 유지할 수 있다.
    * subject의 상태 변경을 주기저긍로 조회하지 않고 자동으로 감지할 수 있다.
    * 런타임에 옵저버를 추가하거나 제거할 수 있다.
* 단점
    * 복잡도가 증가한다.
    * 다수의 Observer 객체를 동혹 이후 해지하지 않는다면 memory leak이 발생할 수도 있다. (WeakReference 참조)

___
___

<br/> 

<br/> 

### 옵저버 (Observer) 패턴

* 자바
  * Observable과 Observer (자바 9부터 deprecated)
  * 자바 9 이후 부터는
    * PropertyChangeListener, PropertyChangeEvent
    * Flow API
  * SAX(Simple API for XML)라이브러리
* 스프링
  * ApplicationContext와 ApplicationEvent

