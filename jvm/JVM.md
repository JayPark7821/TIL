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
