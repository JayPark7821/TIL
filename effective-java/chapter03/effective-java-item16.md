# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 16. public 클래스에서는 public 필드가 아닌 접근자 메서드를 사용하라.

### 핵심정리 
* 클라이언트 코드가 필드를 직접 사용하면 캡슐화의 장점을 제공하지 못한다.
* 필드를 변경하려면 API를 변경해야 한다.
* 필드에 접근할 때 부수 작업을 할 수 없다. 
* Package-private 클래스 또는 private 중첩 클래스라면 데이터 필드를 노출해도 문제가 없다.


### 내부를 노출한 Dimesion클래스의 심각한 성능 문제는 오늘날까지도 해결되지 못했다. p103

```java
public class DimensionExample {

    public static void main(String[] args) {
        Button button = new Button("hello button");
        button.setBounds(0, 0, 20, 10);

        Dimension size = button.getSize();
        System.out.println(size.height);
        System.out.println(size.width);
    }

}
```

![image](https://user-images.githubusercontent.com/60100532/211332942-fd719a68-d21f-4c79-b73e-96581a212681.png)

* Dimension 클래스의 필드 height와 width는 public이다.
* 이 필드를 직접 사용하면 캡슐화의 장점을 제공하지 못한다.
* height와 width는 언제 어디서든 바뀔 수 있기 때문에
* 사용하는 쪽에서 복사해서 사용해야한다. -> 성능 저하

```java
public class DimensionExample {

    public static void main(String[] args) {
        Button button = new Button("hello button");
        button.setBounds(0, 0, 20, 10);

        Dimension size = button.getSize();
        System.out.println(size.height);
        System.out.println(size.width);
		
		// 만약 다른곳에 size를 넘긴다고하면
        doSomething(size);
    }
	
	private static void doSomething(Dimension size) {
		// size.width = 100;  <- 여기서 직접 size를 변경하면 다른곳에 영향을 줄 수 있기때문에
        
        Dimenion copy = new Dimension(); // 복사해서 사용해야한다.
        copy.width = size.width;
		copy.height = size.height; 
    }
}
```


