## Java Memory

* When applications run, they need access to some of our computer's memory,  
  for example, to store the objects that we create  

## Stack
* Every thread has its own stack,   
  One important aspect of the stack is that java knows exactly when data on the stack can be destroyed.


```java
public class Main {

    public static void main(String[] args) {
        int value = 7;
        value = calculate(value);
    }

    public static int calculate(int data){
        int tempValue = data + 3;
        int newValue = tempValue * 2;
        return newValue;
    }
}
```
![img_8.png](img_8.png)    

![img_9.png](img_9.png)  

![img_10.png](img_10.png)  
* parameter data is a copy of the variable that is passed into the calculate method  
  so as we enter the calculate method, a new variable is added to the stack called data  

![img_11.png](img_11.png)  
* when the methods returns, all the data created on the stack for the method that we were in is popped  

![img_12.png](img_12.png)  

![img_13.png](img_13.png)
* when it gets to the closing bracket, the thread is completed and at this point the stack can now be emptied  
  all the memory that was used for the stack can be freed up
