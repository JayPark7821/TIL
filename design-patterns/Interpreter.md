# Design-patterns
## 행동 관련 패턴(Behavioral Patterns)

---
### 인터프리터 (Interpreter) 패턴
* 자주 등장하는 문제를 간단한 언어로 정의하고 재사용하는 패턴
* 반복되는 문제 패턴을 언어 또는 문법으로 정의하고 확장할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/201877319-ce5eabaf-85eb-4afb-b7e6-4b9eac9c2bc5.png)

### 코드로 인터프리터 패턴을 알아보자.

```java
public class PostfixNotation {

  private final String expression;

  public PostfixNotation(String expression) {
    this.expression = expression;
  }

  public static void main(String[] args) {
    PostfixNotation postfixNotation = new PostfixNotation("123+-");
    postfixNotation.calculate();
  }

  private void calculate() {
    Stack<Integer> numbers = new Stack<>();

    for (char c : this.expression.toCharArray()) {
      switch (c) {
        case '+':
          numbers.push(numbers.pop() + numbers.pop());
          break;
        case '-':
          int right = numbers.pop();
          int left = numbers.pop();
          numbers.push(left - right);
          break;
        default:
          numbers.push(Integer.parseInt(c + ""));
      }
    }

    System.out.println(numbers.pop());
  }
}

```

### 인터프리터 패턴을 적용.

---  
#### Client 코드
```java
public class App {

  public static void main(String[] args) {
    PostfixExpression expression = PostfixParser.parse("xyz+-a+");
    int result = expression.interpret(Map.of('x', 1, 'y', 2, 'z', 3, 'a', 4));
    System.out.println(result);
  }
}

```
#### PostfixExpression
```java
public interface PostfixExpression {
  int interpret(Map<Character, Integer> context);
}
```

#### VariableExpression
```java
public class VariableExpression implements PostfixExpression {

  private Character character;

  public VariableExpression(Character character) {
    this.character = character;
  }

  @Override
  public int interpret(Map<Character, Integer> context) {
    return context.get(this.character);
  }
}

```
---
 
#### PlusExpression
```java
public class PlusExpression implements PostfixExpression {

  private PostfixExpression left;

  private PostfixExpression right;

  public PlusExpression(PostfixExpression left, PostfixExpression right) {
    this.left = left;
    this.right = right;
  }

  @Override
  public int interpret(Map<Character, Integer> context) {
    return left.interpret(context) + right.interpret(context);
  }
}

```

#### MinusExpression
````java
public class MinusExpression implements PostfixExpression {

  private PostfixExpression left;

  private PostfixExpression right;

  public MinusExpression(PostfixExpression left, PostfixExpression right) {
    this.left = left;
    this.right = right;
  }

  @Override
  public int interpret(Map<Character, Integer> context) {
    return left.interpret(context) - right.interpret(context);
  }
}

````

#### PostfixParser
```java

public class PostfixParser {

  public static PostfixExpression parse(String expression) {
    Stack<PostfixExpression> stack = new Stack<>();
    for (char c : expression.toCharArray()) {
      stack.push(getExpression(c, stack));
    }
    return stack.pop();
  }

  private static PostfixExpression getExpression(char c, Stack<PostfixExpression> stack) {
    switch (c) {
      case '+':
        return new PlusExpression(stack.pop(), stack.pop());
      case '-':
        PostfixExpression right = stack.pop();
        PostfixExpression left = stack.pop();
        return new MinusExpression(left, right);
      default:
        return new VariableExpression(c);
    }
  }
}

```
---
![image](https://user-images.githubusercontent.com/60100532/201884792-fc9406bc-e252-4c71-a323-c3bd8785a766.png)
___
___

<br/> 

<br/> 

### 인터프리터 (Interpreter) 패턴 장단점
* 장점
    * 자주 등장하는 문제 패턴을 언어와 문법으로 정의할 수 있다.
    * 기존 코드를 변경하지 않고 새로운 Expression을 추가할 수 있다.
* 단점
    * 복잡한 문법을 표현하려면 Expression과 Parser가 복잡해진다.


___
___

<br/> 

<br/> 

### 인터프리터 (Interpreter) 패턴

* 자바
  * 자바 컴파일러
  * 정규 표현식
* 스프링
  * SpEL(스프링 Expression Language)
