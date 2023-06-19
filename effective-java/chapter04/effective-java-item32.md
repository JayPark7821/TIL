# Effective-java
## 제네릭
* 제네릭의 장점을 살리고 단점을 최소화하는 방법

### 아이템 32. 제네릭과 가변인수를 함께 쓸 때는 신중하라.

### 핵심정리
* 제네릭 가변인수 배열에 값을 저장한느 것은 안전하지 않다.
  * 힙 오염이 발생할 수 있다.(컴파일 경고 발생)
  * 자바7에 추가된 @SafeVarargs 어노테이션을 사용할 수 있다.
* 제네릭 가변인수 배열의 참조를 밖으로 노출하면 힙 오염을 전달할 수 있다.
  * 예외적으로, @SafeVarargs를 사용한 메서드에 넘기는 것은 안전하다.
  * 예외적으로, 배열의 내용의 일부 함수를 호출하는 일반 메서드로 넘기는 것은 안전하다.
* 아이템 28의 조건에 따라 가변인수를 List로 바꾼다면
  * 배열없이 제네릭만 사용하므로 컴파일러가 타입 안정성을 보장할 수 있다.
  * @SafeVarargs 어노테이션을 사용할 필요가 없다.
  * 실수로 안전하다고 판단할 걱정도 없다.
  
```java
public class Dangerous {
    // 코드 32-1 제네릭과 varargs를 혼용하면 타입 안전성이 깨진다! (191-192쪽)
    static void dangerous(List<String>... stringLists) {
        List<Integer> intList = List.of(42);
        Object[] objects = stringLists; // 배열은 공변이기 때문에 Object[]에 List<String>[]를 대입할 수 있다.
        objects[0] = intList; // 힙 오염 발생
        String s = stringLists[0].get(0); // ClassCastException
    }

    public static void main(String[] args) {
        dangerous(List.of("There be dragons!"));
    }
}

```

```java
public class FlattenWithVarargs {

    @SafeVarargs
    static <T> List<T> flatten(List<? extends T>... lists) {
        List<T> result = new ArrayList<>();
        for (List<? extends T> list : lists)
            result.addAll(list);
        return result;
    }

    public static void main(String[] args) {
        List<Integer> flatList = flatten(
                List.of(1, 2), List.of(3, 4, 5), List.of(6,7));
        System.out.println(flatList);
    }
}
```
* 위 코드의 메서드 flatten의 매개변수를 List로 변경하여 타입의 안정성을 보장하자

```java
    static <T> List<T> flatten(List<List<? extends T>> lists) {
        List<T> result = new ArrayList<>();
        for (List<? extends T> list : lists)
            result.addAll(list);
        return result;
    }
```


### ThreadLocal
* 모든 맴버 변수는 기본적으로 여러 쓰레드에서 공유해서 쓰일 수 있다. - 이때 쓰레드 안정성과 관련된 여러 문제가 발생할 수 있다.
  * 경합 또는 경쟁조건(Race-Conditioin)
  * 교착 상태(Deadlock)
  * Livelock
* 쓰레드 지역 변수를 사용하면 동기화를 하지 않아도 한 쓰레드에서만 접근 가능한 값이기 때문에 안전하게 사용할 수 있다.
* 한 쓰레드 내에서 공유하는 데이터로, 메서드 매개변수에 매번 잔달하지 않고 전역 변수처럼 사용할 수 있다.

### ThreadLocalRandom
* java.util.Random은 멀티 쓰레드 환경에서 CAS(Compare and Set)로 인해 실패 할 가능성이 있기 때문에 성능이 좋지 않다.    
  
![image](https://github.com/JayPark7821/effective-java/assets/60100532/19983c1b-dd95-4b79-94c3-30a568114303)
* Random 대신 ThreadLocalRandom을 사용하면 해당 쓰레드 전용 Random이라 간섭이 발생하지 않는다.
