# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 중재자 (Mediator) 패턴
* 여러 객체들이 소통한는 방법을 캡슐화하는 패턴
* 여러 컴포넌트간의 결합도를 중재자를 통해 낮출 수 있다.

![image](https://user-images.githubusercontent.com/60100532/202461950-dc284b2e-e9ea-4563-b25f-77038d9d1cb4.png)

### 코드로 중재자 패턴을 알아보자.
 
### Hotel

```java
public class Hotel {

    public static void main(String[] args) {
        Guest guest = new Guest();
        guest.getTower(3);
        guest.dinner();

        Restaurant restaurant = new Restaurant();
        restaurant.clean();
    }
}

```
### CleaningService
```java
public class CleaningService {
  public void clean(Gym gym) {
    System.out.println("clean " + gym);
  }

  public void getTower(Guest guest, int numberOfTower) {
    System.out.println(numberOfTower + " towers to " + guest);
  }

  public void clean(Restaurant restaurant) {
    System.out.println("clean " + restaurant);
  }
}

```

### Guest
```java


public class Guest {

  private Restaurant restaurant = new Restaurant();

  private CleaningService cleaningService = new CleaningService();

  public void dinner() {
    restaurant.dinner(this);
  }

  public void getTower(int numberOfTower) {
    cleaningService.getTower(this, numberOfTower);
  }

}

```

### Gym
```java

public class Gym {

  private CleaningService cleaningService;

  public void clean() {
    cleaningService.clean(this);
  }
}

```

### Restaurant
```java
public class Restaurant {

  private CleaningService cleaningService = new CleaningService();
  public void dinner(Guest guest) {
    System.out.println("dinner " + guest);
  }

  public void clean() {
    cleaningService.clean(this);
  }
}


```

### 중재자 패턴을 적용.

---  
#### FrontDesk
```java

public class FrontDesk {

  private CleaningService cleaningService = new CleaningService();

  private Restaurant restaurant = new Restaurant();

  public void getTowers(Guest guest, int numberOfTowers) {
    cleaningService.getTowers(guest.getId(), numberOfTowers);
  }

  public String getRoomNumberFor(Integer guestId) {
    return "1111";
  }

  public void dinner(Guest guest, LocalDateTime dateTime) {
    restaurant.dinner(guest.getId(), dateTime);
  }
}


```
#### CleaningService
```java
public class CleaningService {

  private FrontDesk frontDesk = new FrontDesk();

  public void getTowers(Integer guestId, int numberOfTowers) {
    String roomNumber = this.frontDesk.getRoomNumberFor(guestId);
    System.out.println("provide " + numberOfTowers + " to " + roomNumber);
  }
}

```

#### Guest
```java
public class Guest {

  private Integer id;

  private FrontDesk frontDesk = new FrontDesk();

  public void getTowers(int numberOfTowers) {
    this.frontDesk.getTowers(this, numberOfTowers);
  }

  private void dinner(LocalDateTime dateTime) {
    this.frontDesk.dinner(this, dateTime);
  }

  public Integer getId() {
    return id;
  }

  public void setId(Integer id) {
    this.id = id;
  }
}


```


#### Restaurant
```java
public class Restaurant {
  public void dinner(Integer id, LocalDateTime dateTime) {

  }
}


```
---
![image](https://user-images.githubusercontent.com/60100532/202466833-5c82d5e7-ce47-4c1b-9c7c-fcded841ffe2.png)
___
___

<br/> 

<br/> 

### 중재자 (Mediator) 패턴 장단점
* 장점
    * 컴포넌트 코드를 변경하지 ㅇ낳고 새로운 중재자를 만들어 사용할 수 있다.
    * 각각의 컴포넌트 코드를 보다 간결하게 유지할 수 있다.
* 단점
    * 중재자 역할을 하는 클래스의 복잡도와 결합도가 증가한다.


___
___

<br/> 

<br/> 

### 중재자 (Mediator) 패턴

* 자바
  * ExcutorService
  * Executor
* 스프링
  * DispatcherServlet
