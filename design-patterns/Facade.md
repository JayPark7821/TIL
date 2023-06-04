# Design-patterns
## 구조적인 패턴(Structural Patterns)

---
### 퍼사드 (Facade) 패턴
* 복잡한 서브 시스템 의존성을 최소화하는 방법
* 클라이언트가 사용해야  하는 복잡한 서브 시스템 의존성을 간단한 인터페이스로 추상화 할 수 있다.

![image](https://user-images.githubusercontent.com/60100532/193944132-ac3299c0-e61f-4cb5-9795-095f143239d4.png)


### 다음 코드를 보자

```java
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class Client {

    public static void main(String[] args) {
        String to = "keesun@whiteship.me";
        String from = "whiteship@whiteship.me";
        String host = "127.0.0.1";

        Properties properties = System.getProperties();
        properties.setProperty("mail.smtp.host", host);

        Session session = Session.getDefaultInstance(properties);

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
            message.setSubject("Test Mail from Java Program");
            message.setText("message");

            Transport.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}
```
위 코드를 보면 메일과 관련된 많은 라이브러리들을 의존하고 있다. tightly coupled
그결과로 해당 코드를 변경하기가 매우 어려워지고, 변경되어야할 이유도 많아지고, 코드를 테스트 하기도 어렵다.
가급적이면 유연하게 Loosely coupled 상태로 변경해볼 필요가 있다. 
  
이제 Facade 패턴을 이용해서 위 코드를 변경해 보자.

```java

public class EmailSender {

    private EmailSettings emailSettings;

    public EmailSender(EmailSettings emailSettings) {
        this.emailSettings = emailSettings;
    }

    /**
     * 이메일 보내는 메소드
     * @param emailMessage
     */
    public void sendEmail(EmailMessage emailMessage) {
        Properties properties = System.getProperties();
        properties.setProperty("mail.smtp.host", emailSettings.getHost());

        Session session = Session.getDefaultInstance(properties);

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(emailMessage.getFrom()));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(emailMessage.getTo()));
            message.addRecipient(Message.RecipientType.CC, new InternetAddress(emailMessage.getCc()));
            message.setSubject(emailMessage.getSubject());
            message.setText(emailMessage.getText());

            Transport.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}
```

```java

public class EmailSettings {

    private String host;

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }
}

```

```java

public class EmailMessage {

    private String from;

    private String to;
    private String cc;
    private String bcc;

    private String subject;

    private String text;

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getCc() {
        return cc;
    }

    public void setCc(String cc) {
        this.cc = cc;
    }

    public String getBcc() {
        return bcc;
    }

    public void setBcc(String bcc) {
        this.bcc = bcc;
    }
}

```

```java
public class Client {

    public static void main(String[] args) {
        EmailSettings emailSettings = new EmailSettings();
        emailSettings.setHost("127.0.0.1");

        EmailSender emailSender = new EmailSender(emailSettings);

        EmailMessage emailMessage = new EmailMessage();
        emailMessage.setFrom("keesun");
        emailMessage.setTo("whiteship");
        emailMessage.setCc("일남");
        emailMessage.setSubject("오징어게임");
        emailMessage.setText("밖은 더 지옥이더라고..");

        emailSender.sendEmail(emailMessage);
    }
}
```



___
___

<br/> 

<br/> 

### 퍼사드 (Facade) 패턴 장단점
* 장점
    * 서브 시스템에 대한 의존성을 한곳으로 모을 수 있다. 

* 단점
    * 퍼사드 클래스가 서브 시스템에 대한 모든 의존성을 가지게 된다.

모든 서브시스템에 대한 의존성을 퍼사드가 가지고 있지만.  
클라이언트 코드의 코드 가독성이 좋아진다면 의미 있다고 생각할 수 있다. 

퍼사드 적용전에는 클라이언트 코드에서 라이브러리 코드에 대하여 자세히 알고 있어야 했지만.  
퍼사드에서 구현해 추상화 해놓는다면 코드를 사용하는 클라이언트 입장에서 사용하기 쉽게 만들 수 있다. 


___
___

<br/> 

<br/> 

### 퍼사드 (Facade) 패턴  
실무에서 어떻게 쓰이나?

* 스프링
    * Spring MVC
    * 스프링이 제공하는 대부분의 기술 독립적인 인터페이스와 그 구현체


```java
        MailSender mailSender = new JavaMailSenderImpl();

        PlatformTransactionManager platformTransactionManager = new JdbcTransactionManager();
```  
