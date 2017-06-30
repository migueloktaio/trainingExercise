trigger UpdateUserDetails on User (before insert) {

    profile pLibrarian=[select id, name from profile where name='Librarian' LIMIT 1];
    profile pStudent=[select id, name from Profile where name='Student' LIMIT 1];
    userRole uLibrarian=[SELECT Id,Name FROM UserRole where Name ='Librarian'];
    userRole uStudent=[SELECT Id,Name FROM UserRole where Name ='Student'];
       
    for(User user:trigger.new){
        
        if(user.ProfileId == pLibrarian.id){
            user.UserRoleId= uLibrarian.id;
        }
        
        if (user.ProfileId == pStudent.id ) 
        {
            user.UserRoleId= uStudent.id;
        }
    
    }
    
    
}