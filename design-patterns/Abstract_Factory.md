# Design-patterns
## 객체 생성 관련 디자인 패턴

---
### 추상 팩토리(Abstract Factory) 패턴 3. 서로 관련있는 여러 객체를 만들어주는 인터페이스.
#### 추상 팩토리(Abstract Factory) 패턴
* 구체적으로 어떤 클래스의 인스턴스를(concrete product)를 사용하는지 감출 수 있다.

![image](https://user-images.githubusercontent.com/60100532/191276398-ec597b7b-a710-43f0-9747-feea311daa86.png)

 여러 관련있는 인스턴스를 만들어주는 팩토리를 추상화된 형태(interface, abstract)로 정의하는 패턴  
 구체적인 팩토리에서 구체적인 인스턴스를 만드는것은 팩토리메소드패턴과 굉장히 비슷하지만  
 초점이 (팩토리를 사용하는) 클라이언트 쪽에 있다. 
 
> ###  목적  
> 클라이언트(팩토리에서 인스턴스를 만들어서 쓰는) 코드를 인터페이스 기반으로 코딩을 할 수 있게끔 도와주는 패턴


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
	void sendEmailTo(String email, Ship ship);
}

```
### DefaultShipFactory
```java

public abstract class DefaultShipFactory implements ShipFactory{
    @Override
    public void sendEmailTo(String email, Ship ship) {
        System.out.println(ship.getName() + " 다 만들었습니다.");
    }
}

```
### WhiteshipFactory
```java

public class WhiteshipFactory extends DefaultShipFactory {

    @Override
    public Ship createShip() {
        Ship ship = new Whiteship();
        ship.setAnchor(new WhiteAnchor());
        ship.setWheel(new WhiteWheel());
        return ship;
    }
}
```
WhiteshipFactory 코드를 보면 직접 구체적인 클래스 타입을 생성해서 전달해주고 있다. (new WhiteAnchor, new WhiteWheel)
이떄 문제는 만약 미래에 WhiteWheel이 아닌 BlackWheel이 필요하다면..... 코드를 수정해야한다.  

이제 코드를 변경하지 않고 그때그때 필요한 클래스타입을 전달하는 방법을 알아보자.

WhiteshipFactory <- 클라이언트 코드에 해당함.

먼저 비슷한류의 제품들을 만들어주는 인터페이스를 정의한다.  
예제에선 Anchor들과 , Wheel들이 될 것이다. 

ShipPartsFactory라는 추상 팩토리를 정의하자.
```java
public interface ShipPartsFactory {
    Anchor createAnchor();
    Wheel createWheel();
}
```
```java
public interface Wheel {
}
```
```java
public interface Anchor {
}
```

이제 추상 팩토리의 구체적인 팩토리를 만들어 보자.

```java
public class WhiteshipPartsFactory implements ShipPartsFactory {

    @Override
    public Anchor createAnchor() {
        return new WhiteAnchor();
    }

    @Override
    public Wheel createWheel() {
        return new WhiteWheel();
    }
}
```
WhiteAnchor와 WhiteWheel은 각각 Anchor와 Wheel의 특징을 가지고 있을 테니   
Anchor를 Implements함으로서.
각각 Anchor와 Wheel Interface, 규약을 따른다고 명시해 준다. 
```java
public class WhiteAnchor implements Anchor {
}
```
```java
public class WhiteWheel implements Wheel {
}

```

이제 클라이언트 코드에서 팩토리를 만들었으니 사용해보자.

```java
public class WhiteshipFactory extends DefaultShipFactory {

    private ShipPartsFactory shipPartsFactory;

    public WhiteshipFactory(ShipPartsFactory shipPartsFactory) {
        this.shipPartsFactory = shipPartsFactory;
    }

    @Override
    public Ship createShip() {
        Ship ship = new Whiteship();
        ship.setAnchor(shipPartsFactory.createAnchor());
        ship.setWheel(shipPartsFactory.createWheel());
        return ship;
    }
}
```
WhiteshipFactory 생성자에 필요한 제품군(Anchor와 Wheel의 묶음)을 만들어주는 팩토리를 넣어주면 클라이언트 코드 변경 없이  
원하는 Ship을 생성할 수 있게 되었다.

WhiteAnchorPro, WhiteWheelPro를 추가해보자.
```java
public class WhiteAnchorPro implements Anchor {
}
```

```java
public class WhiteWheelPro implements Wheel{
}
```

```java
public class WhitePartsProFactory implements ShipPartsFactory {
	@Override
	public Anchor createAnchor() {
		return new WhiteAnchorPro();
	}

	@Override
	public Wheel createWheel() {
		return new WhiteWheelPro();
	}
}
```

결과 확인  
![image](https://user-images.githubusercontent.com/60100532/191292252-2bb10eb8-c559-4fd8-a39d-870848756fd1.png)

WhiteshipFactory의 내부 코드 변경 없이  
그때그때 필요한 Factory를 생성자에 전달해 원하는 값을 얻을 수 있게 되었다.


<br/> 

<br/> 

___
___ 

* ### 추상 팩토리 패턴을 적용했을 때의 장점
* 먼저 팩토리 매소드 패턴을 다시 살펴보자
* 추상 팩토리 패턴, 팩토리 메소드 패턴은 둘 다 인스턴스(객체)를 만드는 것을 추상화한 것은 맞다.
* 하지만 보는 관점이 구체적인 인스턴스(concrete class) 인스턴스를 만드는 과정을 concrete factory로 숨기고 그 위에 추상화되어있는 factory를 제공하는 것이 팩토리 매소드 패턴이고
* 거의 같은 모양이지만 추상 팩토리 패턴은 클라이언트(사용하는) 관점에서 본다
* 팩토리를 통해서 추상화된 인터페이스만 클라이언트가 쓸 수 있게끔 해준다. 
* 클라이언트 입장에서 concrete class를 직접 참조해서 쓸 필요가 없어진다.

> * 정리하면 
> * 추상팩토리, 팩토리 메소드 두 패턴 모두 모양과 효과는 비슷하지만.
>   * 둘 다 구체적인 객체 생성과정을 추상화한 인터페이스 제공
> * 관점이 다르다.
>   * 팩토리 메소드 패턴은 "팩토리를 구현하는 방법 (inheritance)"에 초점을 둔다.
>   * 추상 팩토리 패턴은 "팩토리를 사용하는 방법 (composition)"에 초점을 둔다.
> * 목적이 조금 다르다.
>   * 팩토리 메소드 패턴은 구체적인 객체 생성 과정을 하위 또는 구체적인 클래스로 옮기는 것이 목적
>   * 추상 팩토리 패턴은 관련있는 여러 객체를 구체적인 클래스에 의존하지 않고 만들 수 있게 해주는 것이 목적.



___

<br/> 

<br/> 

### 추상 팩토리 패턴 3. 실무에서는 어떻게 쓰이나?

* 자바 라이브러리
 * javax.xml.xpath.XPathFactory#newInstance()
 * javax.xml.transform.TransformerFactory#newInstance()
 * javax.xml.parsers.DocumentBuilderFactory#newInstance()
* 스프링
  * FactoryBean과 그 구현체



#### javax.xml.xpath.XPathFactory#newInstance
```java
public class DocumentBuilderFactoryExample {

 public static void main(String[] args) throws ParserConfigurationException, IOException, SAXException {
  DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();// 팩토리로부터  newInstance를 사용해 factory를 만든 다음
  DocumentBuilder builder = factory.newDocumentBuilder(); // 그 팩토리에서 제공하는 메소드를 통해서 추상적인 타입의 인스턴스를 가져온다.
  Document document = builder.parse(new File("src/main/resources/config.xml"));
  System.out.println(document.getDocumentElement());
 }
}
```

![image](https://user-images.githubusercontent.com/60100532/191378805-5cbf8381-64d1-48b7-b34d-6e7d9af84298.png)

#### FactoryBean과 그 구현체
```java
public class ShipFactory implements FactoryBean<Ship> {

    @Override
    public Ship getObject() throws Exception {
        Ship ship = new Whiteship();
        ship.setName("whiteship");
        return ship;
    }

    @Override
    public Class<?> getObjectType() {
        return Ship.class;
    }
}
```

![image](https://user-images.githubusercontent.com/60100532/191379417-faf58e28-72c0-4246-a50b-7d956ad5a0ec.png)


```java
@Configuration
public class FactoryBeanConfig {

    @Bean
    public ShipFactory shipFactory() {
        return new ShipFactory();
    }
}

```

```java
public class FactoryBeanExample {

    public static void main(String[] args) {

        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(FactoryBeanConfig.class);
        Ship bean = applicationContext.getBean(Ship.class);
        System.out.println(bean);

        ApplicationContext applicationContext1 = new AnnotationConfigApplicationContext(FactoryBeanConfig.class);
        ShipFactory bean1 = applicationContext1.getBean(ShipFactory.class);
        System.out.println(bean1);
    }

    /**
     * 08:05:00.187 [main] DEBUG org.springframework.beans.factory.support.DefaultListableBeanFactory - Creating shared instance of singleton bean 'shipFactory'
     Ship{name='whiteship', color='white', logo='🛥️'}
     ...
     org.designpatterns._01_creational_patterns._03_abstract_factory._03_java.ShipFactory@747f281
     */
}
```
