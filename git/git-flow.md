# Git Flow 전략
* Git을 사용하여 개발하는 환경에서 Branch간의 문제 없이 배포까지 안정적으로 할 수 있도록 `Branch를 관리하는 전략`

___
## 1. 주요 Branch
* Main(Master)
* Dev
* Feature
* Release
* Hotfix

### 1-1 Main(Master) Branch
* `BiocoreDx 운영(prod)환경에 배포될 Branch`
* 언제든지 배포 가능한 형태를 유지 해야함!!

### 1-2 Dev Branch
* Main(Master) Branch로 생성한 브랜치
* 다음 배포에 나갈 feature들을 merge

### 1-3 Feature Branch
* 기능 단위 개발 브랜치
* Feature Branch에 개발 & Commit 완료 후 Dev Branch 로 merge
* Branch 명을 결함관리대장 ID 또는 요구사항정의서의 요구사항 ID등 으로 명명

### 1-4 Release Branch
* `BiocoreDx 테스트 환경에 배포될 Branch`
* Dev Branch 기준으로 Release Branch 생성
* 다음 배포에 나갈 코드들의 snapshot 개념
* Release Branch가 생성된 이후에는 개발된 feature들은 Release Branch에 merge
* 테스트 완료후 Main(Master) Branch로 merge

### 1-5 Hotfix
* 운영중 긴급한 오류를 해결하기 위한 브랜치
* Main(Master)브랜치에서 바로 Hotfix Branch 생성
* 당장 수정해야하는 최소한의 부분만 수정후 commit Main(Master) Branch에 merge  
  <br />

<br />    

<br />  

<br />  


<br />  

___  

<br />  

## 2. 정기배포를 위한 Git Flow 전략 Sample
- 요구 사항
1. 공통 모듈의 메인화면 Tab 기능 개발
2. Select Box 내부 필터 기능 개발

![image](https://user-images.githubusercontent.com/60100532/199138501-7edf7497-4017-4642-8c71-3d9006bfce8c.png)  
<br />

**1. 다음과 같은 구조로 Branch를 생성 후 Feature 개발 진행. (Master -> Dev -> Feature Branch 생성)**
![image](https://user-images.githubusercontent.com/60100532/199145193-bd5b984e-13a3-474b-bf40-fbd90336613c.png)
* Master Branch를 기준으로 Dev Branch 생성
* Dev Branch 기준으로 각 Feature Branch 생성   
  <br />

**2. 개발 완료 -> feature Branch commit**  
![image](https://user-images.githubusercontent.com/60100532/199145715-f0eb66e0-0a86-40f9-8aff-3580fb9ebede.png)  
<br />

**3. feature branch -> Dev Branch Merge.**  
![image](https://user-images.githubusercontent.com/60100532/199146179-8e5ce47e-4086-4fa6-bffe-4699d063c1f0.png)  
<br />

**4. Dev Branch를 기준으로 배포를 위한 Release Branch 생성**  
![image](https://user-images.githubusercontent.com/60100532/199146377-83cb45ee-ef6b-45f7-bf0e-25a7f0f0c330.png)  
<br />

___  
<br />  

## 3. 시나리오별 가이드
## 3-1. Release Branch 생성 후 추가 작업이 필요해질 경우
**5. 기존 feature ( 메인화면 Tab, Select Box 내부 필터) 외**   
**리포트 preview 없이 바로 다운로드 기능 개발 추가 요구사항 발생.**
![image](https://user-images.githubusercontent.com/60100532/199139662-1ca7f4fc-8fe3-4ad2-936f-99ba3f751ccb.png)  
<br />


**6. Release Branch 생성 이후부턴 Dev Branch 기준이 아닌 Release Branch를 base로 Feature Branch 생성**  
![image](https://user-images.githubusercontent.com/60100532/199146916-92976b01-998d-4638-b63c-635666dfe7af.png)  
<br />

**7. 개발 완료후 Release Base로 생성한 Branch에 commit**  
![image](https://user-images.githubusercontent.com/60100532/199147241-935d4692-6a26-410e-b0e1-3b2599eba5a3.png)  
<br />

**8. Dev Branch가 아닌 Release Branch에 merge.**  
![image](https://user-images.githubusercontent.com/60100532/199154118-880aff34-0e1b-42d9-b757-7e1e021d8cc8.png)  
<br />

**9. Release Branch -> 테스트 환경 배포 & 테스트**    
<br />    
<br />

**10. Release Branch -> Master(Main) Branch**  
![image](https://user-images.githubusercontent.com/60100532/199154292-bf4ac81a-29af-4a2c-b3ba-28b9128e923e.png)  
<br />

**11. Master(Main) Branch -> 운영 환경 배포**  
![image](https://user-images.githubusercontent.com/60100532/199154563-7600a0c5-d47a-4442-a01a-05dfc5f96d8b.png)  
<br />

**12. Master(Main)에 추가된 작업 내용 -> Dev Branch에 merge (Dev와 Master Sync)**  
![image](https://user-images.githubusercontent.com/60100532/199154784-1df7cacb-2cbd-4bb0-8432-7589edc5c122.png)
* Dev Branch는 Master를 Base로 생성된 Branch. ( 즉 `Dev = Master + @`의 코드를 가지고 있어야함)
* 만약 Sync가 맞지 않을 경우엔 `Dev != Master + @` 가 된다.
* 이러한 상태로 누군가 Dev에서 신규 Branch를 생성하게 된다면 코드가 꼬이게 됨.
  <br />
___  
<br />  

## 3-2. Release Branch 생성 후 추가 작업이 없는 경우
**5. Release Branch -> 테스트 환경 배포 & 테스트**  
<br />   
<br />

**7. Release Branch -> Master(Main) Branch에 Merge -> 운영환경에 배포**  
![image](https://user-images.githubusercontent.com/60100532/199156456-16baef11-66e0-4ba5-9959-8bf12994cc48.png)  
<br />

**6. Master(Main) 작업 내용 -> Dev Branch에 merge (Dev와 Master Sync)**   
![image](https://user-images.githubusercontent.com/60100532/199156596-7dcb273d-ae3e-4ad6-be1b-9e6f0da83124.png)  
<br />
___    
<br />  

## 3-3. Hotfix가 필요한 경우
**3. 다음과 같은 branch 상황에서 운영에서 장애 발생 (Hotfix로 장애(이슈) 수정하여 배포가 나가야함.)**  
![image](https://user-images.githubusercontent.com/60100532/199157305-10c1f65b-9461-45ba-b418-14de30294948.png)  
<br />

**4. Master(Main) Branch를 기준으로 Hotfix Branch 생성 & 개발 & 커밋**  
![image](https://user-images.githubusercontent.com/60100532/199157524-d5ff461c-72b4-4086-bb9c-db92e4ff3322.png)  
<br />

**5. Hotfix Branch -> Master(Main) Branch merge**  
![image](https://user-images.githubusercontent.com/60100532/199157646-4324a871-07a3-4958-8e6d-0cb5abd8ef6a.png)  
<br />

**6. Master(Main) 운영환경 배포**  
![image](https://user-images.githubusercontent.com/60100532/199157828-ff3404b4-3392-428a-b9af-0372d82f406a.png)  
<br />

**7. Master(Main) -> Dev Branch에 merge (Dev와 Master Sync)**    
![image](https://user-images.githubusercontent.com/60100532/199158060-0b5c7148-b808-49e9-9af2-4394f7882bbe.png)  
<br />

**8. 개발자들에게 Dev 브랜치가 merge 되었음을 알리고 Dev Branch를 pull 받거나 본인 local Branch에 merge 후 작업하라 전달**    
![image](https://user-images.githubusercontent.com/60100532/199158558-eeb063d4-c717-4884-a753-9dbc7b137061.png)  
<br />

**9. 이후 작업은 Dev Branch를 Base로 새로운 Feature Branch 생성후 작업**  
<br />

___

> #### 위의 모든 시나리오에서 Master Branch를 배포한 후에는 Master Branch -> Dev Branch에 Merge
> #### Master Branch가 Dev Branch에 merge된 이후엔 반드시 Dev Branch를 pull 받거나 local Branch에 merge한 후 작업 해야 함!