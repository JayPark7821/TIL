# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 21. 인터페이스는 구현하는 쪽을 생각해 설계하라

### 핵심정리
* 기존 인터페이스에 디폴트 메서드 구현을 추가하는 것은 위험한 일이다.
  * 디폴트 메서드는 구현 클래스에 대해 아무것도 모른채 합의 없이 무작정 "삽입" 될 뿐이다.
  * 디폴트 메서드는 기존 구현체에 런타임 오류를 일으킬 수 있다.
* 인터페이스를 설계할 때는 세심한 주의를 기울여야 한다.
  * 서로 다른 방식으로 최소한 세 가지는 구현을 해보자.
  
```java
public interface Collection<E> extends Iterable<E> {
	
	
	default boolean removeIf(Predicate<? super E> filter) {
		Objects.requireNonNull(filter);
		boolean removed = false;
		final Iterator<E> each = iterator();
		while (each.hasNext()) {
			if (filter.test(each.next())) {
				each.remove();
				removed = true;
			}
		}
		return removed;
	}
}
```
* Ex 1
* 디폴트 메소드로 굉장히 편리한 기능을 추가했다. 
  * 때문에 해당 interface인 Collection을 구현한 모든 클래스에서 해당 메소드 removeIf를 사용할 수 있게 되었다.
  * 하지만 한가지 예로 SyncronizedCollection의 경우 removeIf를 사용하면 문제가 발생할 수 있다. 해당 클래스는 모든 매소드를    
   동기화를 통해 멀티 쓰레드 환경에서 오직 한 쓰레드만 동작하게 해야하는데 removeIf는 동기화를 지원하지 않는다. (ConcurrentModificationException이 발생할 수 있다.)

* Ex 2  
```java
public interface MarkerInterface {

	default void hello() {
		System.out.println("hello interface");
	}
}
```

```java
public class SuperClass {

	private void hello() {
		System.out.println("hello class");
	}
}

```

```java

public class SubClass extends SuperClass implements MarkerInterface {

	public static void main(String[] args) {
		SubClass subClass = new SubClass();
		subClass.hello();
	}

}

```

* 위 코드를 실행하면 에러가 발생한다.
> `Exception in thread "main" java.lang.IllegalAccessError: class com.tripbook.main.global.entity.item21.SubClass tried to access private method 'void com.tripbook.main.global.entity.item21.SuperClass.hello()' (com.tripbook.main.global.entity.item21.SubClass and com.tripbook.main.global.entity.item21.SuperClass are in unnamed module of loader 'app')
  at com.tripbook.main.global.entity.item21.SubClass.main(SubClass.java:7)`

* 만약 hello 라는 디폴트 메소드가 MarkerInterface에 정의되어 있지 않았다면 SuperClass의 hello 메소드를 호출할 수 없다. private 이기때문에
* 하지만 MarkerInterface에 hello 메소드가 정의되어 있기 때문에 개발자는 인터페이스의 디폴트 메소드를 호출하길 원해 hello메소드를 호출했지만
* 위 와같은 에러가 발생한다. 


* ConcurrentModificationException
* https://docs.oracle.com/javase/8/docs/api/java/util/ConcurrentModificationException.html
```java

public class FailFast {

	public static void main(String[] args) {
		//        List<Integer> numbers = List.of(1, 2, 3, 4, 5);

		List<Integer> numbers = new ArrayList<>();
		numbers.add(1);
		numbers.add(2);
		numbers.add(3);
		numbers.add(4);
		numbers.add(5);

       // for (Integer number : numbers) {
       //     if (number == 3) {
       //         numbers.remove(number);
       //     }
       // }
       // -> ConcurrentModificationException 발생 
	   
		// removeIf 사용하기
       numbers.removeIf(number -> number == 3);
 
		numbers.forEach(System.out::println);
	}
}

```