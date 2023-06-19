# Effective-java
## 제네릭
* 제네릭의 장점을 살리고 단점을 최소화하는 방법

### 아이템 33. 타입 안전 이종 컨테이너를 고려하라.

### 핵심정리 : 타입 토큰을 사용한 타입 안전 이종 컨테이너
* 타입 안전 이종 컨테이너 : 한 타입의 객체만 감을 수 있는 컨테이너가 아니라 여러 다른 타입 (이종)을 담을 수 있는 타입 안전한 컨테이너.
* 타입 토큰 : `String.class` 또는 `Class<String>`
* 타입 안전 이종 컨테이너 구현 방법 : 컨테이너가 아니라 "키"를 매개변수화 하라!


```java
public class Favorites {

    private Map<Class, Object> map = new HashMap<>();

    public void put(Class clazz, Object value) {
        this.map.put(Objects.requireNonNull(clazz), clazz.cast(value));
    }

    public Object get(Class clazz) {
        return this.map.get(clazz);
    }

    public static void main(String[] args) {
        Favorites favorites = new Favorites();
        favorites.put(String.class, "jay");
        favorites.put(String.class, 2);
        favorites.put(Integer.class, 2);
        favorites.put(Integer.class, "2");
    }
}
```

* class의 class는 제네릭 클래스이다.
* class에 비한정적 와일드 카드를 사용해서 여러 타입을 안전하게 담으려면 아래와 같이 수정하면 된다.

```java
public class Favorites {

	private Map<Class<?>, Object> map = new HashMap<>();

	public <T> void put(Class<T> clazz, T value) {
		this.map.put(Objects.requireNonNull(clazz), clazz.cast(value));
	}

	public <T> T get(Class<T> clazz) {
		return clazz.cast(this.map.get(clazz));
	}

	public static void main(String[] args) {
		Favorites favorites = new Favorites();
		favorites.put(String.class, "Jay");
		favorites.put(Integer.class, 2);
		Integer integer = favorites.get(Integer.class);
		String string = favorites.get(String.class);
		
	}

}

```  
* Class.cast 메서드 사용시 형변환이 가능한지 체크하고 케스트 하기 떄문에 waring이 발생하지 않는다.
![image](https://github.com/JayPark7821/effective-java/assets/60100532/077b33b3-0926-4e4d-810f-1447c2502a97)

* 취약점 1
```java

public static void main(String[] args) {
		Favorites favorites = new Favorites();
		favorites.put((Class)String.class, 1); // class 객체를 로타입으로 넘기면 타입 안정성을 보장할 수 있는 방법이 없다.
		  
		String string = favorites.get(String.class);
		
	}

```

* 취약점 2
```java
    public static void main(String[] args) {
        Favorites favorites = new Favorites();
        favorites.put(String.class, "jay");
        favorites.put(Integer.class, 2);

       favorites.put(List.class, List.of(1, 2, 3)); 
       favorites.put(List.class, List.of("a", "b", "c"));
        // List<Integer> 인지 List<String> 인지 구분할 수 없다.
        // List<Integer>.class 라는 리터럴은 존재하지 않는다.
    
       List list = favorites.get(List.class);
       list.forEach(System.out::println);
    }
```


### 슈퍼 타입 토큰
* 익명 클래스와 제네릭 클래스 상속을 사용한 타입 토큰
* 닐 게프터의 슈터 타입 토큰
* https://gafter.blogspot.com/2006/12/super-type-tokens.html
* https://gafter.blogspot.com/2007/05/limitation-of-super-type-tokens.html

```java

public class GenericTypeInfer {

	static class Super<T> {
		T value;
	}

	public static void main(String[] args) throws NoSuchFieldException {
		Super<String> stringSuper = new Super<>();
		System.out.println(stringSuper.getClass().getDeclaredField("value").getType());
		// -> class java.lang.Object -> 컴파일러가 제네릭을 Object로 치환함.
	}
}
```

* 위 코드에선 T의 타입을 런타임에 알고싶어도 알 수가 없다. 
* 단 한가지 방법이 있다 , 상속 받은 경우에 타입정보가 남는다.
```java
public class GenericTypeInfer {

	static class Super<T> {
		T value;
	}
	
	static class Sub extends Super<String> {
    }

	public static void main(String[] args) throws NoSuchFieldException {
		Super<String> stringSuper = new Super<>();
		System.out.println(stringSuper.getClass().getDeclaredField("value").getType());
		
        Sub sub = new Sub();
		Type type = sub.getClass().getGenericSuperclass();
		ParameterizedType pType = (ParameterizedType) type;
		System.out.println(pType.getActualTypeArguments()[0]);
	}
}
```
* 위 코드에서 Sub클래스의 선언없이 익명 내부클래스를 통해 제네릭 타입을 런타임에 가져올 수 있다.
```java
public class GenericTypeInfer {

    static class Super<T> {
        T value;
    }

    public static void main(String[] args) throws NoSuchFieldException {
        Super<String> stringSuper = new Super<>();
        System.out.println(stringSuper.getClass().getDeclaredField("value").getType());

        Type type = (new Super<String>(){}).getClass().getGenericSuperclass();
        ParameterizedType pType = (ParameterizedType) type;
        Type actualTypeArgument = pType.getActualTypeArguments()[0];
        System.out.println(actualTypeArgument);

    }
}

```


### 한정적 타입 토큰
* 한정적 타입 토큰을 사용한다면, 이종 컨테이너에 사용할 수 있는 타입을 제한할 수 있다.
  * AnnotatedElement<T extends Annotation> T  
    getAnnotation(Class<T> annotationClass);
* asSubclass 메서드
  * 메서드를 호출하는 class 인스턴스를 인수로 명시한 클래스로 형변환 한다.

```java
@Retention(RetentionPolicy.RUNTIME)
public @interface FindMe {
}
```
```java
@FindMe
public class MyService {
}
```
```java

// 코드 asSubclass를 사용해 한정적 타입 토큰을 안전하게 형변환한다. (204쪽)
public class PrintAnnotation {

    static Annotation getAnnotation(AnnotatedElement element, String annotationTypeName) {
        Class<?> annotationType = null; // 비한정적 타입 토큰
        try {
            annotationType = Class.forName(annotationTypeName);
        } catch (Exception ex) {
            throw new IllegalArgumentException(ex);
        }
        return element.getAnnotation(annotationType.asSubclass(Annotation.class));
    }

    // 명시한 클래스의 명시한 애너테이션을 출력하는 테스트 프로그램
    public static void main(String[] args) throws Exception {
        System.out.println(getAnnotation(MyService.class, FindMe.class.getName()));
    }
}

```