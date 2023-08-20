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

---

### 동기, 비동기, Coroutine 비교
#### 주문 생성 동기
* 구매자의 userId와 구매하려는 상품들의 id가 주어졌을때
* userId로 고객 정보를 조회하고
* 상품 id로 상품 정보를 조회한 후
* 상품 정보로 스토어 정보를 조회하고
* 고객 정보로 주소를 조회하고 
* 이 모든 값으로 주문 생성

```kotlin
fun execute(userId: Long, productIds: List<Long>): Order {
    // 1. 고객 정보 조회
    val customer = customerService.findCustomerById(userId)
    
    // 2. 상품 정보 조회
    val products = productService.findAllProductsByIds(productIds)
  
    // 3. 스토어 조회
    val storeIds = products.map{it.storeId} 
    val stores = storeService.findStoresByIds(storeIds)
  
    // 4. 주소 조회
    val daIds = customer.deliveryAddressIds
    val deliveryAddress = deliveryAddressService
                            .findDeliveryAddress(daIds)
                            .first()
  
    // 5. 주문 생성
    val order = OrderService.createOrder(customer, products, deliveryAddress, stores)
  
    return order
}
```
```kotlin
fun main(args: Array<String>){
    val customerService = CustomBlockingService()
    val productService = ProductBlockingService()
    val storeService = StoreBlockingService()
    val deliveryAddressService = DeliveryAddressBlockingService()
    val orderService = OrderBlockingService()
  
    val example = OrderBlockingExample(
        customerService = customerService,
        productService = productService,
        storeService = storeService,
        deliveryAddressService = deliveryAddressService,
        orderService = orderService,
    )
    
    val order = example.execute(1, listOf(1, 2, 3))
    log.info("order: {}", order)
}
```

#### 주문생성 비동기
* CustomerFutureService: 유저 id로 고객 정보를 찾고 java8의 CompletableFuture로 반환
```kotlin
import java.util.concurrent.CompletableFuture

class CustomFutureService{
    fun findCustomerFuture(id: Long): CompletableFuture<Customer>{
        return CompletableFuture.supplyAsync{
            Thread.sleep(1000)
            Customer(id, "jay", listOf(1,2,3))
        }
    }
}
```
* ProductRxjava3Service: 상품 id 목록을 받고 상품들을 찾아서 rxjava3의 Flowable로 반환
```kotlin
class ProductRxjava3Service {
    fun findAllProductsFlowable(
        ids: List<Long>
    ): Flowable<Product> {
        return Flowable.create({ emitter ->
            ids.forEach {
                Thread.sleep(1000)
                val p = Product(it, "product-$it", 1000L + it)
                emitter.onNext(p)
            }
            emitter.onComplete()
        }, BackpressureStrategy.BUFFER)
    }
}
```
* StoreMutinyService: 스토어 id 목록을 받고 해당하는 스토어 목록을 mutiny의 Multi로 반환
```kotlin
class StoreMutinyService {
    fun findStoresMulti(storeIds: List<Long>): Multi<Store> {
        return Multi.createFrom().emitter{
            storeIds.map{id ->
                Store(id, "store-$id")
            }.forEach { store ->
                Thread.sleep(1000)
                it.emit(store)
            }
          it.complete()
        }
    }
}
```
* DeliveryAddressPublisherService: 주소 id 목록을 받고 주소를 찾아서 reactive stream의 Publisher로 반환
```kotlin
class DeliveryAddressPublisherService{
    fun findDeliveryAddressesPublisher(
        ids: List<Long>
    ): Publisher<DeliveryAddress>{
        return Flux.create { sink ->
            ids.map { id -> 
                DeliveryAddress(
                    id =id,
                    roadNameAddress = "도로명 주소 $id",
                    detailAddress = "상세 주소 $id"
                )
            }.forEach{
                Thread.sleep(1000)
                sink.next(it)
            }
            sink.complete()
        }
    }
}
```

* OrderReactorService: customer, products, deliveryAddress, stores등을 인자로 받고 이를 기반으로 Order를 생성하여 Mono로 반환
```kotlin
class OrderReactorService{
    fun createOrderMono(
        customer: Customer,
        products: List<Product>,
        deliveryAddress: DeliveryAddress,
        stores: List<Store>
    ): Mono<Order>{
        return Mono.create {sink ->
            Thread.sleep(1000)
            sink.success(
                Order(
                    stores = stores,
                    products = products,
                    customer = customer,
                    deliveryAddress = deliveryAddress,
                )
            )
        }
    }
}
```

```kotlin
fun execute(userId: Long, productIds: List<Long>) {
    //1.고객 정보 조회 
    customerService.findCustomerFuture(userId).thenAccept { customer ->
        //2.상품 정보 조회 
        productService.findAllProductsFlowable(productIds)
            .toList()
            .subscribe { products ->
                // 3. 스토어 조회
                val storeIds = products.map { it.storeId }
                storeService.findStoresMutli(storeIds)
                    .collect().asList()
                    .subscribe()
                    .with { stores ->
                        // 4. 주소 조회
                        val daIds = customer.deliveryAddressIds
                        deliveryAddressService.findDeliveryAddressesPublisher(daIds)
                            .subscribe(FirstFinder { deliveryAddress ->
                                // 5. 주문 생성 
                                orderService.createOrderMono(
                                    customer, products, deliveryAddress, stores,
                                ).subscribe { order ->
                                    log.info("order: {}", order)
                                }
                            })
                    }
            }
    }
}
```
* subscribe hell....

### 위 비동기 코드에 FSM 적용
* Shared 클래스 생성
```kotlin
class Shared {
    var result: Any? = null
    var label = 0
  
    lateinit var customer: Customer
    lateinit var products: List<Product>
    lateinit var stores: List<Store>
    lateinit var deliveryAddress: DeliveryAddress
}
```
* shared를 인자로 받고 기본 값으로 null을 제공
* main에서 최초로 실행하는 경우 null이 전달되기 때문에 Shared 객체 생성
```kotlin
fun execute(
    userId: Long,
    productIds: List<Long>,
    shared: Shared? = null
){
    val con = shared?: Shared()
}
```
```kotlin
fun main(args: Array<String>){
    val customerService = CustomerFutureService()
    val productService = ProductRxjava3Service()
    val storeService = StoreMutinyService()
    val deliveryAddressService = DeliveryAddressPublisherService()
    val orderService = OrderReactorService()
  
    val example = OrderReactorExample(
        customerService = customerService,
        productService = productService,
        storeService = storeService,
        deliveryAddressService = deliveryAddressService,
        orderService = orderService,
    )
  
    example.execute(1, listOf(1, 2, 3))
}
```

* Shared의 label 값에 따라서 다른 case문이 실행
* case 문에서는 label을 변경하고 
* 이전에 시행됐던 결과를 shared 내부의 중간값에 저장

```kotlin
when (cont.label) {
    0 -> {
        //1.고객 정보 조회 
        cont.label = 1
        ...
    }
    1 -> {
        //2.상품 정보 조회
        cont.customer = cont.result as Customer
        cont.label = 2
        ...
    }
    2 -> {
        // 3. 스토어 조회
        cont.products = cont.result as List<Product>
        cont.label = 3
        ...
    }
    3 -> {
        // 4. 주소 조회
        cont.stores = cont.result as List<Store>
        cont.label = 4
        ...
    }
    4 -> {
        // 5. 주문 생성
        cont.deliveryAddress = cont.result as DeliveryAddress
        cont.label = 5
        ...
    }
    5 -> {
        val order = cont.result as Order
        log.info("order: {}", order)
    }

}
```

* findCustomerFuture의 thenAccept가 실행 된 후 customer를 구하고 cont.result에 값을 저장 후 재귀 호출
* label이 1로 바뀐 후 재귀 호출이 발생했기 때문에 1번 케이스로
* cont.result의 값을 cont.customer로 옮기고
* findAllProductsFlowable에서 products를 구하고 cont.result에 값을 저장한 후 재귀 호출

```kotlin
when (cont.label) {
    0 -> {
        //1.고객 정보 조회 
        cont.label = 1

        customerService.findCustomerFuture(userId)
            .thenAccept { customer ->
                cont.result = customer
                execute(userId, productIds, cont)
            }

    }
    1 -> {
        //2.상품 정보 조회
        cont.customer = cont.result as Customer
        cont.label = 2

        productService.findAllProductsFlowable(productIds)
            .toList()
            .subscribe { products ->
                cont.result = products
                execute(userId, productIds, cont)
            }
    }
    2 -> {
        // 3. 스토어 조회
        cont.products = cont.result as List<Product>
        cont.label = 3
        
        val products = cont.products
        val storeIds = products.map { it.storeId }
        storeService.findStoresMutli(storeIds)
              .collect().asList()
              .subscribe()
              .with { stores ->
                  cont.result = stores
                  execute(userId, productIds, cont)
              }
    }
    3 -> {
        // 4. 주소 조회
        cont.stores = cont.result as List<Store>
        cont.label = 4
        
        val customer = cont.customer
        val daIds = customer.deliveryAddressIds
        deliveryAddressService.findDeliveryAddressesPublisher(daIds)
            .subscribe(FirstFinder { deliveryAddress ->
                cont.result = deliveryAddress
                execute(userId, productIds, cont)
            })
    }
    4 -> {
        // 5. 주문 생성
        cont.deliveryAddress = cont.result as DeliveryAddress
        cont.label = 5
        
        val customer = cont.customer
        val products = cont.products
        val deliveryAddress = cont.deliveryAddress
        val stores = cont.stores
      
        orderService.createOrderMono(
            customer, products, deliveryAddress, stores,
        ).subscribe { order ->
            cont.result = order
            execute(userId, productIds, cont)
        }
    }
    5 -> {
      val order = cont.result as Order
      log.info("order: {}", order)
    }
} 
```

### FSM 기반에서 문제점
* cont.result에 값을 넣고 재귀 함수를 실행하는 부분이 반복적으로 발생
* 재귀 함수를 직접 호출하기 때문에 외부로 분리하기 힘들다.
* main 함수에서는 Shared를 생성하지 않기 때문에 결과를 출력하는 부분이 하드 코딩되어 있다.
-> Continuation을 전달하는 형태로 변경

### CPS 적용하기 
* Shared 객체를 CustomContinuation 객체로 변경
* CustomContinuation은 main으로부터 Continuation을 받는다 (이하 completion)
* 중간값들 뿐만 아니라 arguments와 instance 까지 Continuation에 저장
* context와 resumeWith을 override
* resumeWith에서는 this.result를 갱신하고 that(instance)의 execute를 호출
* 가장 마지막 state에서 complete를 호출하여 completion 호출

```kotlin
import kotlin.coroutines.Continuation

private class CustomContinuation(
    private val completion: Continuation<Any>,
) : Continuation<Any> {
    var result: Any? = null
    var label = 0

    // arguments and instance
    lateinit var that: OrderAsyncExample
    var userId by Delegates.notnull<Long>()
    lateinit var productIds: List<Long>

    // variables
    lateinit var customer: Customer
    lateinit var products: List<Product>
    lateinit var stores: List<Store>
    lateinit var deliveryAddress: DeliveryAddress

    override val context: CoroutineContext
        get() = completion.context

    override fun resumeWith(result: Result<Any>) {
        this.result = result.getOrThrow()()
        that.execute(0, emptyList(), this)
    }

    fun complete(value: Any) {
        completion.resume(value)
    }   
}
```

```kotlin

import java.beans.Customizerimport kotlin.coroutines.Continuation

fun execute(
  userId: Long,
  productIds: List<Long>,
  continuation: Continuation<Any>
){
    val cont = if(continuation is CustomContinuation){
        continuation
    }else{
        CustomContinuation(continuation).apply {
            that = this@OrderAsyncExample
            this.userId = userId
            this.productIds = productIds
        }
    }
}
```

```kotlin
fun main(args: Array<String>){
    ...
  val cont = Continuation<Any>(EmptyCoroutineContext) {
    log.info("order: {}", order)
  }
  
  example.execute(1, listOf(1, 2, 3), cont)
  Thread.sleep(1000)
}
```

```kotlin
 
when (cont.label) {
    0 -> {
        //1.고객 정보 조회 
        cont.label = 1

        customerService.findCustomerFuture(userId)
            .thenAccept(cont::resumeWith)

    }
    1 -> {
        //2.상품 정보 조회
        cont.customer = cont.result as Customer
        cont.label = 2

        productService.findAllProductsFlowable(productIds)
            .toList()
            .subscribe(cont::resumeWith)
    }
}
```

```kotlin
override fun resumeWith(result: Result<Any>) {
    this.result = result.getOrThrow()
    that.execute(0, emptyList(), this)
}
```

---
## 정리
* Kotlin complier는 suspend가 붙은 함수에 Continuation 인자를 추가.
* 다른 suspend 함수를 실행하면 소유하고 있는 Continuation을 전달
  * 이러한 변환으로 인해서 suspend가 없는 함수에서 다른 suspend 함수 호출 불가
  * 전달할 Continuation이 없기 때문
* suspend 함수 내부를 when문을 이용해서 FSM 상태로 변경
* 각각 state에서는 label을 변경하고 비동기 함수를 수행
* 비동기 함수가 완료되면 continuation.resume을 수행하여 다시 복귀
* 하지만 label이 변경되면서 다른 state로 transition
* 마지막 state에 도달하면 completion.resume을 수행하고 종료

## Coroutine 사용하기
* Suspend 함수는 suspend 함수나 coroutine내부가 아니라면 실행 불가.
* Controller 내부에서 suspend 함수를 호출해야 한다면?
* 혹은 변경 불가능한 interface가 Mono나 CompletableFuture를 반환하고 suspend 함수가 아니라면???

### Controller suspend 함수 지원
* spring webflux는 suspend 함수를 지원
* context1, MonoCoroutine, Dispatchers.Unconfined를 context로 갖고 
* reactor-http-nio-2 스레드에서 실행

```kotlin
@RestController
@RequestMapping("/greet")
class GreetController{
    private suspend fun greet(name: String): String{
        return "Hello $name"
    }
  
  @GetMapping("/{name}")
  suspend fun greet(@PathVariable name: String): String{
    return greet(name)
  }
}
```

## Controller suspend 함수 지원
* RequestMappingHandlerAdapter 가 handlerMethod를 실행
* handlerMethod는 invocableMethod를 획득하고 invoke를 통해 실행    

![img.png](img.png)  

* 주어진 method가 suspend 함수인지 확인
* suspend 함수가 맞다면 CoroutineUtils.invokeSuspendingFunction을 실행
* 아니면 method.invoke를 실행

![img_1.png](img_1.png)

* kotlin의 mono를 실행
![img_2.png](img_2.png)

## mono로 반환
* 외부 라이브러리에서 제공되는 인터페이스가 Mono를 반환하는 경우
* 이미 많이 사용되어서 suspend 함수로 변경이 불가능한 경우
* Mono를 반환하는 함수 내부에서 어떻게 suspend 함수를 호출할 수 있을까?

```kotlin
interface GreetMonoService{
    fun greet(name: String): Mono<String>
}
```

```kotlin
class GreetMonoServiceImpl: GreetMonoService{
    private suspend fun greeting(): String{
        delay(1000)
      return "Hello"
    }
  
    override fun greet(name: String): Mono<String> {
        TODO()
    }
}
```

---

![img_3.png](img_3.png)  
* kotlin-coroutines-reactor에서 mono함수를 제공
* mono 함수를 이용해서 내부에서 suspend 함수를 실행
* mono 함수의 결과값은 Mono이기 때문에 그대로 반환.

```kotlin
class GreetMonoServiceImpl: GreetMonoService{
    private suspend fun greeting(): String{
        delay(1000)
      return "Hello"
    }
  
    override fun greet(name: String): Mono<String> {
        return mono {
            greeting()
        }
    }
}
```

## 그럼 monoInternal 함수는 어떻게 Mono를 반환할까?  
![img_4.png](img_4.png)
* monointernal에서 sink로 부터 ReactorContext를 추출
* 추출한 ReactorContext로 CoroutineContext를 생성
* MonoCoroutine을 생성하고 시작

![img_5.png](img_5.png)
* MonoCoroutine은 sink를 인자로 받고
* Coroutine이 complete되면 sink.success를 호출
* cancel되면 sink.error를 호출

--- 

## CompletableFuture로 반환
* CompletableFuture를 반환하는 함수에서 suspend 함수를 사용해야 한다면??

```kotlin
interface GreetCompletableFutureService{
    fun greet(name: String): CompletableFuture<String>
}
```

```kotlin
class GreetCompletableFutureServiceImpl: GreetCompletableFutureService{
    private suspend fun greeting(): String{
        delay(1000)
      return "Hello"
    }
  
    override fun greet(name: String): CompletableFuture<String> {
        TODO()
    }
}
```

* CoroutineScope를 생성
* 해당 CoroutineScope에서 future를 실행하여 suspend 함수를 실행
* 결과를 CompletableFuture로 반환

```kotlin
class GreetCompletableFutureServiceImpl: GreetCompletableFutureService{
    private suspend fun greeting(): String{
        delay(1000)
      return "Hello"
    }
  
    override fun greet(name: String): CompletableFuture<String> {
        return CoroutineScope(Dispatchers.IO).future {
            greeting()
        }
    }
}
```

## Unit으로 반환
```kotlin
class GreetCompletableFutureServiceImpl: GreetCompletableFutureService{
    private suspend fun greeting(): String{
        delay(1000)
      return "Hello"
    }
  
    override fun greet(name: String): CompletableFuture<String> {
        return CoroutineScope(Dispatchers.IO).launch {
            greeting()
        }
    }
}
```
