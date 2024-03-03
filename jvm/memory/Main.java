package jvm.memory;

/**
 * Main
 *
 * @author jaypark
 * @version 1.0.0
 * @since 3/3/24
 */
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
