# Effective-java
## 모든 객체의 공통 메서드
* Object가 제공하는 메서드를 언제 어떻게 재정의해야 하는가

### 아이템 14. Comparable을 구현할지 고민하라. 

### 핵심정리 - CompareTo 규약
* Object.equals에 더해서 순서까지 비교할 수 있으면 Generic을 지원한다.
* 자기 자신(this)이 compareTo에 전달된 객체보다 작으면 음수, 같으면 0, 크면 양수를 리턴한다.
* 반사성, 대칭성, 추이성을 만족해야 한다.
* 반드시 따라야 하는 것은 아니지만 x.compareTo(y) == 0 이라면 x.equals(y)가 true여야 한다.

![image](https://user-images.githubusercontent.com/60100532/210573537-5df33da4-7dc4-48da-aaa4-ad1e1695a762.png)

### Sample Code
```java

public class CompareToConvention {

    public static void main(String[] args) {
        BigDecimal n1 = BigDecimal.valueOf(23134134);
        BigDecimal n2 = BigDecimal.valueOf(11231230);
        BigDecimal n3 = BigDecimal.valueOf(53534552);
        BigDecimal n4 = BigDecimal.valueOf(11231230);

        // p88, 반사성
        System.out.println(n1.compareTo(n1));  // 0

        // p88, 대칭성
        System.out.println(n1.compareTo(n2)); // 1
        System.out.println(n2.compareTo(n1)); // -1

        // p89, 추이성
        System.out.println(n3.compareTo(n1) > 0); //true
        System.out.println(n1.compareTo(n2) > 0); //true
        System.out.println(n3.compareTo(n2) > 0); //true

        // p89, 일관성
        System.out.println(n4.compareTo(n2)); 
        System.out.println(n2.compareTo(n1));
        System.out.println(n4.compareTo(n1));

        // p89, compareTo가 0이라면 equals는 true여야 한다. (아닐 수도 있고..)
        BigDecimal oneZero = new BigDecimal("1.0");
        BigDecimal oneZeroZero = new BigDecimal("1.00");
        System.out.println(oneZero.compareTo(oneZeroZero)); // Tree, TreeMap
        System.out.println(oneZero.equals(oneZeroZero)); // 순서가 없는 콜렉션
    }
}
```
![image](https://user-images.githubusercontent.com/60100532/210575053-bdf4f942-79dd-4403-a90b-1eb258c1e027.png)



### 핵심정리 - CompareTo 구현 방법 1
* 자연적인 순서를 제공할 클래스에 implements Compratable<T> 을 선언한다.
* compareTo 메서드를 재정의한다.
* comprareTo 메서드 안에서 기본 타입은 박싱된 기본 타입의 compare을 사용 해 비교한다.
* 핵심 필드가 여러 개라면 비교 순서가 중요하다. 순서를 결정하는데 있어서 가장   
 중요한 필드를 비교하고 그 값이 0이라면 다음 필드를 비교한다.
* 기존 클래스를 확장하고 필드를 추가하는 경우 compareTo 규약을 지킬 수 없다.
* Composition을 활용할 것.

```java
// PhoneNumber를 비교할 수 있게 만든다. (91-92쪽)
public final class PhoneNumber implements Cloneable, Comparable<PhoneNumber> {
    private final short areaCode, prefix, lineNum;
 
    ...
  
    // 코드 14-2 기본 타입 필드가 여럿일 때의 비교자 (91쪽)
    @Override
    public int compareTo(PhoneNumber pn) {
        int result = Short.compare(areaCode, pn.areaCode);
        if (result == 0)  {
            result = Short.compare(prefix, pn.prefix);
            if (result == 0)
                result = Short.compare(lineNum, pn.lineNum);
        }
        return result;
    }
}
```

### 만약에 상속을 받았다면?!!!
```java
public class Point implements Comparable<Point>{

    final int x, y;
 
    @Override
    public int compareTo(Point point) {
        int result = Integer.compare(this.x, point.x);
        if (result == 0) {
            result = Integer.compare(this.y, point.y);
        }
        return result;
    }
}
```

### 상속을 통해 구현하는 방법은 추천하지 않는다.!!!
```java
public class NamedPoint extends Point {

    final private String name;

    public NamedPoint(int x, int y, String name) {
        super(x, y);
        this.name = name;
    }

	@Override
	public String toString() {
		return "NamedPoint{" +
			"name='" + name + '\'' +
			", x=" + x +
			", y=" + y +
			'}';
	}
	
    public static void main(String[] args) {
        NamedPoint p1 = new NamedPoint(1, 0, "keesun");
        NamedPoint p2 = new NamedPoint(1, 0, "whiteship");

        Set<NamedPoint> points = new TreeSet<>(new Comparator<NamedPoint>() {
            @Override
            public int compare(NamedPoint p1, NamedPoint p2) {
                int result = Integer.compare(p1.getX(), p2.getX());
                if (result == 0) {
                    result = Integer.compare(p1.getY(), p2.getY());
                }
                if (result == 0) {
                    result = p1.name.compareTo(p2.name);
                }
                return result;
            }
        });

        points.add(p1);
        points.add(p2);

        System.out.println(points);
    }

}
```

### Composition을 통해 해결해 보자.

```java
public class NamedPoint implements Comparable<NamedPoint> {

    private final Point point;
    private final String name;

    public NamedPoint(Point point, String name) {
        this.point = point;
        this.name = name;
    }

    public Point getPoint() {
        return this.point;
    }

    @Override
    public int compareTo(NamedPoint namedPoint) {
        int result = this.point.compareTo(namedPoint.point);
        if (result == 0) {
            result = this.name.compareTo(namedPoint.name);
        }
        return result;
    }
}
```

### 핵심정리 - CompareTo 구현 방법 2
* 자바 8부터 함수형 인터페이스, 람다, 메서드 레퍼런스와 Comprator가 제공하는   
기본 메서드와 static 메서드를 사용해서 Comprator를 구현할 수 있다.
  * Comparator가 제공하는 메서드 사용하는 방법
  * Comparator의 static 메서드를 사용해서 Comparator 인스턴스 만들기
  * 인스턴스를 만들었다면 default 메서드를 사용해서 메서드 호출 이어가기 (체이닝)
  * static 메서드와 default 메소드의 매개변수로는 람다 표현식 또는 메서드 레퍼런스를 사용할 수 있다.


```java

public final class PhoneNumber implements Cloneable, Comparable<PhoneNumber> {
	private final short areaCode, prefix, lineNum;
 
    ...

	// 코드 14-2 기본 타입 필드가 여럿일 때의 비교자 (91쪽)
	// @Override
	// public int compareTo(PhoneNumber pn) {
	// 	int result = Short.compare(areaCode, pn.areaCode);
	// 	if (result == 0)  {
	// 		result = Short.compare(prefix, pn.prefix);
	// 		if (result == 0)
	// 			result = Short.compare(lineNum, pn.lineNum);
	// 	}
	// 	return result;
	// }

	// 코드 14-3 비교자 생성 메서드를 활용한 비교자 (92쪽)
	private static final Comparator<PhoneNumber> COMPARATOR =
		comparingInt((PhoneNumber pn) -> pn.areaCode)
			.thenComparingInt(pn -> pn.getPrefix())
			.thenComparingInt(pn -> pn.lineNum);

	   @Override
	   public int compareTo(PhoneNumber pn) {
	       return COMPARATOR.compare(this, pn);
	   }
	
}


```