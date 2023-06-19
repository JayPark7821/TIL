# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 2. 생성자에 매개변수가 많다면 빌더를 고려하라
* 핵심정리
  * 정적 팩토리와 생성자에 선택적 매개변수가 많을 때 고려할 수 있는 방안
    * 대안1: 점층적 생성자 패턴 또는 생성자 체이닝
      * 매개변수가 늘어나면 클라이언트 코드를 작서하거나 읽기 어렵다.
    * 대안2:자바빈즈 패턴
      * 완번한 객체를 만들려면 메서드를 여러번 호출해야한다.(일관성이 무너진 상태가 될 수도 있다.)
    * 클래스를 불변으로 만들 수 없다. 


### 점층적 생성자 패턴
### Sample Code
```java
public class NutritionFacts {
    private final int servingSize;  // (mL, 1회 제공량)     필수
    private final int servings;     // (회, 총 n회 제공량)  필수
    private final int calories;     // (1회 제공량당)       선택
    private final int fat;          // (g/1회 제공량)       선택
    private final int sodium;       // (mg/1회 제공량)      선택
    private final int carbohydrate; // (g/1회 제공량)       선택

    public NutritionFacts(int servingSize, int servings) {
        this(servingSize, servings, 0);
//        this.servingSize = servingSize;
//        this.servings = servings;
//        this.calories = 0;
//        this.fat = 0;
//        this.sodium = 0;
//        this.carbohydrate = 0;
    }

    public NutritionFacts(int servingSize, int servings,
                          int calories) {
        this(servingSize, servings, calories, 0);
//        this.servingSize = servingSize;
//        this.servings = servings;
//        this.calories = calories;
//        this.fat = 0;
//        this.sodium = 0;
//        this.carbohydrate = 0;
    }

    public NutritionFacts(int servingSize, int servings,
                          int calories, int fat) {
        this(servingSize, servings, calories, fat, 0);
//        this.servingSize = servingSize;
//        this.servings = servings;
//        this.calories = calories;
//        this.fat = fat;
//        this.sodium = 0;
//        this.carbohydrate = 0;
    }

    public NutritionFacts(int servingSize, int servings,
                          int calories, int fat, int sodium) {
        this(servingSize, servings, calories, fat, sodium, 0);
//        this.servingSize = servingSize;
//        this.servings = servings;
//        this.calories = calories;
//        this.fat = fat;
//        this.sodium = sodium;
//        this.carbohydrate = 0;
    }

    public NutritionFacts(int servingSize, int servings,
                          int calories, int fat, int sodium, int carbohydrate) {
        this.servingSize  = servingSize;
        this.servings     = servings;
        this.calories     = calories;
        this.fat          = fat;
        this.sodium       = sodium;
        this.carbohydrate = carbohydrate;
    }

    public static void main(String[] args) {
        NutritionFacts cocaCola =
                new NutritionFacts(10, 10);
    }
    
}
```
 
* 위 코드는 생성자도 많지만 생성자에 넘겨주는 파라미터도 많다.
* 필수적인 필드값은 객체를 만들때 받아서 만들수있도록 강제하기 위해 생성자에 넘겨주는게 좋다.
* 위 예시코드처럼 옵셔널한 필드값이 많으면 점층적 생성자 패턴을 고려해보자.
* 위 코드에서 문제점은 생성자로 받는 필드가 전부 int 값 이다. 즉 생성자로 넘긴값이 어떤 파라미터로 들어가는지 알기 힘들다.

### 자바빈즈 패턴
### Sample Code
```java
public class NutritionFacts {
    // 필드 (기본값이 있다면) 기본값으로 초기화된다.
    private int servingSize  = -1; // 필수; 기본값 없음
    private int servings     = -1; // 필수; 기본값 없음
    private int calories     = 0;
    private int fat          = 0;
    private int sodium       = 0;
    private int carbohydrate = 0;
    private boolean healthy;

    public NutritionFacts() { }

    public void setServingSize(int servingSize) {
        this.servingSize = servingSize;
    }

    public void setServings(int servings) {
        this.servings = servings;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }

    public void setFat(int fat) {
        this.fat = fat;
    }

    public void setSodium(int sodium) {
        this.sodium = sodium;
    }

    public void setCarbohydrate(int carbohydrate) {
        this.carbohydrate = carbohydrate;
    }

    public void setHealthy(boolean healthy) {
        this.healthy = healthy;
    }

    public static void main(String[] args) {
        NutritionFacts cocaCola = new NutritionFacts();
        cocaCola.setServingSize(240);
        cocaCola.setServings(8);

        cocaCola.setCalories(100);
        cocaCola.setSodium(35);
        cocaCola.setCarbohydrate(27);
    }
}
```
* 자바빈즈 패턴은 매개변수가 없는 생성자로 객체를 만들 후 Setter를 통해서 원하는 매개변수의 값을 설정하는 방식이다.
* 이전 점층적 생성자 패턴과 다르게 객체의 생성이 매우 단순해졌다.
* 점층적 생성자 패턴에서 보였던 단점은 자바빈즈 패턴에서 보이지 않는다.
* 코드가 길어지긴 했지만 인스턴스를 만들기가 쉬워졌고, 그 결과 코드를 읽기 더 쉬워졌다.
* 단점은 자바빈즈 패턴에서는 객체 하나를 만드려면 메서드를 여러개 호출해야한다.
* 또한 필수 필드값을 강제할 수 없어 객체가 완전히 생성되기 전까지 일관성(Consistency)이 무너진 상태에 놓이게 된다.
* 마지막으로 자바 빈즈 패턴에서는 클래스를 분변으로 만들 수 없다.

### 빌더 패턴
### Sample Code
```java
public class NutritionFacts {
    private final int servingSize;
    private final int servings;
    private final int calories;
    private final int fat;
    private final int sodium;
    private final int carbohydrate;

    public static void main(String[] args) {
        NutritionFacts cocaCola = new Builder(240, 8)
                .calories(100)
                .sodium(35)
                .carbohydrate(27).build();
    }

    public static class Builder {
        // 필수 매개변수
        private final int servingSize;
        private final int servings;

        // 선택 매개변수 - 기본값으로 초기화한다.
        private int calories      = 0;
        private int fat           = 0;
        private int sodium        = 0;
        private int carbohydrate  = 0;

        public Builder(int servingSize, int servings) {
            this.servingSize = servingSize;
            this.servings    = servings;
        }

        public Builder calories(int val)
        { calories = val;      return this; }
        public Builder fat(int val)
        { fat = val;           return this; }
        public Builder sodium(int val)
        { sodium = val;        return this; }
        public Builder carbohydrate(int val)
        { carbohydrate = val;  return this; }

        public NutritionFacts build() {
            return new NutritionFacts(this);
        }
    }

    private NutritionFacts(Builder builder) {
        servingSize  = builder.servingSize;
        servings     = builder.servings;
        calories     = builder.calories;
        fat          = builder.fat;
        sodium       = builder.sodium;
        carbohydrate = builder.carbohydrate;
    }
}
```
* 점층적 생성자 패턴과 자바빈즈 패턴의 장점만 취했다.
* 점층적 생성자 패턴의 안정성과 자바 빈즈 패턴의 가독성을 겸비했다.
* 클라이언트는 필요한 객체를 직접 만드는 대신, 필수 매개변수만으로 생성자를 호출해 빌더 객체를 얻고
* 그 이후 빌더객체가 제공하는 일종의 세터 메서드 들로 원하는 매개변수들을 설정한다.
* 마지막으로 매개변수가 없는 build메서드를 호출해 우리가 피룡한 객체를 얻는다.


### 계층형 빌더 패턴
### Sample Code
```java
// 코드 2-4 계층적으로 설계된 클래스와 잘 어울리는 빌더 패턴 (19쪽)

// 참고: 여기서 사용한 '시뮬레이트한 셀프 타입(simulated self-type)' 관용구는
// 빌더뿐 아니라 임의의 유동적인 계층구조를 허용한다.

public abstract class Pizza {
    public enum Topping { HAM, MUSHROOM, ONION, PEPPER, SAUSAGE }
    final Set<Topping> toppings;

    abstract static class Builder<T extends Builder<T>> {
        EnumSet<Topping> toppings = EnumSet.noneOf(Topping.class);
        public T addTopping(Topping topping) {
            toppings.add(Objects.requireNonNull(topping));
            return self();
        }

        abstract Pizza build();

        // 하위 클래스는 이 메서드를 재정의(overriding)하여
        // "this"를 반환하도록 해야 한다.
        protected abstract T self();
    }
    
    Pizza(Builder<?> builder) {
        toppings = builder.toppings.clone(); // 아이템 50 참조
    }
}
```
```java
// 코드 2-6 칼초네 피자 - 계층적 빌더를 활용한 하위 클래스 (20~21쪽)
public class Calzone extends Pizza {
    private final boolean sauceInside;

    public static class Builder extends Pizza.Builder<Builder> {
        private boolean sauceInside = false; // 기본값

        public Builder sauceInside() {
            sauceInside = true;
            return this;
        }

        @Override public Calzone build() {
            return new Calzone(this);
        }

        @Override protected Builder self() { return this; }
    }

    private Calzone(Builder builder) {
        super(builder);
        sauceInside = builder.sauceInside;
    }

    @Override public String toString() {
        return String.format("%s로 토핑한 칼초네 피자 (소스는 %s에)",
                toppings, sauceInside ? "안" : "바깥");
    }
}
```
```java
// 코드 2-5 뉴욕 피자 - 계층적 빌더를 활용한 하위 클래스 (20쪽)
public class NyPizza extends Pizza {
    public enum Size { SMALL, MEDIUM, LARGE }
    private final Size size;

    public static class Builder extends Pizza.Builder<NyPizza.Builder> {
        private final Size size;

        public Builder(Size size) {
            this.size = Objects.requireNonNull(size);
        }

        @Override public NyPizza build() {
            return new NyPizza(this);
        }

        @Override protected Builder self() { return this; }
    }

    private NyPizza(Builder builder) {
        super(builder);
        size = builder.size;
    }

    @Override public String toString() {
        return toppings + "로 토핑한 뉴욕 피자";
    }
}
```
* 각 하위 클래스(NyPizza, Calzone)의 빌더가 정의한 build 메서드는 해당하는 구체 하위 클래스를 반환하도록 언선한다.
* NyPizza.Builder는 NyPizza를 반환하고, 
* Calzone.Builder는 Calzone를 반환한다.
* 하위 클래스의 메서드가 상위 클래스의 메서드가 정의한 반환 타입이 아닌,
* 그 하위타입을 반환하는 기능을 공변 반환 타이핑(covariant return typing)이라 한다.
* 이 기능을 이용하면 클라이언트가 형변환에 신경 쓰지 않고도 빌더를 사용할 수 있다.

### 자바빈(JavaBean) Page 15
* Java.beans 패키지 안에 있는 모든 것
* 자바빈이 지켜야 할 규약
  * 아규먼트 없는 기본 생성자 
  * getter와 setter 메소드 이름 규약
  * Serializable 인터페이스 구현
* 실제로 오늘날 자바빈 스팩 중에서도 getter와 setter가 주로 쓰이는 이유
  * JPA나 스프링과 같은 여러 프레임워크에서 리플렉션을 통해 특정 객체의 값을 조회하거나 설정하기 떄문
  
### IllegalArgumentException Page 19
* RuntimeException을 상속받은 unchecked exception중에 하나이다.
* checked exception & unchecked exception
  * checked exception이 발생했을때 우리는 2가지 중에 1가지를 해야한다.
    * 다시 checked exception을 던지거나
    * try catch 블럭으로 예외처리를 해줘야 한다.
    * compile time에 체크를 해주기 때문에 컴파일할 수 없다. 
    * 복구가 가능한 상황에서 checked exception을 던진다 
  * unchecked exception 프로그램적인 error이고 복구할 수 있는 방법이 없다.
    * 예외 처리를 하거나할 필요 없다.
    * 복구가 불가능한 상황에서 unchecked exception을 던진다 


___
___

> 핵심정리
> * 생성자나 정적 팩터리가 처리해야 할 매개변수가 많다면 빌더 패턴을 선택하는 게 더 낫다.   
>   매개변수중 다수가 필수가 아니거나 같은 타입이라면 특히 더 그렇다.   
>   빌더는 점층적 생성자보다 클라이언트 코드를 읽고 쓰기가 훨씬 간결하고, 자바빈보다 훨씬 안전하다.