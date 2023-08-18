# Kotlin Coroutines
* 동시성을 지원하는 라이브러리
* 비동기 non blocking으로 동작하는 코드를 동기 방식으로 작성할 수 있게 지원
  * 컴파일된 후의 결과는 동기적으로 동작하지 않는다.
* CoroutineContext를 통해서 dispatcher, error handling, threadLocal 등을 지원
* CoroutineScope를 통해서 structured concurrency와 cancellation을 제공
* flow.channel 등의 심화 기능을 제공

## Intro
### 동기 스타일 지원

```kotlin
object PersonReactorRepository{
    fun findPersonByName(name: String): Mono<Person>{
     ...   
    }
}

object ArticleFutureRepository{
    fun findArticleById(id: Long): CompletableFuture<Article>{
        ...
    }
}

private val log = kLogger()
fun main(){
    val personRepository = PersonReactorRepository
    val articleRepository = ArticleFutureRepository
  
  personRepository.findPersonByName("jay")
    .flatMap{person -> 
        val future = articleRepository.findArticleById(person.id)
      
      Mono.fromFuture(future)
        .map { article -> person to article}
    }.subscribe{ (person, article) ->
        log.info("person: {}, article: {}", person, article)
    }
}
```

* repository는 각각의 반환값을 CompletableFuture와 Mono로 반환
* 기존 비동기로 구현을 한다면 thenApply나 map, flatMap등을 통해서 chaining하고 subscribe


```kotlin
private val log = kLogger()
fun main() = runBlocking {
    val personRepository = PersonReactorRepository
    val articleRepository = ArticleFutureRepository
  
    val person = personRepository.findPersonByName("jay").awaitSingle()
    val article = articleRepository.findArticleById(person.id).await()
    
  log.info("person: {}, article: {}", person, article)
}
```
* runBlocking과 suspend 함수(awaitSingle, await)를 통해서 동기적 스타일로 변경
* non blocking 하지만 동기처럼 보이는 코드 작성 가능

### CoroutineContext

```kotlin
import kotlin.coroutines.CoroutineContext

var threadLocal = ThreadLocal<String>()
threadLocal.set("hello")
log.info("thread: {}", Thread.currentThread().name)
log.info("threadLocal: {}", threadLocal.get())

runBlocking {
    val context = CoroutineName("custom name") + Dispatchers.IO + threadLocal.asContextElement()
  
    launch(context){
        log.info("thread: {}", Thread.currentThread().name)
        log.info("threadLocal: {}", threadLocal.get())
        log.info("coroutine name : {}", coroutineContext[CoroutineName])
    }
}
```

### Structured concurrency

```kotlin
private val log = kLogger()
private suspend fun structured() = coroutineScope{
    log.info("step 1")
    launch{
        delay(1000)
        log.info("finish launch1")
    }
    log.info("step 2")    
    launch{
        delay(100)
        log.info("finish launch2")
    }
    log.info("step 3")
}

fun main() = runBlocking{
    log.info("start runBlocking")
    structured()
    log.info("end runBlocking")
}
```

* coroutineScope를 통해서 별도의 coroutineScope를 생성
* coroutineScope 내에서는 자직 coroutine이 모두 완료되고 coroutine이 끝남을 보장
* 따라서 launch가 모두 끝나고 end runBlocking 로그가 출력


## Coroutine Basics
### suspend 함수
#### 일반 함수에서 suspend 함수 실행
* suspend 함수는 coroutine 혹은 다른 suspend 함수에서 실행 가능

```kotlin
import kotlinx.coroutines.delay

fun normal(){
    delay(1000) // error
}
```
* Kotlin compiler가 suspend 함수를 변환하는 과정을 파악하기 위해서 
* Finite state machine과 Continuation passing style에 대해서 알아야 함.

--- 

### Finite state machine
#### State machine
* 시스템이 가질 수 있는 상태를 표현하는 추상적인 모델
* state: 시스템의 특정한 상황
* Transition: 하나의 state에서 다른 state로 이동
* Event: state transition을 trigger하는 외부 사건

#### Finite state machine
* Finite state machine은 유한한 개수의 state를 갖는 state machine
* 한 번에 오직 하나의 state만을 가질 수 있다.
* Event를 통해서 하나의 state에서 다른 state로 transition이 가능하다.

#### FSM 구현

```kotlin
private val log = kLogger()
class FsmExample {
    fun execute(label: Int = 0){
        var nextLabel: Int? = null
      
        when(label){
            0 ->{
                log.info("Initial")
                nextLabel = 1
            }
            1 ->{
                log.info("State 1")
                nextLabel = 2
            }
            2 ->{
                log.info("State 2")
                nextLabel = 3
            }
            3 ->{
                log.info("end")
            }
        }
      // transition
      if(nextLabel != null){
        this.execute(nextLabel)
      }
    }
}

fun main(){
    val fsmExample = FsmExample()
    fsmExample.execute()
}
```

#### FSM으로 수식 계산하기

```kotlin
object FsmCalculator{
    data class Shared(
        var result: Int = 0,
        var label: Int = 0,
    )
    
    fun calculate(
      initialValue: Int,
      shared: Shared? = null, 
    ){
        val current = shared?: Shared()
      
        when(current.label){
            0 ->{
                current.result = initialValue
                current.label = 1
            }
            1 ->{
                current.result += 1
                current.label = 2
            }
            2 ->{
                current.result *= 2
                current.label = 3
            }
            3 ->{
                log.info("result: {}", current.result)
                return 
            }
        }
      // transition
      this.calculate(initialValue, current)
    }
}

fun main(){
    FsmCalculator.calculate(5)
}
```

* 주어진 값 x에 대하여 (x + 1) * 2를 계산하여 출력 하는 fsm 재귀 함수
* label을 직접 인자로 넘기는 대신
* shared라는 data class를 통해서 전달.
* 추가로 result에 계산된 결과를 저장하여 재귀 함수에 전달.


---

### Continuation passing style
* Caller가 Callee를 호출하는 상황에서
* Callee는 값을 계산하여 continuation을 실행하고 인자로 값을 전달.
* Continuation은 callee 가장 마지막에서 딱 한 번 실행

### Callback vs Continuation
* Callback
  * 추가로 무엇을 해야 하는지
  * 특정 이벤트가 발생했을때 호출
  * 따라서 어디에서나 여러 번 호출될 수 있다.
* Continuation
  * 다음에 무엇을 해야 하는지
  * 모든 결과를 계산하고 다음으로 넘어가는 상황에서 호출
  * 따라서 마지막에서 딱 한번 호출된다.
  * 로직의 제어를 넘긴다 라고도 볼 수 있다.
  

```kotlin
object CallbackExample{
    fun handleButtonClicked(
        callback: () -> Unit,
        continuation: (count: Int) -> Unit
    ){
        var count = 0
      
      for(i in 0 until 5){
          count++
        callback()
      }
        continuation(count)
    }
}

fun main(){
    CallbackExample.handleButtonClicked(
        callback = { log.info("button clicked") },
        continuation = { count -> log.info("count: {}", count) }
    )
}
```

### Continuation 인터페이스
* Kotlin coroutines에서 Continuation 인터페이스를 제공
* resumeWith를 구현하여 외부에서 해당 continuation을 실행할 수 있는 endPoint 제공
* CoroutineContext 포함

### Continuation 구현

```kotlin
private val log = kLogger()
fun main(){
    var visited = false
    val continuation = object: Continuation<Int>{
        override val context: CoroutineContext
            get() = EmptyCoroutineContext

        override fun resumeWith(result: Result<Int>) {
            if( visited){
                log.info("Result: {}", result)
            } else{
                log.info("Visi now")
                visited = true
            }
        }
    }
  
    continuation.resumeWith(10)
    continuation.resumeWith(10)
    continuation.resumeWithException(IllegalStateException())
}
```

* Continuation 인터페이스를 구현하는 익명 클래스를 생성하여 context와 resumeWith를 구현
* context에는 EmptyCoroutineContext를
* resumeWith에서는 상태에 따라서 다른 코드가 실행
* 결과 뿐만 아니라 에러도 전달 가능.

---

### CPS와 FSM
* Continuation passing style
  * 값을 반환하는 대신 Continuation을 실행

* Finite state machine
  * 함수에 인자로 label을 전달
  * label에 따라서 다른 연산을 수행
  * label을 변경하고 재귀 호출을 통해서 transition

### FSM에 CPS 적용
* 1차 : 직접 연산을 수행하는 부분을 CPS가 적용된 연산 함수로 대체
* 2차 : calculate 함수에 CPS를 적용
  * 결과를 찾은 후 log를 하는 부분이 하드 코딩 되어있다.
  * 이 부분 또한 continuation으로 대체

#### 각 연산에 CPS 적용

```kotlin
private fun initialize(value: Int, cont: Continuation<Int>){
    log.info("initialize")
    cont.resume(value)
}

private fun addOne(value: Int, cont: Continuation<Int>){
    log.info("addOne")
    cont.resume(value + 1)
}

private fun multiplyTwo(value: Int, cont: Continuation<Int>){
    log.info("multiplyTwo")
    cont.resume(value * 2)
}
```

* 각각의 함수는 cont.resume가 무엇을 하는지 모르지만 값을 계산하여 반환하는 대신 cont.resume으로 전달

#### 각 연산에 CPS 적용 2

```kotlin

fun calculate(
  initialValue: Int,
  shared: Shared? = null
) {
    val current = shared ?: Shared()
    val cont = object : Continuation<Int> {
        override val context: CoroutineContext
            get() = EmptyCoroutineContext

        override fun resumeWith(result: Result<Int>) {
            current.result = result.getOrThrow()
            this@FsmCalculator.calculate(initialValue, current)
        }
    }
  
  when(current.label){
        0 ->{
            current.label = 1
            initialize(initialValue, cont)
        }
        1 ->{
            val initialized = current.result as Int
            current.label = 2
            addOne(current.result, cont)
        }
        2 ->{
            val added = current.result as Int
          current.label = 3
          multiplyTwo(current.result, cont)
        }
        3 ->{
            val multiplied = current.result as Int
            log.info("result: {}", multiplied)
            return
        }
  }
}
```

#### calculate에 CPS 적용
```kotlin
import kotlin.coroutines.Continuation
import kotlin.coroutines.EmptyCoroutineContext

fun main(){
    val completion = Continuation<Int>(EmptyCoroutineContext){
        log.info("result: {}", it)
    }
    FsmCalculator.calculate(5, completion)
}
```
* main 함수에서 Continuation을 직접 구현하여 calculate에 전달

```kotlin
import kotlin.coroutines.Continuation

private class CustomContinuation(
    val completion: Continuation<Int>,
    val that: FsmCalculator,
) : Continuation<Int>{
    var result: Any? = null
    var label: Int = 0
  
    override val context: CoroutineContext
            get() = EmptyCoroutineContext
  
    override fun resumeWith(result: Result<Int>) {
        this.result = result.getOrThrow()
        that.calculate(0, this)
    }
  
    fun complete(value: Int){
        completion.resume(value)
    }
}
```

```kotlin
fun calculate(
    initialValue: Int,
    continuation: Continuation<Int>
){
    var cont = if(continuation is CustomContinuation){
        continuation
    } else{
        CustomContinuation(continuation, this)
    }
}
```
* calculate 함수에서는 인자로 받은 continuation이 CustomContinuation인지 확인
  * 외부에서는 CustomContinuation 생성 불가 (private class)
  * 즉 CustomContinuation이 아니라면 main이 전달한 continuation, 맞다면 resumeWith를 통해서 재귀적으로 전달된 continuation
* main이 전달한 Continuation이라면 가장 최초로 호출된 시점이기 때문에 CustomContinuation 생성

```kotlin
  when(cont.label){
        0 ->{
            cont.label = 1
            initialize(initialValue, cont)
        }
        1 ->{
            val initialized = cont.result as Int
            cont.label = 2
            addOne(initialized, cont)
        }
        2 ->{
            val added = cont.result as Int
            cont.label = 3
            multiplyTwo(added, cont)
        }
        3 ->{
            val multiplied = cont.result as Int
            cont.complete(multiplied)  
        }
  }
```
* 각각의 case에서 Shared 객체 대신 CustomContinuation의 label과 result를 이용
* 마지막 state에서는 더 이상 직접 log하지 않고 cont.complete 호출


```kotlin
class FsmCalculator{
  private class CustomContinuation(
    val completion: Continuation<Int>,
    val that: FsmCalculator,
  ) : Continuation<Int>{
    var result: Any? = null
    var label: Int = 0

    override val context: CoroutineContext
      get() = EmptyCoroutineContext

    override fun resumeWith(result: Result<Int>) {
      this.result = result.getOrThrow()
      that.calculate(0, this)
    }

    fun complete(value: Int){
      completion.resume(value)
    }
  }

  fun calculate(
    initialValue: Int,
    continuation: Continuation<Int>
  ){
    var cont = if(continuation is CustomContinuation){
      continuation
    } else{
      CustomContinuation(continuation, this)
    }
  }

  private fun initialize(value: Int, cont: Continuation<Int>){
    log.info("initialize")
    cont.resume(value)
  }

  private fun addOne(value: Int, cont: Continuation<Int>){
    log.info("addOne")
    cont.resume(value + 1)
  }

  private fun multiplyTwo(value: Int, cont: Continuation<Int>){
    log.info("multiplyTwo")
    cont.resume(value * 2)
  }
}

fun main(){
  val completion = Continuation<Int>(EmptyCoroutineContext){
    log.info("result: {}", it)
  }
  FsmCalculator.calculate(5, completion)
}
```

