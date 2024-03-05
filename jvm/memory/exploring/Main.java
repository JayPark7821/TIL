package jvm.memory.exploring;

/**
 * Main
 *
 * @author jaypark
 * @version 1.0.0
 * @since 3/4/24
 */
public class Main {

    public static void calculate(int calcValue){
         calcValue = calcValue + 100;
    }
    public static void main(String[] args) {
        int localValue = 5;
        calculate(localValue);
        System.out.println(localValue);
    }
}
