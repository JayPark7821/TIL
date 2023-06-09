## ElasticSearch
### 역색인 파일(Inverted Index Structure)
* 인덱스를 색인어 기반의 검색을 생성 하기 위해 색인어에 대한 통계를 저장하는 구조  
즉, 용어에 대해서 문서를 나열 하는 구조가 역인덱스 라고 하는 인덱스 계열

<br />  

### 색인이란?
* IndexWriter가 index File 들을 생성 하는 과정
* 수정이 불가능한 Immutable Type
* 여러개로 생성된 Segments파일들을 Merge라는 작업을 통해 하나의 색인 파일로 만드는 과정 필요
* 하나의 Index는 하나의 IndexWriter로 구성
![img.png](../images/elastic-search/indexingFlow.png)  

<br />  

### 색인 시 알아야 하는 정보
* Index File Formats
* Index Writer
* Index File Formats은 Segment File이라고도 함
* Segment File은 여러 index File 유형중 하나.
* 색인 파일에는 문서의 Field Data, Term, Frequencies, Position, Deleted Documents등과 같은 정보가 저장되고 색인과 검색 시 확용


<br />  

### 검색이란?
* IndexWriter 색인후, IndexSearchㅗ 검색하는 과정
* IndexSearch는 IndexReader를 이용해서 검색 수행을 하게 된다.  
즉, 하나의 index에는 Segment별로 N개의 LeafReader가 존재함.  
![img.png](../images/elastic-search/indexSearch.png)


<br />  

### 형태소 분석이란?
* 입력 받은 문자열에서 검색 가능한 정보 구조로 분석 및 분해 하는 과정
* Analyzer는 형태소 분석을 위한 최상위 클래스 이며, 하나의 Tokenizer와 다수의 Filter로 구성이 됩니다.
![img.png](../images/elastic-search/analyzer.png)  
* 아래 과정에서 6번의 Token Filter는 정의 된 순서에 맞춰 적용 되기 떄문에 적용 시 순서가 중요 하다.
* 루씬에서 제공 하고 있는 한글 처리를 위한 Analyzer는 CJK와 Nori Analyzer가 존재 한다.  
![img.png](../images/elastic-search/analyzeFlow.png)

