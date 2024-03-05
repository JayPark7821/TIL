## Escaping References

```java
public class CustomerRecords {
    private Map<String, Customer> records;
    
    public void addCustomer(Customer c) {
        this.records.put(c.getName(), c);
    }
    
    public Map<String, Customer> getCustomers() {
        return this.records;
    }
}
```
* In the above sample code has a problem with getCoustomers method  
  getCustomers method returns a reference to the records map,
  which means that the calling code now obtains a reference to the records map and it can do anything with it
  for example, we could write code that looks like below

```java
CustomerRecords records = new CustomerRecords();

Map<String, Customer> customerMap = records.getCustomers();

customerMap.clear();
```
* The getCustomers method returns a reference to the records map,
  which means that I can call clear method on the map and remove all the customers from the records map

* the reference to the records map has escaped from the class in which it should have been encapsulated  
  it's almost as though we've declared this map as a public variable, have violated the principle of encapsulation