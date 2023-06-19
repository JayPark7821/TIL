# Effective-java
## 모든 객체의 공통 메서드
* Object가 제공하는 메서드를 언제 어떻게 재정의해야 하는가

### 아이템 11. equals를 재정의하려거든 hashCode도 재정의하라

### 핵심정리 - hashCode 규약
*  equals 비교에 사용하는 정보가 변경되지 않았다면 hashCode는 매번 같은 값을 리턴해야 한다.  
(변경되거나, 애플리케이션을 다시 실행 했다면 달라질 수 있다.)
* `두 객체에 대한 equals가 같다면, hashCode의 값도 같아야한다.`
* 두 객체에 대한 equals가 다르더라도, hashCode의 값은 같을 수 있지만 해시 테이블 `성능을 고려해 다른 값을 리턴하는 것이 좋다.`

### Sample Code
* hashCode가 구현되어 있지 않은 코드
```java
// equals를 재정의하면 hashCode로 재정의해야 함을 보여준다. (70-71쪽)
public final class PhoneNumber {
    private final short areaCode, prefix, lineNum;

    public PhoneNumber(int areaCode, int prefix, int lineNum) {
        this.areaCode = rangeCheck(areaCode, 999, "area code");
        this.prefix   = rangeCheck(prefix,   999, "prefix");
        this.lineNum  = rangeCheck(lineNum, 9999, "line num");
    }

    private static short rangeCheck(int val, int max, String arg) {
        if (val < 0 || val > max)
            throw new IllegalArgumentException(arg + ": " + val);
        return (short) val;
    }

    @Override public boolean equals(Object o) {
        if (o == this)
            return true;
        if (!(o instanceof PhoneNumber))
            return false;
        PhoneNumber pn = (PhoneNumber)o;
        return pn.lineNum == lineNum && pn.prefix == prefix
                && pn.areaCode == areaCode;
    }
 
    public static void main(String[] args) {
        Map<PhoneNumber, String> m = new HashMap<>();
        m.put(new PhoneNumber(707, 867, 5309), "제니");
        System.out.println(m.get(new PhoneNumber(707, 867, 5309)));
    }
}
```
```java
public class HashMapTest {

    public static void main(String[] args) {
        Map<PhoneNumber, String> map = new HashMap<>();

        PhoneNumber number1 = new PhoneNumber(123, 456, 7890);
        PhoneNumber number2 = new PhoneNumber(123, 456, 7890);

//         TODO 같은 인스턴스인데 다른 hashCode
//         다른 인스턴스인데 같은 hashCode를 쓴다면?
        System.out.println(number1.equals(number2));
        System.out.println(number1.hashCode());
        System.out.println(number2.hashCode());

        map.put(number1, "keesun");
        map.put(number2, "whiteship");

        String s = map.get(number2);
        System.out.println(s);
    }
}
```
![image](https://user-images.githubusercontent.com/60100532/209932849-f1b24d94-c0e7-43df-8988-aa5963e2d9ed.png)

* 위 코드에서 
```java
PhoneNumber number2 = new PhoneNumber(123, 456, 7890);
...
map.put(number1, "keesun");
map.put(number2, "whiteship");

String s = map.get(new PhoneNumber(123, 456, 7890));
System.out.println(s);
```
* 위 코드는 map에 들어있는 값 객체와 동일한 값 객체를 넘겼지만 null이 return 된다.
* hashMap에 넣을때 hashCode()메소드를 실행해서 어느 버켓에 넣을지 정한다음 넣는다.
* 꺼낼때도 hashCode()를 실행해서 어느 버켓에 있는지 찾고, 그 버켓에 있는 객체들을 equals로 비교해서 찾는다.
* 그래서 hashCode가 같은 객체들은 같은 버켓에 들어가고, hashCode가 다르면 다른 버켓에 들어간다.
* 그래서 위 코드에서 number1과 number2는 get으로 찾을수 있지만 
* 아무리 같은 값객체여도 hashCode가 다르기 때문에 new로 생성한 객체는 get으로 찾을수 없다.


### hash collision
* hash collision이란 해시함수가 충돌을 일으키는 것을 말한다.
* 해시함수는 같은 입력값에 대해 같은 출력값을 내야한다.
* 하지만 해시함수는 입력값이 같더라도 출력값이 다를 수 있다.
* 이러한 경우를 hash collision이라고 한다.
* hash collision이 발생하면 해시테이블의 성능이 저하된다.
* hash 버켓은 linked list로 구현되어있다 
* 즉 같은 hash값이라면 같은 버킷에 linked list로 계속 추가되기 때문에
* hash collision이 발생하면 linked list가 길어지기 때문에 성능이 저하된다.

### 핵심정리 - hashCode 구현방법
* 핵심 필드 하나의 값의 해쉬값을 계산해서 result 값을 초기화 한다.
* 기본 타입은 Type.hashCode
* 참조 타입은 해당 필드의 hashCode
* 배열은 모든 우너소를 재귀적으로 위의 로직을 적용하거나 Arrays.hashCode
* result = 31 * result + 해당 필드의 hashCode계산값
* result를 반환한다.

### 전형적인 hashCode 메서드
```java
    // 코드 11-2 전형적인 hashCode 메서드 (70쪽)
   @Override public int hashCode() {
       int result = Short.hashCode(areaCode); // 1
       result = 31 * result + Short.hashCode(prefix); // 2
       result = 31 * result + Short.hashCode(lineNum); // 3
       return result;
   }
```
* 가장 핵심 필드중에 하나는 선택 (areaCode)
* 그 핵심 필드의 해쉬값을 구한다. 
* primitive type은 wrapper 타입의 hashCode를 사용한다.
* reference는 해당 필드의 hashCode를 사용한다.
 

```java
    // 코드 11-3 한 줄짜리 hashCode 메서드 - 성능이 살짝 아쉽다. (71쪽)
   @Override public int hashCode() {
       return Objects.hash(lineNum, prefix, areaCode);
   }

```

```java

    // 해시코드를 지연 초기화하는 hashCode 메서드 - 스레드 안정성까지 고려해야 한다. (71쪽)
    private volatile int hashCode; // 자동으로 0으로 초기화된다.

    @Override public int hashCode() {
        int result = hashCode;
		
        if (result == 0) {
            result = Short.hashCode(areaCode);
            result = 31 * result + Short.hashCode(prefix);
            result = 31 * result + Short.hashCode(lineNum);
            this.hashCode = result;
        }
        return result;
        
    }

```

### hashMap 내부 Linked List
* 자바8 이전 까지는 linked list가 사용되었다. 
* 자바에서 제공하는 linked list가 아닌 hashMap 내부에 구현체가 따로있다. 
* 자바8에서 최적화가 되었다.
* 하나의 버켓에 쌓여있는 데이터가 8개가 넘어가면
* linked list가 아닌 binary tree로 구현된다. 자세히는 red-black tree