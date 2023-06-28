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
![img.png](elastic-search/indexingFlow.png)  

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
![img.png](elastic-search/indexSearch.png)


<br />  

### 형태소 분석이란?
* 입력 받은 문자열에서 검색 가능한 정보 구조로 분석 및 분해 하는 과정
* Analyzer는 형태소 분석을 위한 최상위 클래스 이며, 하나의 Tokenizer와 다수의 Filter로 구성이 됩니다.
![img.png](elastic-search/analyzer.png)  
* 아래 과정에서 6번의 Token Filter는 정의 된 순서에 맞춰 적용 되기 떄문에 적용 시 순서가 중요 하다.
* 루씬에서 제공 하고 있는 한글 처리를 위한 Analyzer는 CJK와 Nori Analyzer가 존재 한다.  
![img.png](elastic-search/analyzeFlow.png)



<br />  

### ElastciSearch와 RDBMS 비교  

|         DBMS         |      ElasticSearch       |
|:--------------------:|:------------------------:|
| DBMS HA 구성(MMM,M/S)  |         Cluster          |
|    DBMS Instance     |           Node           |
|        Table         |          Index           |
|      Partition       |     shard / Routing      |
|         Row          |         Document         |
|        Column        |          Field           |
| Row of Columnar data | Serialized JSON document |   

### 주요 Setting
* path Setting - 인덱스 데이터와 로그 데이터에 대한 저장소 설정
  * path.data: 데이터 저장 경로 array로 설정가능
  * path.logs: 로그 저장 경로
* cluster.name
* node.name
* network.host
* discovery setting 
  * discovery.seed_hosts : 클러스터링 해야하는 노드 리스트 등록 
  * cluster.initial_master_nodes : 클러스터링 초기 마스터 노드 설정
* jvm.options.setting 
  * Heap Size 설정
    * System 리소스의 50%로 설정
    * 31GB가 넘어가지 않도록 구성
    * 설정은 환경변수로 set하거나 jvm.options 파일에 설정 (ES_JAVA_OPTS)
 

### Analysis
* 구조화 되지 않은 텍스트를 검색에 최적화 된 구조의 형식으로 변환 하는 과정

### Text Analysis
* full text검색을 수행 하게 되며, Exact matching이 아니기 때문에 관련된 모든 결과를 반환  
* full text 검색 수행을 위한 분석 과정
  * Tokenization - 텍스트를 토큰이라는 작은 단위로 분할 하는 것 -> 분할 된 토큰은 개별 단어를 의미
  * Normalization - 문자에 대한 변형과 필터를 적용 하는 것(토큰을 표준향식으로 정규화) - 대소문자 적용 / 동의어 처리 / 불용어 제거 등의 작업

### Analyzer
* text를 검색엔진에서 검색 가능한 구조화 된 형식으로 만들어 주는 것
* Analyzer의 구성항목
  * Character Filter 
    * 원본 텍스트에서 불필요한 문자들을 제거 / 추가 / 변경등  
      * 원본 텍스트를 변형해서 Tokenizer로 전달 하여 token 추출되도록 함.
  * Tokenizer - 텍스트를 토큰으로 분할 하는 작업
    * 문자 스트림을 수신 해서 개별 토큰으로 나누고 나눠진 토큰 스트림을 출력
    * 나눠진 토큰의 순서, position, 단어의 시작과 끝의 문자 offset정보를 기록 ( 기록된 정보는 term vector정보로 사용)
  * Token Filter 
    * Tokenizer에서 넘겨 준 토큰 스트림을 받아서 토큰을 제거 / 추가 / 변경
    * 토큰을 소문자로 변환, 불용어 제거, 동의어 추가 등의 작업 수행.
    * `선언 된 순서대로 적용 되며`, 0개 이상 사용가능

### _analyze API 구조
* sample 
```json
GET /_analyze
{
  "analyzer": "standard",
  "text": "2 guys walk into a bar"
}
```

### _analyze API Parameters
* analyzer - 사용할 analyzer 지정
* char_filter - tokenizer로 전달 하기 이전에 입력 된 text를 전처리 하기 위한 filter를 설정(array)
* explain - 기본 false이며, 분석 결과에 대한 상세 정보를 포함하도록 함.
* field - field에 정의 된 analyzer를 사용해서 분석하도록 함.
* filter - tokenizer이 후에 사용할 filter 설정 (array)
* normalizer - analyzer와 유사 하지만, 단일 토큰으로 분석 결과를 만들어 낸다는 차이점이 있음  
 tokenizer를 사용 하지 않음  
 모든 filter적용이 가능 한 것이 아닌 문자 단위로 동작하는 필터만 사용 가능
* text - 형태소 분석할 대상 text (array or string)
* tokenizer - text를 토큰으로 분할 하는 작업을 수행 할 tokenizer 설정

### Mappings
* 문서와 필드를 정의하고 색인 및 저장 하는 방법을 정의
* 필드의 집합이 문서가 되며 각 필드는 Data Type을 가짐
* Matadata fields - 문서를 구성하는 메타정보 필드
* Fields - 필드의 목록과 속성을 가짐

### Runtime fields
* 질의 시점에 평가/계산 되어 결과로 전달됨.
  * 데이터를 다시 색인하지 않고 기존 문서에 필드를 추가.
  * 데이터의 구조를 이해하지 않고 데이터 작업 시작
  * 질의시 인덱싱 된 필드에서 반환된 값을 재정의
  * 기본 스키마를 수정 하지 않고 특정 용도로 필드 정의
  * Runtime field를 대상으로 search, aggregation, filtering, sorting과 같은 기능 즉시 사용

### Field 
### Common Types
* binary - base64로 인코딩 된 바이너리 데이터 저장 허용, 검색 불가능
* boolean - Json true, false값 / 문자열 "true", "false"값 허용 ""(empty String) -> false
* keywords - 주로 sorting, aggregations, term-level queries에 사용  
 term과 term-level query에 사용할 때 설정  
 numeric 데이터 속성 중 range query계획이 없는 경우, keyword로 설정하는 것 추천  
 case sensitive -> normalizer를 통해 upper case filter나 lower case filter를 활용해 대소문자 구분 없이 검색 가능하도록 하는 것 추천
* numbers - numberic data라고 해서 numberic field data type으로 선언할 필요는 없다.   
 range query유형의 질의를 사용하지 않는 경우 keyword field로 선언하는 것이 더 효과적이다.  
 이와 같은 사용이 확실하지 않으면, multi-field기능을 이용해서 keyword와 numeric 선언을 하면 된다.



### Document Modeling
* 문서 모델링은 Elasticsearch에서 아래 구성 요소들과 연관이 있다.
  * indexing searching 
  * analysis
  * settings, mappings
* 결국 우리가 검색 하고자 하는 대상이 어떤 정보와 속성을 가지고 있고 검색을 어떻게 할 것인지를 결정을 해야 한다. 
* -> 이런 과정을 정의 하고 나서야 모델링을 시작 할 수 있다. 
* 검색엔진에서 사용하는 자료구조는 immutable형이다. 한번 색인된 문서는 변경이 되지 않는다.
* 또한 inverted index file구조를 갖기 때문에 문서 중심이 아닌 색인어 중심으로 탐색을 수행
* 검색에서 색인해야 하는 대상 문서들의 집을 flat file이라고 하고 이 파일을 이용해서 실제 색인을 수행 하게 됨
* flat file은 말 그대로 구조적으로 상호관계를 가지지 않는 문서의 레코드 단위로 기록된 파일

#### Indexing
* 보통 색인 작업은 두 가지로 나뉜다.
* 1. Full Indexing
  * 전체 데이터에 대해서 색인.
  * 이 과정이 필요한 이유는 변경된 정보를 반영 하면서 데이터에 대한 동기화가 깨질 수도 있고 불필요한 정보가 남아 있을 수도 있기 때문에 한 번씩 전체 색인을 통해 Clean한 데이터를 만들어 준다.
  * 다만, 전체 색인 해야 하는 대상 데이터가 클 경우 작업에 대한 비용이 많이 들 수 있기 때문에 초기 Index/Shard전략을 잘 수립하고 진행 해야함.
* 2. Incremental Indexing
  * 이 작업은 색인된 데이터에 변경이 발생 했을 경우 즉, 추가/수정/삭제 된 데이터를 색인에 반영.
  * 반영하기 위한 데이터는 특정 크기나 주기로 나눠서 색인 하도록 기능을 구현.
  
#### Searching
* 사용자가 입력한 검색어를 기반으로 정확한 의도를 파악하고 결과를 찾아 주거나 발견 할 수 있도록 도와주는 역할을 함.
* Query Term, Match Range, Compound Query 그리고 Script, Funcion Score등이 많이 사용됨.
* 검색은 이미 색인된 정보를 기반으로 사용자가 입력한 검색어를 매칭하는 과정.
* 이 매칭 하는 과정에서 term query와 같은 exact matching을 하는 것과 
* match query와 같은 입력 검색어를 한번 더 분석해서 분석된 token을 가지고 matching을 하는 방식이 있다.
* 이 두가지 유형을 가장 많이 사용하며, 
* 사용자가 입력한 검색어와 정확히 일치하는 문서를 찾기 위해서는 term query를 사용하고
* 입력한 쿼리와 비슷한 문서를 찾기 위해서는 match query를 사용한다.
* 이외 range query, script query, query string등 다양한 Query api가 있으나. 대부분 term query로 query rewrite되어 처리된다.
* 검색은 특정 필드에 대한 매칭을 하는 방식과 
* 검색 대상이 되는 모든 field의 value를 한꺼번에 매칭 하는 통합 검색 필드 대상의 검색이 있을 수 있다. 
* 보통은 통합 검색 필드 운영을 하고 이외 field는 filter항목 또는 정렬 항목으로 활용

#### Analysis
* 색인과 검색에 필요한 Text분석 설정
* Text에 대한 형태소 분석 과정을 거치는 크게 Tokenization과 Normalization두 가지가 있다.
* Elasticsearch에서는 text유형에 analyzer 설정을 통해 tokenization을 수행하고 
* keyword유형에 normalization을 수행한다.
* 형태소분석은 언어와 목적에 맞는 분석기를 선택하거나 구현해서 적용.
* 일반적으로 많이 사용하는 한글 분석기는 arirang, nori, mecab등이 있으며 
* 적용 하는 tokenizer와 filter에 따라 분석되는 최종 token결과가 달라 질 수 있다.
* 이런 analyzer는 색인 시점과 검색 시점에 각각 적용이 가능 하고 각 field별로도 적용이 가능함
* 분석에 대한 일관성을 유지하고 매칭에 대한 의미를 동일하게 해석 하기 위해서는 색인시 사용한 분석기와 검색에 사용하는 분석기가 같아야함.
* 대부분 한글 분석기는 사전기반의 분석기로 사전 관리에 대한 중요도가 매우 높다.
* 동의어 처리 역시 검색 결과에 영향을 많이 주는 요소로 초기 구성과 관리가 매우 중요.
* 너무 많은 항목을 모두 형태소 분석하게 되면 불필요한 저장 공간의 낭비가 발생 할 수 있으며, 색인 성능도 나빠질 수 있다.
  * 1. 정확한 Keyword matching을 위해서 -> type은 keyword로 설정하고 normalizer를 이용해서 token filter를 적용
  * 2. 어떤 종류의 데이터 유형이던 검색, 분석, 정렬 등과 같은 연산 적업이 필요 없고 단순 화면에 정보를 제공하는 용도라면 index:false설정을 적용.
  * 3. numeric유형을 가지는 field중 range query를 사용하지 않고 정렬에도 사용을 안한다면 keyword로 선언하는게 유리
  * 4. range query를 사용하는 field값에 대한 범위 지정이 가능한 경우 range field유형으로 선언 하는게 유리.

#### Mapping
* 검색, 결과 내 검색, 필터, 정렬, 집계
* full text검색을 요구 하는 경우 검색 대상 field의 data type을 text로 선언
* 입력한 검색어와 정확히 일치 하는 검색을 요구 하는 경우 검색 대상 field의 data type을 keyword로 선언
* 범위 검색과 정렬을 요구 하는 경우 대상 field의 data type을 numeric,data 등으로 선언
* 데이터에 대한 1:N의 관계를 요구 하는 경우 object, nested, join(parent/child), flattened field type, collapse등을 검토 합ㄴ디ㅏ.
* 특정 값에 대한 필터와 집계 기능을 요구 하는 경우 field의 data type을 keyword 또는 numeric으로 선언
* 검색 대상으로만 사용을 하고 value에 대한 활용이 없다면 _source에서 제거
* 문서에 대한 정적 랭킹을 적용하고자 한다면 rank field를 생성하고 numeric으로 선언 합니다.
* 랭킹에 대한 가중치 부여는 field boosting 기법과 rank feature를 활용한 function/script score api를 활용
* dynamic mapping을 사용하기 보다 명시적 mapping설정을 하는게 좋다.
* 하나의 field value를 목적에 맞춰 설정을 다르게 해야 할 경우 fields를 활용
* 통합 검색 field와 같은 기능을 구현 하고자 한다면 copy_to를 이용해서 분석 대상 value를 추가해 준다.
* 문서를 구성할 때 검색 결과 리스팅, 카테고리 리스팅, 상세와 같은 경우 용도와 목적에 맞게 분리 구성 하는게 좋다.

### Auto Completion
* 1. 데이터 분석을 통해 field를 정의하고 검색 대상에 대한 분석 진행.
* 2. mapping 구성
* 3. setting 구성을 통해 형태소 분석에 필요한 설정 진행

#### 서울 지하철 검색 prac
1. 데이터 분석을 통해 field 정의 및 검색 대상에 대한 분석 진행
* 전철역코드, 전철역명, 호선, 외부코드 로 데이터는 이루어져 있음.
* 전철역 코드 - code - id
* 전철역명 - station - 검색
* 전철역명 초성 - chosung - 검생
* 전철역명 자모 - jamo - 검색
* 전철역명 영어 - engtokor - 검색
* 호선 - line - 검색/필터/집계
* 외부코드 - excode

---

<br />  


2. mapping 구성
```json
"id" : {
    "type":"keyword",
    "index":false
    }
```


```json
"station" : {  // 역명 검색 대상
    "type":"text", // full text search 하기 위한 type text
    "analyzer":"analyzer-subway",
    "fields":{ // fields로 멀티필드 선언
        "exact":{
          "type":"keyword", // exact match을 위해 keyword로 선언
          "normalizer":"normalizer-subway"
        },
        "front":{
            "type":"text",
            "analyzer":"edge-front-subway"
            },
        "back":{
            "type":"text",
            "analyzer":"edge-back-subway"
          },
        "partial":{
            "type":"text",
            "analyzer":"ngram-subway"
          },
        }
    }
}
```

```json
"chosung": {
  "type": "text",
  "analyzer": "edge-front-subway",
  "fields" : {
    "exact": {
      "type": "keyword",
      "normalizer": "normalizer-subway"
    },          
    "back": {
      "type": "text",
      "analyzer": "edge-back-subway"
    },
    "partial": {
      "type": "text",
      "analyzer": "ngram-subway"
    }
  }
}
```

```json
"jamo": {
  "type": "text",
  "analyzer": "edge-front-subway",
  "fields" : {
    "exact": {
      "type": "keyword",
      "normalizer": "normalizer-subway"
    },          
    "back": {
      "type": "text",
      "analyzer": "edge-back-subway"
    },
    "partial": {
      "type": "text",
      "analyzer": "ngram-subway"
    }
  }
}
```

```json 
"engtokor": {
  "type": "text",
  "analyzer": "edge-front-subway",
  "fields" : {
    "exact": {
      "type": "keyword",
      "normalizer": "normalizer-subway"
    },          
    "back": {
      "type": "text",
      "analyzer": "edge-back-subway"
    },
    "partial": {
      "type": "text",
      "analyzer": "ngram-subway"
    }
  }
}
```
#### 초성, 자모, 한글 영어 검색은 화면에 보여주지 않고 검색 matching에만 사용하기 때문에 _source에서 제거
```json
    "_source": {
      "excludes": [
        "chosung",
        "jamo",
        "engtokor"
      ]
    }
```   

---

<br />  

3. setting 구성을 통해 형태소 분석에 필요한 설정 진행
```json
"index": {
  "number_of_shards": 1,
  "number_of_replicas": 0,
  "max_ngram_diff": 30   // min_gram 과 max_gram의 차이를 더 크게 할 수 있다. 지정하지 않으면 아래 ngram세팅을 변경해도 적용되지 않는다.
}
```
```json
"analysis": {
      "analyzer": {
        "analyzer-subway": {
          "type": "custom",
          "tokenizer": "arirang_tokenizer"
        },        
        "ngram-subway": {
          "type": "custom",
          "tokenizer": "partial",
          "filter": [
            "lowercase"
          ]
        },
        "edge-front-subway": {
          "type": "custom",
          "tokenizer": "edgefront",
          "filter": [
            "lowercase"
          ]
        },
        "edge-back-subway": {
          "type": "custom",
          "tokenizer": "edgeback",
          "filter": [
            "lowercase"
          ]
        }
      }
}
```
```json
  "tokenizer": {
        "partial": {
          "type": "ngram",
          "min_gram": 1,
          "max_gram": 30,
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "edgefront": {
          "type": "edge_ngram",
          "min_gram": 1,
          "max_gram": 30,
          "token_chars": [
            "letter",
            "digit"
          ]
        },
        "edgeback": {
          "type": "edge_ngram",
          "min_gram": 1,
          "max_gram": 30,
          "size": "back",
          "token_chars": [
            "letter",
            "digit"
          ]
        }
      }
```
```json
"normalizer": {
        "normalizer-subway": {
          "type": "custom",
          "filter": [
            "lowercase"
          ]
        }
      }
```