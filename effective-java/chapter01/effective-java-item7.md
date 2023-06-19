# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 7. 다 쓴 객체 참조를 해제하라

### 핵심정리
* 어떤 객체에 대한 레퍼런스가 남아있다면 해당 객체는 가비지 컬렉션의 대상이 되지 않는다.
* 자기 메모리를 직접 관리하는 클래스라면 메모리 누수에 주의해야 한다.
  * 예) 스택, 캐시, 리스너, 콜백
* 참조 객체를 null 처리하는 일은 예외적인 경우이며 가장 좋은 방법은 유효 범위 밖으로 밀어내는 것이다.

### 다 쓴 객체 참조 해제방법 방법 1
* 직접 null 처리
### Sample Code
```java
// 코드 7-1 메모리 누수가 일어나는 위치는 어디인가? (36쪽)
public class Stack {
    private Object[] elements;
    private int size = 0;
    private static final int DEFAULT_INITIAL_CAPACITY = 16;

    public Stack() {
        elements = new Object[DEFAULT_INITIAL_CAPACITY];
    }

    public void push(Object e) {
        ensureCapacity();
        elements[size++] = e;
    }

   public Object pop() {
       if (size == 0)
           throw new EmptyStackException();
       return elements[--size];
   }

    /**
     * 원소를 위한 공간을 적어도 하나 이상 확보한다.
     * 배열 크기를 늘려야 할 때마다 대략 두 배씩 늘린다.
     */
    private void ensureCapacity() {
        if (elements.length == size)
            elements = Arrays.copyOf(elements, 2 * size + 1);
    }
 
    public static void main(String[] args) {
        Stack stack = new Stack();
        for (String arg : args)
            stack.push(arg);

        while (true)
            System.err.println(stack.pop());
    }
}
```
* 위 코드를 오래 실행하면 점차 가비지 컬렉션 활동과 메모리 사용량이 늘어나 결국 성능이 저하될 것이다.
* 상대적으로 드문 경우긴 하지만 심할 때는 디스크 페이징이나 OutOfMemoryError를 일으킬 수도 있다.
* 앞 코드에서 메모리 누수가 일어나는 코드는 아래 코드와 같다.
```java
   public Object pop() {
       if (size == 0)
           throw new EmptyStackException();
       return elements[--size];
   }
```
* 이 코드에서는 스택이 커졌다가 줄어들었을 때 
* 스택에서 꺼내진 객체들을 가비지 컬렉터가 회수하지 않는다.(프로그램에서 더이상 그 객체를 사용하지 않더라도)
* 해당 스택이 그 객체들의 다 쓴 참조(obsolete reference)를 보유하고 있기 때문이다.
* 다 쓴 참조 -> elements 배열의 활성영역(size 보다 작은 원소들)밖의 참조들

### 해결책
```java
 // 코드 7-2 제대로 구현한 pop 메서드 (37쪽)
    public Object pop() {
        if (size == 0)
            throw new EmptyStackException();
        Object result = elements[--size];
        elements[size] = null; // 다 쓴 참조 해제
        return result;
    }
```
* 다 쓴 참조를 해제하는 가장 좋은 방법은 그 참조를 담은 변수를 유효 범위 밖으로 밀어내는 것이다. null 처리

### 다 쓴 객체 참조 해제방법 방법 2
* 특정 자료구조 사용
### WeakHashMap
* WeakHashMap은 키가 쓸모없어지면 그 키에 해당하는 값을 자동으로 제거해준다.
```java
public class PostRepository {

    private Map<CacheKey, Post> cache;

    public PostRepository() {
        this.cache = new WeakHashMap<>();
    }

    public Post getPostById(CacheKey key) {
        if (cache.containsKey(key)) {
            return cache.get(key);
        } else {
            // TODO DB에서 읽어오거나 REST API를 통해 읽어올 수 있습니다.
            Post post = new Post();
            cache.put(key, post);
            return post;
        }
    }

    public Map<CacheKey, Post> getCache() {
        return cache;
    }
}
```
 ```java
    @Test
    void cache() throws InterruptedException {
        PostRepository postRepository = new PostRepository();
        CacheKey key1 = new CacheKey(1);
        postRepository.getPostById(key1);

        assertFalse(postRepository.getCache().isEmpty());

        key1 = null;
        // TODO run gc
        System.out.println("run gc");
        System.gc();
        System.out.println("wait");
        Thread.sleep(3000L);

        assertTrue(postRepository.getCache().isEmpty());
    }
 ```

### 다 쓴 객체 참조 해제방법 방법 4
* 백그라운드 Thread를 사용해서 주기적으로 가비지 컬렉션을 수행하도록 한다.
* ScheduledThreadPoolExecutor
### Sample Code
```java
   @Test
   void backgroundThread() throws InterruptedException {
       ScheduledExecutorService executor = Executors.newScheduledThreadPool(1);
       PostRepository postRepository = new PostRepository();
       CacheKey key1 = new CacheKey(1);
       postRepository.getPostById(key1);

       Runnable removeOldCache = () -> {
           System.out.println("running removeOldCache task");
           Map<CacheKey, Post> cache = postRepository.getCache();
           Set<CacheKey> cacheKeys = cache.keySet();
           Optional<CacheKey> key = cacheKeys.stream().min(Comparator.comparing(CacheKey::getCreated));
           key.ifPresent((k) -> {
               System.out.println("removing " + k);
               cache.remove(k);
           });
       };

       System.out.println("The time is : " + new Date());

       executor.scheduleAtFixedRate(removeOldCache,
               1, 3, TimeUnit.SECONDS);

       Thread.sleep(20000L);

       executor.shutdown();
   }
```
```java
public class CacheKey {

    private Integer value;

    private LocalDateTime created;

    public CacheKey(Integer value) {
        this.value = value;
        this.created = LocalDateTime.now();
    }

    @Override
    public boolean equals(Object o) {
        return this.value.equals(o);
    }

    @Override
    public int hashCode() {
        return this.value.hashCode();
    }

    public LocalDateTime getCreated() {
        return created;
    }

    @Override
    public String toString() {
        return "CacheKey{" +
                "value=" + value +
                ", created=" + created +
                '}';
    }
}
```

### WeakHashMap p38
* 더이상 사용하지 않는 객체를 GC할 때 자동으로 삭제해주는 Map
  * key가 더이상 강하게 레퍼런스되는 곳이 없다면 해당 엔트리를 제거한다.
* 레퍼런스 종류
  * Strong, Soft, Weak, Phantom
* 맵의 엔트리를 맵의 value가 아니라 key에 의존해야 하는 경우에 사용할 수 있다.
* 캐시를 구현하는데 사용할 수 있지만, 캐시를 직접 구현하는 것은 권장하지 않는다.
  
* custom한 reference type을 key로 사용할떄 WeakHashMap을 사용하는것은 괜찮지만.
* Wrapper type이나 primitive type을 사용할때는 주의해야한다. (WeakHashMap에서 제거가 안됨)


#### Strong & Soft & Weak Reference
```java
public class SoftReferenceExample {

    public static void main(String[] args) throws InterruptedException {
        Object strong = new Object(); // Strong Reference
        SoftReference<Object> soft = new SoftReference<>(strong); // Soft reference
      WeakReference<Object> weak = new WeakReference<>(strong); // Weak reference
        strong = null;

        System.gc();
        Thread.sleep(3000L);

        //  거의 안 없어집니다.
        //  왜냐면 메모리가 충분해서.. 굳이 제거할 필요가 없으니까요.
        System.out.println(soft.get());

      //  거의 없어집니다.
      //  왜냐면 약하니까(?)...
      System.out.println(weak.get());
    }
}
```

#### Phantom Reference
```java
public class PhantomReferenceExample {

    public static void main(String[] args) throws InterruptedException {
        BigObject strong = new BigObject();
        ReferenceQueue<BigObject> rq = new ReferenceQueue<>();

        BigObjectReference<BigObject> phantom = new BigObjectReference<>(strong, rq);
        strong = null;

        System.gc();
        Thread.sleep(3000L);

        // TODO 팬텀은 유령이니까..
        //  죽었지만.. 사라지진 않고 큐에 들어갑니다.
        System.out.println(phantom.isEnqueued());

        Reference<? extends BigObject> reference = rq.poll();
        BigObjectReference bigObjectCleaner = (BigObjectReference) reference;
        bigObjectCleaner.cleanUp();
        reference.clear();
    }
}
```

### 백그라운드 쓰레드, ScheduledThreadPoolExecutor p39
```java
public class ExecutorsExample {

  public static void main(String[] args) {
    Thread thread = new Thread(new Task());
	thread.start();

    System.out.println(Thread.currentThread() + " hello");
  }
  
  static class Task implements Runnable {
    @Override
    public void run() {
		try{
			Thread.sleep(2000L);
        }catch (InterruptedException e){
          System.out.println(Thread.currentThread() + " world");
        }
    }
  }
}

/**
 * Thread[main,5,main] hello
 * Thread[Thread-0,5,main] world
 */

```
* Thread를 만드는 작업은 시스템 리소스를 많이 잡아먹는다.
* 때문에 아래 코드와 같이 여러 Thread가 필요하다고 여러 Thread를 만드는 작업은 비효율적이다.
```java
for(int i = 0; i < 100; i++){
  Thread thread = new Thread(new Task());
  thread.start();
}
```

* 이럴때 Executors의 ThreadPool을 사용하면 된다.
* newFixedThreadPool()
* 내부적으로 blockingQueue를 사용한다. concurrent하게 데이터 접근 가능
```java
ExecutorService service = Executors.newFixedThreadPool(10);
for(int i = 0; i < 100; i++){
    service.execute(new Task());
}

service.shutdown();
```
* ThreadPool의 개수를 조정할때 cpu Intensive한지 I/O Intensive한지에 따라서 조정해야한다.
* 만약 cpu Intensive한 작업이라면 cpu의 코어 수보다 많은 쓰레드를 할당해봤자 성능이 좋아지지 않는다. 
* I/O Intensive한 작업이라면 cpu의 코어 수보다 많은 쓰레드를 할당해야한다. (왜냐하면 cpu는 I/O를 기다리는 시간을 활용할 수 없기 때문이다.)
```java
int numberOfCore = Runtime.getRuntime().availableProcessors();
```

* newCachedThreadPool()
  * 필요한 만큼 Thread를 만들고, 놀고있는 Thread가 있다면 재사용하고, 사용하지 않는 Thread는 60초 후에 제거한다.
  * 즉, Thread를 계속 만들고 제거하는 작업을 반복한다.
  * 작업을 위한 공간이 딱 1개이다. task queue가 1개
  * task queue에 task가 들어오자마자 thread에게 할당하는데 이때 thread가 없다면 새로 만들어서 할당한다.
  * thread가 계속 늘어날 수 있다.

* newSingleThreadExecutor()
  * Thread를 하나만 만들어서 작업을 순차적으로 처리한다.

* newScheduledThreadPool()
  * 일정 시간이 지난 후에 task를 실행하거나, 주기적으로 task를 실행할 수 있다.

#### Runnable
* Runnable은 return type이 없는 task를 실행하는 코드를 담고있다.
```java
public class Task implements Runnable {
	
  @Override
  public void run() {
    try{
      Thread.sleep(2000L);
    }catch (InterruptedException e){
      System.out.println(Thread.currentThread() + " world");
    }
  }
}
```

#### Callable
* Callable은 return type이 있는 task를 실행하는 코드를 담고있다.

```java
import java.util.concurrent.Future;

public class ExecutorsExample {

  public static void main(String[] args) {
    ExecutorService service = Executors.newFixedThreadPool(10);
    Future<String> submit = service.submit(new Task()); // non-blocking
    System.out.println(Thread.currentThread() + " hello");
    System.out.println(submit.get()); // blocking
	service.shutdown();
  }

  static class Task implements Callable<String> {

    @Override
    public String call() throws Exception {
		Thread.sleep(2000L);
        return Thread.currentThread() + " world";
    }
  }
}
```


> 핵심정리
> * 메모리 누수는 겉으로 잘 드러나지 않아 시스템에 수년간 잠복하는 사례도 있다. 이런 누수는 철저한 코드 리뷰나 힙 프로파일러 같은 디버깅 도구를 동원해야만 발견되기도 한다. 그래서 이런 종류의 문제는 예방법을 익혀두는 것이 매우 중요하다.
