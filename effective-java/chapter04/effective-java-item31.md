# Effective-java
## 제네릭
* 제네릭의 장점을 살리고 단점을 최소화하는 방법

### 아이템 31. 한정적 와일드카드를 사용해 API 유연성을 높이라

### 핵심정리 1 : Chooser와 Union API 개선 
* PECS : Producer-Extends, Consumer-Super
  * Producer-Extends
    * Object의 컬렉션 Number나 Integer를 넣을 수 있다.
    * Number의 컬렉션에 Integer를 넣을 수 있다.
  * Consumer-Super
    * Integer의 컬렉션의 객체를 꺼내서 Number의 컬렉션에 담을 수 있다.
    * Number나 Integer의 컬렉션의 객체를 꺼내서 Object의 컬렉션에 담을 수 있다.

```java
public class Stack<E> {
  private E[] elements;
  private int size = 0;
  private static final int DEFAULT_INITIAL_CAPACITY = 16;

  // 코드 29-3 배열을 사용한 코드를 제네릭으로 만드는 방법 1 (172쪽)
  // 배열 elements는 push(E)로 넘어온 E 인스턴스만 담는다.
  // 따라서 타입 안전성을 보장하지만,
  // 이 배열의 런타임 타입은 E[]가 아닌 Object[]다!
  @SuppressWarnings("unchecked")
  public Stack() {
    elements = (E[]) new Object[DEFAULT_INITIAL_CAPACITY];
  }

  public void push(E e) {
    ensureCapacity();
    elements[size++] = e;
  }

  public E pop() {
    if (size==0)
      throw new EmptyStackException();
    E result = elements[--size];
    elements[size] = null; // 다 쓴 참조 해제
    return result;
  }

  public boolean isEmpty() {
    return size == 0;
  }

  private void ensureCapacity() {
    if (elements.length == size)
      elements = Arrays.copyOf(elements, 2 * size + 1);
  }

  // 코드 31-1 와일드카드 타입을 사용하지 않은 pushAll 메서드 - 결함이 있다! (181쪽)
  //    public void pushAll(Iterable<E> src) {
  //        for (E e : src)
  //            push(e);
  //    }

  // 코드 31-2 E 생산자(producer) 매개변수에 와일드카드 타입 적용 (182쪽)
  public void pushAll(Iterable<? extends E> src) {
    for (E e : src)
      push(e);
  }

  // 코드 31-3 와일드카드 타입을 사용하지 않은 popAll 메서드 - 결함이 있다! (183쪽)
  //    public void popAll(Collection<E> dst) {
  //        while (!isEmpty())
  //            dst.add(pop());
  //    }

  // 코드 31-4 E 소비자(consumer) 매개변수에 와일드카드 타입 적용 (183쪽)
  public void popAll(Collection<? super E> dst) {
    while (!isEmpty())
      dst.add(pop());
  }

  // 제네릭 Stack을 사용하는 맛보기 프로그램
  public static void main(String[] args) {
    Stack<Number> numberStack = new Stack<>();
    Iterable<Integer> integers = Arrays.asList(3, 1, 4, 1, 5, 9);
    numberStack.pushAll(integers);

    Iterable<Double> doubles = Arrays.asList(3.1, 1.0, 4.0, 1.0, 5.0, 9.0);
    numberStack.pushAll(doubles);

    Collection<Object> objects = new ArrayList<>();
    numberStack.popAll(objects);

    System.out.println(objects);
  }
}

```

### 핵심정리 2 : Comparator와 Comparable은 소비자
* Comparable을 직접 구현하지 않고, 직접 구현한 다른 타입을 확장한 타입을 지원하려면 와일드 카드가 필요하다.
* ScheduledFuture는 Comparable을 직접 구현하지 않았지만, 그 상위 타입 (Delayed)이 구현하고 있다.

### 핵심정리 3 : 와일드카드 활용 팁
* 메서드 선언에 타입 매개변수가 한 번만 나오면 와일드카드로 대체하라.
  * 한정적 타입이라면 한정적 와일드카드로
  * 비한적적 타입이라면 비한정적 와일드 카드로
* 주의
  * 비한정적 와일드카드로 정의한 타입에는 null을 제회한 아무것도 넣을 수 없다.

```java
public class Swap {
   public static void swap(List<?> list, int i, int j) {
	   list.set(i, list.set(j, list.get(i))); // error 비 한정적 와일드 카드는 어떤 타입이 올지 모르기 떄문에 null을 제외한 아무것도 넣을 수 없다.
   }
```

```java
public class Swap {
    public static <E> void swap(List<E> list, int i, int j) {
		list.set(i, list.set(j, list.get(i))); // 특정한 타입 E라고 알고 있다! 
	}
```

### 타입 추론
* 타입을 추론한느 컴파일러의 기능
* 모든 인자의 가장 구체적인 공통 타입(most specific type)
* 제네릭 메서드와 타입 추론: 메서드 매개변수를 기반으로 타입 매개변수를 추론할 수 있다. 
* 제네릭 클래스 생성자를 호출할 떄 다이아몬드 연산자 <>를 사용하면 타입을 추론한다.
* 자바 컴파일러는 "타겟 타입"을 기반으로 호출하는 제네릭 메서드의 타입 매개변수를 추론한다.
  * 자바 8에서 "타겟 타입"이 "메서드의 인자"까지 확장되면서 이전에 비해 타입 추론이 강화되었다.