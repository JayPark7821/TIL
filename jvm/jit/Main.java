package jvm.jit;

/**
 * Main
 *
 * @author jaypark
 * @version 1.0.0
 * @since 2/29/24
 */
public class Main {

    public static void main(String[] args) {
        PrimeNumbers primeNumbers = new PrimeNumbers();
        Integer max = Integer.parseInt(args[0]);
        primeNumbers.generateNumbers(max);
    }
}
