# Design-patterns
## 객체 생성 관련 디자인 패턴

---
### 빌더(Builder) 패턴 4. 동일한 프로세스를 거쳐 다양한 구성의 인스턴스를 만드는 방법.
#### 빌더(Builder) 패턴
* (복잡한) 객체를 만드는 프로세스를 독립적으로 분리할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/191453618-932471bd-d189-46d9-bbbe-8544ba619b2c.png)


코드로 빌더패턴을 알아보자!!  
빌더 패턴 적용 전
```java
public class TourPlan {

    private String title;

    private int nights;

    private int days;

    private LocalDate startDate;

    private String whereToStay;

    private List<DetailPlan> plans;

    public TourPlan() {
    }

    public TourPlan(String title, int nights, int days, LocalDate startDate, String whereToStay, List<DetailPlan> plans) {
        this.title = title;
        this.nights = nights;
        this.days = days;
        this.startDate = startDate;
        this.whereToStay = whereToStay;
        this.plans = plans;
    }

    @Override
    public String toString() {
        return "TourPlan{" +
                "title='" + title + '\'' +
                ", nights=" + nights +
                ", days=" + days +
                ", startDate=" + startDate +
                ", whereToStay='" + whereToStay + '\'' +
                ", plans=" + plans +
                '}';
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getNights() {
        return nights;
    }

    public void setNights(int nights) {
        this.nights = nights;
    }

    public int getDays() {
        return days;
    }

    public void setDays(int days) {
        this.days = days;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public String getWhereToStay() {
        return whereToStay;
    }

    public void setWhereToStay(String whereToStay) {
        this.whereToStay = whereToStay;
    }

    public List<DetailPlan> getPlans() {
        return plans;
    }

    public void setPlans(List<DetailPlan> plans) {
        this.plans = plans;
    }

    public void addPlan(int day, String plan) {
        this.plans.add(new DetailPlan(day, plan));
    }
}
```

```java
public class DetailPlan {

    private int day;

    private String plan;

    public DetailPlan(int day, String plan) {
        this.day = day;
        this.plan = plan;
    }

    public int getDay() {
        return day;
    }

    public void setDay(int day) {
        this.day = day;
    }

    public String getPlan() {
        return plan;
    }

    public void setPlan(String plan) {
        this.plan = plan;
    }

    @Override
    public String toString() {
        return "DetailPlan{" +
                "day=" + day +
                ", plan='" + plan + '\'' +
                '}';
    }
}


```

```java
public class App {
    public static void main(String[] args) {
        TourPlanBuilder builder = new DefaultTourBuilder();
        TourPlan plan = builder.title("칸쿤 여행")
                .nightsAndDays(2, 3)
                .startDate(LocalDate.of(2020, 2, 2))
                .whereToStay("리조트")
                .addPlan(0, "체크인하고 짐풀기")
                .addPlan(0, "저녁 식사")
                .getPlan();

        TourPlan longBeachTrip = builder.title("롱비치")
                .startDate(LocalDate.of(2020, 1, 2))
                .getPlan();
    }
}
```
위의 코드처럼 객체를 생성하면 객체를 생성할 때 일관된 프로세스가 없다   
또 예를 들어 startDate는 무조건 세팅해야 한다는 조건을 강제하고 싶은데 강제할 수 없다.
마지막으로 다양한 파라미터를 지원하는 생성자를 만들고 싶을 때 생성자 호출이 장황해질 수 있다.

<br/> 

___
___ 

위 코드에 빌더 패턴을 적용해 보자.

### TourPlanBuilder
```java
public interface TourPlanBuilder {

    TourPlanBuilder title(String title); // 메소드 체이닝을 위해 return type을 TourPlanBuilder

    TourPlanBuilder nightsAndDays(int nights, int days);

    TourPlanBuilder startDate(LocalDate localDate);

    TourPlanBuilder whereToStay(String whereToStay);

    TourPlanBuilder addPlan(int day, String plan);


    TourPlan getPlan(); // getPlan 구현할때 인스턴스가 정상적인지 검증하는 로직을 넣기 좋다!
}

```

### DefaultTourBuilder 
```java

public class DefaultTourBuilder implements TourPlanBuilder{

    private String title;

    private int nights;

    private int days;

    private LocalDate startDate;

    private String whereToStay;

    private List<DetailPlan> plans;

    @Override
    public TourPlanBuilder nightsAndDays(int nights, int days) {
        this.nights = nights;
        this.days = days;
        return this;
    }

    @Override
    public TourPlanBuilder title(String title) {
        this.title = title;
        return this;
    }

    @Override
    public TourPlanBuilder startDate(LocalDate startDate) {
        this.startDate = startDate;
        return this;
    }

    @Override
    public TourPlanBuilder whereToStay(String whereToStay) {
        this.whereToStay = whereToStay;
        return this;
    }

    @Override
    public TourPlanBuilder addPlan(int day, String plan) {
        if (this.plans == null) {
            this.plans = new ArrayList<>();
        }

        this.plans.add(new DetailPlan(day, plan));
        return this;
    }

    @Override
    public TourPlan getPlan() {
        return new TourPlan(title, nights, days, startDate, whereToStay, plans);
    }

}
```

### 클라이언트 코드 
```java

public class App {
    public static void main(String[] args) {
        TourPlanBuilder builder = new DefaultTourBuilder();
        TourPlan plan = builder.title("칸쿤 여행")
                .nightsAndDays(2, 3)
                .startDate(LocalDate.of(2020, 2, 2))
                .whereToStay("리조트")
                .addPlan(0, "체크인하고 짐풀기")
                .addPlan(0, "저녁 식사")
                .getPlan();

        TourPlan longBeachTrip = builder.title("롱비치")
                .startDate(LocalDate.of(2020, 1, 2))
                .getPlan();
    }
}
```
만약 빌더 패턴을 적용하지 않고 생성자를 통해서 위의 인스턴스를 선언하려면  
생성자를 장황하게 쓰거나.  
장황하게 만들어져있는 생성자에 수많은 null값이나 기본값들을 넣었어야 했을 것이다.

객체 생성이 자주 발생한다고 한다면 

```java

public class TourDirector {

    private TourPlanBuilder tourPlanBuilder;

    public TourDirector(TourPlanBuilder tourPlanBuilder) {
        this.tourPlanBuilder = tourPlanBuilder;
    }

    public TourPlan cancunTrip() {
        return   tourPlanBuilder.title("칸쿤 여행")
                .nightsAndDays(2, 3)
                .startDate(LocalDate.of(2020, 2, 2))
                .whereToStay("리조트")
                .addPlan(0, "체크인하고 짐풀기")
                .addPlan(0, "저녁 식사")
                .getPlan();

    }

    public TourPlan longBeachTrip() {
        return   tourPlanBuilder.title("롱비치")
                .startDate(LocalDate.of(2020, 1, 2))
                .getPlan();
    }
}

```
위와 같이 미리 선언해 놓고 director 통해서 생성할 수 있다.

```java
import org.designpatterns._01_creational_patterns._04_builder._01_before.TourPlan;
import org.designpatterns._01_creational_patterns._04_builder._02_after.DefaultTourBuilder;
import org.designpatterns._01_creational_patterns._04_builder._02_after.TourDirector;

public class App {
    public static void main(String[] args) {
        TourDirector director = new TourDirector(new DefaultTourBuilder());
        TourPlan tourPlan = director.cancunTrip();
        TourPlan tourPlan1 = director.longBeachTrip();
    }
}
```



<br/> 

<br/> 

___
___ 

* ### 빌더 패턴을 적용했을 때의 장점
  * 장점 
    * 만들기 복잡한 객체를 순차적으로 만들 수 있다.
    * 복잡한 객체를 만드는 구체적인 과정을 숨길 수 있다.
    * 동일한 프로세스를 통해 각기 다르게 구성된 객체를 만들 수도 있다.
    * 불완전한 객체를 사용하지 못하도록 방지할 수 있다.
  * 단점
    * 원하는 객체를 만들려면 빌더부터 만들어야 한다.
    * 구조가 복잡해 진다. (trade off)



<br/> 

<br/> 

___
___ 

* ### 빌더 패턴을 실무에서 어떻게 쓰이나?
* 자바 8 Stream.Builder API
* StringBuilder 
* 롬복의 @Builder
* 스프링
  * UriComponentsBuilder
  * MockMvcWebClientBuilder
  * ...Builder



* #### StringBuilder

```java
public class StringBuilderExample {

    public static void main(String[] args) {
        StringBuilder stringBuilder = new StringBuilder();
        String result = stringBuilder.append("whiteship").append("keesun").toString();
        System.out.println(result);
    }
}
```

![image](https://user-images.githubusercontent.com/60100532/191485402-bbab2d1a-1337-441b-a180-086ba836f207.png)


* #### 자바 8 Stream.Builder API

```java
public class StreamExample {

    public static void main(String[] args) {
        Stream<String> names = Stream.<String>builder().add("keesun").add("whiteship").build();
        names.forEach(System.out::println);
    }
}
```

* #### 롬복의 @Builder

```java
@Builder
public class LombokExample {

    private String title;

    private int nights;

    private int days;

    public static void main(String[] args) {
        LombokExample trip = LombokExample.builder()
                .title("여행")
                .nights(2)
                .days(3)
                .build();
    }

}

```

* #### 스프링
```java
public class SpringExample {

    public static void main(String[] args) {
        UriComponents howToStudyJava = UriComponentsBuilder.newInstance()
                .scheme("http")
                .host("www.whiteship.me")
                .path("java playlist ep1")
                .build().encode();
        System.out.println(howToStudyJava);
    }
}

```

지금까지 알아본 빌더 패턴을 위의 스프링예제와 같이 변경하면 다음과 같이 코딩할 수 있다.

```java
public class InstanceTourBuilder implements TourPlanBuilder {

    private TourPlan tourPlan;
    
    public TourPlanBuilder newInstnace() {
        this.tourPlan = new TourPlan();
        return this;
    }

    @Override
    public TourPlanBuilder title(String title) {
        this.tourPlan.setTitle(title);
        return this;
    }
 
}

```