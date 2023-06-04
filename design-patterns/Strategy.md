# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 전략 (Strategy) 패턴
* 여러 알고리듬을 캡슐화하고 상호 교환 가능하게 만드는 패턴
* 컨텍스트에서 사용할 알고리듬을 클라이언트가 선택한다.

![image](https://user-images.githubusercontent.com/60100532/205215973-69f7e353-7449-4e2f-b04c-b5cfa72ebe09.png)

### 코드로 전략 패턴을 알아보자.
 
### Client code

```java

public class Client {

  public static void main(String[] args) {
    BlueLightRedLight blueLightRedLight = new BlueLightRedLight(3);
    blueLightRedLight.blueLight();
    blueLightRedLight.redLight();
  }
}

```

### BlueLightRedLight
```java

public class BlueLightRedLight {

  private int speed;

  public BlueLightRedLight(int speed) {
    this.speed = speed;
  }

  public void blueLight() {
    if (speed == 1) {
      System.out.println("무 궁 화    꽃   이");
    } else if (speed == 2) {
      System.out.println("무궁화꽃이");
    } else {
      System.out.println("무광꼬치");
    }

  }

  public void redLight() {
    if (speed == 1) {
      System.out.println("피 었 습 니  다.");
    } else if (speed == 2) {
      System.out.println("피었습니다.");
    } else {
      System.out.println("피어씀다");
    }
  }
}


```
 
### 전략 패턴을 적용.
#### Client
```java
public class Client {

  public static void main(String[] args) {
    BlueLightRedLight game = new BlueLightRedLight();
    game.blueLight(new Normal());
    game.redLight(new Fastest());
    game.blueLight(new Speed() {
      @Override
      public void blueLight() {
        System.out.println("blue light");
      }

      @Override
      public void redLight() {
        System.out.println("red light");
      }
    });
  }
}


``` 

#### BlueLightRedLight
```java
public class BlueLightRedLight {

  public void blueLight(Speed speed) {
    speed.blueLight();
  }

  public void redLight(Speed speed) {
    speed.redLight();
  }
}


```

#### Speed
```java
public interface Speed {

  void blueLight();

  void redLight();

}
```

#### Normal
```java

public class Normal implements Speed {
  @Override
  public void blueLight() {
    System.out.println("무 궁 화    꽃   이");
  }

  @Override
  public void redLight() {
    System.out.println("피 었 습 니  다.");
  }
}


```
#### Faster
```java
public class Faster implements Speed {
  @Override
  public void blueLight() {
    System.out.println("무궁화꽃이");
  }

  @Override
  public void redLight() {
    System.out.println("피었습니다.");
  }
}


```


#### Fastest
```java

public class Fastest implements Speed{
  @Override
  public void blueLight() {
    System.out.println("무광꼬치");
  }

  @Override
  public void redLight() {
    System.out.println("피어씀다.");
  }
}

```
 

---
![image](https://user-images.githubusercontent.com/60100532/205217644-101598df-4405-48ef-b1be-c7ba235cd7e0.png)
___
___

<br/> 

<br/> 

### 상태 (State) 패턴 장단점
* 장점
    * 새로운 전략을 추가하더라도 기존 코드를 변경하지 않는다.
    * 상속 대신 위임을 사용할 수 있다.
    * 런타임에 전략을 변경할 수 있다.
* 단점
    * 복잡도가 증가한다.
    * 클라이언트 코드가 구체적인 전략을 알아야 한다.


___
___

<br/> 

<br/> 

### 전략 (Strategy) 패턴
실무에서 어떻게 쓰이나?

* 자바
  * Comparator
* 스프링
  * ApplicationContext
  * PlatformTransactionManager
  

 