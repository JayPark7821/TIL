# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 22. 인터페이스는 타입을 정의하는 용도로만 사용하라.

### 핵심정리
* 상수를 정의하는 용도로 인터페이스를 사용하지 말 것!
  * 클래스 내부에서 사용할 상수는 내부 구현에 해당한다.
  * 내부 구현을 클래스의 API로 노출하는 행위는 좋지 않다.
  * 클라이언트에 혼란을 준다.
* 상수를 정의하는 방법
  * 특정 클래스나 인터페이스
  * 열거형
  * 인스턴스화 할 수 없는 유틸리티 클래스



* 인터페이스의 원래 의도는 타입을 정의하는 것이다.
* 하지만 상수를 정의하기 위해 인터페이스를 사용하는 것은 인터페이스의 원래 의도를 오염시킨다.

* 여러 클래스에서 사용해야하는 상수를 정의하는 한가지 예
```java
public final class PhysicalConstants {
  private PhysicalConstants() { }  // 인스턴스화 방지
  
  public static final double AVOGADROS_NUMBER = 6.022_140_857e23;
  
  public static final double BOLTZMANN_CONST  = 1.380_648_52e-23;

  public static final double ELECTRON_MASS    = 9.109_383_56e-31;
}


```