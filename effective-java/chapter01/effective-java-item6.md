# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 6. 불필요한 객체 생성을 피하라

### 핵심정리
* 문자열
  * 사실상 동일한 객체라서 매번 새로 만들 필요가 없다.
  * new String("자바")을 사용하지 않고 문자열 리터럴 ("자바")을 사용해 기존에 동일한 문자열을 재사용 하는 것이 좋다.
* 정규식, Pattern
  * 생성 비용이 비싼 객체라서 반복해서 생성하기 보다, 캐싱하여 재사용하는 것이 좋다.
* 오토박싱(auto boxing)
  * 기본 타입(int)을 그에 상응하는 박싱된 기본 타입(Integer)으로 상호 변환해주는 기술.
  * 기본 타입과 박싱된 기본 타입을 섞어서 사용하면 변환하는 과정에서 불필요한 객체가 생성될 수 있다.
* "객체 생성은 비싸니 피하라"는 말은 아니다!!!


```java
public class Strings {

    public static void main(String[] args) {
        String hello = "hello";

        //TODO 이 방법은 권장하지 않습니다.
        String hello2 = new String("hello");

        String hello3 = "hello";

        System.out.println(hello == hello2); // false
        System.out.println(hello.equals(hello2)); // true
        System.out.println(hello == hello3); // true
        System.out.println(hello.equals(hello3));// true
    }
}
```

### 문자열
* JVM은 문자열을  intern pool이라는 곳에 미리 생성해두고, 필요할 때마다 그 문자열을 참조하도록 한다.
* 문자열 리터럴을 사용하면 intern pool에 이미 생성된 문자열을 참조하게 된다.
* new String("문자열")을 사용하면 intern pool에 강제로 새로운 문자열을 생성하게 된다.


### 정규표현식
* 정규표현식은 생성 비용이 비싼 객체이다.
* 정규표현식을 사용하는 경우, Pattern 인스턴스를 캐싱하여 재사용하는 것이 좋다.

```java
// 값비싼 객체를 재사용해 성능을 개선한다. (32쪽)
public class RomanNumerals {
    // 코드 6-1 성능을 훨씬 더 끌어올릴 수 있다!
    static boolean isRomanNumeralSlow(String s) {
        return s.matches("^(?=.)M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");
    }

    // 코드 6-2 값비싼 객체를 재사용해 성능을 개선한다.
    private static final Pattern ROMAN = Pattern.compile(
            "^(?=.)M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");

    static boolean isRomanNumeralFast(String s) {
        return ROMAN.matcher(s).matches();
    }

    public static void main(String[] args) {
        boolean result = false;
        long start = System.nanoTime();
        for (int j = 0; j < 100; j++) {
            //TODO 성능 차이를 확인하려면 xxxSlow 메서드를 xxxFast 메서드로 바꿔 실행해보자.
            result = isRomanNumeralSlow("MCMLXXVI");
        }
        long end = System.nanoTime();
        System.out.println(end - start);
        System.out.println(result);
    }
}
```
### 오토박싱(auto boxing)
* 오토박싱은 기본 타입과 박싱된 기본 타입을 섞어서 사용하면 변환하는 과정에서 불필요한 객체가 생성될 수 있다.

```java
public class Sum {
    private static long sum() {
        // TODO Long을 long으로 변경하여 실행
        Long sum = 0L;
        for (long i = 0; i <= Integer.MAX_VALUE; i++)
            sum += i;
        return sum;
    }

    public static void main(String[] args) {
        long start = System.nanoTime();
        long x = sum();
        long end = System.nanoTime();
        System.out.println((end - start) / 1_000_000. + " ms.");
        System.out.println(x);
    }
}
```
### 한 번 쓰고 버려져서 가비지 컬렉션 대상이 된다. p32
* 가비지 컬렉션은 메모리를 회수하는 것이 아니라, 더 이상 사용되지 않는 객체를 찾아내는 것이다.
* Mark, Sweep, Compact
  * Mark - 어떠한 object가 참조를 가지고 있는지 아닌지를 check하는 과정을 Marking이라고 한다. 
  * Sweep - Marking이 끝나면, Marking이 되지 않은 object를 찾아내서 제거하는 과정을 Sweep이라고 한다.
  * Compact - Sweep이 끝나면, 남아있는 object들을 모아서 메모리를 compact하게 정리하는 과정을 Compact라고 한다.
* Young Generation(Eden, S0, S1), Old Generation
* Serial, Parallel, CMS, G1, ZGC, Shenandoah
  