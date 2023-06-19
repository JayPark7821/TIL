# Effective-java
## 모든 객체의 공통 메서드
* Object가 제공하는 메서드를 언제 어떻게 재정의해야 하는가

### 아이템 10. equals는 일반 규약을 지켜 재정의하라

### 핵심정리 - equals를 재정의 하지 않는 것이 최선
* 다음의 경우에 해당한다면 equals를 재정의 할 필요가 없다.
  * 각 인스턴스가 본질적으로 고유하다.
  * 인스턴스의 논리적 동치성을 검사할 필요가 없다.
  * 상위 클래스에서 재정의한 equals가 하위 클래스에도 딱 들어맞는다.
  * 클래스가 private이거나 package-private이고 equals 메서드를 호출할 일이 없다.

---
### 핵심정리 - equals 규약
* 반사성 : A.equals(A) == true
* 대칭성 : A.equals(B) == B.equals(A)
  * CaseInsensitiveString
* 추이성 : A.equals(B) && B.equals(C), A.equals(C)
  * Point, ColorPoint(inherit), CounterPointer, ColorPoint(comp)
* 일관성 : A.equals(B) == A.equals(B)
* null이 아님 : A.equals(null) == false

### 대칭성 Sample Code
```java
// 코드 10-1 잘못된 코드 - 대칭성 위배! (54-55쪽)
public final class CaseInsensitiveString {
    private final String s;

    public CaseInsensitiveString(String s) {
        this.s = Objects.requireNonNull(s);
    }

//     대칭성 위배!
    @Override public boolean equals(Object o) {
        if (o instanceof CaseInsensitiveString)
            return s.equalsIgnoreCase(
                    ((CaseInsensitiveString) o).s);
        if (o instanceof String)  // 한 방향으로만 작동한다!
            return s.equalsIgnoreCase((String) o);
        return false;
    }

    // 문제 시연 (55쪽)
    public static void main(String[] args) {
        CaseInsensitiveString cis = new CaseInsensitiveString("Polish");
//        CaseInsensitiveString cis2 = new CaseInsensitiveString("polish");
        String polish = "polish";
        System.out.println(cis.equals(polish)); // true
        System.out.println(polish.equals(cis)); // false
        // System.out.println(cis2.equals(cis));

        List<CaseInsensitiveString> list = new ArrayList<>();
        list.add(cis);

        System.out.println(list.contains(polish)); // false
    }

    // 수정한 equals 메서드 (56쪽)
   @Override public boolean equals(Object o) {
       return o instanceof CaseInsensitiveString &&
               ((CaseInsensitiveString) o).s.equalsIgnoreCase(s);
   }
}
```

### 추이성 Sample Code
```java
// 단순한 불변 2차원 정수 점(point) 클래스 (56쪽)
public class Point {

    private final int x;
    private final int y;

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    @Override
    public boolean equals(Object o) {
      if (!(o instanceof Point)) {
        return false;
      }
  
      Point p = (Point) o;
      return p.x == x && p.y == y;
    }

    public static void main(String[] args) {
        Point point = new Point(1, 2);
        List<Point> points = new ArrayList<>();
        points.add(point);
        System.out.println(points.contains(new Point(1, 2)));
    }
 
}
```
```java
public enum Color { RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET }
```
```java 
// Point에 값 컴포넌트(color)를 추가 (56쪽)
public class ColorPoint extends Point {
  private final Color color;

  public ColorPoint(int x, int y, Color color) {
    super(x, y);
    this.color = color;
  }

}
```
* int x,y 값을 가지고 있는 Point에서 아래와 같이 equals를 정의했을때
```java
@Override 
public boolean equals(Object o) {
    if (!(o instanceof Point)) {
        return false;
    }

    Point p = (Point) o;
    return p.x == x && p.y == y;
}
```
* Point를 상속받는 ColorPoint에서 equals를 아래와 같이 정의하면
```java

  // 코드 10-2 잘못된 코드 - 대칭성 위배! (57쪽)
@Override 
public boolean equals(Object o) {
   if (!(o instanceof ColorPoint))
       return false;
   return super.equals(o) && ((ColorPoint) o).color == color;
}
```
* 대칭성이 위배된다.
* 단순하게 생각해서 부모클래스에서 정의한 x,y비교하는 로직에 color를 추가하면 된다고 생각할 수 있지만
* Point와 ColorPoint를 비교하면 대칭성을 깨뜨린다.
* Point입장에서 ColorPoint와 비교하면 color를 무시하고 비교해 x,y값만 같으면 true를 반환하지만
* ColorPoint입장에서 Point와 비교하면 x,y값도 같아야 하고 color값도 같아야 true를 반환하기 때문이다.

```java
// 코드 10-3 잘못된 코드 - 추이성 위배! (57쪽)
@Override 
public boolean equals(Object o) {
  if (!(o instanceof Point))
    return false;

  // o가 일반 Point면 색상을 무시하고 비교한다.
  if (!(o instanceof ColorPoint))
    return o.equals(this);

  // o가 ColorPoint면 색상까지 비교한다.
  return super.equals(o) && ((ColorPoint) o).color == color;
}
```
* 이제 위와 같이 정의하면서 ColorPoint에서 Color까지 비교가 가능해졌다.
* 하지만 위와같은 코드는 굉장히 위험한 코드이다!
* Point를 상속받은 ColorPoint와 같은 레벨에 있는 다른 클래스가 생긴다면? 문제가 생긴다!!
* 또한 위 코드는 추이성에 위배된다.


```java
    public static void main(String[] args) {
        ColorPoint p1 = new ColorPoint(1, 2, Color.RED);
        Point p2 = new Point(1, 2);
        ColorPoint p3 = new ColorPoint(1, 2, Color.BLUE);
        System.out.printf("%s %s %s%n",
                          p1.equals(p2), p2.equals(p3), p1.equals(p3));
    }
```
* 위 코드를 실행하면 false true false가 출력된다.
* p1.equals(p2) -> true
  * p1과 p2는 같은 x,y값을 가지고 있고 
  * p1은 Color.RED를 가지고 있고 p2는 Color가 없다
  * 새로 추가한 `if (!(o instanceof ColorPoint)) return o.equals(this);` 로직 때문에 `true`를 return한다.
  
* p2.equals(p3) -> true
  * p2와 p3는 같은 x,y값을 가지고 있고
  * p2는 Color가 없고 p3는 Color.BLUE를 가지고 있다.
  * Point에서 재정의한 equals에서는 x,y값만 비교하기 때문에  `true`를 return한다.

* p1.equals(p3) -> false
  * p1과 p3는 같은 x,y값을 가지고 있지만
  * color값은 서로 다른 값을 가지고 있어 `false`를 return한다.

* 결국 추이성에 위배 된다.

* 이를 해결하기 위해 Point의 equals를 아래와 같이 재정의 한다면 
* Object의 getClass()를 통해 클래스끼리 같은지 비교해볼까? 라고 생각할 수 있다.
```java
    // 잘못된 코드 - 리스코프 치환 원칙 위배! (59쪽)
@Override 
public boolean equals(Object o) {
   if (o == null || o.getClass() != getClass())
       return false;
   Point p = (Point) o;
   return p.x == x && p.y == y;
}
```
* 다음 Sample Code를 보자
```java
// Point의 평범한 하위 클래스 - 값 컴포넌트를 추가하지 않았다. (59쪽)
public class CounterPoint extends Point {
    private static final AtomicInteger counter =
            new AtomicInteger();

    public CounterPoint(int x, int y) {
        super(x, y);
        counter.incrementAndGet();
    }
    public static int numberCreated() { return counter.get(); }
}
```
* Point를 상속받은 CounterPoint가 추가 되었을때 문제가 생기기 시작한다.

```java

// CounterPoint를 Point로 사용하는 테스트 프로그램
public class CounterPointTest {
    // 단위 원 안의 모든 점을 포함하도록 unitCircle을 초기화한다. (58쪽)
    private static final Set<Point> unitCircle = Set.of(
            new Point( 1,  0), new Point( 0,  1),
            new Point(-1,  0), new Point( 0, -1));

    public static boolean onUnitCircle(Point p) {
        return unitCircle.contains(p);
    }

    public static void main(String[] args) {
        Point p1 = new Point(1,  0);
        Point p2 = new CounterPoint(1, 0);

        // true를 출력한다.
        System.out.println(onUnitCircle(p1));

        // true를 출력해야 하지만, Point의 equals가 getClass를 사용해 작성되었다면 그렇지 않다.
        System.out.println(onUnitCircle(p2));
    }
}
```
* Point의 equals를 정의할때 `   if (o == null || o.getClass() != getClass())
  return false;` 라고 정의해서 CounterPoint를 Point와 equals하면 false를 return하게 되어있다.
---
* 결론적으로 `구체 클래스를 확장해 새로운 값을 추가하면서 equals 규약을 만족시킬 방법은 존재하지 않는다`
---
```java
public class EqualsInJava extends Object {

    public static void main(String[] args) throws MalformedURLException {
        long time = System.currentTimeMillis();
        Timestamp timestamp = new Timestamp(time);
        Date date = new Date(time);

        // 대칭성 위배! P60
        System.out.println(date.equals(timestamp)); // true
        System.out.println(timestamp.equals(date)); // false
    }
}
```
* equals규약을 만족시키면서 값을 추가하는 방법은 아래와 같이 composition(위임)을 사용하는 것이다.
```java
// 코드 10-5 equals 규약을 지키면서 값 추가하기 (60쪽)
public class ColorPoint {
    private final Point point;
    private final Color color;

    public ColorPoint(int x, int y, Color color) {
        point = new Point(x, y);
        this.color = Objects.requireNonNull(color);
    }

    /**
     * 이 ColorPoint의 Point 뷰를 반환한다.
     */
    public Point asPoint() {
        return point;
    }

    @Override public boolean equals(Object o) {
        if (!(o instanceof ColorPoint))
            return false;
        ColorPoint cp = (ColorPoint) o;
        return cp.point.equals(point) && cp.color.equals(color);
    }

    @Override public int hashCode() {
        return 31 * point.hashCode() + color.hashCode();
    }
}
```
### 일관성
* A.equals(B) == true 이면 몇번을 호출해도 A.equals(B) == true 이어야 한다.
* 클래스가 불변이든 가변이든 equals의 판단에 신뢰할 수 없는 자원이 끼어들게 해서는 안 된다. 
```java
public class EqualsInJava extends Object {

    public static void main(String[] args) throws MalformedURLException {
        long time = System.currentTimeMillis();
        Timestamp timestamp = new Timestamp(time);
        Date date = new Date(time);
		
        // 일관성 위배 가능성 있음. P61
        URL google1 = new URL("https", "about.google", "/products/");
        URL google2 = new URL("https", "about.google", "/products/");
        System.out.println(google1.equals(google2));
    }
}
```
---
### 핵심정리 - equals 구현 방법
* == 연산자를 사용해 입력이 자기 자신의 참조인지 확인한다.
* instanceof 연산자로 입력이 올바른 타입인지 확인한다.
* 입력을 올바른 타입으로 형변환한다.
* 입력 객체와 자기 자신의 대응되는 핵심 필드가 일치하는지 확인한다.  

<br />  

* 구글의 AutoValue 또는 lombok을 사용한다.
* IDE의 코드 생성 기능을 사용한다.

```java
public class Point{
  private final int x;
  private final int y;
  
  public Point(int x, int y){
    this.x = x;
    this.y = y;
  }
  
  @Override
  public boolean equals(Object o){
    if (this == 0) {
      return true; // 객체의 반사성(동일성) 확인.
    }
	
	if(!(o instanceof Point)){
      return false; // 입력이 올바른 타입인지 확인.
    }
	
    Point p = (Point) o; // 위에서 instanceof로 확인했으므로 100% 안전
	
    return p.x == x && p.y == y; // 입력 객체와 자기 자신의 대응되는 핵심 필드가 일치하는지 확인.
  }
}
```
* 핵심 필드가 일치한는지 확인할때 주의할점
  * float와 double을 제외한 기본 타입 필드는 == 연산자로 비교
  * 참조 타입 필드는 equals 메서드로 비교
  * float와 double은 정적 메서드인 Float.compare와 Double.compare를 사용해 비교

---

### 핵심정리 - 주의사항
* equals를 재정의 할 때 hashCode도 반드시 재정의 하자.
* 너무 복잡하게 해결하지 말자.
* Object가 아닌 타입의 매개변수를 받는 equals 메서드는 선언하지 말자.


