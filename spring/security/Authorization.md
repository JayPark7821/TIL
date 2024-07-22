## Spring Security

### Authorization Architecture
#### Authorities
* Authentication discusses how all Authentication implementations store a list of GrantedAuthority objects.
* The GrantedAuthority interface has only one method
```java
String getAuthority();
```

* This method is used by an AuthorizationManager instance to obtain a precise String representation of the GrantedAuthority.
* By returning a representation as a String, a GrantedAuthority can be easily "read" by most AuthorizationManager implementations.
* If a GrantedAuthority cannot be precisely represented as a String, the GrantedAuthority is considered "complex" and getAuthority() must return null.

<br/>

* Spring Security includes one concrete GrantedAuthority implementation: SimpleGrantedAuthority
* This implementation lets any user-specified String be converted into a GrantedAuthority.
* All AuthenticationProvider instances included with the security architecture use SimpleGrantedAuthority to populate the Authentication object.

<br/>

* By default, role-based authorization rules include ROLE_ as a prefix.
* This means that if there is an authorization rule that requires a security context to have a role of "USER", Spring Security will by default look for a GrantedAuthority#getAuthority that returns "ROLE_USER".


#### Invocation Handling
* A pre, & post invocation decision on whether the invocation is allowed to proceed is made by AuthorizationManager instances.

#### AuthorizationManager
* AuthorizationManagers are called by Spring Security’s request-based, method-based, and message-based authorization components and are responsible for making final access control decisions. 