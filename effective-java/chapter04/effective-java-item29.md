# Effective-java
## 제네릭
* 제네릭의 장점을 살리고 단점을 최소화하는 방법

### 아이템 29. 이왕이면 제네릭 타입으로 만들라

### 핵심정리 
* 배열을 사용하는 코드를 제네릭으로 만들 때 해결 책 두 가지.
* 첫번쨰 방법: 제네릭 배열 (E[]) 대신에 Object 배열을 생성한 뒤에 제네릭 배열로 형변환 한다.
  * 형변환을 배열 생성시 한 번만 한다.
  * 가독성이 좋다.
  * 힙 오염이 발생할 수 있다.

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
        if (size == 0)
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

    // 코드 29-5 제네릭 Stack을 사용하는 맛보기 프로그램 (174쪽)
    public static void main(String[] args) {
        Stack<String> stack = new Stack<>();
        for (String arg : List.of("a", "b", "c"))
            stack.push(arg);
        while (!stack.isEmpty())
            System.out.println(stack.pop().toUpperCase());
    }
}

```
* 두번째 방법: 제네릭 배열 대신에 Object 배열을 사용하고, 배열이 반환한 원소를 E로 형변환 한다.
  * 원소를 읽을 떄 마다 형변환을 해줘야 한다.
 ```java
public class Stack<E> {
    private Object[] elements;
    private int size = 0;
    private static final int DEFAULT_INITIAL_CAPACITY = 16;
    
    public Stack() {
        elements = new Object[DEFAULT_INITIAL_CAPACITY];
    }

    public void push(E e) {
        ensureCapacity();
        elements[size++] = e;
    }

    // 코드 29-4 배열을 사용한 코드를 제네릭으로 만드는 방법 2 (173쪽)
    // 비검사 경고를 적절히 숨긴다.
    public E pop() {
        if (size == 0)
            throw new EmptyStackException();

        // push에서 E 타입만 허용하므로 이 형변환은 안전하다.
        @SuppressWarnings("unchecked") E result = (E) elements[--size];

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

    // 코드 29-5 제네릭 Stack을 사용하는 맛보기 프로그램 (174쪽)
    public static void main(String[] args) {
        Stack<String> stack = new Stack<>();
        for (String arg : List.of("a", "b", "c"))
            stack.push(arg);
        while (!stack.isEmpty())
            System.out.println(stack.pop().toUpperCase());
    }
}
```


### 한정적 타입 매개변수
* Bounded Type Parameters
* 매개변수화 타입을 특정한 타입으로 한정짓고 싶을 떄 사용할 수 있다.
  * `<E extends Number>` 선언할 수 있는 제네릭 타입을 Number를 상속(extends) 했거나 구현한(implements)한 클래스로 제한한다.
* 제한한 타입의 인스턴스를 만들거나, 메서드를 호출할 수도 있다.
  * `<E extends Number>` Number 타입이 제공하는 메서드를 사용할 수 있다.
* 다수의 타입으로 한정 할 수 있다. 이 떄 클래스 타입을 가장 먼저 선언해야 한다.
  *  `<E extends Number & Serializable>` 선언할 제네릭 타입은 Integer와 Number를 모두 상속 또는 구현한 타입이어야 한다.
