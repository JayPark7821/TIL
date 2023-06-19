# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 3. private 생성자나 열거 타입으로 싱글턴임을 보증하라

### 첫번째 방법 : private 생성자 + public static final 필드
* 장점 - 간결하게 싱글턴임을 API에 들어낼 수 있다.
* 단점 1 - 싱글톤을 사용하는 클라이언트를 테스트하기 어려워진다.
  * 타입을 인터페이스로 정의한 다음 그 인터페이스를 구현해 만든 싱글턴이 아니라면 싱글턴 인스턴스를 가짜(mock) 구현으로 대체할 수 없다.
* 단점 2 - 리플렉션으로 private 생성자를 호출할 수 있다.
* 단점 3 - 역직렬화 할 때 새로운 인스턴스가 생길 수 있다.

### Sample Code
```java
// 코드 3-1 public static final 필드 방식의 싱글턴 (23쪽)
public class Elvis implements IElvis, Serializable {

    /**
     * 싱글톤 오브젝트
     */
    public static final Elvis INSTANCE = new Elvis();
    
    private Elvis(){}
  
    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    public void sing() {
        System.out.println("I'll have a blue~ Christmas without you~");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.INSTANCE;
        elvis.leaveTheBuilding();
    }
}
```
### 단점 2 - 리플렉션으로 private 생성자를 호출할 수 있다.
### Sample Code
```java

// 생성자로 여러 인스턴스 만들기
public class ElvisReflection {

    public static void main(String[] args) {
        try {
            Constructor<Elvis> defaultConstructor = Elvis.class.getDeclaredConstructor();
            defaultConstructor.setAccessible(true);
            Elvis elvis1 = defaultConstructor.newInstance();
            Elvis elvis2 = defaultConstructor.newInstance();
            Elvis.INSTANCE.sing();
        } catch (InvocationTargetException | NoSuchMethodException | InstantiationException | IllegalAccessException e) {
            e.printStackTrace();
        }
    }

}
```
### 단점 2 해결 방법
* 해당 인스턴스에 생성여부 flag를 추가해 private 생성자 호출시 flag값 확인하도록 변경
```java
    private static boolean created; // 생성여부 flag 

    private Elvis() {
        if (created) {
            throw new UnsupportedOperationException("can't be created by constructor.");
        }

        created = true;
    }
```
```java
// 코드 3-1 public static final 필드 방식의 싱글턴 (23쪽)
public class Elvis implements IElvis, Serializable {

    /**
     * 싱글톤 오브젝트
     */
    public static final Elvis INSTANCE = new Elvis();
    private static boolean created;

    private Elvis() {
        if (created) {
            throw new UnsupportedOperationException("can't be created by constructor.");
        }

        created = true;
    }

    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    public void sing() {
        System.out.println("I'll have a blue~ Christmas without you~");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.INSTANCE;
        elvis.leaveTheBuilding();
    }

    private Object readResolve() {
        return INSTANCE;
    }

}
```
### 단점 3 - 역직렬화 할 때 새로운 인스턴스가 생길 수 있다.
```java
// 역직렬화로 여러 인스턴스 만들기
public class ElvisSerialization {

    public static void main(String[] args) {
        try (ObjectOutput out = new ObjectOutputStream(new FileOutputStream("elvis.obj"))) {
            out.writeObject(Elvis.INSTANCE);
        } catch (IOException e) {
            e.printStackTrace();
        }

        try (ObjectInput in = new ObjectInputStream(new FileInputStream("elvis.obj"))) {
            Elvis elvis3 = (Elvis) in.readObject();
            System.out.println(elvis3 == Elvis.INSTANCE);
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

}
```
* 위 코드를 실행하면 ` System.out.println(elvis3 == Elvis.INSTANCE);` false가 출력된다. 즉 
* 새로운 elvis의 인스턴스가 생성된것이다.

### 단점 3 해결 방법
* readResolve 메소드를 제공해 해결한다. (역직렬화시 호출됨 (@Override와는 다르다))
```java
// 코드 3-1 public static final 필드 방식의 싱글턴 (23쪽)
public class Elvis implements IElvis, Serializable {

    /**
     * 싱글톤 오브젝트
     */
    public static final Elvis INSTANCE = new Elvis();
    private static boolean created;

    private Elvis() {
    }

    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    public void sing() {
        System.out.println("I'll have a blue~ Christmas without you~");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.INSTANCE;
        elvis.leaveTheBuilding();
    }

    private Object readResolve() {
        return INSTANCE;
    }

}
```



### 두번째 방법 : private 생성자 + 정적 팩토리 메소드
* 장점 1 - API를 바꾸지 않고도 싱글턴이 아니게 변경할 수 있다.
* 장점 2 - 정적 팩토리를 제네릭 싱글톤 팩토리로 만들 수 있다.
* 장점 3 - 정적 팩토리의 메서드 참조를 공급자(Supplier)로 사용할 수 있다.
* 단점은 위 private 생성자  + public static final 필드의 단점과 동일하다.

### Sample Code
```java
// 코드 3-2 정적 팩터리 방식의 싱글턴 (24쪽)
public class Elvis  {
    private static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
    public static Elvis getInstance() { return INSTANCE; }

    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.getInstance();
        elvis.leaveTheBuilding();

        System.out.println(Elvis.getInstance());
        System.out.println(Elvis.getInstance());
    }
}
```
### 장점 1
* API를 바꾸지 않고도 싱글턴이 아니게 변경할 수 있다.
* 클라이언트 코드가 아래와 같을때
```java
    public static void main(String[] args) {
        Elvis elvis = Elvis.getInstance();
        elvis.leaveTheBuilding();

        System.out.println(Elvis.getInstance());
        System.out.println(Elvis.getInstance());
    }
```
* 클라이언트 코드의 변경없이 싱글톤 코드에서
```java
    private static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
    public static Elvis getInstance() { return INSTANCE; }
```
* 싱글톤이 아니게 변경할 수 있다.
```java
    private static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
    public static Elvis getInstance() { return new Elvis(); }
```

### 장점 2
* 정적 팩토리를 제네릭 싱글톤 팩토리로 만들 수 있다.
* 아래 샘플 코드의 elvis1과 elvis2는 같은 해쉬코드를 가지고 있지만.
* 제네릭 타입이 달라 == 비교가 불가능
* 하지만 equals로 비교해보면 같다고 나온다!!
* public class MetaElvis<T> 의 <T>와 public static <E> MetaElvis<E> getInstance()
* <T>와 <E>는 서로 스콥이 다르기 때문에 MetaElvis<E> 앞에 <E>를 선언함.
```java
// 코드 3-2 제네릭 싱글톤 팩토리 (24쪽)
public class MetaElvis<T> {

    private static final MetaElvis<Object> INSTANCE = new MetaElvis<>();

    private MetaElvis() { }

    @SuppressWarnings("unchecked")
    public static <E> MetaElvis<E> getInstance() { return (MetaElvis<E>) INSTANCE; }

    public void say(T t) {
        System.out.println(t);
    }

    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    public static void main(String[] args) {
        MetaElvis<String> elvis1 = MetaElvis.getInstance();
        MetaElvis<Integer> elvis2 = MetaElvis.getInstance();
        System.out.println(elvis1);
        System.out.println(elvis2);
        elvis1.say("hello");
        elvis2.say(100);
    }

}
```

### 장점 3
* 정적 팩토리의 메서드 참조를 공급자(Supplier)로 사용할 수 있다.
* Supplier<T> - Supplier interface만 만족을 하면 어떠한 메소드라도 Supplier type으로 사용할 수 있다.(Java 8이상부터)
* 즉 어떤 타입이든 리턴만 하게된다면 Supplier를 직접 구현하지 않아도 마치 해당 타입처럼 사용가능
* 메소드 이름은 중요하지 않다!!!

```java
public interface Singer {

    void sing();
}
```
#### implements Singer
```java
public class Elvis implements Singer {
    private static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
    public static Elvis getInstance() { return INSTANCE; }

    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.getInstance();
        elvis.leaveTheBuilding();

        System.out.println(Elvis.getInstance());
        System.out.println(Elvis.getInstance());
    }

    @Override
    public void sing() {
        System.out.println("my way~~~");
    }
}
```

```java
public class Concert {

    public void start(Supplier<Singer> singerSupplier) {
        Singer singer = singerSupplier.get();
        singer.sing();
    }

    public static void main(String[] args) {
        Concert concert = new Concert();
        concert.start(Elvis::getInstance);
    }
}
```


### 세번째 방법 : 열거 타입
* 가장 간결한 방법이며 직렬화와 리플렉션에도 안전하다.
* 대부분의 상황에서는 원소가 하나뿐인 열거 타입이 싱글턴을 만드는 가장 좋은 방법이다.

### Sample Code
```java

// 열거 타입 방식의 싱글턴 - 바람직한 방법 (25쪽)
public enum Elvis {
    INSTANCE;

    public void leaveTheBuilding() {
        System.out.println("기다려 자기야, 지금 나갈께!");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.INSTANCE;
        elvis.leaveTheBuilding();
    }
}
```

### 리플랙션으로 부터 안전하다
```java
public class EnumElvisReflection {

    public static void main(String[] args) {
        try {
            Constructor<Elvis> declaredConstructor = Elvis.class.getDeclaredConstructor();
            System.out.println(declaredConstructor);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        }
    }
}
```

### 직렬화 역직렬화로 부터 안전하다.
```java

public class EnumElvisSerialization {

    public static void main(String[] args) {
        try (ObjectOutput out = new ObjectOutputStream(new FileOutputStream("elvis.obj"))) {
            out.writeObject(Elvis.INSTANCE);
        } catch (IOException e) {
            e.printStackTrace();
        }

        try (ObjectInput in = new ObjectInputStream(new FileInputStream("elvis.obj"))) {
            Elvis elvis = (Elvis) in.readObject();
            System.out.println(elvis == Elvis.INSTANCE);
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```

---  

---  

### Method Reference
* 메소드 참조는 람다 표현식의 축약형이다.
```java
public class Person {

    LocalDate birthday;


    public Person(LocalDate birthday) {
      this.birthday = birthday;
    }
  
    public int getAge() {
      return LocalDate.now().getYear() - birthday.getYear();
    }
    
    public static int compareByAge(Person a, Person b) {
        return a.birthday.compareTo(b.birthday);
    }

    public static void main(String[] args) {
        List<Person> people = new ArrayList<>();
        people.add(new Person(LocalDate.of(1982, 7, 15)));
        people.add(new Person(LocalDate.of(2011, 3, 2)));
        people.add(new Person(LocalDate.of(2013, 1, 28)));

        people.sort(new Comparator<Person>() {
            @Override
            public int compare(Person a, Person b) {
                return a.birthday.compareTo(b.birthday);
            }
        });
        
        people.sort((a, b) -> a.birthday.compareTo(b.birthday));
    }

}
```

#### Java8 이전 익명 내부 클래스
```java
new Comparator<Person>() {
            @Override
            public int compare(Person a, Person b) {
                return a.birthday.compareTo(b.birthday);
            }
        }
```
#### Java8 이후 람다 표현식
```java
people.sort((a, b) -> a.birthday.compareTo(b.birthday));
```
* 람다 표현식에서 해야하는 일이 단순하게 메소드호출 하나라면
* 메소드 레퍼런스로 축약할 수 있다.
```java
people.sort(Person::compareByAge);
```

### Method Reference 종류
1. 정적 메소드 레퍼런스 static method reference
```java
public class Person {
  ...
  
    public static int compareByAge(Person a, Person b) {
        return a.birthday.compareTo(b.birthday);
    }

    public static void main(String[] args) {
      ...
      people.sort(Person::compareByAge);
    }

}
```
* static 메소드 compareByAge를 참조하는 static method reference
```java
people.sort(Person::compareByAge);
```
  
<br />  

2. instance method reference
```java
public class Person {
  ...
  
    public int compareByAge(Person a, Person b) {
        return a.birthday.compareTo(b.birthday);
    }

    public static void main(String[] args) {
      ...
        Person person = new Person();
        people.sort(person::compareByAge);
    }

}
```
* 인스턴스 메소드는 당연히 인스턴스를 통해서 접근해야하기 때문에 
* Person person = new Person() 를 통해 인스턴스를 생성해한뒤 생성한 person의 compareByAge 메소드를 참조한다.
```java
people.sort(person::compareByAge);
```

<br />  

3. 임의 객체의 인스턴스 메소드 레퍼런스
* 임의 객체의 메소드 레퍼런스는 첫번째 인자가 자기 자신이 된다.
```java
public class Person {
  ...
  
    public int compareByAge(Person a, Person b) {
        return this.birthday.compareTo(b.birthday);
    }

    public static void main(String[] args) {
      ...
        people.sort(Person::compareByAge);
    }

}
```

<br />  

4. 생성자 메소드 레퍼런스
```java
public class Person {
    public Person(LocalDate birthday) {
      this.birthday = birthday;
    }
    
    public static void main(String[] args) {
        List<LocalDate> dates = new ArrayList<>();
        dates.add(LocalDate.of(1982, 7, 15));
        dates.add(LocalDate.of(1982, 7, 15));
        dates.add(LocalDate.of(1982, 7, 15));
        dates.add(LocalDate.of(1982, 7, 15));
        dates.stream().map(Person::new).collect(Collectors.toList());
    }
}
```


### Functional interface
* 함수형 인터페이스는 추상 메소드가 하나만 있는 인터페이스이다.
* 함수형 인터페이스는 람다 표현식과 메소드 참조에 대한 "타겟 타입"을 제공
* 타겟 타입은 변수 할당, 메소드 호출, 타입 변환에 활용할 수 있다.
* 함수형 인터페이스는 @FunctionalInterface 어노테이션을 사용하여 선언할 수 있다.  
  
```java
public class UsageOfFunctions {

    public static void main(String[] args) {
        List<LocalDate> dates = new ArrayList<>();
        dates.add(LocalDate.of(1982, 7, 15));
        dates.add(LocalDate.of(2011, 3, 2));
        dates.add(LocalDate.of(2013, 1, 28));

        List<Integer> before2000 = dates.stream()
                .filter(d -> d.isBefore(LocalDate.of(2000, 1, 1))) // <- Predicate
                .map(LocalDate::getYear) // <- Function
                .collect(Collectors.toList());
    }
}
```
* Predicate와 Function은 java가 기본으로 제공해주는 함수형 인터페이스이다. (모두 java.util.function안에 들어있다.)
* 기본적으로 Function, Supplier, Consumer, Predicate는 알고 넘어가자
```java
public class DefaultFunctions {

    public static void main(String[] args) {
        Function<Integer, String> intToString = Object::toString;

        Supplier<Person> personSupplier = Person::new;
        Function<LocalDate, Person> personFunction = Person::new;

        Consumer<Integer> integerConsumer = System.out::println;

        Predicate<Person> predicate;
    }
}
```
* Function<T,R> : T타입을 받아서 R타입을 반환하는 함수

![image](https://user-images.githubusercontent.com/60100532/209514109-91f3d554-b9b7-4dc3-a330-bb9d0b76e9a1.png)

* Supplier<T> : T타입을 반환하는 함수  
![image](https://user-images.githubusercontent.com/60100532/209514138-3ee6c26a-969b-4763-be3c-14c8845c94ff.png)

* Consumer<T> : T타입을 받아서 아무것도 반환하지 않는 함수  
![image](https://user-images.githubusercontent.com/60100532/209514063-32015831-5371-4efd-91dd-d54593e14577.png)

* Predicate<T> : T타입을 받아서 boolean을 반환하는 함수
![image](https://user-images.githubusercontent.com/60100532/209514187-851474a9-1b49-4f87-9684-9fdb0886f8c8.png)


* java가 제공해주는 타입 말고 직접 구현이 필요하다면 아래와 같이 구현할 수 있다.
```java
@FunctionalInterface
public interface MyFunction<T, R> {
    R apply(T t);
}
```
