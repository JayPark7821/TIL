# Spring Batch

## ItemReader
```java

package org.springframework.batch.item;

import org.springframework.lang.Nullable;
 
public interface ItemReader<T> {
 
	@Nullable
	T read() throws Exception, UnexpectedInputException, ParseException, NonTransientResourceException;

}
```

### ItemReader 구현체
![image](https://user-images.githubusercontent.com/60100532/200226503-ea77591f-9dc2-4987-8879-ea63d10c304b.png)

___
### Cursor vs Paging
#### 1. Cursor
![image](https://user-images.githubusercontent.com/60100532/200226724-b1ad744c-cb92-46f0-8962-4ed63a3890ca.png)
* 표준 java.sql.ResultSet
* Database와 Connection을 맺은 후 한 번에 하나씩 레코드를 Streaming 하여 다음 레코드로 진행한다.(Cursor를 움직인다.)
* JdbcCursorItemReader, HibernateCursorItemReader, JpaCursorItemReader

#### 2. Paging
![image](https://user-images.githubusercontent.com/60100532/200226927-140e555c-220c-422c-a6f6-883032a743ea.png)
* Page라고 부르는 Chunk 크기만큼 레코드를 가져온다 (PageSize = ChunkSize ) 위사진에서 10row
* 각 페이지의 쿼리를 실행할 때마다 동일한 레코드 정렬 순서를 보장하려면 정렬 조건이 필요하다.
* JdbcPagingItemReader, HibernatePagingItemReader, JpaPagingItemReader



## ItemWriter
```java
package org.springframework.batch.item;

import java.util.List;
 
public interface ItemWriter<T> {
 
	void write(List<? extends T> items) throws Exception;

}
 
```
### ItemWriter 구현체
![image](https://user-images.githubusercontent.com/60100532/200227364-1728a63d-0557-48ae-a623-84da551dd505.png)

### ItemWriter 
![image](https://user-images.githubusercontent.com/60100532/200227800-06ea7329-1826-4ffa-9f33-7f891acb540c.png)
> ItemWriter는 chunk 단위로 write한다 ( write 메소드의 파라미터 시그니쳐 List)
> 


## Tasklet
```java
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.lang.Nullable;

/**
 * Strategy for processing in a step.
 * 
 * @author Dave Syer
 * @author Mahmoud Ben Hassine
 * 
 */
public interface Tasklet {

	@Nullable
	RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception;
}

```
```java
package org.springframework.batch.repeat;
public enum RepeatStatus {

	/**
	 * Indicates that processing can continue.
	 */
	CONTINUABLE(true), 
	/**
	 * Indicates that processing is finished (either successful or unsuccessful)
	 */
	FINISHED(false);
}
```

* RepeatStatus가 RepeatStatus.FINISHED를 반환 할때까지 execute를 실행하게 할 수 있다.  

![image](https://user-images.githubusercontent.com/60100532/200242753-44b7f18f-38a8-4528-a22e-6653ae5fea7f.png)

|name|desc|
|---|---|
|CONTINUABLE | * 처리를 계속할 수 있음 <br />  * SpringBatch에게 해당 Tasklet을 다시 실행하도록 정의|
|FINISHED| * 처리가 완료 되었음 <br />   * 처리의 성공 여부에 관계없이 Tasklet의 처리를 완료하고 다음 처리 진행|


## BeaenScope
### @JobScope, @StepScope

* spring Bean의 기본 Scope는 Singleton
* Bean의 생성 시점을 지정된 Scope가 명시된 method가 실행되는 시점으로 지연  
  `JobScope` job이 실행될 때 생성되고 끝날 때 삭제
  `StepScope` step이 실행될 때 생성되고 끝날 때 삭제
* Why?  
  1. JobParameter를 method실행하는 시점까지 지연시켜 할당할 수 있다.
  2. 동일한 Component를 병렬로 처리할 때 안전할 수 있다.
  3. 
    
