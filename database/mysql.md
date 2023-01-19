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