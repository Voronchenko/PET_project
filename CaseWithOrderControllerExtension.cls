public with sharing class CaseWithOrderControllerExtension {

    private ApexPages.StandardController controller;
    public Case caseObj { get; set; }
    public Product2 affectedProduct { get; set; }
    public Order2__c orderObj { get; set; }
    public List<wrappedProduct> wrappedAvailableProducts { get; set; }
    public List<wrappedProduct> wrappedSelectedProducts { get; set; }
    public List<Order_Line__c> orderLines { get; set; }
    public Boolean isOrderFieldsRequired { get; set; }
    public Boolean isContactFieldRequired { get; set; }

    //Extension constructor which takes standard controller as the argument
    public CaseWithOrderControllerExtension(ApexPages.StandardController stdController) {
        this.controller = stdController;
        this.caseObj = (Case) stdController.getRecord();
        this.affectedProduct = new Product2();
        this.orderObj = new Order2__c();
        this.wrappedAvailableProducts = new List<wrappedProduct> ();
        this.wrappedSelectedProducts = new List<wrappedProduct> ();
        this.orderLines = new List<Order_Line__c> ();
        this.isOrderFieldsRequired = false;
        this.isContactFieldRequired = false;
    }
     

    //Product2 wrapper 
    public class wrappedProduct {
        public Product2 innerProduct { get; set; }
        public Boolean selected { get; set; }
        public Integer quantity { get; set; }

        public wrappedProduct(Product2 product) {
            this.innerProduct = product;
            this.selected = false;
            this.quantity = 0;
        }
    }


    public PageReference objectMappingNewCaseByProduct() {
        getAffectedProduct();
        getRelatedProducts();
        return null;
    }


    public PageReference getAffectedProduct() {

        try {
            List<Product2> prdList = [SELECT Id
                                            , Name
                                            , Description
                                            , ProductCode
                                            , Family_Name__c
                                            FROM Product2 
                                            WHERE Id = :caseObj.Product_part_affected__c LIMIT 1];
            if (!prdList.isEmpty()) {
                affectedProduct = prdList[0];
            }

        } catch(Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }


    //pagination for products in the available products list
    Public Integer noOfRecords { get; set; }
    Public Integer size { get; set; }

    public ApexPages.StandardSetController setCon {
    get {
      if (setCon == null) {

        size = 10;
       
        String familyName = affectedProduct.Family_Name__c;

        String queryString =
        ' SELECT Id' +
        ' , Name' +
        ' , ProductCode' +
        ' , Family_Name__c' +
        ' FROM Product2 ' +
        ' WHERE Family_Name__c =  \'' + familyName + '\' ' +
        ' LIMIT 10000';

        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
      }
      return setCon;
    } set;
  }

    //pagination method
    public PageReference getRelatedProducts() {

        addSelectedProducts();

        setCon = null;

        wrappedAvailableProducts.clear();
        for (Product2 prd : (List<Product2>) setCon.getRecords()) {
            wrappedProduct wap = new wrappedProduct(prd);
            wrappedAvailableProducts.add(wap);
        }

        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
        setCon.setPageNumber(1);

        return null;
    }

    //pagination method
    public PageReference paginationArrowFirst() {
        if (setCon.getHasPrevious()) {
            addSelectedProducts();
            setCon.first();
            wrappedAvailableProducts.clear();
            for (Product2 prd : (List<Product2>) setCon.getRecords()) {
                wrappedProduct wap = new wrappedProduct(prd);
                wrappedAvailableProducts.add(wap);
            }
        }
        return null;
    }

    //pagination method
    public PageReference paginationArrowPrevious() {
        if (setCon.getHasPrevious()) {
            addSelectedProducts();
            setCon.previous();
            wrappedAvailableProducts.clear();
            for (Product2 prd : (List<Product2>) setCon.getRecords()) {
                wrappedProduct wap = new wrappedProduct(prd);
                wrappedAvailableProducts.add(wap);
            }
        }
        return null;
    }

    //pagination method
    public PageReference paginationArrowNext() {
        if (setCon.getHasNext()) {
            addSelectedProducts();
            setCon.next();
            wrappedAvailableProducts.clear();
            for (Product2 prd : (List<Product2>) setCon.getRecords()) {
                wrappedProduct wap = new wrappedProduct(prd);
                wrappedAvailableProducts.add(wap);
            }
        }
        return null;
    }

    //pagination method
    public PageReference paginationArrowLast() {
        if (setCon.getHasNext()) {
            addSelectedProducts();
            setCon.last();
            wrappedAvailableProducts.clear();
            for (Product2 prd : (List<Product2>) setCon.getRecords()) {
                wrappedProduct wap = new wrappedProduct(prd);
                wrappedAvailableProducts.add(wap);
            }
        }
        return null;
    }


    //pagination property
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    
    //pagination property
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }


    //pagination property
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }


    //method for "Add" button 
    public PageReference addSelectedProducts() {
        try {

            //loop through available products to add selected
            if (!wrappedAvailableProducts.isEmpty()) {
                for (wrappedProduct availableProd : wrappedAvailableProducts) {
                    if (availableProd.selected) {

                        isOrderFieldsRequired = true;
                        Boolean noSuchProdFound = true;


                        if (!wrappedSelectedProducts.isEmpty()) {

                            for (wrappedProduct selectedProd : wrappedSelectedProducts) {
                                if (availableProd.innerProduct.Name == selectedProd.innerProduct.Name) {
                                    selectedProd.quantity++;
                                    noSuchProdFound = false;
                                }
                            }
                            if (noSuchProdFound == true) {
                                wrappedProduct wp = new wrappedProduct(availableProd.innerProduct.clone());
                                wp.quantity = 1;
                                wrappedSelectedProducts.add(wp);
                            }
                        } else {
                            wrappedProduct wp = new wrappedProduct(availableProd.innerProduct.clone());
                            wp.quantity = 1;
                            wrappedSelectedProducts.add(wp);
                        }
                    }
                    availableProd.selected = false;
                }

            }
        } catch(Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }


    //method for "Remove" button (for change)
    public PageReference removeSelectedProducts() {
        try {
            //loop through the list of previously added products to remove selected ones
            for (Integer i = (wrappedSelectedProducts.size() - 1); i >= 0; i--) {
                if (wrappedSelectedProducts[i].selected) {
                    wrappedSelectedProducts.remove(i);
                }
            }

            isOrderFieldsRequired = false;
        } catch(Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }


    //before saving case: converting added list to order lines list (for change)
    public PageReference populateOrderLines() {
        try {
            if (!wrappedSelectedProducts.isEmpty()) {
                for (wrappedProduct selectedProd : wrappedSelectedProducts) {
                    Order_Line__c ordLine = new Order_Line__c();
                    ordLine.Case__c = caseObj.Id;
                    ordLine.Order__c = orderObj.Id;
                    ordLine.Description__c = selectedProd.innerProduct.Name;
                    ordLine.Quantity__c = selectedProd.quantity;
                    orderLines.add(ordLine);
                }
            }

        } catch(Exception e) {

            ApexPages.addMessages(e);
        
        }
        return null;
    }


    public PageReference saveCase() {
        try {

            if (caseObj.ContactId != null) {
                insert caseObj;
                insertOrderwithOrderLines();
                PageReference viewPage = new ApexPages.StandardController(caseObj).view();
                viewPage.setRedirect(true);
                return viewPage;

            } else {
                isContactFieldRequired = true;
                ApexPages.Message fieldMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure all required fields are filled out correctly');
                ApexPages.addMessage(fieldMsg);
            }

        } catch(Exception e) {
            Apexpages.addMessages(e);
        }

        return null;
    }


    public PageReference insertOrderwithOrderLines() {
        try {

            if (!wrappedSelectedProducts.isEmpty()) {
                orderObj.Case__c = caseObj.Id;
                insert orderObj;
                populateOrderLines();
                insert orderLines;
            }

        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }


    public PageReference cancelCase() {
        PageReference goBackHomeP = new PageReference('/500/o');
        goBackHomeP.setRedirect(true);
        return goBackHomeP;
    }
}