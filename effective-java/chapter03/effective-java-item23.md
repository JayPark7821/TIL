# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 23. 태그 달린 클래스보다는 클래스 계층 구조를 활용하라.

### 핵심정리
* 태그 달린 클래스의 단점
  * 쓸데없는 코드가 많다.
  * 가독성이 나쁘다.
  * 메모리도 많이 사용한다.
  * 필드를 final로 선언하려면 불필요한 필드까지 초기화 해야한다.
  * 인스턴스 타입만으로는 현재 인스턴스가 나타내는 의미를 알 수 없다. ( 아래 예제 코드의 경우 모든 도형 인스턴스가 Figure 타입이다. )
* 클래스 계층 구조로 바꾸면 모든 단점 해결 가능.

```java
class Figure {
    enum Shape { RECTANGLE, CIRCLE, SQUARE };

    // 태그 필드 - 현재 모양을 나타낸다.
    final Shape shape;

    // 다음 필드들은 모양이 사각형(RECTANGLE)일 때만 쓰인다.
    double length;
    double width;

    // 다음 필드는 모양이 원(CIRCLE)일 때만 쓰인다.
    double radius;

    // 원용 생성자
    Figure(double radius) {
        shape = Shape.CIRCLE;
        this.radius = radius;
    }

    // 사각형용 생성자
    Figure(double length, double width) {
        if (this.length == this.width) {
            shape = Shape.SQUARE;
        } else {
            shape = Shape.RECTANGLE;
        }

        this.length = length;
        this.width = width;
    }

    double area() {
        switch(shape) {
            case RECTANGLE, SQUARE:
                return length * width;
            case CIRCLE:
                return Math.PI * (radius * radius);
            default:
                throw new AssertionError(shape);
        }
    }
}
```

* 위 코드를 계층 구조로 개선하면
```java
abstract class Figure {
    abstract double area();
}
```
```java
class Rectangle extends Figure {
    final double length;
    final double width;

    Rectangle(double length, double width) {
        this.length = length;
        this.width  = width;
    }
    @Override double area() { return length * width; }
}

```

```java
class Circle extends Figure {
    final double radius;

    Circle(double radius) { this.radius = radius; }

    @Override double area() { return Math.PI * (radius * radius); }
}

```
* 위 코드 처럼 계층 구조로 개선할 수 있다.
* 공통적으로 사용해야하는 area 메소드를 Figure 클래스에 정의하고, 각 도형에 맞게 구현하도록 하면 도록 한다.