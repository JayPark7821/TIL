package jvm.memory;

import java.util.ArrayList;
import java.util.List;

/**
 * Main
 *
 * @author jaypark
 * @version 1.0.0
 * @since 3/3/24
 */
public class Main {

    public static void main1(String[] args) {
        int value = 7;
        value = calculate(value);
    }

    public static int calculate(int data){
        int tempValue = data + 3;
        int newValue = tempValue * 2;
        return newValue;
    }

    public static void main(String[] args) {
        List<String> myList = new ArrayList<>();
        myList.add("one");
        myList.add("two");
        myList.add("three");
        printList(myList);
    }

    private static void printList(List<String> myList) {
        System.out.println(myList);
    }
}
