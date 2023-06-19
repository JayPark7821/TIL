# Effective-java
## 객체 생성과 파괴
* 객체를 생성하는 다양한 방법과 파괴 전에 수행해야 할 정리 작업을 관리하는 방법

### 아이템 9. try-finally 보다는 try-with-resources를 사용하라

### 핵심정리
* try-finally는 더이상 최선의 방법이 아니다(자바 7부터)
* try-with-resources를 사용하면 코드가 더 짧고 분명하다.
* 만들어지는 예외 정보도 훨씬 유용하다.


* 자바 라이브러리에는 close 메소드를 호출해 직접 닫아줘야 하는 자원이 많다.
  * InputStream, OutputStream, java.sql.Connection etc
* 전통적으로 자원이 제대로 닫힘을 보장하는 수단으로 try-finally가 사용되었다.
  * 하지만 예외는 try블럭과 finally 블럭 모두에서 발생가능.
  * finally블럭의 예외가 try블럭에서 발생한 예외를 숨길 수 있다. -> 디버깅이 어려워진다.
  * 물론 두번째 예외 대신 첫 번째 예외를 기록하도록 코드를 수정할 수는 있다.

### Sample Code
```java
public class TopLine {
    // 코드 9-1 try-finally - 더 이상 자원을 회수하는 최선의 방책이 아니다! (47쪽)
    static String firstLineOfFile(String path) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(path));
        try {
            return br.readLine();
        } finally {
            br.close();
        }
    }

    public static void main(String[] args) throws IOException {
        String path = args[0];
        System.out.println(firstLineOfFile(path));
    }
}
```

* 만약 try-finally로 여러개의 직접 자원을 다루는 코드가 있다면?
```java
public class Copy {
    private static final int BUFFER_SIZE = 8 * 1024;

    // 코드 9-2 자원이 둘 이상이면 try-finally 방식은 너무 지저분하다! (47쪽)
    static void copy(String src, String dst) throws IOException {
        InputStream in = new FileInputStream(src);
        try {
            OutputStream out = new FileOutputStream(dst);
            try {
                byte[] buf = new byte[BUFFER_SIZE];
                int n;
                while ((n = in.read(buf)) >= 0)
                    out.write(buf, 0, n);
            } finally {
                out.close();
            }
        } finally {
            in.close();
        }
    }

    public static void main(String[] args) throws IOException {
        String src = args[0];
        String dst = args[1];
        copy(src, dst);
    }
}
```
* 코드 이해하기가 어려워진다.....
* finally block의 예외가 try block에서 발생한 예외를 숨길 수 있다.
### Sample Code
```java
public class TopLine {
    // 코드 9-1 try-finally - 더 이상 자원을 회수하는 최선의 방책이 아니다! (47쪽)
    static String firstLineOfFile(String path) throws IOException {
      BufferedReader br = new BadBufferedReader(new FileReader(path));
		try {
            return br.readLine();
        } finally {
            br.close();
        }
    }

    public static void main(String[] args) throws IOException {
        System.out.println(firstLineOfFile("pom.xml"));
    }
}
```
```java
public class BadBufferedReader extends BufferedReader {
    public BadBufferedReader(Reader in, int sz) {
        super(in, sz);
    }

    public BadBufferedReader(Reader in) {
        super(in);
    }

    @Override
    public String readLine() throws IOException {
        throw new CharConversionException();
    }

    @Override
    public void close() throws IOException {
        throw new StreamCorruptedException();
    }
}
```
![image](https://user-images.githubusercontent.com/60100532/209906659-a1fcdc29-334d-4943-900d-5a686fe2df1c.png)
* 가장 나중에 발생한 StreamCorruptedException만 볼수있다.

* 위 같은 문제들을 자바7에서 추가된 try-with-resources를 사용하면 해결할 수 있다.
  * try-with-resources를 사용하려면 해당 자원이 AutoCloseable 인터페이스를 구현해야 한다. 
  * try-with-resources를 사용하면 try 블럭이 끝나는 순간 자동으로 close()가 호출된다.
  * try-with-resources를 사용하면 catch 블럭 없이도 try 블럭에서 발생한 예외를 catch 할 수 있다.
  * try-with-resources를 사용하면 예외가 발생하든 말든 finally 블럭을 사용하지 않아도 된다.

### Sample Code
```java
public class TopLine {
  // 코드 9-1 try-finally - 더 이상 자원을 회수하는 최선의 방책이 아니다! (47쪽)
  static String firstLineOfFile(String path) throws IOException {
    try(BufferedReader br = new BadBufferedReader(new FileReader(path))) {
      return br.readLine();
    }
  }

  public static void main(String[] args) throws IOException {
    System.out.println(firstLineOfFile("pom.xml"));
  }
}
```
```java
public class BadBufferedReader extends BufferedReader {
    public BadBufferedReader(Reader in, int sz) {
        super(in, sz);
    }

    public BadBufferedReader(Reader in) {
        super(in);
    }

    @Override
    public String readLine() throws IOException {
        throw new CharConversionException();
    }

    @Override
    public void close() throws IOException {
        throw new StreamCorruptedException();
    }
}
```
 * try-with-resources를 사용하면 모든 예외를 확인할 수 있다.  
   <img width="629" alt="image" src="https://user-images.githubusercontent.com/60100532/209906910-7253f08d-5f64-45c6-8c8a-0e3825f25236.png">
  

* 복수의 자원 처리하는 try-with-resources
```java
public class Copy {
    private static final int BUFFER_SIZE = 8 * 1024;

    // 코드 9-4 복수의 자원을 처리하는 try-with-resources - 짧고 매혹적이다! (49쪽)
    static void copy(String src, String dst) throws IOException {
        try (InputStream   in = new FileInputStream(src);
             OutputStream out = new FileOutputStream(dst)) {
            byte[] buf = new byte[BUFFER_SIZE];
            int n;
            while ((n = in.read(buf)) >= 0)
                out.write(buf, 0, n);
        }
    }

    public static void main(String[] args) throws IOException {
        String src = args[0];
        String dst = args[1];
        copy(src, dst);
    }
}
```
* try-with-resources 바이트 코드
  <img width="449" alt="image" src="https://user-images.githubusercontent.com/60100532/209907540-00df1d9b-e7a0-489a-9afb-1a5cbb4a3be6.png">

> 핵심정리
> * 꼭 회수해야 하는 자우너을 다룰 때는 try-finally 말고 try-with-resources를 사용하자.   
>   예외는 없다. 코드는 더 짧고 분명해지고, 만들어지는 예외 정보도 훨씬 유용하다.  
>   try-finally로 작성하면 실용적이지 못할 만큼 코드가 지저분해지는 경우라도,  
>   try-with-resources를 사용하면 정확하고 쉽게 자원을 회수할 수 있다.