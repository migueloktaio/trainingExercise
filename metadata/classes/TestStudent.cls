@isTest
public class TestStudent {
	public static book_copy__c extraCopy;
    public static testMethod void testStudent() 
    {
        
      Test.startTest();
	  User runUser = CreateTestUser();	
      User testUser = CreateSearchUser();
      System.debug ('debug User created with name:'+ testUser.name);
      System.runAs(runUser) {
       Student student = new student(); 
       System.assertEquals(student.userView, Student.StudentEnum, 'Student constructed with the student View');
       
       student.searchText = 'no existe';
       student.doSearch();
	   System.debug('debug searchtext: '+ student.searchText);
       System.debug('debug results: '+ student.results);
       System.assertEquals(student.results.size(),0,'No users found');
       //System.assertEquals(student.results[0].name, student.searchText, 'Correctly found user:' + student.results[0].name + ' with id:' +student.results[0].id );
	  
       student.searchText = null;
       student.doSearch();
       System.assertEquals(student.results.size(),0,'Empty field for search text');
       
       Id [] fixedSearchResults= new Id[1];
       fixedSearchResults[0] = testUser.Id;
       Test.setFixedSearchResults(fixedSearchResults);
       
       student.searchText = 'hola';
       student.doSearch();
       System.assertEquals(student.results.size(),1,'User found');
          
	   student.returnSearch();
       System.assertEquals(student.userView, Student.StudentEnum, 'returnSearch working as expected');
	   
       student.studentId = testUser.Id;
       student.studentName = 'hola';
       
       CreateTestData(testUser.Id);
       student.getLoanedBooks();
       System.debug('debug Loans: '+ student.loans.size());
       System.assertEquals(student.loans.size(),3, 'Success searching for loaned books');
       
       student.loanedBookId = student.loans[0].id;
       student.returnBook();
       Loan__c loanStatus = [SELECT id, Status__c,Book_Copy__c from Loan__c where id=:student.loanedBookId];
       System.assertEquals(loanStatus.Status__c,'Returned','Book returned successfully');
       
       book_copy__c copyStatus = [SELECT id,name from book_copy__c where id=:loanStatus.Book_Copy__c];
       student.searchCopy = copyStatus.Name;
       System.debug('debug extracopy name:' + copyStatus.Name +' id: ' +copyStatus.id);
       student.doSearchCopy();
       copyStatus = [SELECT id, Availability__c from book_copy__c where id=:loanStatus.Book_Copy__c];
       System.assertEquals(copyStatus.Availability__c,'Not Available','Copy Book lended successfully');
       
       student.doSearchCopy();
       System.assertEquals(student.bookCopy.Availability__c,'Not Available','Copy already lended');
       
	   student.bookCopy = null;
       student.searchCopy ='no existe';
       student.doSearchCopy();
       System.assertEquals(student.bookCopy,null,'Non existant copy case testet successfully');
       
	   student.userView= Student.LoanEnum;
       student.updateView();
       System.assertEquals(student.userView, Student.LoanEnum, 'Tab constructed with the Loan View');
       
       student.userView= Student.CreatedEnum;
       student.updateView();
       System.assertEquals(student.userView, Student.CreatedEnum, 'Tab constructed with the Created View');
      
       student.createLoan();
	   System.assertEquals(student.userView, Student.CreatedEnum, 'Exception handled correctly');
          
       Test.stopTest();   
      }

			

      
        
    }
    public static User CreateTestUser () 
    {
      Profile pRunUser = [SELECT Id FROM Profile WHERE Name='Librarian'];
      UserRole rRunUser = [SELECT Id FROM UserRole WHERE Name='Librarian'];
      User runUser = new User(Alias = 'L1', Email='miguelc@oktana.io', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = pRunUser.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='miguelc+test@oktana.io');
	  runUser.UserRoleId = rRunUser.Id;
      
      return runUser;
    }
    
    public static User CreateSearchUser()
    {
          Profile pstudent = [SELECT Id FROM Profile WHERE Name='Student'];
          UserRole rstudent = [SELECT Id,Name FROM UserRole where Name ='Student' LIMIT 1];
      	  User uTest = new User(Alias = 'prueba', Email='miguelc+2@oktana.io', 
          EmailEncodingKey='UTF-8', LastName='hola', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = pstudent.Id, 
          TimeZoneSidKey='America/Los_Angeles', UserName='miguelc+test2@oktana.io');
          uTest.FirstName = 'hola';
          uTest.UserRoleId = rstudent.Id;
          insert uTest;
          return [select id,name,UserRoleId from User where id=:uTest.id];      
    } 
    
    public static void CreateTestData(string userId) 
    {
        Book__c book1 = new Book__c();
        book1.Title__c = 'book1';
        book1.Author__c= 'Author1';
        book1.ISBN__c=100;
        insert (book1);
        for (integer x=0; x<=10;x++)
        {
            Book_Copy__c copy = new Book_Copy__c();
            copy.Book__c = book1.id;
            copy.Availability__c = 'Available';
            insert(copy);
            
            Loan__c newLoan = new Loan__c(); 
            newLoan.Book__c = book1.id;
            newLoan.Book_Copy__c = copy.id;
            newLoan.student__c = userId;
            newLoan.Status__c = 'Loaned';
            newLoan.Loan_Date__c = date.today() - x;
            newLoan.Expected_Return_Day__c = date.today() +3-x ;
            newLoan.OwnerId = userid;
            insert(newLoan);
            x=x+4;
        }
    }
    
    
}