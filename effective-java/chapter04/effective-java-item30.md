# Effective-java
## 제네릭
* 제네릭의 장점을 살리고 단점을 최소화하는 방법

### 아이템 30. 이왕이면 제네릭 메서드로 만들라

### 핵심정리 
* 매개변수화 타입을 받는 정적 유틸리티 메서드
  * 한정적 와일드카드 타입을 사용하면 더 유연하게 개선할 수 있다.
* 제네릭 싱글턴 팩터리
  * (소거 방식이기 떄문에) 불변 객체 하나를 어떤 타입으로든 매개변수화 할 수 있다.
* 재귀적 타입 한정
  * 자기 자신이 들어간 표현식을 사용하여 타입 매개변수의 허용 범위를 한정한다.
  

* 제네릭 메서드 example
```java
public class Union {

    //  제네릭 메서드 (177쪽)
    public static <E> Set<E> union(Set<E> s1, Set<E> s2) {
        Set<E> result = new HashSet<>(s1);
        result.addAll(s2);
        return result;
    }
 
    public static void main(String[] args) {
        Set<String> guys = Set.of("톰", "딕", "해리");
        Set<String> stooges = Set.of("래리", "모에", "컬리");
//        Set<Integer> stooges = Set.of(1, 2, 3);
        Set<String> all = union(guys, stooges);

        for (String o : all) {
            System.out.println(o);
        }
    }
}

```

* 제네릭 싱글턴 팩터리 example
* before
```java
public class GenericSingletonFactory {

    public static Function<String, String> stringIdentityFunction() {
        return (t) -> t;
    }

    public static Function<Number, Number> integerIdentityFunction() {
        return (t) -> t;
    }

    // 코드 30-5 제네릭 싱글턴을 사용하는 예 (178쪽)
    public static void main(String[] args) {
        String[] strings = { "삼베", "대마", "나일론" };
        Function<String, String> sameString = stringIdentityFunction();
        for (String s : strings)
            System.out.println(sameString.apply(s));

        Number[] numbers = { 1, 2.0, 3L };
        Function<Number, Number> sameNumber = integerIdentityFunction();
        for (Number n : numbers)
            System.out.println(sameNumber.apply(n));
    }
}

```
* after
```java
public class GenericSingletonFactory {
    // 제네릭 싱글턴 팩터리 패턴 (178쪽)
    private static UnaryOperator<Object> IDENTITY_FN = (t) -> t;

    @SuppressWarnings("unchecked")
    public static <T> UnaryOperator<T> identityFunction() {
        return (UnaryOperator<T>) IDENTITY_FN;
    }

    //  제네릭 싱글턴을 사용하는 예 (178쪽)
    public static void main(String[] args) {
        String[] strings = { "삼베", "대마", "나일론" };
        UnaryOperator<String> sameString = identityFunction();
        for (String s : strings)
            System.out.println(sameString.apply(s));

        Number[] numbers = { 1, 2.0, 3L };
        UnaryOperator<Number> sameNumber = identityFunction();
        for (Number n : numbers)
            System.out.println(sameNumber.apply(n));
    }
}
```

* 재귀적 타입 한정 example
```java
// 재귀적 타입 한정을 이용해 상호 비교할 수 있음을 표현 (179쪽)
public class RecursiveTypeBound {
    //   컬렉션에서 최댓값을 반환한다. - 재귀적 타입 한정 사용 (179쪽)
    public static <E extends Comparable<E>> E max(Collection<E> c) {
        if (c.isEmpty())
            throw new IllegalArgumentException("컬렉션이 비어 있습니다.");

        E result = null;
        for (E e : c)
            if (result == null || e.compareTo(result) > 0)
                result = Objects.requireNonNull(e);

        return result;
    }

    public static void main(String[] args) {
        List<String> argList = List.of("keesun", "whiteship");
        System.out.println(max(argList));
    }
}

```