# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 18. 상속보다는 컴포지션을 사용하라.

### 핵심정리
* 패키지 경계를 넘어 다른 패키지의 구체 클래스를 상속하는 일은 위험하다.
  * 상위 클래스에서 제공하는 메서드 구현이 바뀐다면.....
  * 상위 클래스에서 새로운 메서드가 생긴다면....
* 컴포지션(Composition)
  * 새로운 클래스를 만들고 private 필드로 기존 클래스의 인스턴스를 참조.
  * 새 클래스의 인스턴스 메서드들은 기존 클래스에 대응하는 메서드를 호출해 그 결과를 반환 한다.
  * 기존 클래스의 구현이 바뀌거나, 새로운 메서드가 생기더라도 아무런 영향을 받지 않는다.



### Sample Code
```java

// 코드 18-1 잘못된 예 - 상속을 잘못 사용했다! (114쪽)
public class InstrumentedHashSet<E> extends HashSet<E> {
    // 추가된 원소의 수
    private int addCount = 0;

    public InstrumentedHashSet() {
    }

    public InstrumentedHashSet(int initCap, float loadFactor) {
        super(initCap, loadFactor);
    }

    @Override public boolean add(E e) {
        addCount++;
        return super.add(e);
    }

    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);
    }
 
    public static void main(String[] args) {
        InstrumentedHashSet<String> s = new InstrumentedHashSet<>();
        s.addAll(List.of("틱", "탁탁", "펑"));
        System.out.println(s.getAddCount());  // 6이 출력된다.
    }
}

```

![image](https://user-images.githubusercontent.com/60100532/212539600-84d57fcc-00fc-40ed-b20b-3c0c0b46394b.png)
* HashSet의 add에서 이미 add를 하고있다. 
* 이처럼 상속을 하려면 상위클래스에서 제공하는 메소드의 내부구현이 어떻게 되어있는지 정확히 알아야 한다.
* 여기서 또 문제는 내부구현을 정확하게 이해해고 구현했지만
* 만약 내부 구현이 바뀐다면 ?!!!!!
* 하위 클래스의 구현이 바뀌어야할 수 있다.
* 그리고 상위 클래스에서 나도 모르게 새로운 메서드가 생길 가능성이 있다.
* 이처럼 상속을 사용했을때 코드가 깨지는경우가 많아 진다!!!!!!!!!!  
<br />  

* 이런 문제를 해결하기 위해 컴포지션을 사용한다.

### Sample Code
```java

// 코드 18-3 재사용할 수 있는 전달 클래스 (118쪽)
public class ForwardingSet<E> implements Set<E> {
    private final Set<E> s;
    public ForwardingSet(Set<E> s) { this.s = s; }

    public void clear()               { s.clear();            }
    public boolean contains(Object o) { return s.contains(o); }
    public boolean isEmpty()          { return s.isEmpty();   }
    public int size()                 { return s.size();      }
    public Iterator<E> iterator()     { return s.iterator();  }
    public boolean add(E e)           { return s.add(e);      }
    public boolean remove(Object o)   { return s.remove(o);   }
    public boolean containsAll(Collection<?> c)
                                   { return s.containsAll(c); }
    public boolean addAll(Collection<? extends E> c)
                                   { return s.addAll(c);      }
    public boolean removeAll(Collection<?> c)
                                   { return s.removeAll(c);   }
    public boolean retainAll(Collection<?> c)
                                   { return s.retainAll(c);   }
    public Object[] toArray()          { return s.toArray();  }
    public <T> T[] toArray(T[] a)      { return s.toArray(a); }
    @Override public boolean equals(Object o)
                                       { return s.equals(o);  }
    @Override public int hashCode()    { return s.hashCode(); }
    @Override public String toString() { return s.toString(); }
}

```

* 기존 HashSet을 상속받은 코드는 
```java
    @Override public boolean add(E e) {
        addCount++;
        return super.add(e);
    }

    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);
    }
 
```
* addAll을 호출했을때 add라는 메소드가 Override되어있기 때문에 오버라이드한 add라는 메소드에서 addCount++을 하기때문에 6이 나왔지만
* 컴포지션을 사용한 전달 클래스에서는 단순하게 addAll을 호출하고있기 때문에 3이 나온다.



### 데코레이터 패턴 p119
* 상속이 아닌 위임을 사용해서 보다 유연하게 부가 기능을 추가 가능

![image](https://user-images.githubusercontent.com/60100532/192908078-37bd9aa2-38d9-4d83-9ee7-5b9507d0cd09.png)

### 콜백 프레임워크와 셀프 문제
* 콜백 프레임워크와 래퍼를 같이 사용했을 때 발생할 수 있는 문제
  * 콜백 함수: 다른 함수(A)의 인자로 전달된 함수(B)로, 해당 함수(A) 내부에서 필요
    한 시점에 호출 될 수는 함수 (B)를 말한다.
  * 래퍼로 감싸고 있는 내부 객체가 어떤 클래스(A)의 콜백으로(B) 사용되는 경우에
    this를 전달한다면, 해당 클래스(A)는 래퍼가 아닌 내부 객체를 호출한다. (SELF 문제)

### Sample Code
```java
interface FunctionToCall {

    void call();

    void run();
}

```

```java
class BobFunction implements FunctionToCall {

    private final Service service;

    public BobFunction(Service service) {
        this.service = service;
    }

    @Override
    public void call() {
        System.out.println("밥을 먹을까..");
    }

    @Override
    public void run() {
        this.service.run(this);
    }
}

```
```java
public class Service {

    public void run(FunctionToCall functionToCall) {
        System.out.println("뭐 좀 하다가...");
        functionToCall.call();
    }

    public static void main(String[] args) {
        Service service = new Service();
        BobFunction bobFunction = new BobFunction(service);
		bobFunction.run();
    }
}

```
* 실행 결과
* 뭐 좀 하다가...
* 밥을 먹을까..

### 위 코드에 BobFunctionWrapper를 추가해 보자.
```java
public class BobFunctionWrapper implements FunctionToCall {

    private final BobFunction bobFunction;

    public BobFunctionWrapper(BobFunction bobFunction) {
        this.bobFunction = bobFunction;
    }

    @Override
    public void call() {
        this.bobFunction.call();
        System.out.println("커피도 마실까...");
    }

    @Override
    public void run() {
        this.bobFunction.run();
    }
}
```
```java
public class Service {

    public void run(FunctionToCall functionToCall) {
        System.out.println("뭐 좀 하다가...");
        functionToCall.call();
    }

    public static void main(String[] args) {
        Service service = new Service();
        BobFunction bobFunction = new BobFunction(service);
        BobFunctionWrapper bobFunctionWrapper = new BobFunctionWrapper(bobFunction);
        bobFunctionWrapper.run();
    }
}

```


* BobFunctionWrapper를 추가하고 실행하면 어떠한 결과가 나올까?
* 뭐 좀 하다가...
* 밥을 먹을까..
* 커피도 마실까...
* 라고 출력 될까?
* 정답은 아니다.

* bobFunctionWrapper.run()을 호출하면, 
* bobFunctionWrapper의 run()이 호출되고, 
* bobFunctionWrapper의 run()에서는 bobFunction의 run()을 호출한다.
* bobFunction의 run()에서는 bobFunction의 call()을 호출한다.