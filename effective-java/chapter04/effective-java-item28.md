# Effective-java
## 제네릭
* 제네릭의 장점을 살리고 단점을 최소화하는 방법

### 아이템 28. 배열보다는 리스트를 사용하라.

### 핵심정리 - 배열과 제네릭은 잘 어울리지 않는다.
* 배열은 공변 (covariant), 제네릭은 불공변
* 배열은 실체화(reify) 되지만, 제네릭은 실체화 되지 않는다.(소거)
* new Generic<타입>[배열]은 컴파일 할 수 없다.
* 제네릭 소거: 원소의 타입을 컴파일 타임에만 검사하며 런타임에는 알 수 없다.

```java
public class IntegerToString {

    public static void main(String[] args) {
        // 공변
        Object[] anything = new String[10];
        anything[0] = 1; 
		// anything은 문자열의 배열이지만 1이라는 숫자를 넣어도 컴파일 에러가 발생하지 않는다.
        // 공변이기 때문에!! 

        // 불공변
        List<String> names = new ArrayList<>();
        // List<Object> objects = names;
        // List<String> 은 List<Object>와 다르다!!!!!!
        // 제네릭은 소거된다. List로 -> 제네릭이 없던 자바 하위버전 지원 떄문에 
  
    }
}
```

### @SafeVarargs
* 생성자와 메서드의 제네릭 가변인자에 사용할 수 있는 애노테이션
  * 제네릭 가변인자는 근본적으로 타입 안전하지 않다.( 가변인자가 배열이니까, 제네릭 배열과 같은 문제)
  * 가변 인자 (배열)의 내부 데이터가 오염될 가능성이 있다.
  * @SafeVarargs를 사용하면 가변 인자에 대한 해당 오염에 대한 경고를 숨길 수 있다.

```java
public class SafeVaragsExample {

//    @SafeVarargs // Not actually safe!
    static void notSafe(List<String>... stringLists) { // -> List<String>[] stringLists 로 변경 가능
        Object[] array = stringLists; // List<String>... => List[], 그리고 배열은 공변이니까.
        List<Integer> tmpList = List.of(42);
        array[0] = tmpList; // Semantically invalid, but compiles without warnings
        String s = stringLists[0].get(0); // Oh no, ClassCastException at runtime!
    }

    @SafeVarargs //-> Possible heap pollution from parameterized vararg type 경고
    static <T> void safe(T... values) {
        for (T value: values) {
            System.out.println(value);
        }
    }

    public static void main(String[] args) {
        SafeVaragsExample.safe("a", "b", "c");
        SafeVaragsExample.notSafe(List.of("a", "b", "c"));
    }

}
```