# Design-patterns
## 객체 생성 관련 디자인 패턴

---
### 팩토리 메소드(Factory method) 패턴 2. 구체적으로 어떤 인스턴스를 만들지는 서브 클래스가 정한다.
####  팩토리 메소드 (Factory method) 패턴
* 다양한 구현체 (Product)가 있고, 그중에서 특정한 구현체를 만들 수 있는 다양한 팩토리(Creator)를 제공할 수 있다.
  ![image](https://user-images.githubusercontent.com/60100532/190903173-7ec46333-296f-41b2-ae55-c505463cb130.png)

다음 샘플 코드를 팩토리 메소드패턴을 활용하여 OCP(Open-Closed Principle) 원칙을 지키도록 바꿔보자.
### Client
```java
public class Client {

  public static void main(String[] args) {
    Ship whiteship = ShipFactory.orderShip("Whiteship", "keesun@mail.com");
    System.out.println(whiteship);

    Ship blackship = ShipFactory.orderShip("Blackship", "keesun@mail.com");
    System.out.println(blackship);
  }

}
```
### Ship
```java
public class Ship {

    private String name;

    private String color;

    private String logo;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
    }

    @Override
    public String toString() {
        return "Ship{" +
                "name='" + name + '\'' +
                ", color='" + color + '\'' +
                ", logo='" + logo + '\'' +
                '}';
    }
}

```

### ShipFactory
```java

public class ShipFactory {

    public static Ship orderShip(String name, String email) {
        // validate
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("배 이름을 지어주세요.");
        }
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("연락처를 남겨주세요.");
        }

        prepareFor(name);

        Ship ship = new Ship();
        ship.setName(name);

        // Customizing for specific name
        if (name.equalsIgnoreCase("whiteship")) {
            ship.setLogo("\uD83D\uDEE5️");
        } else if (name.equalsIgnoreCase("blackship")) {
            ship.setLogo("⚓");
        }

        // coloring
        if (name.equalsIgnoreCase("whiteship")) {
            ship.setColor("whiteship");
        } else if (name.equalsIgnoreCase("blackship")) {
            ship.setColor("black");
        }

        // notify
        sendEmailTo(email, ship);

        return ship;
    }

    private static void prepareFor(String name) {
        System.out.println(name + " 만들 준비 중");
    }

    private static void sendEmailTo(String email, Ship ship) {
        System.out.println(ship.getName() + " 다 만들었습니다.");
    }

}
```

<br />  

위 코드에서 만약 whiteship, blackship 말고 다른 ship을 만들어야 한다면....
```java
   // Customizing for specific name
        if (name.equalsIgnoreCase("whiteship")) {
            ship.setLogo("\uD83D\uDEE5️");
        } else if (name.equalsIgnoreCase("blackship")) {
            ship.setLogo("⚓");
        }

        // coloring
        if (name.equalsIgnoreCase("whiteship")) {
            ship.setColor("whiteship");
        } else if (name.equalsIgnoreCase("blackship")) {
            ship.setColor("black");
        }
```
이곳에 if문으로 로직을 추가해야 할 것이다.   
즉 요구사항이 변경될 때마다 내부 코드가 계속 수정돼야 한다.   
즉 변경에 닫혀있지 않은 것이고 OCP 원칙에 위배 된다.   

___

다음은 팩토리 메소드 패턴으로 변경한 코드를 살펴보자.

### Client
```java

public class Client {

    public static void main(String[] args) {
        Ship whiteship = new WhiteShipFactory().orderShip("Whiteship", "jay@mail.com");
        System.out.println(whiteship);

        Ship blackship = new BlackShipFactory().orderShip("Blackship", "jay@mail.com");
        System.out.println(blackship);
    }

}

```
### Ship
```java

public class Ship {

    private String name;

    private String color;

    private String logo;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
    }

    @Override
    public String toString() {
        return "Ship{" +
                "name='" + name + '\'' +
                ", color='" + color + '\'' +
                ", logo='" + logo + '\'' +
                '}';
    }
}
```

### ShipFactory
```java

public interface ShipFactory {

	default Ship orderShip(String name, String email){
		validate(name, email);
		prepareFor(name);
		Ship ship = createShip();
		sendEmailTo(email, ship);
		return ship;
	}

	private void sendEmailTo(String email, Ship ship) {
		System.out.println(ship.getName() + " 다 만들었습니다.");
	}
	Ship createShip();

	private void validate(String name, String email) {
		if (name == null || name.isBlank()) {
			throw new IllegalArgumentException("배 이름을 지어주세요.");
		}
		if (email == null || email.isBlank()) {
			throw new IllegalArgumentException("연락처를 남겨주세요.");
		}
	}

	private void prepareFor(String name) {
		System.out.println(name + " 만들 준비 중");
	}


}
```
### Whiteship
```java
public class Whiteship extends Ship {

	public Whiteship() {
		setName("whiteship");
		setLogo("\uD83D\uDEE5️");
		setColor("white");
	}
}
```
### WhiteshipFactory
```java
public class WhiteShipFactory implements ShipFactory{

    @Override
    public Ship createShip() {
        return new Whiteship();
    }
}

```

### Blackship
```java
public class Blackship extends Ship {

	public Blackship() {
		setName("blackship");
		setColor("black");
		setLogo("⚓");
	}


}

```
### BlackshipFactory
```java

public class BlackShipFactory implements ShipFactory {

	@Override
	public Ship createShip() {
		return new Blackship();
	}
}

```

ShipFactory와 Ship을 각가 구현, 상속받아 기존의 코드의 변경 없이    
Blackship과 whiteship을 추가했다.   

<br />  

![image](https://user-images.githubusercontent.com/60100532/190911416-16ecb45a-d0bf-48c9-9c10-61cd7755c45d.png)

<br />  

하지만 클라이언트 코드가 변경된 것이 아니냐??  
라는 생각이 들 수도 있다.  


이 부분을 수정해 보자

```java

public class Client {

    public static void main(String[] args) {
//        기존 코드
//      Ship whiteship = ShipFactory.orderShip("Whiteship", "keesun@mail.com");
//      System.out.println(whiteship);
//
//      Ship blackship = ShipFactory.orderShip("Blackship", "keesun@mail.com");
//      System.out.println(blackship);

//          factory method패턴 적용후 
//        Ship whiteship = new WhiteShipFactory().orderShip("Whiteship", "jay@mail.com");
//        System.out.println(whiteship);
//
//        Ship blackship = new BlackShipFactory().orderShip("Blackship", "jay@mail.com");
//        System.out.println(blackship);
      
//       
        Client client = new Client();
        client.print(new WhiteShipFactory(), "whiteship", "jay@mail.com");
        client.print(new BlackShipFactory(), "blackship", "jay@mail.com");
        
        

    }

    // interface ShipFactory로 선언한뒤 . 위에서 어떠한 팩토리를 호출하더라로 client 코드는 변경할 필요 X
    private void print(ShipFactory shipFactory, String name, String email) {
      System.out.println(shipFactory.orderShip(name, email));
    }

}

```

<br />  

여기서 또 한가지 문제가 있다 java 9버전 이상을 사용중이라면 interface안에 private method를 선언할 수 있지만.  
그게 아니라면 중간에 추상클래스를 만들어서 해결할 수 있다.

### ShipFactory
```java

public interface ShipFactory {

	default Ship orderShip(String name, String email){
		validate(name, email);
		prepareFor(name);
		Ship ship = createShip();
		sendEmailTo(email, ship);
		return ship;
	}

	void sendEmailTo(String email, Ship ship) {
		System.out.println(ship.getName() + " 다 만들었습니다.");
	}
	Ship createShip();
   //...
}
```

### DefaultShipFactory
```java
public abstract class DefaultShipFactory implements ShipFactory{
    @Override
    public void sendEmailTo(String email, Ship ship) {
        System.out.println(ship.getName() + " 다 만들었습니다.");
    }
    //...
}
```
### BlackShipFactory
```java
public class BlackShipFactory extends DefaultShipFactory {

	@Override
	public Ship createShip() {
		return new Blackship();
	}
}
```

### WhiteShipFactory
```java
public class WhiteShipFactory extends DefaultShipFactory{

  @Override
  public Ship createShip() {
    return new Whiteship();
  }
}

```

<br />  
ShipFactory 안에 있던 private 메소드를 꺼내   
DefaultShipFactory 추상클래스로 구현해주었다.

![image](https://user-images.githubusercontent.com/60100532/190995622-8993ab9e-1cda-4a6f-afe3-57550717fe1d.png)

___
___

<br/> 

<br/> 

### 팩토리 메소드 패턴 2. 실무에서는 어떻게 쓰이나?

* 단순한 팩토리 패턴
  * 매개변수의 값에 따라 또는 메소드에 따라 각기 다른 인스턴스를 리턴하는 단순한 버전의 팩토리 패턴
  * java.lang.Calendar 또는 java.lang.NumberFormat
* 스프링 BeanFactory
  * Object 타입의 Product를 만드는 BeanFactory라는 Creator!

### 단순한 팩토리 패턴
#### java.lang.Calendar
```java

public class CalendarExample {

    public static void main(String[] args) {
        System.out.println( Calendar.getInstance().getClass());
        System.out.println(Calendar.getInstance(Locale.forLanguageTag("th-TH-x-lvariant-TH")).getClass());
        System.out.println(Calendar.getInstance(Locale.forLanguageTag("ja-JP-x-lvariant-JP")).getClass());
    }
}

//class java.util.GregorianCalendar
//class sun.util.BuddhistCalendar
//class java.util.JapaneseImperialCalendar

```

![image](https://user-images.githubusercontent.com/60100532/191000292-5888bdf1-fa52-4ad4-905e-8aca5d78e2e1.png)
파라미터 값에 따라 각기 다른 인스턴스를 만들어서 리턴해 주는 간단한 형태의 팩토리가 구현되어있음


### 스프링 BeanFactory
* Creator (interface) -> BeanFactory
* ConcreteCreator -> ClassPathXmlApplicationContext , AnnotationConfigApplicationContext etc
* Product -> Object (Bean)
* ConcreteProduct -> Bean들
___
___

<br/> 

<br/> 

### 위에서 알아본 내용들을 복습해 보자!!!!!

> 팩토리 메소드 (Factory Method) 패턴 복습
>구체적으로 어떤 것을 만들지는 서브 클래스가 정한다.!!!
> 
> * 팩토리 메소드 패턴을 적용했을 때의 장점은? 단점은?
> * "확장에 열려있고 변경에 닫혀있는 객체 지향 원칙"을 설명하세요
> * 자바 8에 추가된 default 메소드에 대해 설명하세요

___
___ 
 
> * 팩토리 메소드 패턴을 적용했을 때의 장점
>   * 확장에 열려있고 변경에 닫혀있는 (OCP) 객체 지향 원칙을 지키면서 기존 코드 기존의 인스턴스를 만드는 과정이 담겨있는 로직을 건드리지 않고 앞과 비슷한 새로운 인스턴스를 다른 방법으로 만드는 것이 얼마든지 확장이 가능하다.
>   * 이게 가능한 이유는 creater와 product 간의 커플링을 느슨하게 가져갔기 때문이다. (느슨한 결합 )
> * 팩토리 메소드 패턴을 적용했을 때의 단점
>   * 팩토리 메소드 패턴을 적용하면 각자의 역할을 나누다 보니 클래스가 늘어나는 점은 피할 수 없다.
> * "확장에 열려있고 변경에 닫혀있는 객체 지향 원칙"을 설명하세요.
>   * 변경에 닫혀있다는 것은 기존코드를 변경하지 않는다는 말이다. 
>   * 즉 기존 코드를 변경하지 않으면서 새로운 기능을 얼마든지 확장할 수 있게끔 구조를 만드는 객체지향 원칙. 
> * 자바 8에 추가된 default 메소드에 대해 설명하세요
>   * 자바 8에 들어간 interface 기본적인 구현체를 만들 수 있는 기능
>   * 자바 8이전에는 위와 같은 기능이 없었다. 인터페이스에는 항상 추상 메소드만 정의할 수 있었다.
>   * 그 인터페이스를 구현하는 클래스에서 그 메소드를 구현하거나 아니면 그 인터페이스를 구현하는 클래스가 추상 클래스로 만들어 져야 했다.
