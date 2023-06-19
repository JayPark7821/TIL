# Effective-java
## 제네릭 
* 제네릭의 장점을 살리고 단점을 최소화하는 방법

### 아이템 26. 로 타입은 사용하지 말라.

### 용어 정리
* 로 타입 : `List`
* 제네릭 타입 : `List<E>`
* 매개변수화 타입 : `List<String>`
* 타입 매개변수 : `E`
* 실제 타입 매개변수 : `String`
* 한정적 타입 매개변수 : `List<E extends Number>`
* 비한정적 타입 매개변수 : `Class<?>`
* 한정적 와일드카드 타입 : `Class<? extends Annotation>`

```java
    public static void main(String[] args){
        List numbers=new ArrayList();
        numbers.add(10);
        numbers.add("whiteship");
    
        for(Object number:numbers){
            System.out.println((Integer)number);
        }
	}
```

> `10   
> Exception in thread "main" java.lang.ClassCastException: class java.lang.String cannot be cast to class java.lang.Integer (java.lang.String and java.lang.Integer are in module java.base of loader 'bootstrap')
at kr.service.okr.common.config.AdapterInJava.main(AdapterInJava.java:14)`  

### 핵심정리
* 매개변수화 타입을 사용해야 하는 이유
* 런타임이 아닌 컴파일 타임에 문제를 찾을 수 있다.( 안정성 )
* 제네릭을 활용하면 이 정보가 주석이 아닌 타입 선언 자체에 녹아든다. (표현력)
* "로 타입"을 사용하면 안정성과 표현력을 잃는다.
* 그렇다면 자바는 "로 타입"을 왜 지원하는가?
* `List`와 `List<Object>`의 차이는?
* `Set`과 `Set<?>`의 차이는?
* 예외: class 리털러과 instanceof 연산자


```java
public class Box<E> {

	private E item;

	private void add(E e) {
		this.item = e;
	}

	private E get() {
		return this.item;
	}

	public static void main(String[] args) {
		Box<Integer> box = new Box<>();
		box.add(10);
		System.out.println(box.get() * 100);

		printBox(box);
	}
	private static void printBox(Box<?> box) {
		System.out.println(box.get());
	}
}
```
* 그렇다면 자바는 "로 타입"을 왜 지원하는가? -> java 5버전 이전에는 제네릭이 없었다.
* 지금의 java도 제네릭으로 선언한 객체의 바이트 코드를 보면 아래와 같이 오브젝트로 선언되어있고 그 다음 케스팅을 한다.   

<img width="647" alt="스크린샷 2023-05-30 오전 10 14 55" src="https://github.com/JayPark7821/effective-java/assets/60100532/d8f565fa-bd7c-4594-a38d-a7ac1823ca0e">

* `List`와 `List<Object>`의 차이는?  

```java
public class Raw {
    public static void main(String[] args) {
        List<String> strings = new ArrayList<>();
        unsafeAdd(strings, Integer.valueOf(42));
        String s = strings.get(0); // 컴파일러가 자동으로 형변환 코드를 넣어준다.
    }

    private static void unsafeAdd(List list, Object o) {
        list.add(o);
    }
}
```
* 위 코드는 add에서는 에러가 발생하지 않지만
* get으로 꺼낼때  
> `Exception in thread "main" java.lang.ClassCastException: class java.lang.Integer cannot be cast to class java.lang.String (java.lang.Integer and java.lang.String are in module java.base of loader 'bootstrap')
at kr.service.okr.common.config.Raw.main(Raw.java:10)`
* 위 와같은 에러가 발생한다.  

    
* 하지만 unsafeAdd()에서 `List<Object>`로 받는다면

```java
public class Raw {
	public static void main(String[] args) {
		List<String> strings = new ArrayList<>();
		unsafeAdd(strings, Integer.valueOf(42));
		String s = strings.get(0); // 컴파일러가 자동으로 형변환 코드를 넣어준다.
	}

	private static void unsafeAdd(List<Object> list, Object o) {
		list.add(o);
	}
}
```
* `List<String> != List<Object>` 이기 때문에 `컴파일` 에러가 발생한다.

* 예외: class 리털러과 instanceof 연산자
```java
public class UseRawType<E> {

    private E e;

    public static void main(String[] args) {
        System.out.println(UseRawType.class);   
		// System.out.println(UseRawType<Integer>.class); -> 어차피 컴파일 타임에 소거되어 해당 클래스는 결국 없는 클래스.

        UseRawType<String> stringType = new UseRawType<>();

        System.out.println(stringType instanceof UseRawType);
		// instanceof에서도 결국에 소거되지만 사용할수는있지만 의미 없는 코드이다...
    }
}

```