# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 4. 인스턴스화를 막으려거든 private 생성자를 사용하라

### 핵심정리
* 정적 메서드만 담은 유틸리티 클래스는 인스턴스로 만들어 쓰려고 설계한 클래스가 아니다.
* 추상 클래스로 만드는 것으로는 인스턴스화를 막을 수 없다.
* private 생성자를 추가하면 클래스의 인스턴스화를 막을 수 있다.
* 생성자에 주석으로 인스턴스화 불가한 이유를 설명한느 것이 좋다.
* 상속을 방지할 때도 같은 방법을 사용할 수 있다.

### Sample Code
```java
public class UtilityClass {
 
  public static String hello() {
    return "hello";
  }

  public static void main(String[] args) {
    String hello = UtilityClass.hello();

    UtilityClass utilityClass = new UtilityClass();
    utilityClass.hello();
  }
}
```
* 위 코드에서 UtilityClass에 static 메소드만 선언되어있지만 
* 해당 클래스의 인스턴스를 만들어서 hello()를 접근하고 있다.
* 문법적으로 문제는 없지만 굉장히 불필요한 코드이다. 
* 인스턴스를 만들 필요가 없음에도 인스턴스를 만들었고
* hello라는 메소드가 인스턴스 메소드인지 static 메소드인지 헷갈리게 만든다.

```java

public class UtilityClass {

    /**
     * 이 클래스는 인스턴스를 만들 수 없습니다.
     */
    private UtilityClass() {
        throw new AssertionError();
    }

    public static String hello() {
        return "hello";
    }

    public static void main(String[] args) {
        String hello = UtilityClass.hello();

        UtilityClass utilityClass = new UtilityClass();
        utilityClass.hello();
    }
}
```
* 위 코드와 같이 private 생성자를 추가하고 생성자 내부에서 AssertionError를 발생시키면
* 생성자가 호출될때 예외가 발생하고 인스턴스화를 막을 수 있다.
* AssertionError는 AssertionError를 상속받는 RuntimeException이다.
 