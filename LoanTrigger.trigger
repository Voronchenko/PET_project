trigger LoanTrigger on Loan__c (after insert) {

	List <Loan__c> loansToUpdate = [ SELECT Id, decision__c 
									 FROM Loan__c 
									 WHERE Id NOT IN (SELECT Loan__c FROM Loan_Part__c) 
									 AND id IN :Trigger.new 
									 AND decision__c ='Awaiting check'];

	List <Loan_Part__c> newLoanParts = new List <Loan_Part__c>();

	if (!loansToUpdate.isEmpty()){
		for (Loan__c lo: loansToUpdate){
			Loan_Part__c loanPart = new Loan_Part__c ();
			loanPart.Loan__c = lo.id;
			loanPart.Name__c = 'auto created';
			newLoanParts.add(loanPart);
			lo.decision__c = 'Checked';
		}
		insert newLoanParts;
		update loansToUpdate;
	}
}