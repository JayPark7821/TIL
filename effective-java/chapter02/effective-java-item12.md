# Effective-java
## 모든 객체의 공통 메서드
* Object가 제공하는 메서드를 언제 어떻게 재정의해야 하는가

### 아이템 12. toString을 항상 재정의하라

### 핵심정리
* toString은 간결하면서 살마이 읽기 쉬운 형태의 유익한 정보를 반환해야 한다.
* Object의 toString은 클래스이름@16진수로 표시한 해시 코드
* 객체가 가진 모든 정보를 보여주는 것이 좋다.
* 값 클래스라면 포맷을 문서에 명시하는 것이 좋으며   
해당 포맷으로 객체를 생성할 수 있는 정적 팩터리나 생성자를 제공하는 것이 좋다.
* toString이 반환한 값에 포함된 정볼르 얻어올 수 있는 API를 제공하는 것이 좋다. 
* 경우에 따라 AutoValue, lombok 또는 IDE를 사용하지 않는게 적절할 수 있다. 

#Sample Code
* Object의 toString을 재정의하지 않은 경우
```java
  public static void main(String[] args) {
        PhoneNumber jenny = new PhoneNumber(707, 867, 5309);
        System.out.println("제니의 번호: " + jenny);
    }

```
![image](https://user-images.githubusercontent.com/60100532/210140828-74abab30-d443-4fa5-a8e3-3c5a006f6ecf.png)


```java
  /**
     * 이 전화번호의 문자열 표현을 반환한다.
     * 이 문자열은 "XXX-YYY-ZZZZ" 형태의 12글자로 구성된다.
     * XXX는 지역 코드, YYY는 프리픽스, ZZZZ는 가입자 번호다.
     * 각각의 대문자는 10진수 숫자 하나를 나타낸다.
     *
     * 전화번호의 각 부분의 값이 너무 작아서 자릿수를 채울 수 없다면,
     * 앞에서부터 0으로 채워나간다. 예컨대 가입자 번호가 123이라면
     * 전화번호의 마지막 네 문자는 "0123"이 된다.
     */
    @Override public String toString() {
        return String.format("%03d-%03d-%04d",
                areaCode, prefix, lineNum);
    }
```