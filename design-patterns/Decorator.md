# Design-patterns
## 구조적인 패턴(Structural Patterns)

---
### 데코레이터 (Decorator) 패턴
* 기존 코드를 변경하지 않고 부가 기능을 추가하는 패턴
* 상속이 아닌 위임을 사용해서 보다 유연하게(런타임에) 부가 기능을 추가하는 것도 가능하다

![image](https://user-images.githubusercontent.com/60100532/192908078-37bd9aa2-38d9-4d83-9ee7-5b9507d0cd09.png)

### 클라이언트 코드
```java

public class Client {

    private CommentService commentService;

    public Client(CommentService commentService) {
        this.commentService = commentService;
    }

    private void writeComment(String comment) {
        commentService.addComment(comment);
    }

    public static void main(String[] args) {
//        Client client = new Client(new CommentService());
//        Client client = new Client(new TrimmingCommentService());
        Client client = new Client(new SpamFilteringCommentService());
        client.writeComment("오징어게임");
        client.writeComment("보는게 하는거 보다 재밌을 수가 없지...");
        client.writeComment("http://whiteship.me");
    }

}

```
### CommentService (Component)
```java
public class CommentService {
    public void addComment(String comment) {
        System.out.println(comment);
    }
}

```
### SpamFilteringCommentService 
```java

public class SpamFilteringCommentService extends CommentService {

    @Override
    public void addComment(String comment) {
        boolean isSpam = isSpam(comment);
        if (!isSpam) {
            super.addComment(comment);
        }
    }

    private boolean isSpam(String comment) {
        return comment.contains("http");
    }
}

```
### TrimmingCommentService
```java
public class TrimmingCommentService extends CommentService {

    @Override
    public void addComment(String comment) {
        super.addComment(trim(comment));
    }

    private String trim(String comment) {
        return comment.replace("...", "");
    }

}

```

### 위 코드에 데코레이터 패턴을 적용해 보자.
![image](https://user-images.githubusercontent.com/60100532/192908078-37bd9aa2-38d9-4d83-9ee7-5b9507d0cd09.png)

먼저 Decorator 와 ConcreteComponent의 상위 인터페이스 Component를 만들어주자.
```java

public interface CommentService {

    void addComment(String comment);
}

```


컴포넌트들을 감싸고 감싼 컴포넌트를 그대로 호출해줄 데코레이터를 만들어주자!
```java

public class CommentDecorator implements CommentService{

	private CommentService commentService;

	public CommentDecorator(CommentService commentService) {
		this.commentService = commentService;
	}

	@Override
	public void addComment(String comment) {
		commentService.addComment(comment);

	}
}

```

기존에 CommentService에서 하던 코드를 가져와 ConcreteComponent를 만들어 주자!!
```java
public class DefaultCommentService implements CommentService{
	@Override
	public void addComment(String comment) {
		System.out.println(comment);
	}
}

```

Concrete Decorator들을 선언해 주자!!

```java
public class SpamFilteringCommentDecorator extends CommentDecorator{
	public SpamFilteringCommentDecorator(CommentService commentService) {
		super(commentService);
	}

	@Override
	public void addComment(String comment) {
		if (isNoSpam(comment)) {
			super.addComment(comment);
		}

	}

	private boolean isNoSpam(String comment) {
		return !comment.contains("http");
	}
}

```
```java
public class TrimmingCommentDecorator extends CommentDecorator{

	public TrimmingCommentDecorator(CommentService commentService) {
		super(commentService);
	}

	@Override
	public void addComment(String comment) {
		super.addComment(trim(comment));
	}

	private String trim(String comment) {
		return comment.replace("...", "");
	}
}

```
```java
public class Client {

	private CommentService commentService;

	public Client(CommentService commentService) {
		this.commentService = commentService;
	}

	public void writeComment(String comment) {
		commentService.addComment(comment);

	}
}

```
```java
public class App {

    private static boolean enabledSpamFilter = true;

    private static boolean enabledTrimming = true;

    public static void main(String[] args) {
        CommentService commentService = new DefaultCommentService();

        if (enabledSpamFilter) {
            commentService = new SpamFilteringCommentDecorator(commentService);
        }

        if (enabledTrimming) {
            commentService = new TrimmingCommentDecorator(commentService);
        }

        Client client = new Client(commentService);
        client.writeComment("오징어게임");
        client.writeComment("보는게 하는거 보다 재밌을 수가 없지...");
        client.writeComment("http://whiteship.me");
    }
}
```


___
___

<br/> 

<br/> 

### 데코레이터 (Decorator) 패턴 장단점
* 장점
    * 새로운 클래스를 만들지 않고 기존 기능을 조합할 수 있다.
    * 컴파일 타임이 아닌 런타임에 동적으로 기능 변경이 가능

* 단점
    * 데코레이터를 조합하는 코드가 복잡할 수 있다.


___
___

<br/> 

<br/> 

### 데코레이터 (Decorator) 패턴
실무에서 어떻게 쓰이나?

* 자바
  * InputStream, OutputStream, Reader, Writer의 생성자를 활용한 랩퍼
  * java.util.Collections가 제공하는 메소드들 활용한 랩퍼
  * javax.servlet.http.HttpServletRequest/ResponseWrapper
* 스프링
  * ServerHttpRequestDecorator
  

```java

public class DecoratorInJava {

    public static void main(String[] args) {
        // Collections가 제공하는 데코레이터 메소드
        ArrayList list = new ArrayList<>();
        list.add(new Book());

        List books = Collections.checkedList(list, Book.class);


//        books.add(new Item());

        List unmodifiableList = Collections.unmodifiableList(list);
        list.add(new Item());
        unmodifiableList.add(new Book());


        // 서블릿 요청 또는 응답 랩퍼
        HttpServletRequestWrapper requestWrapper;
        HttpServletResponseWrapper responseWrapper;
    }

    private static class Book {

    }

    private static class Item {

    }
}

```

```java
public class DecoratorInSpring {

    public static void main(String[] args) {
        // 빈 설정 데코레이터
        BeanDefinitionDecorator decorator;

        // 웹플럭스 HTTP 요청 /응답 데코레이터
        ServerHttpRequestDecorator httpRequestDecorator;
        ServerHttpResponseDecorator httpResponseDecorator;
    }
}

```