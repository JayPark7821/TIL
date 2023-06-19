# Effective-java
## 모든 객체의 공통 메서드
* Object가 제공하는 메서드를 언제 어떻게 재정의해야 하는가

### 아이템 13. clone 재정의는 주의해서 진행하라. 

### 핵심정리 - 애매모호한 clone 규약
* clone 규약
  * x.clone() != x 반드시 true
  * x.clone().getClass() == x.getClass() 반드시 true
  * x.clone().equals(x) true가 아닐 수도 있다.
* 불변 객체라면 다음으로 충분하다. 
  * Cloneable 인터페이스를 구현하고
  * clone 메서드를 재정의한다. 이때 super.clone()을 사용해야 한다.

### Sample Code
```java
 public static void main(String[] args) {
        PhoneNumber pn = new PhoneNumber(707, 867, 5309);
        Map<PhoneNumber, String> m = new HashMap<>();
        m.put(pn, "제니");
        PhoneNumber clone = pn.clone();
        System.out.println(m.get(clone));

        System.out.println(clone != pn); // 반드시 true
        System.out.println(clone.getClass() == pn.getClass()); // 반드시 true
        System.out.println(clone.equals(pn)); // true가 아닐 수도 있다.
    }
```

### 핵심정리 - 가변 객체의 clone 구현하는 방법
* 접근 제한자는 public 반환 타입은 자신의 클래스로 변경한다.
* super.clone()을 호출한 다음 필요한 필드를 수정한다.
  * 배열을 복제할 때는 배열의 clone 메서드를 사용하라.
  * 경우에 따라 final을 사용할 수 없을지도 모른다. 
  * 필요한 경우 deep copy를 해야한다. 
  * super.clone으ㅗ 객체를 만든 뒤, 고수준 메서드를 호출하는 방법도 있다. 
  * 오버라이딩 할 수 있는 메서드는 참조하지 않도록 조심해야 한다.
  * 상속용 클래스는 Cloneable을 구현하지 않는 것이 좋다. 
  * Cloneable을 구현한 스레드 안전 클래스를 작성할 때는 동기화를 해야 한다.

### Sample Code
```java
// Stack의 복제 가능 버전 (80-81쪽)
public class Stack implements Cloneable {
    private Object[] elements;
    private int size = 0;
    private static final int DEFAULT_INITIAL_CAPACITY = 16;

    public Stack() {
        this.elements = new Object[DEFAULT_INITIAL_CAPACITY];
    }

    public void push(Object e) {
        ensureCapacity();
        elements[size++] = e;
    }
    
    public Object pop() {
        if (size == 0)
            throw new EmptyStackException();
        Object result = elements[--size];
        elements[size] = null; // 다 쓴 참조 해제
        return result;
    }

    public boolean isEmpty() {
        return size ==0;
    }

    // 코드 13-2 가변 상태를 참조하는 클래스용 clone 메서드
    // TODO stack -> elementsS[0, 1]
    // TODO copy -> elementsC[0, 1]
    // TODO elementsS[0] == elementsC[0]

    @Override public Stack clone() {
        try {
            Stack result = (Stack) super.clone();
            result.elements = elements.clone();
            return result;
        } catch (CloneNotSupportedException e) {
            throw new AssertionError();
        }
    }

    // 원소를 위한 공간을 적어도 하나 이상 확보한다.
    private void ensureCapacity() {
        if (elements.length == size)
            elements = Arrays.copyOf(elements, 2 * size + 1);
    }
    
    // clone이 동작하는 모습을 보려면 명령줄 인수를 몇 개 덧붙여서 호출해야 한다.
    public static void main(String[] args) {
        Object[] values = new Object[2];
        values[0] = new PhoneNumber(123, 456, 7890);
        values[1] = new PhoneNumber(321, 764, 2341);

        Stack stack = new Stack();
        for (Object arg : values)
            stack.push(arg);

        Stack copy = stack.clone();

        System.out.println("pop from stack");
        while (!stack.isEmpty())
            System.out.println(stack.pop() + " ");

        System.out.println("pop from copy");
        while (!copy.isEmpty())
            System.out.println(copy.pop() + " ");

        System.out.println(stack.elements[0] == copy.elements[0]);
    }
}
```

### clone 재정의는 주의해서 진행하라.
* p89. 비검사 예외(Unchecked Exception)였어야 했다는 신호다.
* P81. HashTable과 LinkedList
* P83. 깊은 복사 (deep copy)
* p85. clone 메서드 역시 적절히 동기화 해줘야 한다.
* p86. TreeSet


### UncheckedException
* 왜 우리는 비검사 예외를 선호하는가?
  * 컴파일 에러를 신경쓰지 않아도 되며,
  * try-catch로 감싸거나
  * 메서드 선언부에 선언하지 않아도 된다. 
  * 그렇다면 우리는 비검사 예외만 쓰면 되는걸까? 검사 예외는 왜 있는 걸까?
  
* 그렇다면 우리는 비검사 예외만 쓰면 되는 걸까?
  * 왜 잡지 않은 예외를 메서드에 선언해야 하는가?
    * 메서드에 선언한 예외는 프로그래밍 인터페이스의 일부다. 즉 해당 메서드를 사용하는 코드가 반디스 알아야 하는 정보다. 그래야 해당 예외가 발생했을 상황에 대처하는 코드를 작성할 수 있을 테니까
  * 비검사 예외는 그럼 왜 메서드에 선언하지 않아도 되는가?
    * 비검사 예외는 어떤 식으로든 처리하거나 복구할 수 없는 경우에 사용하는 예외다.    
     가령 숫자를 0으로 나누거나. null 레퍼런스에 메서드를 호출하는 등.
    * 이런 예외는 프로그램 전반에 걸쳐 어디서든 발생할 수 있기 때문에 이 모든 비검사 예외를 메서드에 선언하도록 강제한다면 프로그램의 명확도가 떨어진다. 
    
  