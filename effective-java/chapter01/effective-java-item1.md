# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 1. 생성자 대신 정적 팩토리 메서드를 고려하라
* 핵심정리
  * 장점
    * 이름을 가질 수 있다(동일한 시그니처의 생성자를 두개 가질 수 없다.)
    * 호출될 때마다 인스턴스를 새로 생성하지 않아도 된다.(Boolean.valueOf)
    * 반환 타입의 하위 타입 객체를 반환할 수 있는 능력이 있다(인터페이스 기반 프레임워크, 인터페이스에서 정적 메소드)
    * 입력 매개변수에 따라 매번 다른 클래스의 객체를 반환할 수 있다.(EnumSet)
    * 정적 팩토리 메서드를 작성하는 시점에는 반환할 객체의 클래스가 존재하지 않아도 된다.(서비스 제공자 프레임워크)
  * 단점
    * 상송을 하려면 public이나 protected 생성하기 


### 정적 팩토리 메서드의 첫번째 장점!!! 
#### - 이름을 가질 수 있다
* 한 클래스에 시그니처가 같은 생성자가 여러 개 필요할 것 같으면, 생성자를 정적 팩터리 메서드로 바꾸고  
  각각의 차이를 잘 드러내는 이름을 지어주자!!!

### Sample Code
```java
public class Order {

	private boolean prime;

	private boolean urgent;

	private Product product;

  public Order(Product product, boolean prime) {
    this.prime = prime;
    this.product = product;
  }
}
```

* 위 코드에서 prime대신 urgent를 받는 생성자를 추가로 선언하면 컴파일 에러가 발생한다.
  * 생성자의 시그니처는 받는 파라미터 타입까지 본다.   
  완전하게 동일한 시그니처의 생성자는 같이 있을 수 없다
  
```java
public class Order {
  ...
  
  public Order(Product product, boolean prime) {
    this.prime = prime;
    this.product = product;
  }

  public Order(Product product, boolean urgent) {
    this.urgent = urgent;
    this.product = product;
  }
}
```

* 이 문제를 해결하기 위해 정적 팩토리 메소드를 활용하자!!!!
* primeOrder와 urgentOrder 처럼 (만들어지는 객체의 특징을)메소드 명으로 의도를 명확하게 나타낼 수 있다.

```java

public class Order {
  ...
  public static Order primeOrder(Product product) {
    Order order = new Order();
    order.prime = true;
    order.product = product;
    return order;
  }
  
  public static Order urgentOrder(Product product) {
    Order order = new Order();
    order.urgent = true;
    order.product = product;
    return order;
  }
}

```

### 정적 팩토리 메서드의 두번째 장점!!! 
#### - 호출될 때마다 인스턴스를 새로 생성하지 않아도 된다.
* 인스턴스의 생성을 통제할 수 있다!

```java
public class Settings {
  private boolean useAutoSteering;
  private boolean useABS;
  private Difficulty difficulty;

  public static void main(String[] args) {
    System.out.println(new Settings());
    System.out.println(new Settings());
    System.out.println(new Settings());
  }
}
```
* 위 처럼 생성자를 사용하면 매번 새로운 인스턴스가 생성된다  

![image](https://user-images.githubusercontent.com/60100532/208928268-d06ea596-1b77-4700-9369-c2c74c68a4aa.png)
* 하지만 우리는 가끔 인스턴스를 매번 새로 만들지   
  아니면 특정 경우에만 생성할지 등등   
  인스턴스를 생성하는 방법을 통제할 필요가 생길 때가 있다.
* 생성자가 있다면 통제가 불가능하다!  
  (어디서든 생성자를 호출해서 새로운 인스턴스를 만들 수 있다.)

* 만약에 우리가 위의 Settings라는 인스턴스를 오직 1개만 만들어서 사용해야 한다면
* 그때 정적 팩토리 메소드를 통해서 통제할 수 있다.  


```java
public class Settings {
  private boolean useAutoSteering;
  private boolean useABS;
  private Difficulty difficulty;
  
  private Settings() {
  }

  private static final Settings SETTINGS = new Settings();
  
  public static Settings newInstance() {
    return SETTINGS;
  }
}
```
1. 기본 생성자를 private으로 선언해 외부에서 아무도 호출하지 못하게 한다.
2. 미리 Settings를 만들어 놓고
3. newInstance()라는 메소드로 정적 팩토리 메소드를 선언해 미리 생성해놓은 Settings를 return한다. 
> 이렇게 하면 외부에서 Settings인스턴스를 가져갈 수 있는 방법이 오로지 newInstance라는 정적 팩토리 메소드를 통해서만 가져갈 수 있다.
> 

* example : Boolean.valueOf(false);   
  
![image](https://user-images.githubusercontent.com/60100532/208933098-071050e9-ba2a-4af8-835f-bb14306f131d.png)

* 디자인 패턴 
* 플라이웨이트 (flyweight) 패턴
* 자주 변하는 속성(또는 외적인 속성, extrinsit)과 변하지 않는 속성(또는 내적인 속성, intrinsit)을 분리하고 `케싱` 재사용하여 메모리 사용을 줄일 수 있다.

![image](https://user-images.githubusercontent.com/60100532/200568408-76c19d4e-f254-4371-ba40-a16b7c2d6d7a.png)
* 케싱 개념 미리 가지고있다가 필요할때 꺼내 준다 -> 정적 팩토리 메소드 패턴과 유사.


### 정적 팩토리 메서드의 세,네 번째 장점!!! 
#### - 반환 타입의 하위 타입 객체를 반환할 수 있는 능력이 있다. 
#### - 입력 매개변수에 따라 매번 다른 클래스의 객체를 반환할 수 있다.
* 인터페이스를 사용할 수 있다.
* 정적 팩토리 메소드 리턴 타입에는 인터페이스를 선언하고 실제 리턴해주는 인스턴스는 인터페이스의 구현체로 바꿔 리턴하거나 
* 클래스를 리턴 타입으로 선언해 그 클래스의 하위 클래스를 리턴해 줄 수 있어 굉장한 유연함이 생긴다.  
  
  
* 기존에 생성자(생성자는 해당하는 클래스의 인스턴스만 만들어 준다.)를 사용할때는   
  KoreanHelloService나 EnglishHelloService의 선언한 생성자가 return해 주는 인스턴스만! 가져올 수 있었지만.
* 정적 팩토리 메소드를 사용하게 된다면   
  정적 팩토리 메소드의 반환타입에 호환 가능한 다른 타입으로 return해 줄 수 있다.       
  

<br />    

#### 아래 코드를 보자.
* HelloServiceFactory의 of 라는 정적 팩토리 메소드에서   
HelloService 인터페이스를 return하도록 선언했지만 
* 전달 받은 변수에 따라서 그 구현체인 KoreanHelloService의 인스턴스나 
* EnglishHelloService의 인스턴스로 return해 줄 수 있다. 

```java
public class HelloServiceFactory{
  public static HelloService of(String lang) {
    if (lang.equals("ko")) {
      return new KoreanHelloService();
    } else {
      return new EnglishHelloService();
    }
  }
}
public interface HelloService {

  String hello();
}

public class KoreanHelloService implements HelloService {
	
	@Override
    public String hello() {
      return 안녕하세요;
    }
}
public class EnglishHelloService implements HelloService {
	
	@Override
    public String hello() {
      return "hello";
    }
}


```
* 정적 팩토리 메소드를 사용하면  
  아래 코드처럼 구체적인 타입을 클라이언트로부터 숨길 수 있다.
```java
public static void main(String[]args){
    HelloService ko = HelloServiceFactory.of("ko");        
}
```

* 자바 8버전 부터는 HelloServiceFactory의 of와 같은 스태틱 메소드를 인터페이스에 선언할 수 있어 불필요한 Factory클래스의 선언을 줄일 수 있다..


### 정적 팩토리 메서드의 다섯 번째 장점!!!
#### - 정적 팩토리 메소드를 작성하는 시점에는 반환할 객체의 클래스가 존재하지 않아도 된다.
* 서비스 제공자 프레임워크(service provider framework)를 만드는 근간이 됨

* 현재 HelloService에 대한 구현체가 없는 상황

```java
import java.util.Optional;
import java.util.ServiceLoader;

public interface HelloService {
  String hello();
}

public class HelloServiceFactory {
  public static void main(String[] args) {
    ServiceLoader<HelloService> load = ServiceLoader.load(HelloService.class);// ServiceLoad java가 기본으로 제공하는 정적 팩토리 메소드
    Optional<HelloService> helloService = load.findFirst();
    helloService.ifPresent(h -> System.out.println(h.hello()));
  }
}
```

  
___
___



### 정적 팩토리 메서드의 첫번째 단점!!!
#### - 상속을 하려면 public이나 protected 생성자가 필요하니 정적 팩터리 메서드만 제공하면 하위 클래스를 만들 수 없다.
* 정적 팩토리 메서드만을 사용하게 만든 클래스가 있다면 그렇게 하기 위해 생성자를 `private`으로 선언해야 한다.
* 이말은 즉 해당 클래스는 상속을 허용하지 않는다.
* 하지만 이는 컴포지션(delegate)을 사용하도록 유도해 굳이 상속없이 해당클래스의 내부 기능들을 사용할 수 있다
* 이점에서 오리혀 장점으로 받아들일 수도 있다.

```java
public class Settings {
  private boolean useAutoSteering;
  private boolean useABS;
  private Difficulty difficulty;
  
  private Settings() {
  }

  private static final Settings SETTINGS = new Settings();
  
  public static Settings newInstance() {
    return SETTINGS;
  }
}

public class AdvancedSettings {
  Settings settings;
}
```
 
* 정적 팩토리 메서드를 제공한다고 해서 꼭 생성자를 `private`으로 만들 필요는 없다.
* `new ArrayList<>()`, `List.of()`


### 정적 팩토리 메서드의 두번째 단점!!!
#### - 정적 팩토리 메소드는 프로그래머가 찾기 어렵다.
* 자바독에 메소드는 생성자처럼 API설명에 명확히 드러나지 않는다. 
* 해당 클래스에 선언된 메소드가 많다면, 정적 팩토리 메소드를 찾기는 더욱 어려워진다.
* 이단점을 완화 하기 위해 API문서를 잘 작성하고, 정적 팩토리 메소드 이름도 널리 알려진 규약을 따라 짓는다.


```java
/**
 * 이 클래스의 인스턴스는 #getInstance()를 통해 사용한다.
 * @see #getInstance()
 */
public class Settings {
  ...
  private Settings() {
  }

  private static final Settings SETTINGS = new Settings();
  
  public static Settings getInstance() {
    return SETTINGS;
  }
}
```
  
---  
---  

> 핵심 정리
> * 정적 팩토리 메소드와 public 생성자는 각자의 쓰임새가 있으니 상대적인 장단점을 이해하고 사용하는 것이 좋다.    
>   그렇다고 하더라도 정적 팩토리를 사용하는 게 유리한 경우가 더 많으므로 무작정 public 생성자를 제공하던 습관이 있다면 고치자.