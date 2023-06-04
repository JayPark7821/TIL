# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 커맨드 (Command) 패턴
* 요청을 캡슐화 하여 호출자(invoker)와 수신자(receiver)를 분리하는 패턴
  * 요청을 처리하는 방법이 바뀌더라도, 호출자의 코드는 변경되지 않는다.

![image](https://user-images.githubusercontent.com/60100532/201589765-f853335e-1f24-4203-80a6-a1e3cf0b0fd8.png)

### 코드로 커맨드 패턴을 알아보자.

#### 커맨드 패턴 적용전의 코드를 살펴보자.
#### Button
```java
public class Button {

  private Light light;

  public Button(Light light) {
    this.light = light;
  }

  public void press() {
    light.off();
  }

  public static void main(String[] args) {
    Button button = new Button(new Light());
    button.press();
    button.press();
    button.press();
    button.press();
  }
}

```
#### MyApp
```java
public class MyApp {

  private Game game;

  public MyApp(Game game) {
    this.game = game;
  }

  public void press() {
    game.start();
  }

  public static void main(String[] args) {
    Button button = new Button(new Light());
    button.press();
    button.press();
    button.press();
    button.press();
  }
}
```

#### Game
```java

public class Game {

  private boolean isStarted;

  public void start() {
    System.out.println("게임을 시작합니다.");
    this.isStarted = true;
  }

  public void end() {
    System.out.println("게임을 종료합니다.");
    this.isStarted = false;
  }

  public boolean isStarted() {
    return isStarted;
  }
}


```
#### Light
```java

public class Light {

  private boolean isOn;

  public void on() {
    System.out.println("불을 켭니다.");
    this.isOn = true;
  }

  public void off() {
    System.out.println("불을 끕니다.");
    this.isOn = false;
  }

  public boolean isOn() {
    return this.isOn;
  }
}

```
 
>위 코드의 문제는 receiver(Game, Light)를 직접적으로 사용해 커플링이 심하다.
> 커맨드 패턴을 사용해서 위 문제를 해결해 보자.


#### Command
```java
 public interface Command {

  void execute();

  void undo();
}
```

#### Button
```java

public class Button {

  private Stack<Command> commands = new Stack<>();

  public void press(Command command) {
    command.execute();
    commands.push(command);
  }

  public void undo() {
    if (!commands.isEmpty()) {
      Command command = commands.pop();
      command.undo();
    }
  }

  public static void main(String[] args) {
    Button button = new Button();
    button.press(new GameStartCommand(new Game()));
    button.press(new LightOnCommand(new Light()));
    button.undo();
    button.undo();
  }
}
```

#### MyApp
```java
public class MyApp {

  private Command command;

  public MyApp(Command command) {
    this.command = command;
  }

  public void press() {
    command.execute();
  }

  public static void main(String[] args) {
    MyApp myApp = new MyApp(new GameStartCommand(new Game()));
  }
}

```
#### GameStartCommand

```java
public class GameStartCommand implements Command {

  private Game game;

  public GameStartCommand(Game game) {
    this.game = game;
  }

  @Override
  public void execute() {
    game.start();
  }

  @Override
  public void undo() {
    new GameEndCommand(this.game).execute();
  }
}


```

#### GameEndCommand

```java
public class GameEndCommand implements Command {

  private Game game;

  public GameEndCommand(Game game) {
    this.game = game;
  }

  @Override
  public void execute() {
    game.end();
  }

  @Override
  public void undo() {
    new GameStartCommand(this.game).execute();
  }
}

```



#### LightOnCommand
```java
public class LightOnCommand implements Command {

  private Light light;

  public LightOnCommand(Light light) {
    this.light = light;
  }

  @Override
  public void execute() {
    light.on();
  }

  @Override
  public void undo() {
    new LightOffCommand(this.light).execute();
  }
}

```

#### LightOffCommand 
```java
public class LightOffCommand implements Command {

  private Light light;

  public LightOffCommand(Light light) {
    this.light = light;
  }

  @Override
  public void execute() {
    light.off();
  }

  @Override
  public void undo() {
    new LightOnCommand(this.light).execute();
  }
}

```
![image](https://user-images.githubusercontent.com/60100532/201592826-7d685d16-e028-474a-808b-2fb0be1328a0.png)


___
___

<br/> 

<br/> 

### 커맨드 (Command) 패턴 장단점
* 장점
  * 기존 코드를 변경하지 않고 새로운 커맨드를 만들 수 있다.
  * 수신자의 코드가 변경되어도 호출자의 코드는 변경되지 않는다.
  * 커맨드 객체를 로깅, DB에 저장, 네트워크로 전솓ㅇ 하는 등 다양한 방법으로 활용할 수도 있다.
* 단점
  * 코드가 복잡해지고 클래스가 많아진다.

___
___

<br/> 

<br/> 

### 커맨드 (Command) 패턴 

* 자바
  * Runnable
  * 람다
  * 메소드 레퍼런스
  
* 스프링
  * SimpleJdbcInsert
  * SimpleJdbcCall
  
 