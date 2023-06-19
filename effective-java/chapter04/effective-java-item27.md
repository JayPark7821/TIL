# Effective-java
## 제네릭
* 제네릭의 장점을 살리고 단점을 최소화하는 방법  
   
### 아이템 27. 비검사 경고를 제거하라.

### 핵심정리
* 비검사 (unchecked) 경고란?
  * 컴파일러가 타입 안정성을 확인하는데 필요한 정보가 충붆치 않을 떄 발생시키는 경고.
* 할 수 있는 한 모든 비검사 경고를 제거하라.
* 경고를 제거할 수 없지만 안전하다고 확신한다면  
 @SuppressWarning("unchecked") 애노테이션을 달아 경고를 숨기자.
* @SuppressWarning("unchecked") 애노테이션은 항상 가능한 한 좁은 범위에 적용하자.
* @SuppressWarning("unchecked") 애노테이션을 사용할 때면 그 경고를 무시해도 안전한 이유를 항상 주석으로 남겨야 한다.

* 비검사 경고  
  ![image](https://github.com/JayPark7821/effective-java/assets/60100532/9b8669c4-8ed2-4002-97cb-0b068b5ff117)
```java
public class SetExample {
	public static void main(String[] args) {
		Set names = new HashSet();
		Set<String> strings = new HashSet<>(); // java 6 부터 <> 다이아몬드 연산자 사용 가능
	}
}
```

* @SuppressWarnings("unchecked") example  (ArrayList.java)

* ![image](https://github.com/JayPark7821/effective-java/assets/60100532/8eafbcdf-af62-43a4-ba8b-3b8099183624)


### 개념 정리 
* Annotation
* java Annotation을 정의하는 방법
* @Retention : 어노테이션의 정보를 얼마나 오래 유지할 것인가.
  * Runtime, Source, Class
* @Target : 어노테이션을 사용할 수 있는 위치 지정.
  * Type, Field, Method, Parameter, ...
  
* Retention Policy
  * Source : 컴파일러가 컴파일할 때만 유지. 컴파일 이후에는 사라짐.
  * Class : 컴파일한 후에도 JVM에 의해 계속 참조가능. 단, 리플렉션을 이용해서 어노테이션 정보를 얻을 수 없음 (바이트코드에서 참조 가능).
  * Runtime : 컴파일한 후에도 JVM에 의해 계속 참조가능. 리플렉션을 이용해서 어노테이션 정보를 얻을 수 있음.