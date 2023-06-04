# Design-patterns
## 구조적인 패턴(Structural Patterns)

---
### 플라이웨이트 (flyweight) 패턴
* 객체를 가볍게 만들어 메모리 사용을 줄이는 패턴.( 공통 부분 재사용)
* 자주 변하는 속성(또는 외적인 속성, extrinsit)과 변하지 않는 속성(또는 내적인 속성, intrinsit)을 분리하고 재사용하여 메모리 사용을 줄일 수 있다.

![image](https://user-images.githubusercontent.com/60100532/200568408-76c19d4e-f254-4371-ba40-a16b7c2d6d7a.png)


### 다음 코드를 보자

```java
public class Character {

  private char value;

  private String color;

  private String fontFamily;

  private int fontSize;

  public Character(char value, String color, String fontFamily, int fontSize) {
    this.value = value;
    this.color = color;
    this.fontFamily = fontFamily;
    this.fontSize = fontSize;
  }
}
```
```java
public class Client {

    public static void main(String[] args) {
        Character c1 = new Character('h', "white", "Nanum", 12);
        Character c2 = new Character('e', "white", "Nanum", 12);
        Character c3 = new Character('l', "white", "Nanum", 12);
        Character c4 = new Character('l', "white", "Nanum", 12);
        Character c5 = new Character('o', "white", "Nanum", 12);
    }
}

```
위 코드에서 자주 변하는 속성과 자주 변하지 않는 속성을 분리해
플라이웨이트 패턴을 적용해 보자.

```java

public class Character {

    private char value;

    private String color;

    private Font font;

    public Character(char value, String color, Font font) {
        this.value = value;
        this.color = color;
        this.font = font;
    }
}

```

```java

public final class Font {

    final String family;

    final int size;

    public Font(String family, int size) {
        this.family = family;
        this.size = size;
    }

    public String getFamily() {
        return family;
    }

    public int getSize() {
        return size;
    }
}

```
```java
import java.util.HashMap;
import java.util.Map;

public class FontFactory {

    private Map<String, Font> cache = new HashMap<>();

    public Font getFont(String font) {
        if (cache.containsKey(font)) {
            return cache.get(font);
        } else {
            String[] split = font.split(":");
            Font newFont = new Font(split[0], Integer.parseInt(split[1]));
            cache.put(font, newFont);
            return newFont;
        }
    }
}

```
```java

public class Client {

    public static void main(String[] args) {
        FontFactory fontFactory = new FontFactory();
        Character c1 = new Character('h', "white", fontFactory.getFont("nanum:12"));
        Character c2 = new Character('e', "white", fontFactory.getFont("nanum:12"));
        Character c3 = new Character('l', "white", fontFactory.getFont("nanum:12"));
    }
}

```
___
___

<br/> 

<br/> 

### 플라이웨이트 (Flyweight) 패턴 장단점
* 장점
    * 어플리케이션에서 사용하는 메모리를 줄일 수 있다. 

* 단점
    * 코드의 복잡도가 증가한다.
