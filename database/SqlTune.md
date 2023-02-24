# 개념적인 튜닝 용어
## 오브젝트 스캔 유형
* 오브젝트 스캔 유형은 테이블 스캔과 인덱스 스캔으로 구분,
* 테이블 스캔은 인덱스를 거치지 않고 바로 디스크에 위치한 테이블 데이터에 접근.
* 인덱스 스캔은 인덱스로 테이블 데이터를 찾아가는 유형

### 테이블 풀 스킨
* 테이블 풀 스캔은 인덱스를 거치지 않고 테이블로 바로 직행해 처음부터 끝까지 모든 데이터를 읽는 방식
* where절의 조건문을 기준으로 활용할 수 있는 인덱스가 없거나, 전체 데이터 대비 대량의 데이터가 필요할 때 테이블 풀 스캔 방식을 사용
* 테이블 풀 스캔은 테이블의 모든 데이터를 읽어야 하므로 성능측면에서는 부정적

<br />

### 인덱스 범위 스캔
* 인덱스 범위 스캔은 말 그대로 인덱스 범위 기준으로 스캔한 뒤 스캔한 결과를 바탕으로 테이블 데이터 찾아감.
* sql에서 between, in, >, <, like 등의 조건문을 사용할 때 인덱스 범위 스캔이 발생
* 좁은 범위를 스캔할 때는 성능적으로 매우 효율적, 넓은 범위를 스캔할 때는 비효율적인 방식


<br />

### 인덱스 풀 스캔
* 인덱스 풀 스캔은 말 그대로 인덱스를 처음부터 끝까지 모두 스캔하는 방식
* 단, 테이블에 접근하지 않고 인덱스로 구성된 열 정보만 요구하는 sql 문에서 인덱스 풀 스캔이 수행 됨
* 인덱스 풀 스캔은 테이블에 접근하지 않으므로 테이블 풀 스캔보다는 효율적
* 인덱스라는 오브젝트의 전 영역을 모두 검색하는 방식인 만큼 범위를 최대한 줄이는 방향으로 튜닝 필요


<br />

### 인덱스 고유 스캔
* 인덱스 고유 스캔은 기본 키나 고유 인덱스로 테이블에 접근하는 방식.
* 인덱스를 사용하는 스캔 방식 중 가장 효율적 스캔 방법
* where 절에 = 조건으로 작성,해당 열이 기본 키 또는 고유 인덱스의 선두 열로 설정되었을 때 인덱스 고유 스캔이 발생

<br />

### 인덱스 루스 스캔
* 인덱스 루스 스캔은 인덱스의 피룡한 부분들만 골라 스캔하는 방식
* 인덱스 범위 스캔처럼 넓은 범위에 전부 접근하지 않고, where절 조건문 기준으로 필요한 데이터와 필요하지 않은 데이터를 구분한 뒤 불필요한 인덱스 키는 무시
* 인덱스 루스 스캔은 보통 group by 구문이나 max(), min() 함수가 사용된 경우 발생
* `이미 오름차순으로 정렬된 인덱스 에서 최댓값이나 최솟값이 필요한 경우가 이에 해당`

<br />

### 인덱스 병합 스캔
* 인덱스 병합 스캔은 테이블 내에 생성된 인덱스들을 통합해서 스캔하는 방식
* where 절에 여러 열들이 서로 다른 인덱스로 존재하면 옵티마이저가 해당하는 인덱스를 가져와 모두 활용하는 방식을 취함.
* 통합하는 방법으로는 union, intersection방식이 있으며 plan으로 확인 가능
* `인덱스 병합 스캔은 물리적으로 존재하는 개별 인덱스를 각각 수행하므로 인덱스에 접근하는 시간이 몇 배로 걸림.`
* 따라서 별개로 생성된 인덱스들은 보통 하나의 인덱스로 통합하여 sql 튜닝 하거나, sql문 자체를 독립된 하나의 인덱스만 수행하도록 변경하여 튜닝



## 응용 용어
### 선택도
* 선택도란 테이블의 특정 열을 기준으로 해당 열의 조건절에 따라 선택되는 데이터 비율을 의미.
* 만약 해당 열에 중복되는 데이터가 많다면 선택도가 높다.
* 해당 열에 중복되는 데이터가 적다면 선택도가 낮다.
* `낮은 선택도를 갖는 열은 데이터를 조회하는 sql문에서 원하는 데이터를 빨리 찾기 위한 인덱스 열을 생성할때 주요 고려 대상`
> 선택도 = 선택한 데이터 건수 / 전체 데이터 건수  
> 선택도 = 1 / DISTINCT(count 열명)
>

### 카디널리티
* 카디널리티의 사전적 정의는 하나의 데이터 유형으로 정의되는 데이터 행의 개수로 전체 데이터에 접근한 뒤 출력될 것이라 예상되는 데이터 건수.
* 현업에서는 전체 행에 대한 특정 열의 중복 수치를 나타내는 지표로 활용

> 카디널리티 = 전체 데이터 건수 * 선택도

* 특정 열에 중복된 값이 많다면 카디널리티가 낮고,
* 해당 열을 조회하면 상당수의 데이터를 거리지 못한 채 대량의 데이터가 출력되리라 예측

| a   | b  |
|-----|----|
| 1   | 1  |
| 1   |2|
| 1   |3|
| 1   |4|
| 1   |5|
| 2   |6|
| 2   |7|
| 2   |8|

* a열의 카디널리티는 낮고,
* b열의 카디널리티는 높다.

### 힌트
* 데이터를 빨리 찾을 수 있게 추가 정보를 전달하는 것
* 힌트는 아래와 같이 사용
```sql
SELECT 컬럼
FROM 테이블 USE INDEX (인덱스명)
WHERE 조건
```
* 주요 힌트 목록

| 힌트            | 설명                         |
|---------------|----------------------------|
| STRAIGHT_JOIN | from 절에 작성된 테이블 순으로 조인을 유도 |
| USE INDEX     | 특정 인덱스를 사용하도록 유도           |
| IGNORE INDEX  | 특정 인덱스를 사용하지 않도록 유도        | 
| FORCE INDEX   | 특정 인덱스를 사용하도록 강하게 유도       |


* 주의사항
* 힌트로 특정 인덱스를 사용하라고 명시 했는데 해당 인덱스가 삭제되면 에러 발생함.
---
# 실행계획
## 기본 실행 계획 항목 분석
### id
* 실행 순서를 표시하는 숫자. SQL문이 수행되는 차례를 ID로 표기한 것으로, 조인할 때는 똑같은 ID가 표시됨
* ID가 작을수록 먼저 수행된 것이고 ID가 같은 값이면 조인이 이루어졌다고 해석
---
### select_type
* SQL문을 구성하는 SELECT 문의 유형을 출력하는 항목
* SELECT 문이 단순히 FROM절에 위치한 것인지, 서브쿼리인지, UNION 절로 묶인 SELECT 문인지 등의 정보 제공

#### | SIMPLE |
* UNION이나 내부 쿼리가 없는 SELECT 문이라는 걸 의미하는 유형입니다. (단순한 SELECT 구문으로만 작성된 경우)

#### | PRIMARY |
* 서브쿼리가 포함된 SQL 문이 있을 때 첫 번쨰 SELECT 문에 해당하는 구문에 표시되는 유형입니다.
* 서브쿼리를 감싸는 외부 쿼리이거나, UNION이 포함된 SQL 문에서 첫 번째로 SELECT 키워드가 작성된 구문에 표시됨.

#### | SUBQUERY |
* 독립적으로 수행되는 서브쿼리를 의미함.
* SELECT 절의 스칼라 서브쿼리와 WHERE 절의 중첩 서브쿼리일 경우에 해당함

#### | DERIVED |
* FROM 절에 작성된 서브쿼리라는 의미
* FROM 절의 별도 임시 테이블인 인라인 뷰를 말함.

#### | UNION |
* UNION이나 UNION ALL로 묶인 SELECT 문에서 첫 번째 SELECT 구문을 제외한 이후의 SELECT 구문에 해당함
* (UNION구문의 첫 번째 SELECT 절은 PRIMARY 유형으로 표시됨)

#### | UNION RESULT |
* UNION ALL이 아닌 UNION 구문으로 SELECT 절을 결합했을 때 출력됩니다.
* UNION은 출력 결과에 중복이 없는 유일한 속성을 가지므로 각 SELECT 절에서 데이터를 가져와 정렬하여 중복 체크하는 과정을 거칩니다.
* 따라서 UNION RESULT는 별도의 메모리 또는 디스크에 임시 테이블을 만들어 중복을 제거하겠다는 의미로 해석할 수 있다.
* `UNION 구문으로 결합되기 전의 각 SELECT 문이 중복되지 않는 결과가 보장될 때는 UNION 구문 보다는 UNION ALL 구문으로 변경하는 것이 좋다.`

#### | DEPENDENT SUBQUERY |
* UNION 또는 UNION ALL을 사용하는 서브쿼리가 메인 테이블의 영향을 받는 경우
* UNION으로 연결된 단위 쿼리들 중에서 처음으로 작성한 단위 쿼리에 해당하는 경우.
* `UNION으로 연결되는 첫 번째 단위 쿼리가 독립적으로 수행하지 못하고 메인 테이블로부터 값을 하나씩 공급받는 구조- > 튜닝 대상`

#### | DEPENDENT UNION |
* UNION 또는 UNION ALL을 사용하는 서브쿼리가 메인 테이블에 영향을 받는 경우
* UNION으로 연결된 단위 쿼리들 중에서 두 번째 단위 쿼리에 해당되는 경우.
* `UNION으로 연결되는 두 번째 단위 쿼리가 독립적으로 수행하지 못하고 메인 테이블로부터 값을 하나씩 공급받는 구조- > 튜닝 대상`

#### | UNCACHEABLE SUBQUERY |
* 메모리에 상주하여 재활용되어야 할 서브쿼리가 재사용되지 못할 때 출력되는 유형
* 해당 서브쿼리 안에 사용자 정의 함수나 사용자 변수가 포함되거나, RAND(), UUID()함수 등을 사용하여 매번 조회 시 마다 다른 결과를 반환하는 경우
* `만약 자주 호출되는 SQL문이라면 메모리에 서브쿼리 결과가 상주할 수 있도록 변경하는 방향으로 튜닝 고려`

#### | MATERIALIZED |
* IN절 구문에 연결된 서브쿼리가 임시 테이블을 생성한 뒤, 조인이나 가공 작업을 수행할 떄 출력되는 유형.
* 즉 IN 절의 서브쿼리를 임시 테이블로 만들어서 조인 작업을 수행하는 것
---
### table
* 테이블명을 표시하는 항목
* 실행 계획 정보에서 테이블명이나 테이블 별칭을 출력
* 서브쿼리나 임시 테이블을 만들어서 별도의 작업을 수행할 때는 subquery, derived라고 표시됨.

---
### partitions
* 실행 게획의 부가 정보로, 데이터가 저장된 논리적인 영역을 표시.
* 만약 너무 많은 영역의 파티션에 접근하는 것으로 출력된다면 파티션 정의 튜닝 고려.
---

### type
* 테이블의 데이터를 어떻게 찾을지에 관한 정보를 제공함
* 테이블을 처음부터 끝까지 전부 확인할지 아니면 인덱스를 통해 바로 데이터를 찾아갈지 등을 해석할 수 있다.

#### | system |
* 테이블에 데이터가 없거나 한 개만 있는 경우로, 성능상 최상의 type이라고 할 수 있습니다.

#### | const |
* 조회되는 데이터가 단 1건일 때 출력되는 유형으로, 성능상 매우 유리한 방식.
* 고유 인덱스나 기본 키를 사용하여 단 1건의 데이터에만 접근하면 되므로 속도나 리소스 사용 측면에서 매우 유리한 방식.

#### | eq_ref |
* 조인이 수행될 떄 드리븐 테이블의 데이터에 접근하며 고유 인덱스 또는 기본 키로 단 1건의 데이터를 조회하는 방식.
* 드라이빙 테이블과의 조인 키가 드리븐 테이블에 유일하므로 조인이 수행될 떄 성능상 가장 유리.

#### | ref |
* 조인을 수행할 떄 드리븐 테이블의 데이터 접근 범위가 2개 이상일 경우를 의미
* 즉 조인이 수행될때 일대다 관계가 되므로, 드라이빙 테이블의 1개 값이 드리븐 테이블에서는 2개 이상의 데이터로 존재함.
* 기본 키나 고유 인덱스를 활용하면 2개 이상의 데이터가 검색되거나, 유일성 없는 비고유 인덱스를 사용하게 된다.
* 드리븐 테이블의 데이터 양이 많지 않을때는 성능 저하를 크게 우려하지 않아도 되지만,
* 데이터양이 많다면 접근해야 할 데이터 범위가 넓어져 성능 저하의 원인이 되는지 확인해야함.
* 한편으로 =,<,> 등의 연산자를 사용해 인덱스로 생성된 열을 비교할 떄도 출력됨.

#### | ref_or_null |
* ref 유형과 유사하지만 IS NULL 구문에 대해 인덱스를 활용하도록 최적화된 방식.
* MySQL과 MariaBD는 NULL에 대해서도 인덱스를 활용하여 검색할 수 있으며, 이때 NULL은 사장 앞쪽에 정렬됨.
* 테이블에 검색할 NULL 데이터양이 적다면 ref_of_null 방식을 활용했을 때 효율적인 SQL문이 될 것이나,
* 검색할 NULL 데이터양이 많다면 튜닝의 대상

#### | range |
* 테이블 내의 연속된 데이터 범위를 조회하는 유형
* 주어진 데이터 범위 내에서 행 단위로 스캔하지만, 스캔할 범위가 넓으면 성능 저하의 요인이 될 수 있음

#### | fulltext |
* 텍스트 검색을 빠르게 처리하기 위해 전문 인덱스를 사용하여 데이터에 접근하는 방식

#### | index_merge |
* 결합된 인덱스들이 동시에 사용된든 유형입니다.
* `특정 테이블에 생성된 두 개 이상의 인덱스가 병합되어 동시에 적용됩니다.( 전문 인덱스 제외)`

#### | index |
* type 항목의 index 유형은 인덱스 풀 스캔을 의미한다.
* 즉 물리적인 인덱스 블록을 처음부터 끝까지 훑는 방식
* 보통 인덱스는 테이블보다 크기가 작으므로 테이블 풀 스캔 방식보다는 빠를 가능성이 높다.

#### | ALL |
* 테이블을 처음부터 끝까지 읽는 테이블 풀 스캔 방식에 해당됨.
* All 유형은 활용할 수 있는 인덱스가 없거나, 인덱스를 활용하는게 오히려 비효율적이라고 옵티마이저가 판단했을때 선택
* `All 유형일 때는 인덱스를 새로 추가하거나 기존 익덱스를 변경하여 인덱스를 활용하도록 튜닝`
* `전체 테이블중 10~20% 이상의 데이터를 검색해야 한다면 All 유형이 나올 가능성이 높음.`
---
### possible_keys
* 옵티마이저가 sql문을 최적화하고자 사용할 수 있는 인덱스 목록을 출력
* 사용할 수 있는 후보군의 기본 키와 인덱스 목록만 보여주므로 튜닝의 효용성은 없음.
---
### key
* 옵티마이저가 sql문을 최적화 하고자 선택한 기본키(PK) 또는 인덱스명을 출력
* 비효율적인 인덱스나, 인덱스 자체를 사용하지 않았다면 튜닝 대상
---
### key_len
* 인덱스를 사용할 때는 인덱스 전체를 사용하거나 일부 인덱스만 사용합니다.
* key_len은 이렇게 사용한 인덱스의 바이트 수를 의미함.
* UTF-8 캐릭터셋 기준으로 INT 4바이트, VARCHAR 3바이트
---
### ref
* 테이블 조인을 수행할 때 어떤 조건으로 해당 테이블에 액세스 되었는지를 알려주는 정보.
---
### row
* sql문을 수행하고자 접근하는 데이터의 모든 행 수를 나타내는 예측 항목.
* `sql문의 최종 결과 건수와 비교해 rows수가 크게 차이 날 떄는 불필요하게 MySQL엔진까지 데이터를 많이 가져왔다는 뜻 -> 튜닝 대상`
---
### filtered
* sql문을 통해 DB 엔진으로 가져온 데이터 대상으로 필터 조건에 따라 어느 정도의 비율로 데이터를 제거했는지를 의미하는 항목.
* DB엔진으로 100건의 데이터를 가져왔다고 가졍했을때 조건에의해 10건이 필터링 되었다면 100/10 = 10 이라는 정보가 출력
---
### Extra
* sql문을 어떻게 수행할 것인지에 관한 추가 정보를 보여주는 항목

#### | Distinct |
* 중복이 제거되어 유일한 값을 찾을 때 출력되는 정보
* 중복 제거가 포함되는 distinct 키워드나 union 구문이 포함된 경우 출력된다.

#### | Using where |
* 실행 계획에서 자주 볼 수 있는 extra 정보입니다. where 절의 필터 조건을 사용해 MySQL 엔진으로 가져온 데이터를 추출할 것이라는 의미로 이해

#### | Using temporary |
* 데이터의 중간 결과를 저장하고자 임시 테이블을 생성하겠다는 의미.
* 데이터를 가져와 저장한 뒤에 정렬 작업을 수행하거나 중복을 제거하는 작업등을 수행.
* 보통 Distinct, Group by, Order by 구문이 포함된 경우 Using temporary 정보가 출력됨.
* `임시 테이블을 메모리에 생성하거나, 메모리 영역을 초과하여 디스크에 임시 테이블을 생성하면 성능 저하의 원인-> 튜닝 대상`

#### | Using index |
* 물리적인 데이터 파일을 읽지 않고 인덱스만을 일거서 sql 요청을 처리하는 경우 ( 커버링 인덱스 )
* 성능 측면에서 효율적.

#### | Using filesort |
* 정렬이 필요한 데이터를 메모리에 올리고 정렬 작업을 수행하는 경우
* 인덱스를 사용하지 못할 때는 정렬을 위해 메모리 영역에 데이터를 올림.
* Using filesort는 추가적인 정렬 작업이므로 인덱스를 활용하도록 튜닝 검토 대상.

#### | Using join buffer |
* 조인을 수행하기 위해 중간 데이터 결과를 저장하는 조인 버퍼를 사용한다는 의미.
* 드라이빙 테이블의 데이터에 먼저 접근한 결과를 조인 버퍼에 담고,
* 조인 버퍼와 드리븐 테이블 간에 서로 일치하는 조인 키값을 찾는 과정 수행.

#### | Using index condition  |
* MySql엔진에서 인덱스로 생성된 열의 필터 조건에 따라 요청된 데이터만 필터링하는 Using where 방식과 달리,
* 필터 조건을 스토리지 엔진으로 전달하여 필터링 작업에 대한 MySql엔진의 부하를 줄이는 방식
* 스토리지 엔진의 데이터 결과를 MySql엔진으로 전송하는 데이터 양 자체를 줄여 성능 효율을 높일 수 있는 옵티마이저의 최적화 방식

#### | Using index for group-by |
* sql 문에 Group by 구문이나 Distinct 구문이 포함될 때는 인덱스로 정렬 작업을 수행하여 최적화함.
* 이때 Using index for group-by는 인덱스로 정렬 작업을 수행하는 인덱스 루스 스캔일 때 출력됨.

#### | Not exists |
* 하나의 일치하는 행을 찾으면 추가로 행을 더 검색하지 않아도 될 떄 출력되는 유형입니다.

### 좋고 나쁨을 판단하는 기준

* select_type 항목의 판단 기준

| 좋음                              |나쁨                        |
|---------------------------------|---------------------------|
| SIMPLE <br/>PRIMARY<br/>DERIVED |DEPENDENT<br/>UNCACHEABLE |

* type 항목의 판단 기준

| 좋음                           | 나쁨            |
|------------------------------|---------------|
| SYSTEM <br/>CONST<br/>EQ_REF | INDEX<br/>ALL |
* extra 항목의 판단 기준

| 좋음           | 나쁨                                 |
|--------------|------------------------------------|
| Using index  | Using filesort<br/>Using temporary |

---


# Sql Tuning
## 실무적인 SQL 튜닝 절차 이해하기
* SQL 문의 구성요소는 크게 두 가지로 구분할 수 있다.
* 가시적으로는 테이블 현황, 조건절, 그루핑 열, 정렬되는 열, select 절의 열 등이 있고,
* 비 가시적으로는 실행 계획, 인덱스 현황, 조건절 열들의 데이터 분포, 데이터의 적재 속도, 업무 특성등이 있다.

1. sql문 실행결과 & 현황 파악
  * 결과 및 소요시간 확인.
  * 조인/서브쿼리 구조
  * 동등/범위 조건
2. 가시적, 비 가시적 요소 파악
  * 가시적 : 테이블의 데이터 건수, select절 컬럼 분석, 조건절 컬럼 분석, 그루핑/정렬 컬럼
  * 비가시적 : 실행 계획, 인덱스 현황, 데이터 변경 추이, 업무적 특징.
3. 튜닝 방향 판단 & 개선/적용


### 기본 키를 변형하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220267490-76b226ec-b48a-49fb-ba37-69a210a8e8e1.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220267753-a009dede-c1b2-4d3a-898d-93cc28ed9019.png)

#### 튜닝 수행
* | 데이터 확인 |  
  ![image](https://user-images.githubusercontent.com/60100532/220268027-48959575-be69-4508-b370-46bc1139244c.png)
* | index 확인 |  
  ![image](https://user-images.githubusercontent.com/60100532/220268355-3c391226-6abe-4886-8b22-a9b20994b516.png)

* 튜닝 전 sql 문에서는 사원번호 열(기본키)을 where절 조건으로 작성했지만   
  substring(사원번호,1,4)와 length(사원번호)와 같이 가공하여 사용했으므로
* 기본키를 사용하지 못하고 테이블 풀 스캔(Type ALL)을 수행하게 됨
* 따라서 가공된 사원번호 열을 변경하여 기본 키를 사용할 수 있도록 튜닝.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  * 기존 가공되어 사용되던 사원번호(기본키)를 변형없이 사용하도록 변경
  * ![image](https://user-images.githubusercontent.com/60100532/220269424-2b70dc32-d10b-4de2-9990-461a7f5af502.png)
* | 튜닝 후 실행 계획 |
  * ![image](https://user-images.githubusercontent.com/60100532/220269793-131e9adb-4928-4936-9b68-02224415e062.png)
  * where 절의 between 구문에 의해 기본키 (key : primary)의 특정 범위 스캔(type : range)
  * 출력할 사원번호가 10개 이므로 rows항목에서도 10이라는 값을 출력


---

### 사용하지 않는 함수를 포함하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220271368-8629b97f-1fba-48a5-b030-3c0b489f7623.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220271773-b1052128-7b65-4213-89e1-1823dd85237b.png)
* key 항목이 I_성별_성 , type 항목이 index
* 즉 I_성별_성 인덱스를 활용해 인덱스 풀스캔 수행
* 또한 extra에 Using temporary, Using filesort가 표시되어 있음 -> 임시 테이블 생성 및 정렬 수행.

#### 튜닝 수행
* 성별 컬럼은 not null  
  ![image](https://user-images.githubusercontent.com/60100532/220273581-3965b108-947d-45d0-b97c-ca225371467b.png)
* 따라서 ifnull() 함수를 처리하려고 DB 내부적으로 별도의 임시 테이블을 만들어서 null값 예외처리를 필요 없음.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  * ifnull() 함수를 제거하고 성별 열만 그대로 사용하여 튜닝한 쿼리.
  * ![image](https://user-images.githubusercontent.com/60100532/220273991-ca0c3b87-3e4c-4c45-8d62-9f2dabd9d2e1.png)
* | 튜닝 후 실행 계획 |
  * ![image](https://user-images.githubusercontent.com/60100532/220275374-df16838c-37a7-4b1c-985b-966f9648c4da.png)
  * key 항목이 I_성별_성 , type 항목이 index
  * 즉 I_성별_성 인덱스를 활용해 인덱스 풀스캔 수행.
  * extra 항목에 Using index가 표시되어 있음 -> 인덱스 풀 스캔 수행. (기존 임시 테이블 없이)

---

### 형변환으로 인덱스를 활용하지 못하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220276171-0dc92fb9-e621-4d92-9be3-ad308ba356ae.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220278858-aa7a6e96-108d-492d-9a22-5b6f49b9a0f8.png)
  * key 항목 I_사용여부, type 항목 index
  * I_사용여부 인덱스를 활용해 인덱스 풀스캔 수행
  * rows 항목 449385 즉 스토리지 엔진에서 449385건을 읽어와 42842으로 필터링해 출력함.
  * 스토리지 엔진에서 불필요한 I/O 발생.


#### 튜닝 수행
* 데이터 확인  
  ![image](https://user-images.githubusercontent.com/60100532/220285934-e841dd65-db5b-4ff1-a3b4-7580f72f697f.png)
* 사용여부 컬럼 값이 1인 데이터는 전체 데이터 대비 2% 미만.  
  ![image](https://user-images.githubusercontent.com/60100532/220286646-1b6d3983-b2ca-47f4-8f68-854616c94dec.png)
* 사용여부 열 type은 문자형인 char(1) 즉 where 사원번호 = 1과 같이 숫자 유형으로 데이터에 접근해
* 내부적으로 형변환이 발생 -> 그결과 I_사용여부 인덱스를 제대로 활용하지 못함.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220287068-88018c18-56d4-4520-84b5-c2d6818640ca.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220287350-c0229f99-4910-4050-9d9b-631686977f75.png)
  * 스토리지 엔진에서 가져온 데이터 건수가 85682건으로 줄어듬. 스토리지 엔진 I/O감소

---

### 열을 결합하여 사용하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220290622-5734d970-5386-4891-8204-eca5257119e6.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220290731-efaf7bd7-947d-4b9a-bc94-d6237cc7626c.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220290883-dcbf720d-8683-473b-86df-68535ee16f63.png)
  * type 항목 ALL
  * 테이블 풀스캔
  * rows 항목 298980 즉 스토리지 엔진에서 298980건을 읽어와 102건 으로 필터링해 출력함.


#### 튜닝 수행
* 데이터 확인  
  ![image](https://user-images.githubusercontent.com/60100532/220291468-e02b7213-688c-45ea-b64b-2aed9062ee2e.png)
* 인덱스 확인  
  ![image](https://user-images.githubusercontent.com/60100532/220292061-15e157cf-6f29-46f1-9963-8cc3c7b6075d.png)
  * 성별 열과 성 열로 구성된 I_성별_성 인덱스 사용가능.
  * 조건문도 동등 조건(=)이므로 인덱스를 활용하여 빠르게 조회 가능.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220292766-4ba99490-e689-4972-bafb-1e8d4a0fcc1b.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220292845-8b8172f6-9393-4755-a361-6b461c845592.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220293012-70ef8a35-f7c4-4671-9ef7-f31660cbac74.png)
  * key 항목 I_성별_성 인덱스 사용
  * rows 항목 튜닝 전 298980건에서 102건으로 줄어듬. 데이터 엑세스 범위 줄어듬.
---

### 습관적으로 중복을 제거하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220299598-342ae95d-8f33-445f-bd2c-51ff358f3416.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220299703-ce9428d2-6618-4a1e-b550-12d92b4cf73c.png)

* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220299839-8cdc66ad-af09-47af-b344-0cff233a4a58.png)
  * 드라이빙 테이블인 부서관리자 테이블과 드리븐 테이블인 사원 테이블의 id값이 1로 동일함 -> 서로 조인
  * 드라이빙 테이블 부서관리자 테이블의 type 항목 index -> 인덱스 풀스캔
  * 드리븐 테이블 사원 테이블의 type 항목 eq_ref ->  사원번호를 사용해 1건의 데이터를 조회하는 방식으로 조인
  * extra 항목에 Using temporary -별도 임시 테이블 만들고 있음. -> 튜닝 대상
#### 튜닝 수행
* 사원 테이블의 기본 키는 사원번호. -> 사원.사원번호에는 중복된 데이터 없음.
* distinct 키워드 사용할 필요 고민....
> distinct는 나열된 열들을 정렬한 뒤 중복된 데이터는 삭제함.
> distinct를 쿼리에 작성하는 것만으로도 정렬 작업이 포함됨.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220302240-ce7ee7e8-26e0-4c08-8f4f-32394273d9e2.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220302286-f905e1dc-fb37-41d9-92aa-8e59ca5f3151.png)
  * 필요없는 distinct 키워드 제거
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220302591-2752bacf-5ad2-4842-98fc-0b60c2f21418.png)
  * extra 항목의 Using temporary 제거됨
---


### 다수 쿼리를 UNION 연산자로만 합치는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220304194-0232565e-cc49-4096-a204-c4895d99ac12.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220304233-c8d7436c-da36-40a0-bb6c-f3617ae7490f.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220304354-77b3f0d9-9a7b-41ff-b448-b5d14d0e6779.png)
#### 튜닝 수행
* 두 개의 select 문이 UNION 연산자로 통합되는 과정에서 각 select 문의 결과를 합친 뒤 중복을 제거하고 그 결과를 출력함.
* 이미 사원번호라는 기본 키가 출력되는 sql문에서 이처럼 중복 제거가 필요한지 고민해야 함.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220309605-089a0631-1df1-4a33-ad47-4f257be92d4c.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220309676-385004fd-6411-4d7c-83ce-a26916e164c7.png)
  * union -> union all 변경

* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220309852-b1f59539-99b8-440a-8214-6fb50a5f2c02.png)
  * 이전 실행 계획과 달리 id가 1,2의 결과를 단순히 합칠 뿐이므로 세 번째 추가 행은 필요하지 않음.
  * 즉 정렬하여 중복을 제거하는 작업이 제외되면서 불필요한 리소스 낭비 방지.

> UNION ALL 과 UNION의 차이
> * UNION ALL은 여러 개의 SELECT 문을 실행하는 결과를 단수히 합치는 것에 그치지만,   
    > UNION은 여러개의 SELECT 문의 실행 결과를 합친 뒤 중복된 데이터를 제거하는 작업까지 포함함.
---



### 인덱스 고려 없이 열을 사용하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220476685-993c5e9f-3273-4e48-aec0-d8ca0c92252d.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220476740-228bb07b-f0a6-473f-870d-29c9d7f3eb4a.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220476846-0f99b791-3380-4efd-a3ab-332e7bb67d89.png)
  * type 항목이 index, key 항목이 I_성별_성  -> I_성별_성 인덱스를 이용해 풀 스캔
  * 출력 결과는 3274건 이지만 총 298980건의 데이터를 읽어옴
  * Extra 항목에 Using index, Using temporary, Using filesort가 있음
    * Using temporary : 임시 테이블을 사용해 정렬을 수행함
    * Using filesort : 정렬을 수행함
    * Using index : 물리적인 데이터 파일을 읽지 않고 인덱스만 읽음 ( 커버링 인덱스 )
#### 튜닝 수행
* I_성별_성 인덱스를 활용하는데도 임시 테이블을 생성함(Using temporary) -> 필요한가??
#### 튜닝 결과
* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220478307-f06f4040-5631-4476-a0c2-bdf09573b567.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220478334-1a63bd68-dfae-43b7-bf0f-39360392adf6.png)
  * I_성별_성 인덱스를 최대한 활용하기 위해 group by 절에 인덱스 순서대로 성별, 성 으로 그루핑
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220478509-5fdc2ad4-73f0-47c3-91a6-2c88f1d03dab.png)
  *  Extra 항목에 Using temporary, Using filesort가 사라짐.
  * Using index만 남아 커버링 인덱스로 모든 데이터 처리
  * 처리 시간도 0.281 초에서 0.098초로 줄어듬.

---



### 엉뚱한 인덱스를 사용하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220479227-6927af0c-248f-47b2-aa1a-68e5b426419e.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220479264-a8b7b638-af09-4522-a3ca-4d626ad85963.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220479306-1a303684-c2c4-443b-950b-2e32a9090c8d.png)
#### 튜닝 수행
![image](https://user-images.githubusercontent.com/60100532/220480576-365b34e1-ae79-465e-8643-614a7297a9c5.png)  
![image](https://user-images.githubusercontent.com/60100532/220480666-4b9970da-c7e0-4702-ac4a-450b97cddd18.png)  
![image](https://user-images.githubusercontent.com/60100532/220480751-7c322321-ec36-4abf-bbd1-0e051e2391fa.png)
* 전체 사원 데이터 약 30만건
* 입사일자 1989년도 사원 데이터 약 3만건
* 사원번호가 100000 이상인 사원 데이터 약 2만건
* 즉 입사일자로 먼저 필터링 후 사원번호로 필터링하는 것이 효율적일 것 같다.
  ![image](https://user-images.githubusercontent.com/60100532/220481436-6ac99cb1-2017-4475-9083-5382601a369b.png)
* 입사일자의 데이터 유형은 date 타입이지만 문자열 like로 검색
#### 튜닝 결과

* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220481888-4e5d6ea3-4949-446b-8bef-03d7637be702.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220481915-6d23cd8f-00ff-471f-8afd-21cddaecb4ca.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220481830-83796620-b80b-47c4-a59b-580aca3b57b5.png)
  * Extra 항목에 Using index 출력 -> 커버링 인덱스로 처리
  * rows 항목에 5만건 출력 -> 스토리지 엔진 I/O줄임.
---


###  동등 조건으로 인덱스를 사용하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220483449-caa333f4-0438-44fd-9aef-344939155780.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220483476-ebc2ffcb-3bb7-4110-b5f3-b7c5de021d11.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220483515-b40c5397-7347-4ba1-b184-c1e0e0712ff2.png)

#### 튜닝 수행
* 출입문 B의 데이터는 전체 데이터 대비 약 50%이다.
* 앞의 실행계획에 따르면 I_출입문 인덱스로 인덱스 스캔한 뒤 테이블에 다시 접근한다.
* 전체 50%의 데이터를 조회하려고 인덱스를 사용하는게 효율적일지 고민해야함.  
  ![image](https://user-images.githubusercontent.com/60100532/220484526-85a88bf6-a3bc-4bdf-b301-66119c58844f.png)
#### 튜닝 결과
* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220484990-c907abdb-9e5a-4426-b4d6-1216f97b413d.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220485019-d78745a3-33db-454a-a2a0-ee630527d945.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220485172-760dab4f-4afd-436c-ba2a-7cd965cca182.png)
  * type 항목이 ALL 즉 테이블 풀 스캔이 일어난다,
  * 즉 인덱스를 활용하지 않고 전체 약 60만건의 전체 데이터를 가져와 where 출입문 = 'B' 조건절로 데이터 추출
---

###  범위 조건으로 인덱스를 사용하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220486557-7d132533-6e39-46b7-8502-c272d1411732.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220486592-02ce4c8e-a4ce-4f83-bade-c6bb2cd9b003.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220487195-54aca038-c4d5-40ce-a9e1-80bcfba2ffb5.png)
  * I_입사일자 인덱스로 type range 범위 스캔을 수행함.
#### 튜닝 수행
![image](https://user-images.githubusercontent.com/60100532/220487466-0a845111-c72d-4792-9699-e3c832d5ecaa.png)
* 사원 테이블의 전체 데이터 약 30만건
* sql 결과는 48875건 전체 데이터 대비 17%에 해당되는 데이터 조회
* 인덱스를 사용하는것이 효율적일지, 아니면 테이블 풀 스캔이 효율적일지 고민
* 입사일자 기준으로 매번 수 년에 걸친 데이터를 조회하는 경우가 잦다면,  사실상 인덱스 스캔으로 랜덤 액세스의 부하가 발생하는 것 보단
* 테이블 풀 스캔 방식을 고정적으로 설정하는 게 더 효율적일 수 있다.
#### 튜닝 결과
* | 튜닝 후 SQL 문 |  
  ![image](https://user-images.githubusercontent.com/60100532/220489471-574a2dc9-7610-40db-9ae5-0b3561dc1472.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220489507-539056b1-b649-40ef-a6d4-64310992bbfe.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220489555-1f8902d5-ac84-4546-97de-f226d19cbf30.png)
  * where 절의 인덱스를 가공해 인덱스를 사용하지 못하도록 변경
  * 인덱스에 접근 하지 않고 한번에 다수의 페이지에 접근

---

---

##  테이블 조인 설정 변경으로 착한 쿼리 만들기
> MySQL과 MariaDB에서 두 개 테이블의 데이터를 결합하는 조인 알고리즘은 대부분 중첩 루프 조인으로 풀린다.

### 작은 테이블이 먼저 조인에 참여하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |

  ![image](https://user-images.githubusercontent.com/60100532/220491122-042b59b4-9757-40a4-8f04-5ddfda1d01ad.png)    
  ![image](https://user-images.githubusercontent.com/60100532/220491153-b7a7aec6-0734-410c-b5ce-de30f11470f8.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220491411-0f8c85b0-c67c-47ab-ac49-ace510b3242b.png)
#### 튜닝 수행
* 쿼리 튜닝전 데이터 확인    
  ![image](https://user-images.githubusercontent.com/60100532/220491677-4235ae52-5943-4ce1-912e-2a555385ef24.png)    
  ![image](https://user-images.githubusercontent.com/60100532/220491791-ed817473-80a6-4a0a-98a7-fbb944084ecc.png)    
  ![image](https://user-images.githubusercontent.com/60100532/220492155-383fdffe-6827-4df7-81d4-d16b88a21184.png)
* 드라이빙 테이블인 부서 테이블에 데이터 9건
* 드리븐 테이블인 부서사원_매핑 테이블에는 약 33만건
* 그중 조건절로 추출한 데이터는 1341건 전체 건수 대비 약 0.4%
* 상대적으로 규모가 큰 부서사원_매핑 테이블의 매핑.시작일자 >='2002-03-01' 조건을 먼저 적용할 수 있다면 조인할 때 비교대상이 줄어들 것이다.
#### 튜닝 결과
* | 튜닝 후 SQL 문 |    
  ![image](https://user-images.githubusercontent.com/60100532/220493645-cc94aab9-6535-4a09-a8dd-4f7b5f713e56.png)    
  ![image](https://user-images.githubusercontent.com/60100532/220493668-2b6189a8-948e-46b8-832d-e429d02b6a95.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220493717-b4fe1de6-ddb5-4001-8d80-56ba3a031d86.png)
  * 먼저 접근하는 드라이빙 테이블인 부서사원_매핑 테이블은 랜덤 액세스 없이 테이블 풀 스캔 type all 방식으로 접근.
  * 드라이빙 테이블에서 추출된 데이터 만큼 드리븐 테이블 부서 테이블에 접근
  * 즉 상대적으로 대용량인 부서사원_매핑 테이블을 테이블 풀 스캔으로 처리해 데이터 건수를 줄이고
  * 드리븐 테이블인 부서 테이블에는 key primary 로 접근해 1개의 데이터에만 접근
---



### 메인 테이블에 계속 의존하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |
```sql
select 사원.사원번호, 사원.이름, 사원.성
from 사원
where 사원번호 > 450000
and (select max(연봉)
     from 급여
     where 사원번호 = 사원.사원번호
     ) > 100000;
```  
![image](https://user-images.githubusercontent.com/60100532/220494517-16166d7a-073c-411f-9ad3-c7d9536a99da.png)
* | 튜닝 전 실행 계획 |    
  ![image](https://user-images.githubusercontent.com/60100532/220494683-a56e644e-8d10-4d21-8df9-cfb932c9c7f6.png)
#### 튜닝 수행
* 쿼리 튜닝전 데이터 확인    
  ![image](https://user-images.githubusercontent.com/60100532/220498923-e3315f71-aa53-48cf-9219-ffd3ec304ef5.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220498987-4eaeb79b-6076-4870-b9f5-61f00e1b7913.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220499066-4687a6df-23ba-4cef-8f2b-47e6b829e67c.png)
* 사원 테이블 약 30만건
* 급여 테이블 약 50만건
* 사원번호가 450000 초과하는 데이터는 49999건 전체 데이터 대비 약 15%
* 활용하는 인덱스 -> 모두 기본 키
* 보통 실행 계획 select_type의 DEPENDENT라는 키워드가 있으면 외부 테이블에서 조건절을 받은 뒤 처리되어야 한다 -> 튜닝대상
> * 서브쿼리 vs 조인  
    > 조인으로 수행하는 편이 성능 측면에서 유리할 가능성이 높다.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  select 사원.사원번호,
         사원.이름,
         사원.성
  from 사원,
       급여
  where 사원.사원번호 > 450000
  and 사원.사원번호 = 급여.사원번호
  group by 사원.사원번호
  having max(급여.연봉) > 100000;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220500280-2e629e3d-cbe1-4487-b853-16b8f242b456.png)
  * where 절의 서브쿼리를 조인으로 변경 group by 절과 having 절을 이용해 그룹별 최댓값 계산

* | 튜닝 후 실행 계획 |    
  ![image](https://user-images.githubusercontent.com/60100532/220501100-967a718a-23b8-46a7-a53e-9332f3e63e33.png)
  * DEPENDENT SUBQUERY 키워드 제거
---   

### 불필요한 조인을 수행하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  select count(distinct 사원.사원번호) as 데이터건수
  from 사원,
       (select 사원번호
        from 사원출입기록 기록
        where 출입문 = 'A'
        ) 기록
  where 사원.사원번호 = 기록.사원번호;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220502901-92ee5ff6-b0e9-42d8-b74d-e5de1735f151.png)
* | 튜닝 전 실행 계획 |    
  ![image](https://user-images.githubusercontent.com/60100532/220502961-cadd03a6-ccb6-4028-96a6-ebe820d0472b.png)
  * 사원출입기록 테이블과 사원 테이블의 id는 둘 다 1 -> join이 수행됨.
  * where 절에서는 값이 'A'인 상수와 직접 비교하므로 ref 항목이 const로 출력
  * 인덱스를 사용한 동등(=)비교를 수행하므로 type 항목이 ref로 표시됨.
  * type 항목의 eq_ref는 드리븐 테이블에서 기본 키를 사용할때 표시됨.

#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  select count(1) as 데이터건수
  from 사원
  where exists (select 1
                from 사원출입기록 기록
                where 출입문 = 'A'
                and 사원.사원번호 = 기록.사원번호);
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220524643-0965c9f6-0919-4036-acb9-e4f230969a6a.png)


* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220524738-c1b57427-f60d-4e09-b1a8-678ccc7ead30.png)
  * 사원출입기록 테이블은 exists 연산자로 데이터 존재 여부를 파악하기 위해 임시 테이블을 생성하는 MATERIALIZED 로 select type이 표기됨.
---   

## SQL문 재작성으로 착한 쿼리 만들기
### 처음부터 모든 데이터를 가져오는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT 사원.사원번호,
       급여.평균연봉,
       급여.최고연봉,
       급여.최저연봉
  FROM 사원,
       (SELECT 사원번호,
               ROUND(AVG(연봉),0) 평균연봉,
               ROUND(MAX(연봉),0) 최고연봉,
               ROUND(MIN(연봉),0) 최저연봉
        FROM 급여
        GROUP BY 사원번호
        ) 급여
  WHERE 사원.사원번호 = 급여.사원번호
  AND 사원.사원번호 BETWEEN 10001 AND 10100;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220526412-3d433683-1004-4d80-9adc-459393878038.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220526534-fb277d58-ec77-49a8-ae3b-06af4bf26c05.png)
  * 중첩 루프 조인을 하는 두 개 테이블 ( 사원, derived2) 먼저 출력된 사원 테이블이 드라이빙 테이블,
  * 나중에 출력된 derived2 테이블이 드리븐 테이블
  * derived2 테이블은 id가 2이고 select_type 항목이 DERIVED로 표시됨. from 절에서 급여 테이블로 수행한 결과를 메모리나 디스크에 올려놓음
  * 이후 where 절의 조건에 따라 데이터 추출
#### 튜닝 수행
* Extra 항목 Using temporary, Using filesort
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  SELECT 사원.사원번호,
         (SELECT ROUND(AVG(연봉), 0)
          FROM 급여
          WHERE 사원.사원번호 = 급여.사원번호) 평균연봉,
         (SELECT ROUND(MAX(연봉), 0)
          FROM 급여
          WHERE 사원.사원번호 = 급여.사원번호) 최고연봉,
         (SELECT ROUND(MIN(연봉), 0)
          FROM 급여
          WHERE 사원.사원번호 = 급여.사원번호) 최저연봉
  FROM 사원
  WHERE 사원.사원번호 BETWEEN 10001 AND 10100;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220532165-70355e69-f336-44d1-b741-83147da8c5cd.png)
  * 전체 사원 데이터가 아닌 사원 테이블에서 WHERE절 조건으로 100건의 데이터만 가져옴.
  * SELECT 절에서 급여 테이블에 3번이나 접근하므로 혹시 비효율적인 방식은 아닌지 의문이 들 수 있다.
  * 하지만 추출하려는 사원 테이블의 데이터가 100건(극히 소량 약 0.0003%)에 불과 하므로, 인덱스를 활용해 수행하는 스칼라 서브 쿼리는 많은 리소스를 소모하지 않는다.
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220532052-f21cc4b6-8864-4a5e-9c61-870122c16f08.png)
  * select_type 항목이 DEPENDENT SUBQUERY로 표시됨. 이는 호출을 반복해 일으키므로 지나치게 자주 반복 호출될 경우 성능 저하를 일으킬 수 있다.
  * 하지만 위 예시와 같이 100건의 데이터가 추출되는 경우라면, 성능 측면에서 비효율적인 부분은 거의 없다고 볼 수 있다.
---

### 비효율적인 페이징을 수행하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT 사원.사원번호,
       사원.이름,
       사원.성,
       사원.입사일자
  FROM 사원,
       급여
  WHERE 사원.사원번호 = 급여.사원번호
  AND 사원.사원번호 BETWEEN 10001 AND 50000
  GROUP BY 사원.사원번호
  ORDER BY SUM(급여.연봉) DESC
  LIMIT 150,10;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220534941-a17d74e2-70c5-4769-9495-b5d2a8305065.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220535010-ee9f103a-5210-454b-bc9e-5ba91ba52a09.png)
  * 드라이빙 테이블인 사원 테이블을 그룹핑하고 정렬하는 과정에서 임시테이블(extra 항목 Using temporary, Using filesort)을 생성
#### 튜닝 수행
* LIMIT 연산으로 10건의 데이터를 가져오기 위해 수십만 건의 데이터 대상으로 조인을 수행한 뒤 그룹핑과 정렬 연산을 수행하는 것은 과연 효율적인 방식일까?
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  SELECT STRAIGHT_JOIN 사원.사원번호,
       사원.이름,
       사원.성,
       사원.입사일자
  FROM (SELECT 사원번호
        FROM 급여
        WHERE 사원번호 BETWEEN 10001 AND 50000
        GROUP BY 사원번호
        ORDER BY SUM(급여.연봉) DESC
        LIMIT 150,10) 급여,
      사원
  WHERE 사원.사원번호 = 급여.사원번호;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220541260-d849ad22-ceee-450b-b6ce-138b3811540d.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220541482-570be2ce-7da9-41ef-acc1-564b2a8f447f.png)
  * id가 1인 derived2 테이블과 사원 테이블 대상으로 중첩 루프 조인 수행.
  * derived2 테이블은  id가 2에 해당되는 급여 테이블
  * derived2 테이블은 where 절의 조건으로 type 항목이 range이고 가져온 데이터를 임시 테이블에 올려 정렬 작업 수행( extra 항목 Using temporary, Using filesort)
  * 인라인 뷰인 급여 테이블(derived2) 테이블 기준으로 사원 테이블에 반복해 접근
  * 드라이빙 테이블은 type이 ALL이고 (풀 스캔)
  * 드리븐 테이블은 pk를 활용하여 데이터 추출(type 항목 eq_ref)
---


### 필요 이상으로 많은 정보를 가져오는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT COUNT(사원번호) AS 카운트
  FROM (SELECT 사원.사원번호, 부서관리자.부서번호
        FROM (SELECT *
              FROM 사원
              WHERE 성별 = 'M'
              AND 사원번호 > 300000
              ) 사원
        LEFT JOIN 부서관리자 ON 사원.사원번호 = 부서관리자.사원번호
        ) 서브쿼리;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220549047-e71b885c-aace-435b-90af-88158a9899e0.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220549176-543ddb0a-94f5-4f10-976e-b17794671666.png)
#### 튜닝 수행
* 부서관리자 테이블과 외부 조인하는 사원.사원번호 = 관리자.사원번호 조건이 꼭 필요한 내용일지 고민 필요
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  SELECT COUNT(사원번호) AS 카운트
  FROM 사원 FORCE INDEX(PRIMARY)
  WHERE 성별 = 'M'
    AND 사원번호 > 300000
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220552462-8b36152d-4bdd-49b7-b964-53f484c52a27.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220552640-080d6ab2-ff85-496a-927e-1992db40132e.png)
---


### 대량의 데이터를 가져와 조인하는 sql문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT STRAIGHT_JOIN  DISTINCT 매핑.부서번호
  FROM 부서사원_매핑 매핑 ,
  부서관리자 관리자
       
  WHERE 관리자.부서번호 = 매핑.부서번호
  ORDER BY 매핑.부서번호;
  ```  
  ![image](https://user-images.githubusercontent.com/60100532/220553357-71087003-b43a-4073-83dc-acfad0d9de66.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220830898-88bef23a-b882-4b4a-bc88-3ae3249dcdca.png)
  * 드라이빙 테이블 부서사원_매핑 테이블에 데이터 접근을 구체화 할 조건이 없음 -> 인덱스 풀스캔(TYPE 항목 : index)
  * 드리븐 테이블 부서관리자 테이블은 매핑.부서번호로 접근 & distinct연산 수행.
#### 튜닝 수행
* 결론적으로 조회하고 싶은 데이터는 중복이 제거된 부서번호임.
* 부서관리자 테이블과 부서사원_매핑 테이블 모두에 부서번호 컬럼이 있음.
* 둘 중 하나의 테이블은 단순하게 부서번호가 있는지만 판단하면 ??
* 또 조인을 수행한 뒤 그 결과에서 distinct 작업을 수행함.-> 조인하기 전에 미리 중복 제거 가능하지 않을까??
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  SELECT 매핑.부서번호
  FROM (SELECT DISTINCT 부서번호
        FROM 부서사원_매핑 매핑) 매핑
  WHERE EXISTS(SELECT 1
               FROM 부서관리자 관리자
               WHERE 부서번호 = 매핑.부서번호)
  ORDER BY 매핑.부서번호;
  ```    
  ![image](https://user-images.githubusercontent.com/60100532/220832140-ab145248-5fbf-41c4-8ecd-803b027f061e.png)
  * EXISTS연산을 사용해 부서관리자 테이블의 데이터를 모두 확인하지 않고 동일한 부서번호가 있다면 이후 데이터를 확인하지 않고 바로 조회를 종료
  * 중복 제거를 미리 수행하고 SELECT 절에서 활용하지 않는 부서관리자 데이터는 존재 여부만 판단하도록 수정.
* | 튜닝 후 실행 계획 |   
  ![image](https://user-images.githubusercontent.com/60100532/220833081-7c47da59-9ea1-4dc0-bd73-8d032e7697c1.png)
---



## 인덱스 조정으로 착한 쿼리 만들기
### 인덱스 없이 작은 규모의 데이터를 조회하는 SQL문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT *
  FROM 사원
  WHERE 이름 = 'Georgi'
  AND 성 = 'Wielonsky';
  ```    
  ![image](https://user-images.githubusercontent.com/60100532/220834916-32d41da7-77d9-442e-8d86-537b8615ed47.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220834996-f4c69d2f-2502-464c-99cd-18979a68e6ee.png)
  * 테이블 풀 스캔 (type 항목 all)
  * 스토리지 엔진에서 가져온 데이터 중 where 조건에 맞는 데이터 필터링(extra 항목 using where)
#### 튜닝 수행
* 단 한건의 데이터만 가져오는데 테이블 풀 스캔???
* 인덱스로 빠른 데이터 접근 유도하는 방식으로 튜닝
* 단 이름,성으로 구성된 복합 인덱스를 생성하기 전에 더 다양한 값이 있는 열이 무엇인지 파악
  ![image](https://user-images.githubusercontent.com/60100532/220835968-7f1400f5-b0a0-4a1d-90f8-30203012baba.png)
* 성 컬럼의 데이터 숫자가 더 많으므로 데이터 범위를 더 축소할 수 있는 성 컬럼을 선두로 인덱스 생성.
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  ALTER TABLE 사원
    ADD INDEX I_사원_성_이름 (성, 이름);
  ```    
  ![image](https://user-images.githubusercontent.com/60100532/220836298-930e12f9-90f0-41c9-9269-a87275e7149b.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220836345-76f32193-2c76-4723-b646-1f610a471abc.png)
---  


### 인덱스를 하나만 사용하는 SQL문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT *
  FROM 사원
  WHERE 이름 = 'Matt'
  OR 입사일자 = '1987-03-31';
  ```    
  ![image](https://user-images.githubusercontent.com/60100532/220836942-30c0281a-9a77-44fa-a88c-27ad23d8b2ff.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220837151-c7135157-3f61-4b6a-983c-4a3e2e5d5111.png)
  * 사원 테이블 풀 스캔 (type 항목 all)
#### 튜닝 수행
* 조건절에 해당하는 데이터 분포 확인  
  ![image](https://user-images.githubusercontent.com/60100532/220837598-6d0341ba-a431-47c9-a50b-d9503120db5e.png)  
  ![image](https://user-images.githubusercontent.com/60100532/220837679-c7ebc5cf-78d7-49dc-bdd0-12cc1f5270b2.png)   
  ![image](https://user-images.githubusercontent.com/60100532/220837763-1fa56a44-3997-4aa0-b2fd-7f045394b5f2.png)
* 전체 데이터 건수 대비 각 조건의 데이터 건수 매우 적음.
* 소량의 데이터를 가져올 때는 보통 테이블 풀 스캔보다 인덱스 스캔이 효율적.
* 조건절 열이 포함된 인덱스가 있는지 확인.  
  ![image](https://user-images.githubusercontent.com/60100532/220838035-4b26a497-aafd-4d77-870a-9f5c77bb62a1.png)
* 이름 컬럼이 포함된 인덱스는 없음.
* 이름 컬럼에 대한 인덱스를 생성해 각각의 조건이 각각의 인덱스를 사용할 수 있도록 튜닝
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  ALTER TABLE 사원
    ADD INDEX I_사원_이름 (이름);
  ```    
  ![image](https://user-images.githubusercontent.com/60100532/220838321-88fb2673-d161-4aa1-9254-334d727290dd.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220838436-39f2f165-7b1a-49cc-a1b0-6365d695fec4.png)
  * 2개의 조건절이 각각 인덱스 스캔으로 수행되고 각 결과는 병합(TYPE 항목 : index_merge)
  * 결과가 합쳐진 뒤(EXTRA 항목 : Using union) 출력.
  * 만약 WHERE 절 ~ OR 구문에서 한쪽의 조건절이 동등 조건이 아닌 범위 조건(LIKE, BETWEEN구문) 이라면 INDEX_MERGE로 처리되지 않을 수 있음
  * 버전에 따라 다름 -> 실행 계획을 확인한 뒤 UNION 이나 UNION ALL 구문등으로 분리 고려
---



### 비효율적인 인덱스를 사용하는 SQL문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT 사원번호, 이름, 성
  FROM 사원
  WHERE 성별 = 'M'
  AND 성 = 'Baba';
  ```    
  ![image](https://user-images.githubusercontent.com/60100532/220840706-0e0a6273-e865-46f3-b8ba-44a2123f20cf.png)
* | 튜닝 전 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220840767-0ee48b27-98b7-4320-851b-193afeb51d3c.png)
  * I_성별_성 인덱스를 활용해 데이터에 접근
  * 성별과 성 컬럼에 고정된 값으로 조건을 걸었기 때문에 (ref 항목 : const, const)
#### 튜닝 수행
* 조건문에 작성된 열의 데이터 현황 파악  
  ![image](https://user-images.githubusercontent.com/60100532/220841587-c562c485-08aa-46f2-b7c1-44fb7f6ed907.png)
* 성 컬럼의 데이터는 1637건인데 비해 성별 컬럼의 데이터는 단 2건
* 테이블의 데이터가 많아지면 많아질수록 문제가 발생할 수 있음.
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  ALTER TABLE 사원
    DROP INDEX I_성별_성 , 
    ADD INDEX I_성_성별(성, 성별);
  ```     
  ![image](https://user-images.githubusercontent.com/60100532/220842317-d1cc2a7b-c7e8-436d-9f66-a6c6659955fb.png)
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/220842391-84d99d84-8023-4cad-a327-4a9d2e5e6f17.png)
---






### 분산 없이 큰 규모의 데이터를 사용하는 SQL문
#### 현황 분석
* | 튜닝 전 SQL 문 |
  ```sql
  SELECT COUNT(1)
  FROM 급여
  WHERE 시작일자 BETWEEN STR_TO_DATE('2000-01-01', '%Y-%m-%d') 
                    AND STR_TO_DATE('2000-12-31', '%Y-%m-%d');
  ```    
  ![image](https://user-images.githubusercontent.com/60100532/221073986-b26026b7-1b93-42f3-934e-ba8df1d62baf.png)  
* | 튜닝 전 실행 계획 |   
  ![image](https://user-images.githubusercontent.com/60100532/221074231-fdf2ab5a-4755-4bd2-b2c7-c683db808f25.png)  
#### 튜닝 수행
* 급여 테이블의 총 데이터  
  ![image](https://user-images.githubusercontent.com/60100532/221074819-3d516b62-5966-4556-b4ca-3d47787f2d3e.png)  
* 2000년도 데이터는 전체 데이터의 약 9%에 불과  
  ![image](https://user-images.githubusercontent.com/60100532/221074955-8c6d7e52-47a5-4460-a96e-c4df40796ddd.png)  
* 1986년 부터 2002년 까지 데이터가 고루 퍼져있다.
* 특정 컬럼으로 논리적 분할하는 파티셔닝 가능.
#### 튜닝 결과
* | 튜닝 후 SQL 문 |
  ```sql
  alter table 급여
    partition by range COLUMNS (시작일자)
        (
            partition p85 values less than ('1985-12-31'),
            partition p86 values less than ('1986-12-31'),
            partition p87 values less than ('1987-12-31'),
            partition p88 values less than ('1988-12-31'),
            partition p89 values less than ('1989-12-31'),
            partition p90 values less than ('1990-12-31'),
            partition p91 values less than ('1991-12-31'),
            partition p92 values less than ('1992-12-31'),
            partition p93 values less than ('1993-12-31'),
            partition p94 values less than ('1994-12-31'),
            partition p95 values less than ('1995-12-31'),
            partition p96 values less than ('1996-12-31'),
            partition p97 values less than ('1997-12-31'),
            partition p98 values less than ('1998-12-31'),
            partition p99 values less than ('1999-12-31'),
            partition p00 values less than ('2000-12-31'),
            partition p01 values less than ('2001-12-31'),
            partition p02 values less than ('2002-12-31'),
            partition p03 values less than (maxvalue )
        )
  ```     
  ![image](https://user-images.githubusercontent.com/60100532/221075760-fc8da5fa-b996-4424-8f58-fd11f502eb9b.png)  
* | 튜닝 후 실행 계획 |  
  ![image](https://user-images.githubusercontent.com/60100532/221076112-813d923a-73b7-4386-9b0f-d1d4eb21e320.png)
---

