@isTest
private class GetCommitteeInformationTest {
    
    @testSetup static void setup() {
        // Create common test Comitte
        Committee__c committee = new Committee__c();
        committee.Committee_Active__c = true;
        committee.Display_On_Site__c = true;
        committee.Accessibility__c = 'Public';
        committee.Website_Display_Name__c = 'State Legislative Affairs';
        committee.Pillar__c = 'Capital/Partnering';
        committee.Website_Region_Display__c = 'All Members';
        committee.Meeting_Cadence__c = 'Monthly';
        committee.Meeting_Format__c = 'Virtual Via Zoom';
        committee.Website_Description__c  = 'We are the best';
        insert committee;  
        
        Event__c event = new Event__c();
        event.Title__c= 'Test Event';
        event.Committee__c = committee.Id;
        event.Start_Time__c = System.today();
        insert event;
        
        List<Committee_Responsibility__c> reqs = new List<Committee_Responsibility__c>();
        Committee_Responsibility__c req = new Committee_Responsibility__c();
        req.Committee__c = committee.Id;
        req.Responsibility_Party__c = 'Committee';
        req.Responsibility_Type__c = 'Plan Workshops';
        req.Responsibility_Text__c = 'Test';
        reqs.add(req);
        Committee_Responsibility__c req1 = new Committee_Responsibility__c();
        req1.Committee__c = committee.Id;
        req1.Responsibility_Party__c = 'Biocom California';
        req1.Responsibility_Type__c = 'Plan Workshops';
        req1.Responsibility_Text__c = 'Test';
        reqs.add(req1);
        insert reqs;
        
        Contact con = new Contact();
        con.LastName ='Test Contact';
        insert con;
        
        Account acct = new Account();
        acct.name = 'Testing Account';
        insert acct;
        
        List<Committee_Member__c> members = new List<Committee_Member__c>();
        Committee_Member__c member1 = new Committee_Member__c();
        member1.Committee_Role__c = 'Chair';
        member1.Committtee_Member__c = con.Id;
        member1.Committee__c = committee.Id;
        member1.Account__c = acct.id;
        member1.Member_Active__c = true;
        member1.DisplayOnWebsite__c = true;
        members.add(member1);
        
        Committee_Member__c member2 = new Committee_Member__c();
        member2.Committee_Role__c = 'Biocom Staff';
        member2.Committtee_Member__c = con.Id;
        member2.Committee__c = committee.Id;
        member2.Member_Active__c = true;
        member2.DisplayOnWebsite__c = true;
        member2.Account__c = acct.id;
        members.add(member2);
        
        Committee_Member__c member3 = new Committee_Member__c();
        member3.Committee_Role__c = 'Biocom Contact';
        member3.Committtee_Member__c = con.Id;
        member3.Member_Active__c = true;
        member3.DisplayOnWebsite__c = true;
        member3.Committee__c = committee.Id;
        member3.Account__c = acct.id;
        members.add(member3);
        insert members;
        
        Committee_Eligibility_Requirement__c eliReq = new Committee_Eligibility_Requirement__c();
        eliReq.Committee__c = committee.Id;
        eliReq.Order_Number__c = 1;
        eliReq.Description__c = 'Test Desc';
        insert eliReq;
    }
    @isTest static void testGetCommitteInfo() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/committees';       
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        GetCommitteeInformation.doGet();
        Test.stopTest();
    }
    
    @isTest static void testGetCommitteeRelatedInfo() {
        Committee__c com = [Select Id from Committee__c Limit 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/committees'; 
        req.params.put('id',com.Id);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        GetCommitteeInformation.doGet();
        Test.stopTest();
    }
    
}
