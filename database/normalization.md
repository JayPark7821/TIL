## 정규화???!!

### 중복된 데이터면 반드시 정규화를 해야할까?
* 사실 실무에서 중복 데이터면 기계적으로 정규화하려고 한다....
* 하지만 정규화도 비용이다. 읽기 비용을 지불하고 쓰기 비용을 줄이는것

### 그럼 정규화시 뭘 고려해야 할까?
* 얼마나 빠르게 데이터의 최신성을 보장해야 하는가?
* 히스토리성 데이터는 오히려 정규화를 하지 않아야 한다.
* 데이터 변경 주기와 조회 주기는 어떻게 되는가??
  * 데이터 변경주기 > 조회 주기 -> 정규화 하는것이 유리 (쓰기에 이점을 가져간다) 
* 객체 탐색 깊이가 얼마나 깊은가?
( 보통 웹서비스의 경우 읽기 쓰비 비율을 비교해보면 읽기가 압도적으로 높다!)

### 정규화를 하기로 했다면 읽기시 데이터를 어떻게 가져올 것인가?
* 테이블 조인을 많이 활용하는데, 이건 사실 고민해볼 문제다!
* 테이블 조인은 서로 다른 테이블의 결합도를 엄청나게 높인다.
* 조회시에는 성능이 좋은 별도 데이터베이스나 캐싱등 다양한 최적화 기법을 이용할 수 있다.
* 조인을 사용하게 되면, 이런 기법들을 사용하는데 제한이 있거나 더 많은 리소스가 들 수 있다.
* 읽기 쿼리 한번 더 발생되는 것은 그렇게 큰 부담이 아닐 수도 있다. 