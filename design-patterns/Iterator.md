# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 이터레이터 (Iterator) 패턴
* 집합 객체 내부 구조를 노출시키지 않고 순회 하는 방법을 제공하는 패턴.
* 집합 객체를 순회하는 클라이언트 코드를 변경하지 않고 다양한 순회 방법을 제공할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/202192547-0a4690c9-735f-4254-96a9-a7f49584bceb.png)

### 코드로 이터레이터 패턴을 알아보자.
#### Client 코드
```java

public class Client {

  public static void main(String[] args) {
    Board board = new Board();
    board.addPost("디자인 패턴 게임");
    board.addPost("선생님, 저랑 디자인 패턴 하나 학습하시겠습니까?");
    board.addPost("지금 이 자리에 계신 여러분들은 모두 디자인 패턴을 학습하고 계신 분들입니다.");

    // TODO 들어간 순서대로 순회하기
    List<Post> posts = board.getPosts();
    for (int i = 0 ; i < posts.size() ; i++) {
      Post post = posts.get(i);
      System.out.println(post.getTitle());
    }

    // TODO 가장 최신 글 먼저 순회하기
    Collections.sort(posts, (p1, p2) -> p2.getCreatedDateTime().compareTo(p1.getCreatedDateTime()));
    for (int i = 0 ; i < posts.size() ; i++) {
      Post post = posts.get(i);
      System.out.println(post.getTitle());
    }
  }

}

```

### Board
```java

public class Board {

    List<Post> posts = new ArrayList<>();

    public List<Post> getPosts() {
        return posts;
    }

    public void setPosts(List<Post> posts) {
        this.posts = posts;
    }

    public void addPost(String content) {
        this.posts.add(new Post(content));
    }
}

```

### Post
```java

public class Post {

    private String title;

    private LocalDateTime createdDateTime;

    public Post(String title) {
        this.title = title;
        this.createdDateTime = LocalDateTime.now();
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public LocalDateTime getCreatedDateTime() {
        return createdDateTime;
    }

    public void setCreatedDateTime(LocalDateTime createdDateTime) {
        this.createdDateTime = createdDateTime;
    }
}

```



### 이터레이터 패턴을 적용.

---  
#### Client 코드
```java

public class Client {

  public static void main(String[] args) {
    Board board = new Board();
    board.addPost("디자인 패턴 게임");
    board.addPost("선생님, 저랑 디자인 패턴 하나 학습하시겠습니까?");
    board.addPost("지금 이 자리에 계신 여러분들은 모두 디자인 패턴을 학습하고 계신 분들입니다.");

    // TODO 들어간 순서대로 순회하기
    List<Post> posts = board.getPosts();
    Iterator<Post> iterator = posts.iterator();
    System.out.println(iterator.getClass());

    for (int i = 0 ; i < posts.size() ; i++) {
      Post post = posts.get(i);
      System.out.println(post.getTitle());
    }

    // TODO 가장 최신 글 먼저 순회하기
    Iterator<Post> recentPostIterator = board.getRecentPostIterator();
    while(recentPostIterator.hasNext()) {
      System.out.println(recentPostIterator.next().getTitle());
    }
  }

}

```
#### Board
```java
public class Board {

  List<Post> posts = new ArrayList<>();

  public List<Post> getPosts() {
    return posts;
  }

  public void addPost(String content) {
    this.posts.add(new Post(content));
  }

  public Iterator<Post> getRecentPostIterator() {
    return new RecentPostIterator(this.posts);
  }


}

```

#### RecentPostIterator
```java
public class RecentPostIterator implements Iterator<Post> {

  private Iterator<Post> internalIterator;

  public RecentPostIterator(List<Post> posts) {
    Collections.sort(posts, (p1, p2) -> p2.getCreatedDateTime().compareTo(p1.getCreatedDateTime()));
    this.internalIterator = posts.iterator();
  }

  @Override
  public boolean hasNext() {
    return this.internalIterator.hasNext();
  }

  @Override
  public Post next() {
    return this.internalIterator.next();
  }
}


```
---
![image](https://user-images.githubusercontent.com/60100532/202195975-d139ac4c-3277-4ee8-863a-5395416fbf81.png)
___
___

<br/> 

<br/> 

### 이터레이터 (Iterator) 패턴 장단점
* 장점
    * 집합 객체가 가지고 있는 객체들에 손쉽게 접근할 수 있다.
    * 일관된 인터페이스를 사용해 여러 형태의 집합 구조를 순회할 수 있다.
* 단점
    * 클래스가 늘어나고 복잡도가 증가한다.


> 반드시 iterator를 써야하는 것은 아니지만.
> 1. 다양한 방법으로 순회할 필요가 있거나. 
> 2. 그 내부에 있는 집합 객체의 구조가 변경될 가능성이 있다면   
> 
> iterator 패턴 적용을 고려해 보자.
___
___

<br/> 

<br/> 

### 이터레이터 (Iterator) 패턴

* 자바
  * java.util.Enumeration과 java.util.Iterator
  * Java StAX (Streaming API for XML)의 Iterator 기반 API
    * XmlEventReader, XmlEventWriter
* 스프링
  * CompositeIterator
