# Design-patterns
## 구조적인 패턴(Structural Patterns)

---
### 어댑터 (Adapter) 패턴
* 기존 코드를 클라이언트가 사용하는 인터페이스의 구현체로 바꿔주는 패턴
* 클라이언트가 사용하는 인터페이스를 따르지 않는 기존 코드를 재사용할 수 있게 해준다.

>예를 들어보자  
미국에서 사온 110v짜리 냉장고가 있다고 했을때  
이걸 한국에서 사용하려면 변압기를 사용해 220v-> 110v로 변압해줘야 한다.  
여기서 변압기가 우리가 알아볼 어댑터 이다.

![image](https://user-images.githubusercontent.com/60100532/192100095-af48cfd0-8d05-4e0e-9b20-0c102746ebfd.png)


### 코드로 어댑터 패턴을 알아보자.

### 먼저 Target이 될 코드를 살펴보자.
#### interface UserDetails
```java

public interface UserDetails {

    String getUsername();

    String getPassword();

}
```

#### interface UserDetailsService
```java
public interface UserDetailsService {

    UserDetails loadUser(String username);

}
```

### 다음으로 client 코드를 살펴보자.
#### LoginHandler
```java
public class LoginHandler {

    UserDetailsService userDetailsService;

    public LoginHandler(UserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    public String login(String username, String password) {
        UserDetails userDetails = userDetailsService.loadUser(username);
        if (userDetails.getPassword().equals(password)) {
            return userDetails.getUsername();
        } else {
            throw new IllegalArgumentException();
        }
    }
}
```



### 다음으로 Adaptee코드를 살펴보자.


#### Account
```java
public class Account {

    private String name;

    private String password;

    private String email;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
```

#### AccountService
```java
public class AccountService {

    public Account findAccountByUsername(String username) {
        Account account = new Account();
        account.setName(username);
        account.setPassword(username);
        account.setEmail(username);
        return account;
    }

    public void createNewAccount(Account account) {

    }

    public void updateAccount(Account account) {

    }
}
```

위 코드에 adapter 패턴을 적용해 보자.
2가지 방법을 알아볼예정인데 
먼저 별로의 adapter class를 만들어 보자.

#### AccountUserDetailsService
```java

public class AccountUserDetailsService implements UserDetailsService {  // 우리가 맞춰야하는 target interface를 구현함.

    private AccountService accountService; // Adaptee의 클래스 사용

    public AccountUserDetailsService(AccountService accountService) {
        this.accountService = accountService;
    }

    @Override
    public UserDetails loadUser(String username) {
        return new AccountUserDetails(accountService.findAccountByUsername(username));
    }
}

```
#### AccountUserDetails
```java
public class AccountUserDetails implements UserDetails {

    private Account account;

    public AccountUserDetails(Account account) {
        this.account = account;
    }

    @Override
    public String getUsername() {
        return account.getName();
    }

    @Override
    public String getPassword() {
        return account.getPassword();
    }
}

```

```java
public class App {

    public static void main(String[] args) {
        AccountService accountService = new AccountService();
        UserDetailsService userDetailsService = new AccountUserDetailsService(accountService);
        LoginHandler loginHandler = new LoginHandler(userDetailsService);
        String login = loginHandler.login("keesun", "keesun");
        System.out.println(login);
    }
}

```

다음은 Adaptee를 직접 Adapter로 구현해보자
```java
public class Account implements UserDetails {

    private String name;

    private String password;

    private String email;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String getUsername() {
        return this.name;
    }

    @Override
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

}

```

```java
public class AccountService implements UserDetailsService {

    public Account findAccountByUsername(String username) {
        Account account = new Account();
        account.setName(username);
        account.setPassword(username);
        account.setEmail(username);
        return account;
    }

    public void createNewAccount(Account account) {

    }

    public void updateAccount(Account account) {

    }

    @Override
    public UserDetails loadUser(String username) {
        return findAccountByUsername(username);
    }
}

```

___
___

<br/> 

<br/> 

### 어댑터 (Adapter) 패턴 장단점
* 장점
  * 기존 코드(Adaptee)를 변경하지 않고 원하는 인터페이스 구현체를 만들어 재사용할 수 있다. (객체지향 원칙 OCP)
  * 기존 코드가 하던 일과 특정 인터페이스 구현체로 변환하는 작업을 각기 다른 클래스로 분리하여 관리할 수 있다. (단일 책임 원칙 SRP)
* 단점
  * 새 클래스가 생겨 복잡도가 증가할 수 있다. 경우에 따라서는 기존 코드가 해당 인터페이스를 구현하도록 수정하는 것이 좋은 선택이 될 수도 있다.

___
___

<br/> 

<br/> 

### 어댑터 (Adapter) 패턴 
실무에서 어떻게 쓰이나?

* 자바
  * java.util.Arrays#asList(T...)
  * java.util.Collections#list(Enumeration),java.util.Collections#enumeration()
  * java.io.InputStreamReader(InputStream)
  * java.io.OutputStreamWriter(OutputStream)
* 스프링
  * HandlerAdapter : 우리가 작성하는 다양한 형태의 핸들러 코드를 스프링 MVC가 실행할 수 있는 형태로 변환해주는 어댑터용 인터페이스 
  

####  *  자바
```java

public class AdapterInJava {

    public static void main(String[] args) {
        // collections
        List<String> strings = Arrays.asList("a", "b", "c");
        Enumeration<String> enumeration = Collections.enumeration(strings);
        // Strings -> Adaptee
        // Collections.enumeration -> Adapter
        // Enumeration -> target
        ArrayList<String> list = Collections.list(enumeration);

        // io
        try(InputStream is = new FileInputStream("input.txt");
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader reader = new BufferedReader(isr)) {
            while(reader.ready()) {
                System.out.println(reader.readLine());
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
```
 