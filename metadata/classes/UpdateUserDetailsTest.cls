@isTest

private class UpdateUserDetailsTest {

    public static List<User> userList;
    public static List<Profile> profileList;
    public static List<UserRole> roleList;
	public static List<TestCase> testCaseList;
    
    public static Profile pLibrarian=[select id, name from profile where name='Librarian' LIMIT 1];
	public static Profile pStudent=[select id, Name from Profile where name='Student' LIMIT 1];
	public static Profile pStandard = [SELECT Id,Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
 	public static UserRole uLibrarian=[SELECT Id,Name FROM UserRole where Name ='Librarian' LIMIT 1];
   	public static UserRole uStudent=[SELECT Id,Name FROM UserRole where Name ='Student' LIMIT 1];

    static void init() 
    {
		initializeUsers();
        initializeProfile();
        initializeUserRole();
    }
    
    static void initializeUsers () 
    {
        userList = new List<User>();      
        
        User uStandard = new User(LastName = 'Standard',
			FirstName='Olpar',
			Alias = 'Ostan',
			Email = 'Ostan@asdf.com',
			Username = 'Ostan@asdf.com',
			ProfileId = pStandard.Id,
			TimeZoneSidKey = 'GMT',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LocaleSidKey = 'en_US'
		);
        
        User uLibrarian = new User(LastName = 'LIVESTON',
			FirstName='JASON',
			Alias = 'jliv',
			Email = 'jason.liveston@asdf.com',
			Username = 'jason.liveston@asdf.com',
			ProfileId = pLibrarian.Id,
			TimeZoneSidKey = 'GMT',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LocaleSidKey = 'en_US'
		);
       
        User uStudent = new User(LastName = 'Mac',
			FirstName='Luzar',
			Alias = 'Jarm',
			Email = 'mac.luzar@asdf.com',
			Username = 'mac.luzar@asdf.com',
			ProfileId = pStudent.Id,
			TimeZoneSidKey = 'GMT',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LocaleSidKey = 'en_US'
		);

        userList.add(uStandard);
        userList.add(uLibrarian);
        userList.add(uStudent);
        
    }
    
    static void initializeProfile() 
    {
        profileList = new List<Profile>(); 
        profileList.add(pLibrarian);
        profileList.add(pStudent);
        profileList.add(pStandard);
    }
    
    static void initializeUserRole() 
    {
        roleList = new List<UserRole>();
        roleList.add(uLibrarian);
        roleList.add(uStudent);
    }
    
    static void generateTestMatrix() 
    {
       	for (UserRole roleToTest:roleList) {
         for(User user:userList){

             User testUser = [select id, name, ProfileId,UserRoleId from user where id = :user.id ];
             Profile testProfile = [select id,name from Profile where id = :testUser.ProfileId];
             TestCase testCase = new TestCase(testUser,testProfile,roleToTest);
             testCaseList.add (testCase);
         }
        }
        
    }
    
    static void runTests() 
    {
        for (TestCase testCase:testCaseList) {
        	
            testCase.runTestCase();
        
        }
    }
   
    
    static testMethod void testUpdateUserDetails() {
 	init();
    Test.startTest();
    
    insert userList;
   	generateTestMatrix();
	runTests();
        
    Test.stopTest();   
        
    }
    

    private class TestCase 
    {

        User user;
        Profile profile;
        UserRole roleToTest;
            
        public testCase(User user, Profile profile, UserRole roleToTest) {
            this.user = user;
            this.profile = profile;
            this.roleToTest = roleToTest;
        }
        
        public void runTestCase () 
        {
			System.debug('Testing created user:"'+this.user.Name +'"" with profile: "'
                         + this.profile.Name+ '" against rol:"' + this.roleToTest.name+'".');
            
            System.assertEquals(this.user.UserRoleId, this.roleToTest.id);
            

        }
        
        
    }
    
}