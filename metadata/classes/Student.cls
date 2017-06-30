public class Student {

    public enum ViewState {STUDENT, OVERDUE, LOANS, CREATED}
    public ViewState StudentEnum = ViewState.STUDENT;
    public ViewState OverdueEnum = ViewState.OVERDUE;
    public ViewState LoanEnum = ViewState.LOANS;
    public ViewState CreatedEnum = ViewState.CREATED;
    public ViewState userView {get; set;}
    public boolean showStudent {get; set;}
    public boolean showLoan {get; set;}
    public boolean showBookLoan {get; set;}
    public boolean showMessageTop {get; set;}
    public boolean showMessageMiddle {get; set;}
    public boolean showMessageBottom {get; set;}
	public String searchText { get; set; }
    public String searchCopy {get; set;}
    public String studentId { get;
                             set {
                                 studentId = value;
                             }}
    public String studentName { get;
                             set {
                                 studentName = value;
                             }}
    public String loanedBookId {
        					 get;
                             set {
                                 loanedBookId = value;
                             }
    }
    public userRole uStudent=[SELECT Id,Name FROM UserRole where Name ='Student'];
	public List<User> results { get; set;}
    public List<Loan__c> loans {get; set;}
	public Book_Copy__c bookCopy; 
    
    public Student ()
    {
        userView = ViewState.STUDENT;
        updateView();
    }
    
    public void updateView() {
        
        if (userView == ViewState.STUDENT)
        {
                showStudent = true;
        		showLoan = false;
            	showBookLoan = false;
            	showMessageTop = true;
				showMessageMiddle = false;
				showMessageBottom = false;

        }
        
        if (userView == ViewState.OVERDUE)
        {
                showStudent = false;
        		showLoan = true;
            	showBookLoan = false;
                showMessageTop = false;
				showMessageMiddle = true;
				showMessageBottom = false;
        }
        
        if (userView == ViewState.LOANS)
        {
                showStudent = false;
        		showLoan = true;
            	showBookLoan = true;
                showMessageTop = false;
				showMessageMiddle = true;
				showMessageBottom = false;
        }
        
        if (userView == ViewState.CREATED)
        {
                showStudent = false;
        		showLoan = true;
            	showBookLoan = true;
                showMessageTop = false;
				showMessageMiddle = false;
				showMessageBottom = true;
        }
    }
    
    
    public PageReference returnSearch() 
    {
        userView = ViewState.STUDENT;
        updateView();
        return null;
    }
    
    public PageReference getLoanedBooks() 
    {
        loans = (List<Loan__c>) [select id, Book_Title__c, Expected_Return_Day__c from Loan__c where OwnerId =:studentId AND Status__c ='Loaned' order by Expected_Return_Day__c];
        userView=ViewState.LOANS;
        checkOverdue();
		updateView();
        return null;
    }
        
    public void checkOverdue() 
    {
        boolean isBookOverdue = false;
        for (loan__c lo:loans) 
        {
            if (lo.Expected_Return_Day__c < date.today())
            {
                isBookOverdue=true;
                userView=ViewState.OVERDUE;
                break;
            }
        }
        if (loans.size()>0 && isBookOverdue) 
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Student has books overdue'));
        }
    }
    
    public PageReference returnBook() 
    {
         Loan__c loan = [SELECT id, Status__c from Loan__c where id=:loanedBookId];
         loan.Status__c = 'Returned';
         update(loan);
         return getLoanedBooks();
    } 
    
    public PageReference doSearch() {
       		try{
            	results = (List<User>)[FIND :searchText IN ALL FIELDS RETURNING User(Id, Name Where UserRoleId =:uStudent.Id)] [0];
            } catch(Exception ex)
            {
              
            }
 
        	updateView();
        		//results = [select Id, Name from User where Name like:'%searchText%' AND UserRoleId =:uStudent.Id];
           	return null;
    }
    
    public PageReference doSearchCopy() 
    {
        try{
   			BookCopy = [select id,name,Book__c,Availability__c from Book_Copy__c where name =:searchCopy ];
            if(BookCopy.Availability__c == 'Available')
        	{
				createLoan();
            }else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Book Copy is already lended'));
            }
		} catch(Exception ex){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Book Copy Code does not exist'));
        }
        
        return null;     

    }
	        
    public void createLoan() 
    {
         Loan__c newLoan = new Loan__c();
      	 Try {
            newLoan.Book__c = BookCopy.Book__c;
            newLoan.Book_Copy__c = BookCopy.id;
            newLoan.student__c = studentId;
            newLoan.Status__c = 'Loaned';
            newLoan.Loan_Date__c = date.today();
            newLoan.Expected_Return_Day__c = date.today() +3;
            newLoan.OwnerId = studentId;
            insert (newLoan);
            
            } 
        	catch (Exception e)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error:'+ e.getMessage()));
            }
        	finally 
            {
                if (newLoan.Id != null) 
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Loan created sucessfully'));
                    userView = ViewState.CREATED;
					getLoanedBooks();                    
                }                
            }
        
    }   
}