# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 24. 멤버 클래스는 되도록 static으로 만들라.

### 핵심정리
* 네 종류의 중첩 클래스와 각각의 쓰임  
  
* 정적 멤버 클래스
  * 바깥 클래스와 함께 쓰일 때만 유용한 public 도우미 클래스 예) Calculator.Operation.PLUS
* 비 정적 멤버 클래스
  * 바깥 클래스의 인스턴스와 암묵정으로 연결된다.
  * 어댑터를 정의할 떄 자주 쓰인다.
  * 멤버 클래스에서 바깥 인스턴스를 참조할 필요가 없다면 무조건 정적 멤버 클래스로 만들자.
* 익명 클래스
  * 바깥 클래스의 멤버가 아니며, 쓰이는 시점과 동시에 인스턴스가 만들어진다.
  * 비정적인 문맥에서 사용될 때만 바깥 클래스의 인스턴스를 참조할 수 있다.
  * 자바에서 람다를 지원하기 전에 즉석엥서 작은 함수나 객체나 처리 객체를 만들 떄 사용했다.
  * 정적 팩터리 메서드를 만들 떄 사용할 수도 있다.
* 지역 클래스
  * 가장 드물게 사용된다.
  * 지역 변수를 선언하는 곳이면 어디든 지역 클래스를 정의해 사용할 수 있다.
  * 가독성을 위해 짧게 작성해야 한다.
  

* 정적 멤버 클래스
```java

public class OutterClass {

    private static int number = 10;

    static private class InnerClass {
        void doSomething() {
            System.out.println(number);
          // 정적 멤버 클래스는 바깥 클래스의 static 필드에 접근 가능
        }
    }

    public static void main(String[] args) {
        InnerClass innerClass = new InnerClass();
		// 정적 멤버 클래스는 바깥 클래스의 인스턴스를 필요로 하지 않는다.
        innerClass.doSomething();

    }
}
```  
  
* 비 정적 멤버 클래스 
```java
public class OutterClass {

    private int number = 10;

    void printNumber() {
        InnerClass innerClass = new InnerClass();
    }

    private class InnerClass {
        void doSomething() {
            System.out.println(number);
            OutterClass.this.printNumber();
			// 바깥 클래스의 인스턴스를 참조할 수 있다. 암묵적으로 바깥 클래스의 인스턴스에 대한 참조가 생긴다.
          // 즉 비정적 멤버 클래스의 인스턴스는 바깥 클래스의 인스턴스없이는 단독으로 생성될 수 없다.
        }
    }

    public static void main(String[] args) {
        InnerClass innerClass = new OutterClass().new InnerClass();
        innerClass.doSomething();
    }

}
```

#### 어댑터 패턴
* 기존 코드를 클라이언트가 사용하는 인터페이스의 구현체로 바꿔주는 패턴
* 클라이언트가 사용하는 인터페이스를 따르지 않는 기존 코드를 재사용할 수 있게 해준다.
![image](https://user-images.githubusercontent.com/60100532/192100095-af48cfd0-8d05-4e0e-9b20-0c102746ebfd.png)

* sample code
```java
public class AdapterInJava {

    public static void main(String[] args) {
        try(InputStream is = new FileInputStream("number.txt");
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader reader = new BufferedReader(isr)) {
            while(reader.ready()) {
                System.out.println(reader.readLine());
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
```