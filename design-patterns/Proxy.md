# Design-patterns
## 구조적인 패턴(Structural Patterns)

---
### 프록시 (Proxy) 패턴
* 특정 객체에 대한 접근을 제어하거나 기능을 추가할 수 있는 패턴
* 초기화 지연, 접근 제어, 로깅, 캐싱 등 다양하게 응용해 사용 할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/200796601-daf367b0-45b8-4e6c-bbf6-7a86d73fa762.png)


### 다음 코드를 보자

```java
public class Client {

  public static void main(String[] args) throws InterruptedException {
    GameService gameService = new GameService();
    gameService.startGame();
  }
}
```
```java
public class GameService {

  public void startGame() {
    System.out.println("이 자리에 오신 여러분을 진심으로 환영합니다.");
  }
}
```
프록시 패턴을 적용해   
startGame()의 실행시간을 출력해보자.



```java
public class Client {

  public static void main(String[] args) {
    GameService gameService = new GameServiceProxy();
    gameService.startGame();
  }
}
```

```java
public interface GameService {

  void startGame();

}
```

```java
public class DefaultGameService implements GameService {

  @Override
  public void startGame() {
    System.out.println("이 자리에 오신 여러분을 진심으로 환영합니다.");
  }
}

```

```java

public class GameServiceProxy implements GameService {

  private GameService gameService;

  @Override
  public void startGame() {
    long before = System.currentTimeMillis();
    if (this.gameService == null) {
      this.gameService = new DefaultGameService();
    }

    gameService.startGame();
    System.out.println(System.currentTimeMillis() - before);
  }
}

```



___
___

<br/> 

<br/> 

### 프록시 (Proxy) 패턴 장단점
* 장점
    * 기존 코드를 변경하지 않고 새로운 기능을 추가할 수 있다.
    * 기존 코드가 해야 하는 일만 유지할 수 있다.
    * 기능 추가 및 초기화 지연 등으로 다양하게 활용할 수 있다.

* 단점
    * 코드의 복잡도가 증가한다.
 

___
___

<br/> 

<br/> 

### 프록시 (Proxy) 패턴  
실무에서 어떻게 쓰이나?

* 자바
  * 다이나믹 프록시, java.lang.reflect.Proxy

* 스프링
    * Spring AOP 