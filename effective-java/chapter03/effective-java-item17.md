# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 17. 변경 가능성을 최소화 하라.

### 핵심정리 - 불변 클래스
* 불변 클래스는 가변 클래스보다 설계하고 구현하고 사용하기 쉬우며, 오류가 생길 여지도 적고 훨씬 안전하다.
* 불변 클래스를 만드는 다섯 가지 규칙
  * 객체의 상태를 변경하는 메서드를 제공하지 않는다.
  * 클래스를 확장할 수 없도록 한다.  - final class
  * 모든 필드를 final로 선언한다.
  * 모든 필드를 private으로 선언한다.
  * 자신 외에는 내부의 가변 컴포넌트에 접근할 수 없도록 한다.


```java
public final class Person {

    private final Address address;

    public Person(Address address) {
        this.address = address;
    }

    public Address getAddress() {
        Address copyOfAddress = new Address();
        copyOfAddress.setStreet(address.getStreet());
        copyOfAddress.setZipCode(address.getZipCode());
        copyOfAddress.setCity(address.getCity());
        return copyOfAddress;
    }

    public static void main(String[] args) {
        Address seattle = new Address();
        seattle.setCity("Seattle");

        Person person = new Person(seattle);

        Address redmond = person.getAddress();
        redmond.setCity("Redmond");

        System.out.println(person.address.getCity());
    }
}

```
```java

public class Address {

    private String zipCode;

    private String street;

    private String city;

    public String getZipCode() {
        return zipCode;
    }

    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }
}

```

### 방어적으로 복사를 활용해 불변 클래스 만들어준다. 
```java
public final class Person {
  ...
  public Address getAddress() {
    Address copyOfAddress = new Address();
    copyOfAddress.setStreet(address.getStreet());
    copyOfAddress.setZipCode(address.getZipCode());
    copyOfAddress.setCity(address.getCity());
    return copyOfAddress;
  }
}
```
### 만약에 그냥 address를 넘겨주면
```java
public final class Person {
  ...
  public Address getAddress() {
    return address;
  }
}
```
* address.set000등의 세터로 Person의 정보가 바뀔수 있다.


### 핵심정리 - 불변 클래스의 장점과 단점
* 장점 
  * 함수형 프로그래밍에 적합하다 ( 피연산자에 함수를 적용한 결과를 반환하지만 피연산자가 바뀌지는 않는다.) 
  * 불변 객체는 단순하다.
  * 불변 객체는 근본적으로 스레드 안전하여 따로 동기화할 필요 없다.
  * 불변 객체는 안심하고 공유할 수 있다. ( 상수, public static final)
  * 불변 객체 끼리는 내부 데이터를 공유할 수 있다.
  * 객체를 만들 때 불변 객체로 구현하면 이점이 많다.
  * 실패 원자성을 제공한다.
* 단점 
  * 값이 다르다면 반드시 별도의 객체로 만들어야 한다.
  * "다단계 연산"을 제공하거나. "가변 동반 클래스"를 제공하여 대처할 수 있다.


### 불변 객체 끼리는 내부 데이터를 공유할 수 있다.
![image](https://user-images.githubusercontent.com/60100532/212084591-ffdaff14-c174-4499-906a-be9d7c017a97.png)
```java
public class BigIntExample {

  public static void main(String[] args) {
    BigInteger ten = BigInteger.TEN;
    BigInteger minusTen = ten.negate();
  }
}
```
###  "가변 동반 클래스"를 제공하여 대처할 수 있다.
```java
public class StringExample {

    public static void main(String[] args) {
        String name = "whiteship";

        StringBuilder nameBuilder = new StringBuilder(name);
        nameBuilder.append("keesun");
    }
}

```

### 핵심정리 - 불변 클래스를 만들 때 고려할 점
* 상속을 막을 수 있는 또 다른 방법
  * private 또는 package-private 생성자 + 정적 팩터리
  * 확장이 가능하다. 다수의 package-private 구현 클래스를 만들 수 있다.
  * 정적 팩터리를 통해 여러 구현 클래스중 하나를 활용할 수 있는 유연성을 제공하고 객체 캐싱 기능으로 성능을 향상 시킬 수도 있다.
* 재정의가 가능한 클래스는 방어적인 복사를 사용해야 한다.
* 모든 “외부에 공개하는” 필드가 final이어야 한다.
  * 계산 비용이 큰 값은 해당 값이 필요로 할 때 (나중에) 계산하여 final이 아닌 필드에 캐시해서 쓸 수도 있다


### 새로 생성된 불변 인스턴스를 동기화 없이 다른 스레드로 건네도 문제없이 동작
* final을 사용하면 안전하게 초기화 할 수 있다.
* JMM
  * 자바 메모리 모델은 JVM의 메모리 구조가 아니다.
  * 적법한 (legal) 프로그램의 실행 규칙
  * 메모리 모델이 허용하는 범위내에서 프로그램을 어떻게 실행하든 규현체(JVM)의 자유다. (이 과정에서 실행 순서가 바뀔 수도 있다.)
* 어떤 인스턴스의 final 변수를 초기화 하기 전까지 해당 인스턴스를 참조하는 모든 쓰레드는 기다려야 한다.(Freeze)

### java.util.concurrent 패키지
* 병행(Concurrency)프로그래밍에 유용하게 사용할 수 있는 유틸리티 묶음
  * 병행(Concurrency)과 병렬(Parellel) 프로그래밍의 차이
    * 병행은 여러 작업을 번갈아 가며 실행해 마치 동시에 여러 작업을 처리하듯 보이지만. 실제로는 한번에 오직 한 작업만 실행한다.
      ![image](https://user-images.githubusercontent.com/60100532/212477551-5b5c4087-03bc-4b73-867c-f4fb56c143f4.png)
    * 병렬은 여러 작업을 동시에 처리한다. CPU가 여러개 있어야 가능하다.
    * 자바의 concurrent 패키지는 병행 애플리케이션에 유용한 다양한 툴을 제공한다.
    * BlockingQueue, Callable, ConcurrrentMap, Executor, ExecutorService, Future,

### CountDownLatch 클래스
* 초기화 할 때 숫자를 입력하고, await() 메서드를 사용해서 숫자가 0이 될때까지 기다린다.
* 숫자를 셀 때는 countDown() 메서드를 사용한다.
* 재사용할 수 있는 인스턴스가 아니다. 숫자를 리셋해서 재사용하려면 CyclicBarrier를 사용해야 한다.
* 시작 또는 종료 신호로 사용할 수 있다.