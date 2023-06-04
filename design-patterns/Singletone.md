# Design-patterns
## 객체 생성 관련 디자인 패턴

---
### 싱글톤 패턴 1. 싱글톤 패턴을 가장 단순히 구현하는 방법
####  싱글톤 (Singleton) 패턴
인스턴스를 오직 한개만 제공하는 클래스

  * 시스템 런타임, 환경 세팅에 대한 정보 등, 인스턴스가 여러개 일 때 문제가 생길 수 있는 경우가 있다. 인스턴스를 오직 한개만 만들어 제공하는 클래스가 필요하다.
  
|Singleton|
|----|
| - instance : Singleton|
| + getInstance():Singleton|

```java
public class Settings{
    
}
```

```java
public class App{
    public static void main(String[]args){
        Settings = new Settings();
        Settings1 = new Settings();
        System.out.println(settings != settings1);
        // ture 
    } 
}
```
싱글톤 패턴을 구현 시 new를 사용해서 인스턴스를 만들게 허용하면 싱글톤 패턴을 만족시킬 수 없다.

해당 클래스 밖에서 new를 사용해 생성자를 사용하지 하지 못하게 하려면 
private 생성자를 만들어 준다.

```java
public class Settings{
    private Settings(){}
}
```
```java
public class App{
    public static void main(String[]args){
        Settings = new Settings(); //-- 컴파일 에러
        Settings1 = new Settings();//-- 컴파일 에러
        System.out.println(settings != settings1);
      
    } 
}
```
이렇게 되면 밖에서 settings의 인스턴스를 만들 수 없기 때문에
Settings 클래스 안에서 인스턴스를 만들어서 글로벌하게 접근 가능한 방법을 제공해야 한다.
```java
public class Settings{
    private Settings(){}
    
    public static Settings getInstance(){
        return new Settings();
    }
}
```
```java
public class App{
    public static void main(String[]args){
        Settings = Settings.getInstance();
        Settings1 = Settings.getInstance(); 
        System.out.println(settings != settings1);
        // true
    } 
}
```
하지만 이경우에도 Settings의 getInstance() 내부에서 new를 사용해 호출될 때마다 Settings 인스턴스를 생성해 return하기 때문에 
싱글톤 패턴을 만족하지 못한다.

```java
public class Settings{
    
    private static Settings instance;
    
    private Settings(){}
    
    public static Settings getInstance(){
        if (instance == null) {
            instance = new Settings();
        }
        return instance;
    }
}
```
```java
public class App{
    public static void main(String[]args){
        Settings = Settings.getInstance();
        System.out.println(settings ==  Settings.getInstance());
        // true
    } 
}
```
위와 같이 싱글톤 패턴을 구현할 수 있다.
하지만 위 같은 방법은 치명적인 단점이 있다.
과연 멀티 쓰레드 환경에서 위 코드가 안전할까??? 

정답은 아니다.

a쓰레드 b쓰레드 2개의 쓰레드가 있다고 가정하고

a쓰레드가 최초에 instance가 null인 상태에서 if문안으로 들어왔지만 아직 new Settings()를 실행하기 전에
b쓰레드가 if (instance == null)문을 통과했다면 
결과적으로 a, b 쓰레드는 서로 다른 settings 인스턴스를 생성하게 된다.

이 문제를 해결하는 가장 간단한 방법은
`Synchronized` 키워드를 사용하는 것이다.

getInstance()에 synchronized라는 키워드를 사용해 동시에 여러 쓰래드가 접근하지 못하도록 한다.
하지만 성능에 손해가 발생할 수 있다.

동기화라는 메커니즘 자체가 Lock을 사용해 Lock을 가지고 있는 쓰레드만 접근할 수 있게 하고 또 완료한 후에 Lock을 반환하는 메커니즘
이러한 처리 과정이 더 추가 되기 때문에 성능에 손해를 볼수있다.

```java
public class Settings{
    
    private static Settings instance;
    
    private Settings(){}
    
    public static synchronized Settings getInstance(){
        if (instance == null) {
            instance = new Settings();
        }
        return instance;
    }
}
```


이번에는 성능을 고려해 이른 초기화(Eager Initialization)을 사용해 싱글톤 패턴을 구현해보자

```java
public class Settings{
    
    private static final Settings INSTANCE = new Settings();
    
    private Settings(){}
    
    public static Settings getInstance(){
        return INSTANCE;
    }
}
```

하지만 여기에도 단점은 있다. 
바로 미리! 만든다는 것이 단점이다.
static final로 Settings instance를 미리 생성했는데 정작 어플리케이션에서 사용하지 않을 수 있다.

그렇다면 getInstance()를 호출할 때 (사용이 될 때) 그때 Settings instance를 생성하고 싶다면
double checked locking을 사용해 볼 수 있다.

```java
public class Settings{
    
    private static volatile Settings instance;
    
    private Settings(){}
    
    public static Settings getInstance(){
		if (instance == null) {
			synchronized (Settings.class) {
				if (instance == null) {
					instance = new Settings();
				}
			}
		}
		return instance;
    }
}
```
double checked locking을 사용하면 싱글톤 패턴을 구현할 순 있지만 
코드가 많이 복잡해지고 volatile키워드에 대해 이해하고 있어야 한다.

다음으로는 static inner 클래스를 사용해 싱글톤 패턴을 구현해 보자.

static inner 클래스 사용

```java
public class Settings{
 
    private Settings(){}

	private static class SettingsHolder {
		private static final Settings INSTANCE = new Settings();
	}
	
    public static Settings getInstance(){
		return SettingsHolder.INSTANCE;
    }
}
```

```java
public class App {
	public static void main(String[] args) throws NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException {
		Settings settings = Settings.getInstance();
		Settings settings1 = Settings.getInstance();
		System.out.println(settings == settings1);
        // true 
        
		// 리플랙션 사용
		Constructor<Settings> constructor = Settings.class.getDeclaredConstructor();
		constructor.setAccessible(true);
		Settings settings2 = constructor.newInstance();
		System.out.println(settings == settings2);
        //false

	}
}
```
위 코드를 보면 double checked locking을 사용한 코드에 비해 코드가 훨씬 간단해지면서
싱글톤 패턴을 구현했다.
하지만 코드에서 보이는 것처럼 리플랙션을 이용하면 얼마든지 싱글톤 패턴을 깨버릴 수 있다.  

다음은 직열화 역직렬화 방법으로 싱글톤 패턴을 깨보자.

```java
import java.io.Serializable;

public class Settings implements Serializable {

	private Settings() {
	}

	private static class SettingsHolder {
		private static final Settings INSTANCE = new Settings();
	}

	public static Settings getInstance() {
		return SettingsHolder.INSTANCE;
	}
}
```

```java
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;

public class App {
	public static void main(String[] args) throws IOException, ClassNotFoundException{
		Settings settings = Settings.getInstance();
		Settings settings1 = null;
		try (ObjectOutput out = new ObjectOutputStream(new FileOutputStream("settings.obj"))) {
			out.writeObject(settings);
		}

		try (ObjectInput in = new ObjectInputStream(new FileInputStream("settings.obj"))) {
			settings1 = in.readObject();
		}

		System.out.println(settings == settings1);
        //false 
	}
}
```



직열화 역직렬화 싱글톤 해결방법

```java
import java.io.Serializable;

public class Settings implements Serializable {

	private Settings() {
	}

	private static class SettingsHolder {
		private static final Settings INSTANCE = new Settings();
	}

	public static Settings getInstance() {
		return SettingsHolder.INSTANCE;
	}
	
	// 명시적으로 메소드가 정의되어 있지는 않지만
    // protected Object readResolve() 이런 시그니쳐를 가지고 있으면 역직렬화시 반드시 
    // readResolve 메소드를 실행하게 되어 있다.
	protected Object readResolve() {
		return getInstance();
	}
	
}
```

```java
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;

public class App {
	public static void main(String[] args) throws IOException, ClassNotFoundException{
		Settings settings = Settings.getInstance();
		Settings settings1 = null;
		try (ObjectOutput out = new ObjectOutputStream(new FileOutputStream("settings.obj"))) {
			out.writeObject(settings);
		}

		try (ObjectInput in = new ObjectInputStream(new FileInputStream("settings.obj"))) {
			settings1 = in.readObject();
		}

		System.out.println(settings == settings1);
        //true
	}
}
```


리플랙션에는 대응할수 있는 방법이 없다...
사용하는 쪽에서 이상하게 사용하면 싱글톤으로 사용하는것을 포기한것이니 그러려니 할 수도 있지만
이것까지 막고 싶은 경우에는

단순하게 
`enum`을 사용하면 된다.

```java

public enum Settings {
	INSTANCE;
}
```

위 코드는 리플렉션에 안전하다.

```java
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

public class App {

	public static void main(String[] args) throws
		InvocationTargetException,
		InstantiationException,
		IllegalAccessException {

		Settings settings = Settings.INSTANCE;

		Settings settings1 = null;
		Constructor<?>[] constructors = Settings.class.getDeclaredConstructors();
		for (Constructor<?> constructor : constructors) {
			constructor.setAccessible(true);
			settings1 = (Settings)constructor.newInstance("INSTANCE");
		}
		System.out.println(settings == settings1);
	}
}
/*
    Exception in thread "main" java.lang.IllegalArgumentException: Cannot reflectively create enum objects
	at java.base/java.lang.reflect.Constructor.newInstanceWithCaller(Constructor.java:492)
	at java.base/java.lang.reflect.Constructor.newInstance(Constructor.java:480)
	at org.example.testddd.App.main(App.java:19)

 */

```

enum은 reflection에서 newInstance를 할수 없도록 막아 놓았다.

![image](https://user-images.githubusercontent.com/60100532/190861498-9c5704cd-b85d-4073-a88e-ce1a7e3ce9c7.png)


enum은 기본적으로 Serializable을 구현하고 있다.
enum의 바이트코드를 보면 Enum을 상속 받고 있다.
![image](https://user-images.githubusercontent.com/60100532/190861586-7a07db7e-e892-48fa-a263-20bcfc25cfc5.png)  

   
 <br/> 

이제 Enum class를 살펴보면  
이미 Serializable을 구현하고 있다.  
즉 우리가 만든 Settings도 Serializable을 구현하고있다.

 <br/> 

![image](https://user-images.githubusercontent.com/60100532/190861626-64d9974e-d72b-4f9a-a8e0-d98f1cc7b7cc.png)


 <br/> 

enum의 직렬화 역직렬화는  
우리가 별다른 장치를 추가하지 않아도 안전하게 동일한 인스턴스로 역직렬화가 된다

```java

public class App {

	public static void main(String[] args) throws IOException, ClassNotFoundException {
		Settings settings = Settings.INSTANCE;

		Settings settings1 = null;
		try (ObjectOutput out = new ObjectOutputStream(new FileOutputStream("settings.obj"))) {
			out.writeObject(settings);
		}

		try (ObjectInput in = new ObjectInputStream(new FileInputStream("settings.obj"))) {
			settings1 = (Settings)in.readObject();
		}

		System.out.println(settings == settings1);
		// true
	}
}

```

___
___

<br/> 

<br/> 

### 싱글톤 패턴 2. 싱글톤 (Singleton) 패턴 실무에서는 어떻게 쓰이나?


* 자바 java.lang.Runtime
* 스프링에서 빈의 스코프 중에 하나로 싱글톤 스코프.
* 다른 디자인 패턴(빌더, 퍼사드, 추상 팩토리 등) 구현체의 일부로 쓰이기도 한다.


### 자바 java.lang.Runtime

```java
public class App {

	public static void main(String[] args) {
		Runtime runtime = new Runtime(); // error
        
	}
}
```
자바 Runtime은 new로는 만들수 없다.  
  

아래 Runtime을 보면 private 생성자로 선언되어있고  
getRuntime을 통해서만 가져올 수 있다.

![image](https://user-images.githubusercontent.com/60100532/190862228-18433da2-08cb-4b26-8e2a-11d83262d20f.png)

<br/>  

### 스프링에서 빈의 스코프 중에 하나로 싱글톤 스코프.
> 엄밀하게 따지면 싱글톤 패턴과는 다르다!!!
> 스프링이 ApplicationContext 내부에서 instance를 singleton으로 관리를 해주는것이지 싱글톤 패턴과는 엄밀하게 말하면 다르다!!!

```java

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SpringConfig {

	@Bean
	public String hello() {
		return "hello";
	}

}

```

```java
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class SpringExample {

	public static void main(String[] args) {
		ApplicationContext applicationContext = new AnnotationConfigApplicationContext(SpringConfig.class);
		String hello = applicationContext.getBean("hello", String.class);
		String hello1 = applicationContext.getBean("hello", String.class);
		System.out.println(hello == hello1);
		
		// true
	}
}

```

___
___

<br/> 

<br/> 

### 위에서 알아본 내용들을 복습해 보자!!!!!

> 싱글톤 (Singleton) 패턴 복습
> 
> * 자바에서 enum을 사용하지 않고 싱글톤 패턴을 구현하는 방법은?
> * private 생성자와 static 메소드를 사용하는 방법의 단점은?
> * enum을 사용해 싱글톤 패턴을 구현하는 방법의 장점과 단점은?
> * static inner 클래스를 사용해 싱글톤 패턴을 구현하라.