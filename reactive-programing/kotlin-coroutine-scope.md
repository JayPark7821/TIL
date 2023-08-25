# Kotlin Coroutines

## CoroutineScope

### CoroutineScope
* CoroutineScope는 Coroutine들에 대한 scope를 정의
  * scope에는 여러 Coroutine들이 포함.
  * 자식 coroutine들에 대한 생명주기를 관리
  * 자식 coroutine들이 모두 완료되어야만 scpoe도 완료
* 이런 관리를 위해서 CoroutineScope의 CoroutineContext에는 꼭 Job을 포

![img_34.png](img_34.png)

### CoroutineScope 함수
* CoroutineScope 함수를 이용해서 CoroutineScope를 생성
* 인자로 주어진 context에 Job이 포함되어있는지 확인
* 포함되어있지 않다면 Job을 생성하여 추가하고 ContextScope에 전달
* ContextScope는 CoroutineScope의 단순한 구현체

![img_35.png](img_35.png)  
![img_36.png](img_36.png)  
![img_37.png](img_37.png)

```kotlin
import kotlin.coroutines.EmptyCoroutineContext

fun main() {
  val cs = CoroutineScope(EmptyCoroutineContext)
  
  log.info("context : {}" , cs.coroutineContext)
  log.info("class name :{}", cs.javaClass.name)
}
```  
![img_38.png](img_38.png)  


* EmptyCoroutineContext를 통해 텅빈 CoroutineContext를 생성
* 하지만 Job을 생성하여 ContextScope를 생성하기 때문에 JobImpl 포함

### Coroutine builder
* Coroutine builder는 CoroutineScope로 부터 Coroutine을 생성
* CoroutineScope의 CoroutineContext와 인자로 전달 받은 context를 merge하여 newContext 생성
* Coroutine을 생성하여 start하고 반환
  * CoroutineScope의 Job을 부모로 갖는다.
  * Coroutine builder를 통해서 생성된 Coroutine은 비동기하게 시작
 
### Coroutine builder - launch
* standaloneCoroutine을 생성하고 start
  * isLazy가 true 라면 LazyStandaloneCoroutine을 생성
* standaloneCoroutine을 Job으로 반환
  * 외부에서 launch를 실행한 후 Job을 획득하여 cancel, join등을 실행 가능
* newCoroutineContext를 통해 CoroutineScope의 coroutineContext와 인자로 주어진 context를 merge

![img_39.png](img_39.png)  
![img_40.png](img_40.png)

```kotlin
fun main(){
    runBlocking {
        val cs = CoroutineScope(EmptyCoroutineContext)
        log.info("job : {}", cs.coroutineContext[Job])

        val job = cs.launch {
            // coroutine created
            delay(100)
            log.info("context : {}", this.coroutineContext)
            log.info("class name : {}", this.javaClass.simpleName) 
        }
        log.info("step1")
        job.join()
        log.info("step2")
    }
}
```  
![img_41.png](img_41.png)

* CoroutineScope에 coroutine builder인 launch를 통해서 coroutine을 생성하고 this로 접근
* 비동기로 동작하기 때문에 join을 통해서 완료될 떄까지 suspend

### Coroutine builder - async
* DeferredCoroutine을 생성하고 start
  * isLazy가 true 라면 LazyDeferredCoroutine을 생성
* DeferredCoroutine을 Deferred로 반환
  * Deferred는 Job을 상속하고 있기 때문에 cancel,join 뿐만 아니라 
  * await을 통해서 block이 반환하는 값에 접근 가능

![img_42.png](img_42.png)  
![img_43.png](img_43.png)

```kotlin
fun main(){
    runBlocking {
        val cs = CoroutineScope(EmptyCoroutineContext)
        log.info("job : {}", cs.coroutineContext[Job])

        val deferred = cs.async {
            delay(100)
            log.info("context : {}", this.coroutineContext)
            log.info("class name : {}", this.javaClass.simpleName)

            100
        }

        log.info("step1")
        log.info("result : {} ",deferred.await())
        log.info("step2")
    }
}
```  

![img_44.png](img_44.png)

* CoroutineScope에 coroutine builder인 async를 통해서 coroutine을 생성하고 this로 접근
* 비동기로 동작하기 때문에 await을 통해서 완료될 떄까지 suspend하고 값에 접근

### 정리
* 비동기 적으로 동작을 해야하고 반환값이 필요없다면 launch
* 비동기 적으로 동작을 해야하고 반환값이 필요하다면 async
