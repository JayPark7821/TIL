# Design-patterns
## 구조적인 패턴(Structural Patterns)

---
### 컴포짓 (Composite) 패턴
* 그룹 전체와 개별 객체를 동일하게 처리할 수 있는 패턴
* 클라이언트 입장에서는 '전체'나 '부분'이나 모두 동일한 컴포넌트로 인식할 수 있는 계층 구조를 만든다. (Part-Whole Hierarchy)

![image](https://user-images.githubusercontent.com/60100532/192537975-c17c5b75-1ed0-4568-95ee-c4f065510d20.png)
클라이언트는 값을 구할만한 모든 컴포넌트들의 공통적인 인터페이스 타입만 바라본다.

### 코드로 컴포짓 패턴을 알아보자.
#### Bag
```java
public class Bag {

    private List<Item> items = new ArrayList<>();

    public void add(Item item) {
        items.add(item);
    }

    public List<Item> getItems() {
        return items;
    }
}
```
#### Item
```java
public class Item {

    private String name;

    private int price;

    public Item(String name, int price) {
        this.name = name;
        this.price = price;
    }

    public int getPrice() {
        return this.price;
    }
}

```
#### Client
```java
public class Client {

    public static void main(String[] args) {
        Item doranBlade = new Item("도란검", 450);
        Item healPotion = new Item("체력 물약", 50);

        Bag bag = new Bag();
        bag.add(doranBlade);
        bag.add(healPotion);

        Client client = new Client();
        client.printPrice(doranBlade);
        client.printPrice(bag);
    }

    private void printPrice(Item item) {
        System.out.println(item.getPrice());
    }

    private void printPrice(Bag bag) {
        int sum = bag.getItems().stream().mapToInt(Item::getPrice).sum();
        System.out.println(sum);
    }

}

```
 
위 코드를 컴포짓 패턴을 적용해서 변경해보자.   
먼저 모든 컴포넌트들(Bag, Item) 의 공통적인 인터페이스 타입을 만들어 공통적인 getPrice()를 추출해 보자.

#### Component
```java

public interface Component {
	int getPrice();
}

```

다음으로 각각의 컴포넌트에서 공통적인 인터페이서 Component를 구현한다.

```java
public class Item implements Component{

    private String name;

    private int price;

    public Item(String name, int price) {
        this.name = name;
        this.price = price;
    }

    @Override
    public int getPrice() {
        return this.price;
    }
}

```

Bag에서 컴포넌트 Item이 아닌 추상화된 Component 타입을 사용하도록 한다.
```java
public class Bag implements Component {

    private List<Component> components = new ArrayList<>();

    public void add(Component component) {
        components.add(component);
    }

    public List<Component> getComponents() {
        return components;
    }

    @Override
    public int getPrice() {
        return components.stream().mapToInt(Component::getPrice).sum();
    }
}

```

#### client 코드
```java
public class Client {

    public static void main(String[] args) {
        Component doranBlade = new Item("도란검", 450);
        Component healPotion = new Item("체력 물약", 50);

        Bag bag = new Bag();
        bag.add(doranBlade);
        bag.add(healPotion);

        Client client = new Client();
        client.printPrice(doranBlade);
        client.printPrice(bag);
    }

    private void printPrice(Component component) {
        System.out.println(component.getPrice());
    }
}
```


___
___

<br/> 

<br/> 

### 컴포짓 (Composite) 패턴 장단점
* 장점
  * 복잡한 트리 구조를 편리하게 사용할 수 있다.
  * 다형성과 재귀를 활용할 수 있다.
  * 클라이언트 코드를 변경하지 않고 새로운 엘리먼트 타입을 추가할 수 있다. ( 위 클라이언트 코드중 private void printPrice(Component component){})
    * Component 타입을 사용하고 있기 때문에 새로운 컴포넌트가 추가되어도 클라이언트 코드는 변경할 필요가 없다. 
 
* 단점
  * 트리를 만들어야 하기 때문에 (공통된 인터페이스를 정의해야 하기 때문에) 지나치게 일반화 해야 하는 경우도 생길 수 있다.


___
___

<br/> 

<br/> 

### 컴포짓 (Composite) 패턴
실무에서 어떻게 쓰이나?

* 자바
  * Swing 라이브러리
  * JSF (JavaServer Faces) 라이브러리


```java

public class SwingExample {

    public static void main(String[] args) {
        JFrame frame = new JFrame();

        JTextField textField = new JTextField();
        textField.setBounds(200, 200, 200, 40);
        frame.add(textField);

        JButton button = new JButton("click");
        button.setBounds(200, 100, 60, 40);
        button.addActionListener(e -> textField.setText("Hello Swing"));
        frame.add(button);

        frame.setSize(600, 400);
        frame.setLayout(null);
        frame.setVisible(true);
    }
}

```