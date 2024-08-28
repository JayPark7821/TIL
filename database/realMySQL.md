## Real MySQL

### Ep.01 
### CHAR vs VARCHAR

* 공통점
  * 문자열 저장용 컬럼
  * 최대 저장 가능 문자 길이 명시 (바이트 수 아님) ex) CHAR(10) -> 10글자 
    * CHAR(10) VARCHAR(10) 두 타입 모두 어떤 문자열 셋을 사용하는가에 따라 사용하는 저장 공간의 크기가 달라질 수 있음
    
* 차이점
  * 저장 방식
    * CHAR : 값의 실제 크기에 관계없이 설정된 고정된 공간 할당 여부 
    * VARCHAR : 저장되는 문자열 길이 만큼만 저장 공간 할당
  * 최대 저장 길이 : CHAR(255) vs VARCHAR(16383)
  * 저장된 값의 길이 관리 여부 (VARCHAR와 가변 길이 문자셋 사용하는 CHAR는 저장된 값 길이 관리)
  * CHAR도 UTF-8 MB4와 같이 가변길이 문자셋을 사용하면 컬럼에 저장된 값의 길이를 같이 관리 


#### CHAR vs VARCHAR (Latin1)

* CHAR(10)   
![img_1.png](img_1.png)

* VARCHAR(10)  
![img_2.png](img_2.png)

#### CHAR vs VARCHAR (UTF-8MB4)
* VARCHAR(10)
  * (문자당 바이트 수가 달라도) 문자 셋 관계없이, 꼭 필요한 만큼만 공간 사용
* CHAR(10)
  * 예약하는 공간 크기 달라짐 ( 가변길이 문자 셋인 경우, 길이 저장용 바이트 사용)  
  ![img_3.png](img_3.png)
  * UTF-8MB4 문자 셋을 사용하는 컬럼에서 한글 2글자의 경우, 바이트 수 기준으로 공백 4개 채움  
  ![img_4.png](img_4.png)
  * 4글자의 경우, CHAR(10) 컬럼에는 12 바이트를 사용하고, 미리 예약하는 빈 공백 공간 없음


### CHAR 타입의 공간 낭비
* 일반적으로 알고 있는 구분 기준
  * 고정된 길이의 값 저장은 CHAR 타입, 그 외의 경우 VARCHAR 타입

* CHAR 대신 VARCHAR를 사용하면?
  * 어떤 경우에는 CHAR 타입의 공간 낭비 심함
    * 저장되는 문자열의 최소 최대 길이 가변 폭이 큰 경우 
  * 하지만 그렇지 않은 경우도 있음
    * 저장되는 문자열의 최소 최대 길이 가변폭이 작은 경우 
  * 저장되는 값의 길이 변동이 크지 않다면 낭비는 크지 않음


### 컬럼 값의 길이 변경시 작동 방법
* VARCHAR(10) 레코드 INSERT ( ABCD )
![img_5.png](img_5.png)
* VARCHAR(10) 레코드 UPDATE ( ABCDE )  
![img_6.png](img_6.png)
  * 레코드의 길이가 변경되었기 때문에 원래 레코드가 저장되어있던 위치에 inplace update 불가능
  * MySQL server의 각 DataPage는 insert update delete 되면서 구조가 계속 변경됨 레코드를 저장할 수 있는 빈 공간을 찾는것이 어려워짐
  * 결국에는 레코드를 입력할 수 있는 빈 공간을 찾을 수 없게 되고 결국 page의 레코드들을 다시 정리하는 작업이 필요해짐
* 만약 해당 컬럼이 VARCHAR(10)이 아니라 CHAR(10)이면 
* MySQL server는 해당 컬럼의 크기만큼 빈 공간을 미리 확보해 두었기 떄문에 공간 낭비는 되었겠지만 위와 같이 데이터가 한 글자 더 늘어나는 형태로 업데이트가 실행되어도 레코드를 옮겨 쓰기 하는 작업이 필요 없음

<br/>

* 이와 같이 MySQL server에서 CHAR 타입의 장점은 이렇게 레코드의 위치를 옮겨 적어야 하는 가능성을 낮춰 줄 수 있다. 
* 특시 저장되는 문자열의 가변 길이 폭이 좁고 자주 변경되는 컬럼의 경우 VARCHAR 보다 CHAR 타입을 사용하면 컬럼의 길이 변경시 data page 관리 작업을 최소화 하고 자연스럽게 페이지의 프레그멘테이션을 최소화 해줌

<br/>

### 문자열 타입 선정
* VARCHAR 보다는 CHAR를 선택해야 하는 경우
  * 값의 가변 길이 범위 폭이 좁고 
  * 자주 변경되는 경우 (특히 인덱스된 컬럼인 경우)
* 위 같은 경우 VARCHAR 사용시
  * 데이터 페이지 내부의 조각화 현상 커짐
  * CHAR 타입보다 공간 효율 떨어짐
  * 내부적으로 빈번한 page reorganization 작업 필요


### Ep.02
### VARCHAR vs TEXT
#### 공통점
  * 문자열 속성 값을 저장
  * 최대 65535 Bytes 까지 저장 가능
####  차이점
  * VARCHAR 타입 컬럼에는 지정된 글자 수 만큼만 데이터 저장 가능
    * VARCHAR(10) -> 10글자 이하만 저장 가능
  * TEXT 타입 걸렄은 인덱스 생성 시 반드시 Prefix 길이 지정 필요
    * CREATE INDEX idx_name ON table_name (text_column(10));
  * TEXT 타입 컬럼은 표현식으로만 디폴트 값 지정가능
    * CREATE TABLE table_name (text_column TEXT DEFAULT 'default value'); -> error
    * CREATE TABLE table_name (text_column TEXT DEFAULT ('default value')); -> success

<br />   

####  일반적인 사용 형태
  * 길이가 짧으면 VARCHAR, 길이가 길면 TEXT
####  그렇다면 CARCHAR(5000) vs TEXT ??? 
  * MySQL에서는 세션에서 어떤 테이블에 저장된 데이터를 읽는다고 할 때 메모리에 이를 위한 버퍼 공간을 미리 할당해두고 그걸 유지하면서 재활용함,   
  이 버퍼 공간은 테이블 레코드의 최대 사이즈로 메모리에 할당되는데 이때 VARCHAR 타입 컬럼의 경우 이 버퍼 공간에 포함돼서 메모리 공간을 재사용할 수 있지만   
  텍스트 타입인 경우 그렇지 않고 그때그떄 필요할 때마다 메모리가 할당되고 해제됩니다.
  * VARCHAR 타입은 메모리 버퍼 공간을 미리 할당해두며 재활용 가능, TEXT 타입은 그때 그때 필요할 때마다 할당 & 해제
  * 컬럼 사용이 빈번하고 메모리 용령이 충분하다면 VARCHAR 타입 추천
  * VARCHAR(5000)과 같이 길이가 긴 컬럼들을 자주 추가하는 경우, Row 사이즈 제한 (65,535 Byte)에 도달할 수 있으므로 적절하게 TEXT 타입과 같이 사용하는 것을 권장
####  VARCHAR(30) VS VARCHAR(255)
  * 실제 최대 사용하는 길이만큼 명시해야 메모리 사용 효유율 증가
  * 디스크 공간 효율 차이도 미미하게 존재 내부적으로 컬럼에 저장되는 데이터의 길이 정보를 저장 (1Byte vs 2Byte)

#### VARCHAR & TEXT 주의사항
* 저장되는 값의 사이즈가 크면 Off-Page 형태로 데이터가 저장될 수 있음
  * MySQL의 Innodb Storage Engine에서 하나의 레코드 크기가 데이터 페이지의 절반 크기보다 큰 경우에는 레코드에서 외부로 저장할 가변길이 컬럼을 선택하게 되고 선택된 컬럼은 별로 외부 페이지에 데이터가 저장  
  실제 다른 컬럼들이 모두 저장되어있는 본래의 데이터 페이지에는 외부 페이지를 가르키는 20바이트의 포인터 값만 저장되어 있음 -> external off page
  * 쿼리에서 Off-Page 컬럼의 참조 여부에 따라 쿼리 처리 성능이 매우 달라짐

```sql
CREATE TABLE user_log
(
  id         int NOT NULL AUTO_INCREMENT,
  user_id    int NOT NULL,
  extra_info TEXT,
  PRIMARY KEY (id),
  KEY ix_user_id (user_id)
)
  
```

```sql
select user_id, email 
from user_log
where user_id = 7;
# 4684 rows in set (0.32 sec)
```
```sql
select user_id, email, extra_info 
from user_log
where user_id = 7;
# 4684 rows in set (1.23 sec)
```

#### 정리
* 상대적으로 저장되는 데이터 사이즈가 많이 크지 않고, 컬럼 사용이 빈번하며 DB서버의 메모리 용량이 충분하다면 VARCHAR 타입 권장
* 저장되는 데이터 사이즈가 큰 편이고, 컬럼을 자주 사용하지 않으며 테이블에서 다른 문자열 컬럼들이 많이 사용된다면 TEXT 타입 권장
* VARCHAR 타입을 사용하는 경우, 길이는 실제 사용되는 만큼만 지정

### Ep.03
### COUNT(*) vs COUNT(DISTINCT)
#### COUNT(*) 성능 개선
* Covering Index
```sql
select count(*) where ix_fd1=? and ix_fd2=?;
select count(ix_fd2) where ix_fd1=?;
```
* Non-Covering Index
```sql
select count(*) where ix_fd1=? and non_ix_fd2=?;
select count(non_ix_fd2) where ix_fd1=?;
```
#### COUNT(*) vs COUNT(DISTINCT expr)
* COUNT(*)는 레코드 건수만 확인
* COUNT(DISTINCT expr)는 임시 테이블로 중복 제거후 건수 확인  
테이블 -> select(중복 여부 확인) -> insert or update -> 중복 제거용 임시 테이블  
테이블의 레코드를 모두 임시 테이블로 복사 후 임시 테이블의 최종 레코드 건수 반환

`만약 레코드 건수가 너무 많다면 MySQL 서버는 너무 큰 임시 테이블이 메모리에 상주하는것을 막기 위해서 적절한 타이밍에 다시 디스크에 옮겨 저장하는 작업을 진행 -> 메모리 cpu 뿐만 아니라 io 작업도 가중됨 성능 저하`

#### COUNT(*) 튜닝
* 최고의 튜닝은 쿼리 자체를 제거하는 것
  * 전체 결과 건수 확인 쿼리 제거 
  * 페이지 번호 없이, "이전" "이후" 페이지 이동
* 쿼리를 제거할 수 없다면, 대략적 건수 활용
  * 부분 레코드 건수 조회 
    * 표시할 페이지 번호만큼의 레코드만 건수 확인  
    select count(*) from (select 1 from table limit 200) z;
  * 임의의 페이지 번호는 표기
    * 첫 페이지에서 10개 페이지 표시 후 -> 실제 해당 페이지로 이동하면서 페이지 번호 보정
  * 통계 정보 활용
    * 쿼리 조건이 없는 경우, 테이블 통계 활용  
    ```sql
        select table_rows 
        from information_schema.tables 
        where schema_name= ? and table_name= ?;
    ```
    * 쿼리 조건이 있는 경우, 실행 계획 활용
      * 정확도 낮음
      * 조인이나 서브쿼리 사용시 계산 난이도 높음  
  
  * `성능은 빠르지만, 페이지 이동하면서 보정 필요` 
    
* 제거 대상
  * where 조건이 없는 count(*) 
  * where 조건에 일치하는 레코드 건수가 많은 count(*)
* 인덱스를 활용하여 최적화 대상
  * 정확한 count(*)가 필요한 경우
  * count(*) 대상 건수가 소량인 경우
  * where 조건이 인덱스로 처리될 수 있는 경우

### Ep.04
### Paging query
#### 페이징 쿼리란?
* 원하는 전체 데이터에 대해 부분적으로 나눠서 데이터를 조회 및 처리하는 방법
* db 및 어플리케이션 서버의 리소스(CPU/memory/network) 사용 효율 증가
* 어플리케이션 단의 처리 시간 단축

#### 페이징 쿼리 작성
* DB 서버에서 제공하는 LIMIT & OFFSET 구문을 사용하는 경우가 많음
* LIMIT & OFFSET을 사용하는 경우 오히려 DBMS 서버에 더 많은 부하를 발생시킴
* DBMS에서 순차적으로 레코드를 읽지 않고 지정된 OFFSET 이후 데이터만 바로 가져올 수는 없음
* 결국 LIMIT & OFFSET 구문을 사용하는 경우 쿼리 실행 횟수가 늘어날수록 점점 더 읽는 데이터가 많아지고 응답 시간이 길어짐
  * 500건씩 N번 조회시 최종적으로 ((1*500) + (2*500)+...+(N*500)) 건의 레코드 읽기가 발생
  * LIMIT & OFFSET을 사용하지 않고 한번에 모두 읽어서 가져가는 것보다 많은 데이터를 읽고 처리

<br/>

* LIMIT & OFFSET 구문을 사용하지 않으면서 데이터를 원하는 만큼만 조회해서 가져갈 수 있도록 쿼리를 작성해야함
* 대표적으로 아래 두 가지 방식으로 구현해볼 수 있음
  * 범위 기반 방식
  * 데이터 개수 기반 방식

#### 범위 기반 방식
* 날짜 기간이나 숫자 범위로 나눠서 데이터를 조회하는 방식
* 매 쿼리 실행시 where절에서 조회 범위를 직접 지정하는 형태로, 쿼리에서 LIMIT절이 사용되지 않음
* 주로 배치 작업 등에서 테이블의 전체 데이터를 일정한 날짜/숫자 범위로 나눠서 조회할 떄 사용
* 쿼리에서 사용되는 조회 조건도 굉장히 단순하며, 여러 번 쿼리를 나눠 실행하더라도 사용하는 쿼리 형태는 동 
* 숫자인 id값을 바탕으로 범위를 나눠 데이터 조회 
```sql
select *
from users
where id > 0 AND id <= 500
```
* 날짜 기준으로 나눠서 조회 
```sql
select *
from payments
where finished_at >= '2022-01-01' AND finished_at < '2022-01-02'
```

#### 데이터 개수 기반 방식
* 지정된 데이터 건수 만큼 결과 데이터를 반환하는 형태로 구현된 방식
* 배치보다는 주로 서비스 단에서 많이 사용되는 방식으로, 쿼리에서 ORDER BY와 LIMIT절을 사용하여 데이터를 조회
* 처음 쿼리를 실행할 떄 (1회차)와 그 이후 쿼리를 실행할 때 (N회차) 쿼리 형태가 달라짐
* 쿼리의 WHERE절에서 사용되는 조건 타입에 따라서 N회차 실행 시의 쿼리 형태도 달라짐

<br/>

#### 동등 조건 사용

```sql
CREATE TABLE payments
(
  id      int NOT NULL AUTO_INCREMENT,
  user_id int NOT NULL,
  PRIMARY KEY (id),
  KEY ix_userid_id (user_id, id)
);
```
 * 페이징 적용 대상 쿼리
```sql
SELECT *
FROM payments
WHERE user_id = ?
```

* 1회차 쿼리
```sql
SELECT *
from payments
WHERE user_id = ?
ORDER BY id
LIMIT 30
```

* N회차 쿼리
```sql
SELECT *
from payments
WHERE user_id = ? 
  AND id > {마지막으로 조회한 id}
ORDER BY id
LIMIT 30
```

* ORDER BY절에는 각각의 데이터를 식별할 수 있 식별자 컬럼(PK와 같은 컬럼)이 반드시 포함되어야 함

<br/>

#### 범위 조건 사용


```sql
CREATE TABLE payments
(
  id      int NOT NULL AUTO_INCREMENT,
  user_id int NOT NULL,
  finished_at datetime NOT NULL,
  
  PRIMARY KEY (id),
  KEY ix_finishedat_id (finished_at, id)
);
```
* 페이징 적용 대상 쿼리
```sql
SELECT *
FROM payments
WHERE finished_at >= ?
    AND finished_at < ?
```

* 1회차 쿼리
```sql
SELECT *
from payments
WHERE finished_at >= '{시작 날짜}'
  AND finished_at < '{종료 날짜}'
ORDER BY finished_at, id
LIMIT 30
``` 
 
* 왜 ORDER BY 절에 finished_at 컬럼이 포함되어야 하는가?
  * ORDER BY 절에 id 컬럼만 명시하는 경우 `조건을 만족하는 데이터들을 모두 읽어들인 후 id로 정렬한다음 지정된 건수만큼 반환 하게 됨`
  * ORDER BY 절에 finished_at 컬럼을 선두에 명시하면, (finished_at, id) 인덱스를 사용해서 정렬 작업 없이 원하는 건수만큼 데이터를 순차적으로 읽을 수 있으므로 처리 효율 향상

* 범위 조건에서의 N회차 쿼리
  * 데이터  

| finished_at         | id |
|---------------------|----|
| 2024-01-01 00:00:00 | 5  |
| 2024-01-01 00:00:01 | 1  |
| 2024-01-01 00:00:01 | 2  |
| 2024-01-01 00:00:01 | 3  |
| 2024-01-01 00:00:02 | 8  |
| 2024-01-01 00:00:02 | 9  |
| 2024-01-01 00:00:03 | 4  |
| 2024-01-01 00:00:03 | 6  |

  * 1회차 쿼리 예시   
  ```sql
    SELECT *
    from payments
    WHERE finished_at >= '2024-01-01 00:00:00'
      AND finished_at < '2024-01-02 00:00:00'
    ORDER BY finished_at, id
    LIMIT 5
  ```

  * 결과  

  | finished_at         | id |
|---------------------|----|
| 2024-01-01 00:00:00 | 5  |
| 2024-01-01 00:00:01 | 1  |
| 2024-01-01 00:00:01 | 2  |
| 2024-01-01 00:00:01 | 3  |
| 2024-01-01 00:00:02 | 8  |

  * N회차 쿼리
    * where절에 식별자 컬럼 조건 추가?
    ```sql
        SELECT *
    from payments
    WHERE finished_at >= '2024-01-01 00:00:00'
      AND finished_at < '2024-01-02 00:00:00'
      AND id > 8
    ORDER BY finished_at, id
    LIMIT 5
    ```
    * 결과
    * 데이터 누락 발생 id 4 , 6
    * 범위 조건에서 N회차 쿼리 작성
    ```sql
    SELECT *
    FROM payments
    WHERE ((finished_at = '2024-01-01 00:00:02' AND id > 8) OR (finished_at > '2024-01-01 00:00:02' AND finished_at < '2024-01-02 00:00:00'))
    ORDER BY finished_at, id
    LIMIT 5  
    ```
  * where절에 식별자 컬럼 조건만 추가해도 문제 없는 케이스
  * data  

| created_at          | id |
|---------------------|----|
| 2024-01-01 00:00:00 | 1  |
| 2024-01-01 00:00:01 | 2  |
| 2024-01-01 00:00:01 | 3  |
| 2024-01-01 00:00:01 | 4  |
| 2024-01-01 00:00:02 | 5  |
| 2024-01-01 00:00:02 | 6  |
| 2024-01-01 00:00:02 | 7  |
| 2024-01-01 00:00:02 | 8  |

  ```sql
  SELECT *
  FROM user_logs
  WHERE created_at >= '2024-01-01 00:00:00'
    AND created_at < '2024-01-02 00:00:00'
  ORDER BY created_at, id
  LIMIT 5
  ```

  ```sql
  SELECT *
  FROM user_logs
  WHERE created_at >= '2024-01-01 00:00:02'
    AND created_at < '2024-01-02 00:00:00'
    AND id > 5
  ORDER BY created_at, id
  LIMIT 5
  ```
  * created_at, id 정렬 순서가 같은 경우 where절에 식별자 컬럼 조건만 추가해도 문제 없음  
  * 범위 조건에서의 N회차 쿼리
    * 범위 조건 컬럼과 식별자 컬럼의 값 순서 일치 여부에 따라 두 가지 방식이 존재
    * 범위 조건 컬럼 값 순서와 식별자 컬럼 값 순서가 동일하지 않은 경우는 아래와 같이 사용
    * 1 회차
    ```sql
    SELECT *
    FROM payments
    WHERE finished_at >= '{시작 날짜}'
        AND finished_at < '{종료 날짜}'
    ORDER BY finished_at, id
    LIMIT 5
    ```
    * N 회차
    ```sql
    SELECT *
    FROM payments
    WHERE ((finished_at = '{이전 마지막 데이터의 날짜값}' AND id > '{이전 마지막 데이터의 id}') OR (finished_at > '{이전 마지막 데이터의 finished_at}' AND finished_at < '{종료 날짜}'))
    ORDER BY finished_at, id
    LIMIT 5
    ```
    * 범위 조건 컬럼 ㄱ밧 순서와 식별자 컬럼 값 순서가 동일한 경우는 아래와 같이 사용
    * 1 회차
    ```sql
    SELECT *
    FROM user_logs
    WHERE created_at >= '{시작 날짜}'
        AND created_at < '{종료 날짜}'
    ORDER BY created_at, id
    LIMIT 5
    ```
    * N 회차
    ```sql
    SELECT *
    FROM user_logs
    WHERE created_at >= '{이전 마지막 데이터의 날짜값}'
        AND created_at < '{종료 날짜}'
        AND id > '{이전 마지막 데이터의 id}'
    ORDER BY created_at, id
    LIMIT 5
    ```
#### 정리
* LIMIT & OFFSET 구문은 DB서버 부하를 발생시키므로 사용을 지양
* 페이징 쿼리는 대표적으로 두 가지로 구분할 수 있음
  * 범위 기반 방식
  * 데이터 개수 기반 방식
* 범위 기반 방식은 단순하게 날짜/숫자 값을 특정 범위로 나눠서 쿼리를 실행하는 형태로 1회차와 N회차 쿼리 형태가 동일
* 데이터 개수 기반 방식은 지정한 데이터 개수만큼 조회하는 형태로, 1회차와 N회차 쿼리 형태가 다름
  * 쿼리에 사용되는 조건 타입에 따라, 또 경우에 따라 쿼리 형태가 달라지므로 페이징을 적용하고자 하는 쿼리에 맞는 형태로 페이징 쿼리 작성 필요


### Ep.05
### Stored Function
#### MySQL Function
* Built-in Function 
* User Defined Function 
* Stored Function 

#### DETERMINISTIC vs NOT DETERMINISTIC
* MySQL의 Stored Function은 반드시 DETERMINISTIC 과 NOT DETERMINISTIC 중 하나의 속성을 가진다
* DETERMINISTIC ( 확정적 )
  * 동일 상태와 동일 입력으로 호출 -> 동일한 결과 반환
  * 그렇지 않은 경우 -> NOT DETERMINISTIC
  * ex 오늘 가입한 사용자의 수를 가져오는 함수를 만들었을 때 stored function이 실행되는 도중에도 사용자의 가입은 계속 진행되기 때문에 이 함수는 호출 시점에 따라 결과가 달라질 수 있음  
  하지만 이때 사용자 테이블의 레코드가 달라지는 것도 입력이 달라지는 것으로 해석

* DETERMINISTIC 여부에 따른 차이
```sql
CREATE
  DEFINER=root@'localhost'
  FUNCTION func1() RETURNS INTEGER
  DETERMINISTIC SQL SECURITY INVOKER
BEGIN
    SET @func1_called = IFNULL(@func1_called, 0) + 1;
    RETURN 1;
END;;

CREATE
  DEFINER=root@'localhost'
  FUNCTION func2() RETURNS INTEGER
  NOT DETERMINISTIC SQL SECURITY INVOKER
BEGIN
    SET @func2_called = IFNULL(@func2_called, 0) + 1;
    RETURN 1;
END;;
```

```sql
SELECT * from tab where id = func1();
SELECT * from tab where id = func2();

SELECT @func1_called, @func2_called;
```

| @func1_called | @func2_called |
|---------------|---------------|
| 3             | 12            |

* 두 세션 변수 값의 변화를 보면 func1은 3번 호출되었고 func2는 12번 호출되었음

* DETERMINISTIC 여부에 따른 작동 차이
```sql
EXPLAIN SELECT * from tab where id = func1();

+----+-------------+-------+------+---------+---------+------+-------------+
| id | select_type | table | type | key     | key_len | rows | Extra       |
+----+-------------+-------+------+---------+---------+------+-------------+
| 1  | SIMPLE      | tab   | const| PRIMARY | 4       | 1    | NULL        |
+----+-------------+-------+------+---------+---------+------+-------------+

Note (Code 1003): /* select#1 */ select '1' AS `id`, 'd' AS `COL` from `test`,`tab` where true
```
* Primary key를 const 타입으로 접근하는 것은 테이블의 레코드를 1건만 읽었다는 것을 의미하고 이는 매우 빠르게 처리되는 실행 계획
* 실행 계획 하단의 노트에 명시된 query에서도 where절의 func1 함수 호출이 없어졌다 이는 최적화 되어서 함수 호출 자체가 사라졌다는 것을 의미
```sql
EXPLAIN SELECT * from tab where id = func2();

+----+-------------+-------+------+---------+---------+------+-------------+
| id | select_type | table | type | key     | key_len | rows | Extra       |
+----+-------------+-------+------+---------+---------+------+-------------+
| 1  | SIMPLE      | tab   | ALL  | NULL    | NULL    | 12    | USING WHERE|
+----+-------------+-------+------+---------+---------+------+-------------+

Note (Code 1003): /* select#1 */ select `test`.`tab`.`id` AS `id`, `test`.`tab`.`col` AS `COL` from `test`,`tab` where (`test`.`tab`.`id` = func2())
```
* 실행 계획의 type이 ALL -> 풀 테이블 스캔으로 처리되었다는 것을 의미
* 노트에 표시된 쿼리에서 where절의 func2 함수 호출이 그대로 남아있는 것을 확인할 수 있음

<br/>

* 사실 바로위 에서 NOT DETERMINISTIC의 함수의 호출 횟수가 높았던 이유는 쿼리 실행계획이 인덱스를 사용하지 못하고 풀 테이블 스캔으로 바뀌었기 때문이었음. 
