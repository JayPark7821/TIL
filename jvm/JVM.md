## What happends inside the JVM
* the code we write is compiled into bytecode by the java compiler
* then the bytecode is executed by the JVM

![img.png](img.png)


<br />   

* Often think the virtual machine is interpreting the bytecode,   
 but it contains a number of features and complex algorithms to make it more efficient than that.


<br />   

* Like C, which would be complied to native machine code,  
  which means the code is complied into a runnable format that te operating system can comprehend directly.  
  It doesn't need to be interpreted by another program.  
  This makes it quick to run compared to interpreted languages.


<br />   

* To help get around this problem of slower execution in interpreted languages then complied languages like c  
  the JVM has a feature called Just-In-Time (JIT) compilation.


<br />   

* The JVM will monitor which branches of code are run the most often, which methods or parts of methods.  
  specifically loops are executed the most often, and then the JVM can decide,  
  for example that a particular method should be compiled into native machine code.  
  So at this point, some of our application is being run in interpreted mode as bytecode,  
  and some is no longer bytecode but is running as complied native machine code.  
  Just to be clear, then by native machine code, we mean the code that the operating system can run directly.

<br />   

* The JVM is of course a multi-threaded applciation itself,  
  so the threads within the JVM responsible for running the code that is interpreting the bytecode and executing the bytecode  
  won't be affected by the threads that are running the JIT compilation.
  so the process of JIT compilation doesn't stop the application from running.
  while the compilation is taking place, The JVM will continue to use interpreted version but once,  
  that compilation is complete then the native machine code version is available to be used,  
  the JVM can switch to using that instead of the interpreted version.

<br />   


```java
public class Main {

    public static void main(String[] args) {
        PrimeNumbers primeNumbers = new PrimeNumbers();
        Integer max = Integer.parseInt(args[0]);
        primeNumbers.generateNumbers(max);
    }
}
```

```java
import java.util.ArrayList;
import java.util.List;

public class PrimeNumbers {

	private List<Integer> primes;
	
	private Boolean isPrime(Integer testNumber) {
		for (int i = 2; i < testNumber; i++) {
			if (testNumber % i == 0) return false;
		}
		return true;
	}
	
	private Integer getNextPrimeAbove(Integer previous) {
		Integer testNumber = previous + 1;
		while (!isPrime(testNumber)) {
			testNumber++;
		}
		return testNumber;
	}
	
	public void generateNumbers (Integer max) {
		primes = new ArrayList<Integer>();
		primes.add(2);

		Integer next = 2;
		while (primes.size() <= max) {
			next = getNextPrimeAbove(next);
			primes.add(next);
		}
//		System.out.println(primes);
	}

}
```  
* run with java  -XX:+PrintCompilation Main 5000  

![img_1.png](img_1.png)  
![img_2.png](img_2.png)  
![img_3.png](img_3.png)

* The first column is the number of milliseconds since JVM started
* The second column is the order or code block was compiled
* The third column has few different value, 
  * N means native method
  * S means it's synchronized method
  * ! means there's some exception handling going on
  * % means that the code has bean natively compiled and is now running in a special part of memory called the code cache  
    that means the method is now running in the most optimal way possible.
* The fourth column has number from 0 to 4 and this tells us what kind of compiling has taken place
  * 0 means no compilation the code has just been interpreted
  * 1 to 4 mean that progressively deeper level of compilation has happened



<br />   

* There are actually two compilers built into the JVM called C1 and C2
  * C1 is able to do the first three levels of compilation level 1, 2, 3 each progressively more complex then the last one
  * C2 can to the fourth level of compilation 
* The JVM decides which level of compilation to apply to a particular code blocks based on how often it's run and how complex it is.  
  -> this called profiling the code  

` run the sample code with java  -XX:+UnlockDiagnosticVMOptions -XX:+LogComilation jvm.jit.Main 5000`
![img_5.png](img_5.png)
![img_4.png](img_4.png)


* So the JVM place the code into the code cache if it's going to be used a lot.  
  but the code cache has limited size and if there are lots of methods that could be saved in the code cache  
  then some will need to removed from the code cache to make space for the next one.  
  the removed ones could be recompiled and re-added later on

* if the code cache is full, we can see the following warning message appear in the console  
`VM warning: CodeCache is full. Compiler has been disabled.`  
* this tells us that the application would run better if another part of code could be compiled to native machine code  
  but there's no there's no space in the code cache to do that.
* we can find out the size of the code cache by using JVM flag which is `-XX:+PrintCodeCache`  

![img_6.png](img_6.png)

* we can change the code cache size with following three different flags
  * `InitialCodeCacheSize` - the size of the code cache when the application starts  
  * `ReservedCodeCacheSize`  - the maximum size of the code cache
  * `CodeCacheExpansionSize` - the amount by which the code cache will grow if it needs to expand  
![img_7.png](img_7.png)


* with `-XX:-TieredCompilation` we can turn off tiered compilation to tell the JVM to run in interpreted mode only  
  maybe an application that is running one line of code only, maybe like serverless application for example, that wil fire up  
  run a single statement and then shut down again could conceivably be quicker using interpreted mode only.

* there are two factors that can affect the performance of out application  
  the first is how many threads are available to run this compiling process  
  the second is what's the threshold for native compilation

` can change the number of threads for compilation with -XX:CICompilerCount={number of threads}`    

` can change the threshold for native compilation with -XX:CompileThreshold={number of threshold}`






