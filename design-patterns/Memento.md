# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 메멘토 (Memento) 패턴
* 캡슐화를 유지하면서 객체 내부 상태를 외부에 저장하는 방법
* 객체 상태를 외부에 저장했다가 해당 상태로 다시 복구할 수 있다.
 
![image](https://user-images.githubusercontent.com/60100532/204077449-9c9b5346-9f6f-4551-a8e4-58dc9ad2fe7a.png)

### 코드로 메멘토 패턴을 알아보자.
 
### Client code

```java
public class Client {

  public static void main(String[] args) {
    Game game = new Game();
    game.setRedTeamScore(10);
    game.setBlueTeamScore(20);

    int blueTeamScore = game.getBlueTeamScore();
    int redTeamScore = game.getRedTeamScore();

    Game restoredGame = new Game();
    restoredGame.setBlueTeamScore(blueTeamScore);
    restoredGame.setRedTeamScore(redTeamScore);
  }
}


```
### Game
```java
public class Game implements Serializable {

  private int redTeamScore;

  private int blueTeamScore;

  public int getRedTeamScore() {
    return redTeamScore;
  }

  public void setRedTeamScore(int redTeamScore) {
    this.redTeamScore = redTeamScore;
  }

  public int getBlueTeamScore() {
    return blueTeamScore;
  }

  public void setBlueTeamScore(int blueTeamScore) {
    this.blueTeamScore = blueTeamScore;
  }
}


```
 * 현재 클라이언트 코드에서 Game의 내부 정보인 redTeamScore, blueTeamScore를 알고 있어야 한다. 
 * 나중에 Game의 정보가 변경되면 client code도 변경해야함....
 * 메멘토 패턴을 적용해 Client의 Game클래스의 내부정보의 의존성을 끊어 

### 메멘토 패턴을 적용.
#### Client
```java
public class Client {

    public static void main(String[] args) {
        Game game = new Game();
        game.setBlueTeamScore(10);
        game.setRedTeamScore(20);

        GameSave save = game.save();

        game.setBlueTeamScore(12);
        game.setRedTeamScore(22);

        game.restore(save);

        System.out.println(game.getBlueTeamScore());
        System.out.println(game.getRedTeamScore());
    }
}

```
---  
#### GameSave
```java
public final class GameSave {

    private final int blueTeamScore;

    private final int redTeamScore;

    public GameSave(int blueTeamScore, int redTeamScore) {
        this.blueTeamScore = blueTeamScore;
        this.redTeamScore = redTeamScore;
    }

    public int getBlueTeamScore() {
        return blueTeamScore;
    }

    public int getRedTeamScore() {
        return redTeamScore;
    }
}

```

#### Game
```java
public class Game {

  private int redTeamScore;

  private int blueTeamScore;

  public int getRedTeamScore() {
    return redTeamScore;
  }

  public void setRedTeamScore(int redTeamScore) {
    this.redTeamScore = redTeamScore;
  }

  public int getBlueTeamScore() {
    return blueTeamScore;
  }

  public void setBlueTeamScore(int blueTeamScore) {
    this.blueTeamScore = blueTeamScore;
  }

  public GameSave save() {
    return new GameSave(this.blueTeamScore, this.redTeamScore);
  }

  public void restore(GameSave gameSave) {
    this.blueTeamScore = gameSave.getBlueTeamScore();
    this.redTeamScore = gameSave.getRedTeamScore();
  }

}

```
---
![image](https://user-images.githubusercontent.com/60100532/204077517-f89ab97f-f246-4c34-a247-e37a23efb5e7.png)
___
___

<br/> 

<br/> 

### 메멘토 (Memento) 패턴 장단점
* 장점
    * 캡슐화를 지키면서 상태 객체 상태 스냅샷을 만들 수 있다.
    * 객체 상태 저장하고 또는 복원하는 역할을 Care Taker에게 위임할 수 있다.
    * 객체 상태가 바뀌어도 클라이언트 코드는 변경되지 않는다.
* 단점
    * 많은 정보를 저장하는 Memento를 자주 생성하는 경우 메모리 사용량에 많은 영향을 줄 수 있다.

___
___

<br/> 

<br/> 

### 메멘토 (Memento) 패턴

* 자바
  * 객체 긱렬화, java.io.Serializable
  * java.util.Date

