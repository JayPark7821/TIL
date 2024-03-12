package jvm.memory.exploring.string;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.IntStream;

/**
 * Main
 *
 * @author jaypark
 * @version 1.0.0
 * @since 3/12/24
 */
public class Main {

    public static void main(String[] args) {

        Date start = new Date();

        List<String> strings = new ArrayList<>();
        for (int i = 1 ; i < 10_000_000; i++){
            String s = String.valueOf(i).intern();
            strings.add(s);
        }

        Date end = new Date();

        System.out.println("Elapsed time " + ( end.getTime() - start.getTime()));
    }
}
