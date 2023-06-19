# Effective-java
## 클래스와 인터페이스
* 클래스와 인터페이스를 쓰기 편하고, 견고하며, 유연하게 만드는 방법

### 아이템 20. 추상 클래스보다 인터페이스를 우선하라.

### 핵심정리 - 인터페이스의 장점
* 자바 8부터 인터페이스도 디폴트 메서드를 제공할 수 있다. (완벽 공략 3)
* 기존 클래스도 손쉽게 새로운 인터페이스를 구현해 넣을 수 있다.
* 인터페이스는 믹스인(mixtin) 정의에 안성맞춤이다. (선택적인 기능 추가)
* 계층구조가 없는 타입 프레임워크를 만들 수 있다.
* 래퍼 클래스와 함께 사용하면 인터페이스는 기능을 향상 시키는 안전하고 강력한 수단이 된다. (아이템 18)
* 구현이 명백한 것은 인터페이스의 디폴트 메서드를 사용해 프로그래머의 일감을 덜어 줄 수 있다
                               
```java
/*
 * default method example
 */

public interface TimeClient {

	void setTime(int hour, int minute, int second);
	void setDate(int day, int month, int year);
	void setDateAndTime(int day, int month, int year,
		int hour, int minute, int second);
	LocalDateTime getLocalDateTime();

	static ZoneId getZonedId(String zoneString) {
		try {
			return ZoneId.of(zoneString);
		} catch (DateTimeException e) {
			System.err.println("Invalid time zone: " + zoneString + "; using default time zone instead.");
			return ZoneId.systemDefault();
		}
	}

	default ZonedDateTime getZonedDateTime(String zoneString) {
		return ZonedDateTime.of(getLocalDateTime(), getZonedId(zoneString));
	}
}
```

* default 메소드 추가로 기존 인터페이스를 구현한 클래스들의 컴파일 에러를 발생시키지 않고 기능을 추가할 수 있다.
                                 
### 핵심정리 - 인터페이스와 추상 골격(skeletal) 클래스
* 인터페이스와 추상 클래스의 장점을 모두 취할 수 있다.
 * 인터페이스 - 디폴트 메서드 구현
 * 추상 골격 클래스 - 나머지 메서드 구현
 * 템플릿 메서드 패턴
* 다중 상속을 시뮬레이트할 수 있다.
* 골격 구현은 상속용 클래스이기 때문에 아이템 19를 따라야 한다

```java
public class IntArrays {
	static List<Integer> intArrayAsList(int[] a) {
		Objects.requireNonNull(a);
		return new List<>();
	}
}
```  
![image](https://github.com/JayPark7821/effective-java/assets/60100532/5397bb52-5381-4197-9bfd-ae01609fc1c8)

```java	
static List<Integer> intArrayAsList(int[] a) {
		Objects.requireNonNull(a);
 
		return new AbstractList<>() {
			@Override public Integer get(int i) {
				return a[i];  // 오토박싱(아이템 6)
			}

			@Override public Integer set(int i, Integer val) {
				int oldVal = a[i];
				a[i] = val;     // 오토언박싱
				return oldVal;  // 오토박싱
			}

			@Override public int size() {
				return a.length;
			}
		};
	}
```  
* 다중 상속 example  
```java
public abstract class AbstractCat {

    protected abstract String sound();

    protected abstract String name();
}

```
```java
public class MyCat extends AbstractCat   {
	
	@Override
	protected String sound() {
		return "인싸 고양이 두 마리가 나가신다!";
	}

	@Override
	protected String name() {
		return "유미";
	}

	public static void main(String[] args) {
		MyCat myCat = new MyCat();
		System.out.println(myCat.sound());
		System.out.println(myCat.name()); 
	}
}
```

* 위와같은 상황에서 상속을 하나 더 받고 싶다면??
* 인터페이스를 활용하여 다중 상속을 시뮬레이트 할 수 있다.
```java
public interface Flyable {

    void fly();
}
```

```java
public class AbstractFlyable implements Flyable {

	@Override
	public void fly() {
		System.out.println("너랑 딱 붙어있을게!");
	}
}
```
```java
public class MyCat extends AbstractCat implements Flyable {

	private MyFlyable myFlyable = new MyFlyable();

	@Override
	protected String sound() {
		return "인싸 고양이 두 마리가 나가신다!";
	}

	@Override
	protected String name() {
		return "유미";
	}

	public static void main(String[] args) {
		MyCat myCat = new MyCat();
		System.out.println(myCat.sound());
		System.out.println(myCat.name());
		myCat.fly();
	}

	@Override
	public void fly() {
		this.myFlyable.fly();
	}

	private class MyFlyable extends AbstractFlyable {
		@Override
		public void fly() {
			System.out.println("날아라.");
		}
	}
}
```


### 템플릿 메소드 패턴
* 알고리즘 구조를 서브 클래스가 확장할 수 있도록 템플릿으로 제공하는 방법
* 추상 클래스는 템플릿을 제공하고 하위 클래스는 구체적인 알고리즘 제공  
  ![image](https://user-images.githubusercontent.com/60100532/205218720-352209e3-e659-450d-852b-a9b687fc960e.png)

```java
public abstract class FileProcessor {

  private String path;
  public FileProcessor(String path) {
    this.path = path;
  }

  public final int process() {
    try(BufferedReader reader = new BufferedReader(new FileReader(path))) {
      int result = 0;
      String line = null;
      while((line = reader.readLine()) != null) {
        result = getResult(result, Integer.parseInt(line));
      }
      return result;
    } catch (IOException e) {
      throw new IllegalArgumentException(path + "에 해당하는 파일이 없습니다.", e);
    }
  }

  protected abstract int getResult(int result, int number);

}
```

```java
public class Plus extends FileProcessor {
    public Plus(String path) {
        super(path);
    }

    @Override
    protected int getResult(int result, int number) {
        return result + number;
    }

}

```

* 템플릿 콜백 패턴
```java
 public  class FileProcessor {

	private String path;
	public FileProcessor(String path) {
		this.path = path;
	}

	public final int process(BiFunction<Integer, Integer, Integer> operator) {
		try(BufferedReader reader = new BufferedReader(new FileReader(path))) {
			int result = 0;
			String line = null;
			while((line = reader.readLine()) != null) {
				result = operator.apply(result, Integer.parseInt(line));
			}
			return result;
		} catch (IOException e) {
			throw new IllegalArgumentException(path + "에 해당하는 파일이 없습니다.", e);
		}
	}

	// protected abstract int getResult(int result, int number);

}

```

```java

public class Client {

    public static void main(String[] args) {
        FileProcessor fileProcessor = new Plus("number.txt");
        System.out.println(fileProcessor.process((a,b) -> a + b));
    }
}

```

* 스프링에서 템플릿 콜백 패턴을 사용하는 예 ) JdbcTemplate, RestTemplate
  
--- 
### 디폴트 메소드와 Object 메서드
* 인터페이스의 디폴트 메소드로 Object 메소드를 재정의 할 수 없는 이유
  * 디폴트 메소드 핵심 목적은 '인터페이스의 진화'
  * 두 가지 규칙만 유지한다.
    * "클래스보다 인터페이스를 우선시 한다."
    * "더 구체적인 인터페이스가 우선시 된다."
  * 불안정하다.  

* 인터페이스에서 만약 toString을 재정의 했다고 한다면
* Object의 toString을 사용해야하나 아니면 인터페이스에 재정의된 toString을 사용해야하나?
* 심지어 인터페이스는 필드를 가질수없는데 ...... toString, hashCode, equals는 구현할 이유가???
![image](https://github.com/JayPark7821/effective-java/assets/60100532/d9a918e5-5a18-4867-aedf-5dd7a9cc4e52)


