public with sharing class TableController {
    public TableController() {
        
    }
    @AuraEnabled
    public static List<DataTableResponse>  getSearchRecords(String searchStr){
        
        List<DataTableResponse>  tableResponseList = new List<DataTableResponse>();
        String query = 'Find  \'' + String.escapeSingleQuotes(searchStr) + '\' IN ALL Fields Returning ';
        try{
        for(Dynamic_Data_Table__mdt dynamicDataTable: [SELECT Id, DeveloperName,Object_Name__c, Field_Value__c, Header__c, Query__c, Table_Title__c FROM Dynamic_Data_Table__mdt]){
            DataTableResponse dtr = new DataTableResponse();
            List<String> columsList = new List<String>();
            List<DataTableColumns> datatableColumList = new List<DataTableColumns>();
            List<String> fieldApiNameList = new List<String>();
            List<sobject> tableRecords = new List<Sobject>();
            if(dynamicDataTable.Header__c != null){
                columsList = dynamicDataTable.Header__c.split(',');
            } 
            
            query+= dynamicDataTable.Object_Name__c + '( ';
            if(dynamicDataTable.Field_Value__c != null){
                fieldApiNameList = dynamicDataTable.Field_Value__c.split(',');
            } 
            for(Integer i = 0 ; i< columsList.size() ; i ++){
                DataTableColumns tableCoumn = new DataTableColumns(columsList[i].trim(), fieldApiNameList[i].subStringBefore(':').trim(),fieldApiNameList[i].subStringAfter(':').trim());
                datatableColumList.add(tableCoumn);
                query+= fieldApiNameList[i].subStringBefore(':').trim() + ',';
            }
            
            query+= 'Id ), ';
          /*  String soqlQuery;
            System.debug('search'+ searchStr);
            if(String.isNotBlank(searchStr) && String.isNotEmpty(searchStr)){
                searchStr = '%'+ searchStr +'%';
                if(dynamicDataTable.Object_Name__c == 'Account'){
                    soqlQuery = dynamicDataTable.Query__c + ' Where Name LIKE :searchStr';
                }else if(dynamicDataTable.Object_Name__c == 'Contact'){
                    soqlQuery = dynamicDataTable.Query__c + ' Where LastName LIKE :searchStr';
                }else{
                    soqlQuery = dynamicDataTable.Query__c;
                }
            }else{
                soqlQuery = dynamicDataTable.Query__c;
            }           
           // tableRecords = Database.query(soqlQuery);*/
            dtr.count = tableRecords.size();
            dtr.lstDataTableData =  tableRecords;
            dtr.ObjectName = dynamicDataTable.Object_Name__c;
            dtr.lstDatatableCoumns = datatableColumList;
            tableResponseList.add(dtr);
        }
            
            Map<String,List<Sobject>>  mapObjectNameWithRecord = new Map<String,List<Sobject>>();
        System.debug('Query' + query);
            query = query.substring(0, query.lastIndexOf(','));
		        System.debug('Query' + query);            
   				List<List<sobject>> records = Search.query(query);
            for(List<Sobject> record:records){
                System.debug('records'+ record);
                if(!record.isEmpty()){
                    String sObjName = record[0].Id.getSObjectType().getDescribe().getName();
                    mapObjectNameWithRecord.put(sObjName,record);
                }
            }
            
            for(DataTableResponse tableResponse: tableResponseList){
                tableResponse.lstDataTableData = mapObjectNameWithRecord.get(tableResponse.ObjectName);
                tableResponse.count = mapObjectNameWithRecord.get(tableResponse.ObjectName)!= null ? mapObjectNameWithRecord.get(tableResponse.ObjectName).size() : 0;
            }
            System.debug('data'+ tableResponseList);
        }catch(Exception e){
            System.debug('Exception ' + e.getLineNumber() + ' ' + e.getMessage());
        }
        return tableResponseList; 
    }
    
    public class DataTableColumns{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}  
        @AuraEnabled
        public String type {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
        }
    }
    
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDatatableCoumns {get;set;}
        @AuraEnabled
        public List<sobject> lstDataTableData {get;set;}
        @AuraEnabled
        public String ObjectName {get;set;}
        @AuraEnabled
        public Integer count {get;set;}
    }
}