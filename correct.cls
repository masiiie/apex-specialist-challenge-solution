Test.startTest();
for(Case caseItem : newCases){
    caseItem.status = 'Closed';
}
Database.SaveResult[] results = Database.update(newCases, false);
Test.stopTest();


@isTest