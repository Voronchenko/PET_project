trigger ContactTrigger on Contact (before insert) {

	if (Trigger.isBefore) {
		if (Trigger.isInsert) {

			Set<Id> idForRelatedAccount = new Set<Id>();

			for(Contact ct: Trigger.new){
				if(ct.AccountId != null){ idForRelatedAccount.add(ct.AccountId); }
			}

			Map <Id, Account> idToAccount = new Map <Id, Account>([ SELECT Id, ShippingAddress, BillingAddress, Phone, Ownership, AnnualRevenue 
																	FROM Account 
																	WHERE Id IN : idForRelatedAccount]);

			for(Contact ct: Trigger.new){
				if(ct.AccountId != null){
					ct.BillingAddress__c = idToAccount.get(ct.AccountId).BillingAddress.getPostalCode();
					ct.OrganizationPhone__c = idToAccount.get(ct.AccountId).Phone;
					ct.ParentAccountOwnership__c = idToAccount.get(ct.AccountId).Ownership;
					ct.ParentAccountRevenue__c = idToAccount.get(ct.AccountId).AnnualRevenue;
				}
			}
    	}
    }
}