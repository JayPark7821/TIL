# MySql 아키텍쳐
![image](https://user-images.githubusercontent.com/60100532/201478416-c4f0a20c-a684-490b-b4cb-c4f9d1eca3ca.png)
___
![image](https://user-images.githubusercontent.com/60100532/201478491-43c18b10-8c7f-4121-ab7c-7d1585498a6a.png)

## MySql 엔진
<br />  

___
### 쿼리파서
* sql을 파싱하여 Syntax tree를 만듬
* 이 과정에서 문법 오류 검사가 이루어짐

### 전처리기
* 쿼리파서에서 만든 Tree를 바탕으로 전처리 시작
* 테이블이나 컬럼 존재 여부, 접근권한 등 Semantic 오류 검사

> * 쿼리파서, 전처리기는 컴파일 과정과 매우 유사하다.
> * 하지만 Sql은 프로그래밍 언어처럼 커파일 타임때 검증 할 수 없어 매번 구문 평가를 진행
>

### 옴티마이저
* 쿼리를 처리하기 위한 여러 방법들을 만들고, 각 방법들의 비용정보와 테이블의 통계정보를 이용해 비용을 산정
* 테이블 순서, 불필요한 조건 제거, 통계정보를 바탕으로 전략을 결정 (실행 계획 수립)
* 옵티마이저가 어떤 전략을 결정하느냐에 따라 성능이 많이 달라진다.
* 가끔씩 성능이 나쁜 판단을 해 개발자가 힌트를 사용해 도움을 줄 수 있다.

![image](https://user-images.githubusercontent.com/60100532/201478747-241734bc-30f3-48e4-aac3-ed81cbe26163.png)


> * 소프트 파싱 : SQL, 실행계획을 캐시에서 찾아 옵티마이저 과정을 생략하고 실행 단계로 넘어감.
> * 하드 파싱 : SQL, 실행계획을 캐시에서 찾지못해 옵티마이저 과정을 거치고나서 실행단계로 넘어감.   
<br />  
  
* ### MySql에는 소프트 파싱이 없다.
* 하지만 5 버전 까지는 쿼리 캐시가 있었음
* 쿼리캐시는 sql에 해당하는 데이터를 저장하는 것
* '쿼리캐시는 데이터를 캐시하기 때문에 테이블의 데이터가 변경되면 캐시의 데이터도 함께 갱신시켜줘야함'

* ### Oracle에는 소프트 파싱이 존재
* 실행계획까지만 캐싱
* 하지만 모든 sql과 맵핑해 데이터까지 캐싱하지는 않음(힘트나 설정으로 가능하긴함.)

## MySql 스토리지 엔진
<br />  

___
* 디스크에서 데이터를 가져오거나 저장하는 역할
* Mysql  스토리지 엔진은 플러그인 형태로 Handler API만 맞춘다면 직접 구현해서 사용할 수 있다.
* InnoDB, Mylsam등 여러개의 스토리지 엔진이 존재
* 8.0대 부터는 InnoDB엔진이 디폴트



## 쓰기락과 읽기락
* 락을 통해 동시성을 제어할 때는, 락의 범위를 최소화 하는 것이 중요.
* MySql에서는 트랜잭션의 커밋 혹은 롤백시점에 잠금이 풀린다. -> 트랜잭션이 곧 락의 범위 
* MySql에서는 쓰기락, 읽기락 두가지 락을 제공

|                     | 읽기락(Shared Lock) | 쓰기락(Exclusive Lock) |
|---------------------|------------------|---------------------|
| 읽기락(Shared Lock)    | O                | 대기                  |
| 쓰기락(Exclusive Lock) | 대기               | 대기                  |

* 읽기락은 SELECT ... FOR SHARE
* 쓰기락은 SELECT ... FOR UPDATE 또는 UPDATE, DELETE 쿼리
* 를 통해 획득 할 수 있다.

* 매번 잠금이 발생할 경우, 성능저하를 피할 수 없음   
-> MySql에서 일반 SELECT는(FOR SHARE나 FOR UPDATE가 없는) nonblocking consistent read로 동작(대기 없는 read)
* 이것이 가능한 이유는 undo log를 통해서 원본데이터를 변경했을때 커밋되기전 데이터를 관리하고 있기 때문
* MySql에서 record lock은 row가 아니라 index를 lock한다.  
-> 인덱스가 없는 조건으로 Locking Read시 불필요한 데이터들이 잠길 수 있음.


### 낙관적 락
* 동시성 제어를 위한 가장 보편적인 방법은 락을 통한 줄세우기  
-> 비관적 락 (쓰기락 & 읽기락)
* 락을 통한 동시성 제어는 불필요한 대기 상태를 만듬 
* 동시성이 빈번하지 않은 쿼리로 인해 다른 쿼리가 대기한다면???
* 동시성 이슈가 빈번하지 않길 기대하고, 어플리케이션에서 동시성을 제어한다.
* CAS(Compare and set)을 통해 제어한다.  

![image](https://user-images.githubusercontent.com/60100532/213745980-2d1d522b-2e5e-4433-9356-2bb480dcb63a.png)

* 실패에 대한 처리를 직접 구현해야 함

### 좋아요 구현
* 게시물에 컬럼 추가를 통한 구현 - 비관적 락
  1. 조회시 컬럼만 읽어 오면 됨
  2. 쓰기시 게시물 레코드에 대한 경합이 발생 -> 하나의 자원(게시물)을 두고 락 대기
  3. 같은 회원이 하나에 게시물에 대해 여러 번 좋아요를 누를 수 있음

```java
public Optional<Post> findById(Long id, Boolean requireLock) {
		String sql = String.format("""
				SELECT * 
				FROM %s
				WHERE id = :postId
			""", TABLE);
		if(requireLock)
			sql += " FOR UPDATE";
		
		MapSqlParameterSource params = new MapSqlParameterSource().addValue("postId", id);
		return Optional.of(namedParameterJdbcTemplate.queryForObject(sql, params, ROW_MAPPER));
	}
```

* 좋아요 테이블을 통한 구현
  1. 조회시 매번 count쿼리 연산
  2. 쓰기시 경합 없이 인서트만 발생
  3. 회원정보등 다양한 정보 저장 가능

```java
	public Page<PostDto> getPosts(Long memberId, Pageable pageable) {
		return postRepository.findAllByMemberId(memberId, pageable)
			.map(this::toDto);

	}

	private PostDto toDto(Post post) {
		return new PostDto(
			post.getId(),
			post.getContents(),
			post.getCreatedAt(),
			postLikeRepository.getCount(post.getId())
		);
	}
```
```java
	public Long getCount(Long postId) {
		String sql = String.format("""
			select count(id)
			from %s
			WHERE postId = :postId
			""", TABLE);
		MapSqlParameterSource param = new MapSqlParameterSource()
			.addValue("postId", postId);
		return namedParameterJdbcTemplate.queryForObject(sql, param, Long.class);
	}

```
    
### 병목 해소하기
* 쓰기 지점의 병목은 하나의 레코드를 점유
* 조회 지점의 병목은 카운트 쿼리   

-> 좋아요 수는 높은 정합성을 요구하는 데이터인가????

![image](https://user-images.githubusercontent.com/60100532/213925990-af2e3e7a-77b1-4b21-8df8-0f275d1f85a0.png)

* 결국 데이터의 성질, 병목지점등을 파악하고, 적당한 기술들을 도입해 해소 해야한다.
* 