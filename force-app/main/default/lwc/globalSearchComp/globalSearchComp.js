import { LightningElement,track } from 'lwc';
import getRecords from '@salesforce/apex/TableController.getSearchRecords';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';

export default class GlobalSearchComp extends LightningElement {
    
    @track DataTableResponseWrappper;
    @track finalSObjectDataList;
    @track tableCoumn;
    @track tableData;
    table = new Map();


    connectedCallback(){
   //     this.getTable();
    }

    handleChange(event){
        console.log('Combo value: ', event.target.value);
    }

    get options() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Account', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
        ];
    }

    showTableData(event){
        console.log(event.target.name);
        let eachTableWrapper = this.table.get(event.target.name);
        this.tableCoumn = eachTableWrapper.lstDatatableCoumns;
        this.tableData = eachTableWrapper.lstDataTableData;
    }

    getTable(){
        getRecords({searchStr : this.queryTerm})
        .then((result) =>{
            console.log('Found Records::' + JSON.stringify(result));
            if(result){
                let sObjectRelatedFieldListValues = [];
                this.DataTableResponseWrappper = result;
                result.forEach(element =>{
                    this.table.set(element.ObjectName,element);
                })

                this.tableCoumn = this.table.get('Contact').lstDatatableCoumns;
                this.tableData = this.table.get('Contact').lstDataTableData;
               /* for (let row of result.lstDataTableData) 
                {
                        const finalSobjectRow = {}
                        let rowIndexes = Object.keys(row); 
                        rowIndexes.forEach((rowIndex) => 
                        {
                            const relatedFieldValue = row[rowIndex];
                            console.log('relatedFieldValue.constructo', relatedFieldValue.constructor)
                            if(relatedFieldValue.constructor === Object)
                            {
                                this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                }
                else
                {
                    finalSobjectRow[rowIndex] = relatedFieldValue;
                }
                
            });
            sObjectRelatedFieldListValues.push(finalSobjectRow);
        }*/
      //  this.DataTableResponseWrappper = result;
        //this.finalSObjectDataList = sObjectRelatedFieldListValues;
            }
          //  this.tableResult = result;
        })
        .catch((error)=>{
            console.log('Error in Searching Record'+ error)
        })
    }
    tableResult;
    queryTerm;
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        console.log(evt.keyCode)
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
            console.log('Query Term', this.queryTerm)
            this.getTable();
            
        }
    }


    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => 
    {        
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => 
        {
            let finalKey = fieldName + '.'+ key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }
}