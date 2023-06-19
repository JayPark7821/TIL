# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 8. Finalizer와 cleaner 사용을 피하라

### 핵심정리
* finalizer와 cleaner는 즉시 수행된다는 보장이 없다.
* finalizer와 cleaner는 실행되지 않을 수도 있다.
* finalizer 동작 중에 예외가 발생하면 정리 작업이 처리되지 않을 수도 있다.
* finalizer와 cleaner는 심각한 성능 문제를 일으킨다.
* finalizer는 보안 문제가 있다.
* `반납할 자원이 있는 클래스는 AutoCloseable을 구현하고 클라이언트에서 close()를 호출하거나 try-with-resources 구문을 사용해야 한다.`

### finalizer
![image](https://user-images.githubusercontent.com/60100532/209748243-05ce3f97-9097-4a30-ac4f-245065c6141e.png)
```java
public class FinalizerIsBad {

    @Override
    protected void finalize() throws Throwable {
        System.out.print("");
    }
}
```
```java
public class App {

    /**
     * 코드 참고 https://www.baeldung.com/java-finalize
     */
    public static void main(String[] args) throws InterruptedException, ClassNotFoundException, NoSuchFieldException, IllegalAccessException {
        int i = 0;
        while(true) {
            i++;
            new FinalizerIsBad();

            if ((i % 1_000_000) == 0) {
                Class<?> finalizerClass = Class.forName("java.lang.ref.Finalizer");
                Field queueStaticField = finalizerClass.getDeclaredField("queue");
                queueStaticField.setAccessible(true);
                ReferenceQueue<Object> referenceQueue = (ReferenceQueue) queueStaticField.get(null);

                Field queueLengthField = ReferenceQueue.class.getDeclaredField("queueLength");
                queueLengthField.setAccessible(true);
                long queueLength = (long) queueLengthField.get(referenceQueue);
                System.out.format("There are %d references in the queue%n", queueLength);
            }
        }
    }
}
```
![image](https://user-images.githubusercontent.com/60100532/209761720-3ea97d98-24a3-4e82-8122-7955f138407d.png)
* 큐에 70만개의 reference가 쌓인 이유
* 객체를 만드느라 바빠서 finalizer의 queue를 처리한는 thread의 우선순위가 더 낮아서 
* 큐에 들어어있는 reference를 정리하지 못했기 때문에


### cleaner
```java
public class BigObject {

    private List<Object> resource;

    public BigObject(List<Object> resource) {
        this.resource = resource;
    }

    public static class ResourceCleaner implements Runnable {

        private List<Object> resourceToClean;

        public ResourceCleaner(List<Object> resourceToClean) {
            this.resourceToClean = resourceToClean;
        }

        @Override
        public void run() {
            resourceToClean = null;
            System.out.println("cleaned up.");
        }
    }
}
```
```java
public class CleanerIsNotGood {

    public static void main(String[] args) throws InterruptedException {
        Cleaner cleaner = Cleaner.create();

        List<Object> resourceToCleanUp = new ArrayList<>();
        BigObject bigObject = new BigObject(resourceToCleanUp);
        cleaner.register(bigObject, new BigObject.ResourceCleaner(resourceToCleanUp));

        bigObject = null;
        System.gc();
        Thread.sleep(3000L);
    }

}
```
### AutoCloseable
* 권장하는 방법
```java
public class AutoClosableIsGood implements Closeable {

    private BufferedReader reader;

    public AutoClosableIsGood(String path) {
        try {
            this.reader = new BufferedReader(new FileReader(path));
        } catch (FileNotFoundException e) {
            throw new IllegalArgumentException(path);
        }
    }

    @Override
    public void close() {
        try {
            reader.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
```
```java
public class App {

    public static void main(String[] args) { 
        try(AutoClosableIsGood good = new AutoClosableIsGood("")) {
            // TODO 자원 반납 처리가 됨.

        }
    }
}
```
### 책에 나온 예제 코드
```java
// cleaner 안전망을 갖춘 자원을 제대로 활용하는 클라이언트 (45쪽)
public class Adult {
    public static void main(String[] args) {
        try (Room myRoom = new Room(7)) {
            System.out.println("안녕~");
        }
    }
}
```
```java
// cleaner 안전망을 갖춘 자원을 제대로 활용하지 못하는 클라이언트 (45쪽)
public class Teenager {

    public static void main(String[] args) {
        new Room(99);
        System.out.println("Peace out");

        // 다음 줄의 주석을 해제한 후 동작을 다시 확인해보자.
        // 단, 가비지 컬렉러를 강제로 호출하는 이런 방식에 의존해서는 절대 안 된다!
        System.gc();
    }
}
```
```java
// 코드 8-1 cleaner를 안전망으로 활용하는 AutoCloseable 클래스 (44쪽)
public class Room implements AutoCloseable {
    private static final Cleaner cleaner = Cleaner.create();

    // 청소가 필요한 자원. 절대 Room을 참조해서는 안 된다!
    private static class State implements Runnable {
        int numJunkPiles; // Number of junk piles in this room

        State(int numJunkPiles) {
            this.numJunkPiles = numJunkPiles;
        }

        // close 메서드나 cleaner가 호출한다.
        @Override public void run() {
            System.out.println("Cleaning room");
            numJunkPiles = 0;
        }
    }

    // 방의 상태. cleanable과 공유한다.
    private final State state;

    // cleanable 객체. 수거 대상이 되면 방을 청소한다.
    private final Cleaner.Cleanable cleanable;

    public Room(int numJunkPiles) {
        state = new State(numJunkPiles);
        cleanable = cleaner.register(this, state);
    }

    @Override public void close() {
        cleanable.clean();
    }
}
```
### 정리
* finalizer와 cleaner 둘다 사용을 권장하지 않는다.
* 권장한는 방법은 autoCloseable, try-with-resources를 사용하는 것이다.
* cleaner를 사용해야 한다면 안전망으로 사용할 수 있다.

### 정적이 아닌 중첩 클래스는 자동으로 바깥 객체의 참조를 갖는다. p45
```java
public class OuterClass {

    class InnerClass {
    }

    public static void main(String[] args) {
        OuterClass outerClass = new OuterClass();
        InnerClass innerClass = outerClass.new InnerClass();

        System.out.println(innerClass);

        outerClass.printFiled();
    }

    private void printFiled() {
        Field[] declaredFields = InnerClass.class.getDeclaredFields();
        for(Field field : declaredFields) {
            System.out.println("field type:" + field.getType());
            System.out.println("field name:" + field.getName());
        }
    }
}
```

![image](https://user-images.githubusercontent.com/60100532/209772944-fe6a706b-569b-49ee-bc22-c67fc7abff69.png)
* OuterClass타입의 this$0 이라는 필드를 가지고 있다.

#### InnerClass에서 OuterClass의 필드나 메소드를 사용하고 싶다면?
```java
public class OuterClass {

	private void hi() {
	}
	
	class InnerClass {
	    public void hi() {
            OuterClass.this.hi();
        }
	}
}
```
* 결론 적으로 바깥 객체의 참조를 갖는다는 것은 바깥 객체가 수거되지 않는 한 수거되지 않는다는 것이다.

### 람다 역시 바깥 객체의 참조를 갖기 쉽다. p45
```java
public class LambdaExample {

	private int value = 10;

	private Runnable instanceLambda = () -> {
		System.out.println(value);
	};

	public static void main(String[] args) {
		LambdaExample example = new LambdaExample();
		Field[] declaredFields = example.instanceLambda.getClass().getDeclaredFields();
		for (Field field : declaredFields) {
			System.out.println("field type: " + field.getType());
			System.out.println("field name: " + field.getName());
		}
	}

}
```
![image](https://user-images.githubusercontent.com/60100532/209773972-797945ea-c078-4b96-85a3-9ecb4309c5b0.png)

### Finalizer 공격
```java
public class Account {

    private String accountId;

    public Account(String accountId) {
        this.accountId = accountId;

        if (accountId.equals("푸틴")) {
            throw new IllegalArgumentException("푸틴은 계정을 막습니다.");
        }
    }

    public void transfer(BigDecimal amount, String to) {
        System.out.printf("transfer %f from %s to %s\n", amount, accountId, to);
    }

}
```
```java
public class BrokenAccount extends Account {

    public BrokenAccount(String accountId) {
        super(accountId);
    }

    @Override
    protected void finalize() throws Throwable {
        this.transfer(BigDecimal.valueOf(100), "keesun");
    }
}
```

```java
class AccountTest {

    @Test
    void 일반_계정() {
        Account account = new Account("keesun");
        account.transfer(BigDecimal.valueOf(10.4),"hello");
    }

    @Test
    void 푸틴_계정() throws InterruptedException {
        Account account = null;
        try {
            account = new BrokenAccount("푸틴");
        } catch (Exception exception) {
            System.out.println("이러면???");
        }

        System.gc();
        Thread.sleep(3000L);
    }

}

```
### 해결방법
```java
public final class Account {
    ...
}
```
* 만약 Account에서 상속을 사용해야하면
```java
public class Account {
	@Override
    protected final void finalize() throws Throwable {
    }
}
```
* finalize()를 override하고 final을 붙여서 재정의를 막는다.
