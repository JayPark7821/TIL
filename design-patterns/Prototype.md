# Design-patterns
## 객체 생성 관련 디자인 패턴

---
### 프로토타입 (Prototype) 패턴 5. 기존 인스턴스를 복제하여 새로운 인스턴스를 만드는 방법
#### 프로토타입 (Prototype) 패턴
* 복제 기능을 갖추고 있는 기존 인스턴스를 프로토타입으로 사용해 새 인스턴스를 만들 수 있다.


보통 기존의 객체를 응용해서 새로운 인스턴스를 만들때 유용하게 쓸 수 있다.  
특히나 기존에 인스턴스를 만들때 시간이 오래 걸리는 작업 (db에서 데이터르 읽어와서 인스턴스를 만든다거나, Http 요청으로 데이터를 받아와서 인스턴스를 만들때 )  
이런경우 인스턴스를만들때 마다 db와 네트웍을 타야하지만  
기존에 db와 네트웍을 호출해 만들어진 객체를 가지고 있는 데이터를 복제를해서 인스턴스를 만들고 원하는값만 일부 변경해서 사용한다면  
훨씬 효율적일 수 있다.  

![image](https://user-images.githubusercontent.com/60100532/191623744-85b85c95-5c52-4117-92bd-f1787267fcd4.png)

### 코드로 프로토타입 패턴을 알아보자.

```java

public class GithubRepository {

    private String user;

    private String name;

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}

```
```java

public class GithubIssue {

  private int id;

  private String title;

  private GithubRepository repository;

  public GithubIssue(GithubRepository repository) {
    this.repository = repository;
  }

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public GithubRepository getRepository() {
    return repository;
  }

  public String getUrl() {
    return String.format("https://github.com/%s/%s/issues/%d",
            repository.getUser(),
            repository.getName(),
            this.getId());
  }
}

 ```
```java

public class App {

    public static void main(String[] args) {
        GithubRepository repository = new GithubRepository();
        repository.setUser("whiteship");
        repository.setName("live-study");

        GithubIssue githubIssue = new GithubIssue(repository);
        githubIssue.setId(1);
        githubIssue.setTitle("1주차 과제: JVM은 무엇이며 자바 코드는 어떻게 실행하는 것인가.");

        String url = githubIssue.getUrl();
        System.out.println(url);
        
        /**
         *     GithubRepository repository = new GithubRepository();
         *         repository.setUser("whiteship");
         *         repository.setName("live-study");
         *
         *         GithubIssue githubIssue = new GithubIssue(repository);
         *         githubIssue.setId(1);
         *         githubIssue.setTitle("1주차 과제: JVM은 무엇이며 자바 코드는 어떻게 실행하는 것인가.");
         */
        
        // 인스턴스를 새로 만드는 것이 아닌 기존에 있는 githubIssue를 활용해 복사한다음 원하는 데이터만 변경
        GithubIssue clone = githubIssue.clone();
        // clone != githubIssue
        // clone.equals(githubIssue) true

        clone.setId(2);
        clone.setTitle("2주차 과제");
    }
}
```
Clone이랑 메소드는 Object안에 들어있다.!!!
![image](https://user-images.githubusercontent.com/60100532/191715979-6c19ece7-dd8c-45de-80e4-a7eab78e7ff4.png)

하지만 protected라 바로 사용할 수 없다.

```java

public class GithubIssue implements Cloneable {

    private int id;

    private String title;

    private GithubRepository repository;

    public GithubIssue(GithubRepository repository) {
        this.repository = repository;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public GithubRepository getRepository() {
        return repository;
    }

    public String getUrl() {
        return String.format("https://github.com/%s/%s/issues/%d",
                repository.getUser(),
                repository.getName(),
                this.getId());
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        GithubIssue that = (GithubIssue) o;
        return id == that.id && Objects.equals(title, that.title) && Objects.equals(repository, that.repository);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, title, repository);
    }

}
```


자바가 기본으로 제공해주는 클론을 사용하려면 Cloneable을 implements하고

아래와 같은방식으로 사용할 수 있다.
```java
    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
```

이제 clone을 사용해 보자.

```java

public class App {

    public static void main(String[] args) throws CloneNotSupportedException {
        GithubRepository repository = new GithubRepository();
        repository.setUser("whiteship");
        repository.setName("live-study");

        GithubIssue githubIssue = new GithubIssue(repository);
        githubIssue.setId(1);
        githubIssue.setTitle("1주차 과제: JVM은 무엇이며 자바 코드는 어떻게 실행하는 것인가.");

        String url = githubIssue.getUrl();
        System.out.println(url);
        //https://github.com/whiteship/live-study/issues/1

        GithubIssue clone = (GithubIssue) githubIssue.clone();
        System.out.println(clone.getUrl());
        //https://github.com/whiteship/live-study/issues/1



        System.out.println(clone != githubIssue); //true
        System.out.println(clone.equals(githubIssue));//true
        System.out.println(clone.getClass() == githubIssue.getClass());//true
    }
}
```
자바가 기본적으로 제공해주는 clone은 shallow copy이다.
![image](https://user-images.githubusercontent.com/60100532/191718874-884421d3-bfd4-4be6-8d9d-0a561f3e6d35.png)

shallow copy면 clone된 인스턴스도 clone대상이 갖고있던 레퍼런스를 그대로 바라보기 때문에 
만약에 클론을 만들고 나서 레퍼런스를 변경하면 clone의 값도 변경된다.

다음 코드를 보자.

```java

public class App {

    public static void main(String[] args) throws CloneNotSupportedException {
        GithubRepository repository = new GithubRepository();
        repository.setUser("whiteship");
        repository.setName("live-study");

        GithubIssue githubIssue = new GithubIssue(repository);
        githubIssue.setId(1);
        githubIssue.setTitle("1주차 과제: JVM은 무엇이며 자바 코드는 어떻게 실행하는 것인가.");

        String url = githubIssue.getUrl();
        System.out.println(url);
        //https://github.com/whiteship/live-study/issues/1



        GithubIssue clone = (GithubIssue) githubIssue.clone();
        System.out.println(clone.getUrl());
        //https://github.com/whiteship/live-study/issues/1
        repository.setUser("Keesun");

        System.out.println(clone != githubIssue); // true
        System.out.println(clone.equals(githubIssue)); // true
        System.out.println(clone.getClass() == githubIssue.getClass()); // true
        System.out.println(clone.getRepository() == githubIssue.getRepository()); // true

        System.out.println(clone.getUrl());
        //https://github.com/Keesun/live-study/issues/1
    }
}
```
레퍼런스인 repository의 속성값을 변경했더니 clone의 값도 변경되었다!!!

만약 deep copy을 구현해야한다면 자바가 기본으로 제공해주는 clone을 직접 구현하면 된다.  
아래와 같은 방식으로 구현할 수 있다.

```java
    @Override
    protected Object clone() throws CloneNotSupportedException {
        GithubRepository repository = new GithubRepository();
        repository.setUser(this.repository.getUser());
        repository.setName(this.repository.getName());

        GithubIssue githubIssue = new GithubIssue(repository);
        githubIssue.setId(this.id);
        githubIssue.setTitle(this.title);

        return githubIssue;
    }
```

<br/> 

<br/> 

___
___ 

* ### 프로토타입 패턴을 적용했을 때의 장단점
* 장점
  * 복잡한 객체를 만드는 과정을 숨길 수 있다.
  * 기존 객체를 복제하는 과정이 새 인스턴스를 만드는 것보다 비용(시간 또는 메모리)적인 면에서 효율적일 수도 있다.
  * 추상적인 타입을 리턴할 수 있다.
* 단점
  * 복제한 객체를 만드는 과정 자체가 복잡할 수 있다.(특히, 순환 참조가 있는 경우)


___  


<br/> 

<br/> 

### 프로토타입 패턴 실무에서는 어떻게 쓰이나?

* 자바 Object클래스의 clone 메소드와 Cloneable 인터페이스
* shallow copy와 deep copy
* ModelMapper

프로토타입 패턴은 아니지만 다음 예제를 한번 살펴 보자.

```java
public class JavaCollectionExample {

    public static void main(String[] args) {
        Student keesun = new Student("keesun");
        Student whiteship = new Student("whiteship");
        List<Student> students = new ArrayList<>();
        students.add(keesun);
        students.add(whiteship);

        // ArrayList<Student> clone = (ArrayList<Student>) students.clone();

        List<Student> clone = new ArrayList<>(students);
        System.out.println(clone);
    }
}
```

![image](https://user-images.githubusercontent.com/60100532/191971794-30c5282a-0849-45d7-8ec4-c2f74e16bb7b.png)
ArrayList가 구현하고있는 Cloneable을 사용해서 clone을 할 수 있지만
```java
ArrayList<Student> clone = (ArrayList<Student>) students.clone(); 
```

이 방법은 잘 쓰이지 않는다.

우리는 보통 어떤 변수에 타입을 지정할때 가능한 그 타입을 추상적인 타입을 사용한다.  
해서 보통  ArrayList<Student> students = new ArrayList<>();가 아닌 List<Student> students = new ArrayList<>();로 선언한다.
추상적인 타입을 사용해 좀더 유연하게 가져갈 수 있다.  
추상적인 타입을 사용하면 뒤에오는 오브젝트를 추상적인 타입을 구현한 다른 구현체로 얼마든지 바꿀 수 있다.
  
  
하지만 List는 Cloneable을 상속하고 있지 않다.  
해서 보통은 위의 예제 코드 처럼 생성자를 사용한다.
(엄밀하게 따지만 프로토타입은 아니다)
```java
List<Student> clone = new ArrayList<>(students);
```

  


