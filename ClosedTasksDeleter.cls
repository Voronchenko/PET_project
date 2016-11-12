public class ClosedTasksDeleter {

    @InvocableMethod(label = 'Delete Open Case Related Tasks' description = 'Deletes all the open tasks related to the current case')
    public static void deleteOpenCaseRelatedTasks (List<Case> cases) { 
    	
        Set<id> relevantCasesIds = new Set<id> ();
    	
        for (Case ca: cases) {
    		if (ca.isClosed) { relevantCasesIds.add(ca.id) ;}
    	}

    	List <Task> tasksToDelete = [ SELECT Id, WhatId, isClosed 
									  FROM Task 
									  WHERE WhatId IN :relevantCasesIds 
									  AND isClosed = true];
		delete tasksToDelete;
    }
}