# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 방문자 (Visitor) 패턴
* 기존 코드를 변경하지 않고 새로운 기능을 추가하는 방법
* 더블 디스패치(Double Dispatch)를 활용할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/205222656-6b2baea6-a70c-4d2b-ae0d-d20fde93a425.png)

### 코드로 방문자 패턴을 알아보자.
 
### Client code

```java

public class Client {

  public static void main(String[] args) {
    Shape rectangle = new Rectangle();
    Device device = new Phone();
    rectangle.printTo(device);
  }
}


```

### Shape
```java

public interface Shape {

  void printTo(Device device);

}
```
 
### Rectangle
```java
public class Rectangle implements Shape {

    @Override
    public void printTo(Device device) {
        if (device instanceof Phone) {
            System.out.println("print Rectangle to phone");
        } else if (device instanceof Watch) {
            System.out.println("print Rectangle to watch");
        }
    }
}

```
### Triangle
```java

public class Triangle implements Shape {

  @Override
  public void printTo(Device device) {
    if (device instanceof Phone) {
      System.out.println("print Triangle to Phone");
    } else if (device instanceof Watch) {
      System.out.println("print Triangle to Watch");
    }
  }

}
```

### Device
```java
public interface Device {
}

```

### Phone
```java
public class Phone implements Device{
}

```

### Watch
```java
public class Watch implements Device{
}

```



### 방문자 패턴을 적용.

### Client code

```java
public class Client {

  public static void main(String[] args) {
    Shape rectangle = new Rectangle();
    Device device = new Pad();
    rectangle.accept(device);
  }
}



```

### Shape
```java

public interface Shape {

  void accept(Device device);

}

```

### Rectangle
```java

public class Rectangle implements Shape {


  @Override
  public void accept(Device device) {
    device.print(this);
  }
}


```
### Triangle
```java
public class Triangle implements Shape {


  @Override
  public void accept(Device device) {
    device.print(this);
  }
}

```

### Device
```java

public interface Device {

  void print(Rectangle rectangle);

  void print(Triangle triangle);
 
}

```

### Phone
```java

public class Phone implements Device {

  @Override
  public void print(Rectangle rectangle) {
    System.out.println("Print Rectangle to Phone");

  }

  @Override
  public void print(Triangle triangle) {
    System.out.println("Print Triangle to Phone");
  }
}


```

### Watch
```java
public class Watch implements Device {
	
  @Override
  public void print(Rectangle rectangle) {
    System.out.println("Print Rectangle to Watch");
  }

  @Override
  public void print(Triangle triangle) {
    System.out.println("Print Triangle to Watch");
  }
}

```



---
![image](https://user-images.githubusercontent.com/60100532/205217644-101598df-4405-48ef-b1be-c7ba235cd7e0.png)
___
___

<br/> 

<br/> 

### 방문자 (Visitor) 패턴 장단점
* 장점
    * 기존 코드를 변경하지 않고 새로운 코드를 추가할 수 있다.
    * 추가 기능을 한 곳에 모아둘 수 있다.

* 단점
    * 복잡도가 증가한다.
    * 새로운 Element를 추가하거나 제거할 때 모든 Visitor 코드를 변경해야 한다.


___
___

<br/> 

<br/> 

### 방문자 (Visitor) 패턴
실무에서 어떻게 쓰이나?

* 자바
  * File Visitor, SimpleFileVisitor
  * AnnotationValueVisitor
  * ElementVisitor
* 스프링
  * BeanDefinitionVisitor
  

 