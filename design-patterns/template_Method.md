# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 템플릿 메소드 (Template method) 패턴
* 알고리듬 구조를 서브 클래스가 확장할 수 있도록 템플릿으로 제공하는 방법
* 추상 클래스는 템플릿을 제공하고 하위 클래스는 구체적인 알고리듬을 제공한다.


  ![image](https://user-images.githubusercontent.com/60100532/205218720-352209e3-e659-450d-852b-a9b687fc960e.png)


### 코드로 템플릿 메소드 패턴을 알아보자.
 
### Client code

```java
public class Client {

  public static void main(String[] args) {
    FileProcessor fileProcessor = new FileProcessor("number.txt");
    int result = fileProcessor.process();
    System.out.println(result);
  }
}


```

### FileProcessor
```java
public class FileProcessor {

  private String path;
  public FileProcessor(String path) {
    this.path = path;
  }

  public int process() {
    try(BufferedReader reader = new BufferedReader(new FileReader(path))) {
      int result = 0;
      String line = null;
      while((line = reader.readLine()) != null) {
        result += Integer.parseInt(line);
      }
      return result;
    } catch (IOException e) {
      throw new IllegalArgumentException(path + "에 해당하는 파일이 없습니다.", e);
    }
  }
}
 

```
### MultuplyFileProcessor
```java
public class MultuplyFileProcessor {

  private String path;
  public MultuplyFileProcessor(String path) {
    this.path = path;
  }

  public int process() {
    try(BufferedReader reader = new BufferedReader(new FileReader(path))) {
      int result = 0;
      String line = null;
      while((line = reader.readLine()) != null) {
        result *= Integer.parseInt(line);
      }
      return result;
    } catch (IOException e) {
      throw new IllegalArgumentException(path + "에 해당하는 파일이 없습니다.", e);
    }
  }
}

```
 
### 템플릿 메소드 패턴을 적용.
#### Client
```java

public class Client {

  public static void main(String[] args) {
    FileProcessor fileProcessor = new Multiply("number.txt");
    int result = fileProcessor.process();
    System.out.println(result);
  }
}

``` 

#### FileProcessor
```java

public abstract class FileProcessor {

  private String path;
  public FileProcessor(String path) {
    this.path = path;
  }

  public final int process(Operator operator) {
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

#### Plus
```java
public class Plus implements Operator {
  @Override
  public int getResult(int result, int number) {
    return result += number;
  }
}

```
#### Multiply
```java
public class Multiply extends FileProcessor {
  public Multiply(String path) {
    super(path);
  }

  @Override
  protected int getResult(int result, int number) {
    return result *= number;
  }

}

```

### 템플릿 콜백( Template-Callback) 패턴
* 콜백으로 상속 대신 위임을 사용하는 템플릿 패턴
* 상속 대신 익명 내부 클래스 또는 람다 표현식을 활용할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/205220706-8ea39546-ec7a-404e-b590-d3fd8518084b.png)
#### 템플릿 콜백용 callback interface
#### Operator
```java
public interface Operator {

    abstract int getResult(int result, int number);
}

```

#### Client Code
```java
public class Client {

    public static void main(String[] args) {
        FileProcessor fileProcessor = new Multiply("number.txt");
        int result = fileProcessor.process((sum, number) -> sum += number);
        System.out.println(result);
    }
}

```
 
___
___

<br/> 

<br/> 

### 템플릿 메소드 (Template method) 패턴 장단점
* 장점
    * 템플릿 코드를 재사용하고 중복 코드를 줄일 수 있다.
    * 템플릿 코드를 변경하지 않고 상속을 받아서 구체적인 알고리듬만 변경할 수 있다.

* 단점
    * 리스코프 치환 원직을 위반할 수도 있다.
    * 알고리듬 구조가 복잡할 수록 템플릿을 유지하기 어려워 진다.


___
___

<br/> 

<br/> 

### 템플릿 메소드 (Template method) 패턴
실무에서 어떻게 쓰이나?

* 자바
  * HttpServlet
* 스프링
  * 템플릿 메소드 패턴
    * Configuration
  * 템플릿 콜백 패턴
    * JdbcTemplate
    * RestTemplate
  

 