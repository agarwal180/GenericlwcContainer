import { LightningElement, api, track } from 'lwc';
import saveFiles from '@salesforce/apex/SmartCityFileUploading.saveFiles';
import getContentDetails from '@salesforce/apex/SmartCityFileUploading.getContentDetails';
import ResourcesStatic from '@salesforce/resourceUrl/ResourcesStatic';
import deleteContentDocument from '@salesforce/apex/SmartCityFileUploading.deleteContentDocument';
import { NavigationMixin } from 'lightning/navigation';

const MAX_FILE_SIZE = 5242880;
    const fileType = ["image/jpeg", "image/jpg", "image/png", "application/pdf","application/msword",
"application/vnd.openxmlformats-officedocument.wordprocessingml.document"];

export default class GenericUploadDocument extends NavigationMixin(LightningElement) {
    @api label;
    @api documentTitle;
    @api documentHeader;
    @api name;
    @api recordId;
    @api documentTitleDescription;
    @api filerequired;
    @api validfile;
    @api uploadfiles
    @api fileformatsize;
    @api title;
    uploadFile;
    FileId;
    FilesUploaded = [];
    @api FileTypeError;
    @api FileSizeError;
    @api acceptedFormats;
    @api error;
    uploadUrl = ResourcesStatic + '/Static_Resources/images/icons/icnUpload.svg';
    showLoadingSpinner;

    connectedCallback(){
        console.log('Error', this.error);
        this.getContentDetails();
    }

    getContentDetails(){
        console.log('recordId', this.recordId);
        console.log('titl', this.title);
        getContentDetails({  recordId: this.recordId,title : this.title })
            .then(data => {
                    console.log('data', data);
                    if(data){
                        this.uploadFile = data[0];
                        if(this.uploadFile){
                            const selectedEvent = new CustomEvent('upload', {
                                detail: {
                                    File: this.uploadFile
                                }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
            })
            .catch((error) =>{
                        console.log('error', error);
            })
    }
    handleFileChanges(event) {
        console.log('handle');
        this.FilesUploaded = [];
        this.uploadFile= '';
        if (event.target.files.length >= 2) {
            this.error = 'You can upload only one file at a time';
        } else {
            let file = event.target.files[0];
           // console.log('size', this.maxSize);
            if (file.size > MAX_FILE_SIZE) {
                console.log("file Size and File Type is not matching", MAX_FILE_SIZE);
                this.error = this.FileSizeError;
            } else {
                console.log('handle');
                console.log('test', file.type);
                console.log('file type', this.filetype);
                if (fileType.includes(file.type) == false) {
                    console.log('Type');
                    this.error = this.FileTypeError;
                } else {
                    console.log('File reader')
                    let fileReader = new FileReader();
                    console.log('handle save');
                    fileReader.onload = (() => {
                        let fileContents = fileReader.result;
                        let base64 = 'base64,';
                        let content = fileContents.indexOf(base64) + base64.length;
                        fileContents = fileContents.substring(content);
                        console.log('Content', fileContents);
                        console.log('handle save');
                        this.FilesUploaded.push({
                            Title: this.title + file.name,
                            VersionData: fileContents
                        });
                        console.log('', this.FilesUploaded);
                        this.handleSaveFiles();
                        this.error='';
                    });
                    fileReader.readAsDataURL(file);
                }
            }
        }
    }

    
    previewFile(file){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: file.fileUrl
                }
            }, false );
        
    }

    getBaseUrl(){
        let baseUrl = 'https://'+location.host+'/';
        return baseUrl;
    }

    @api
    validateFile() {
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
            console.log('Test', isInputsCorrect)
        if (!isInputsCorrect) {
            this.uploadError = 'Please Upload Valid File';
        } else {
            this.uploadError = '';
        }
        return isInputsCorrect;
    }

    removeFile(event) {
        console.log('dataset', event.target.dataset.id) ;
        console.log('Firl Name', event.target.dataset.name);
        this.showLoadingSpinner = true;
        let name = event.target.dataset.name;
        deleteContentDocument({
            recordId : event.target.dataset.id
        })
        .then(result => {

            this.uploadFile='';
            const selectedEvent = new CustomEvent('delete', {
                detail: name
            });
            this.dispatchEvent(selectedEvent);
        })
        .catch(error => {
            console.error('**** error **** \n ',error)
        })
        .finally(()=>{
            this.showLoadingSpinner = false;
        });

    }

    handleSaveFiles() {
        console.log('handle save', this.FilesUploaded);
        console.log('record', this.recordId);
        this.showLoadingSpinner = true;
        saveFiles({ filesToInsert: this.FilesUploaded, recordId: this.recordId })
            .then(data => {
                console.log('file uploaded SuccessFully' + JSON.stringify(data));
                this.getContentDetails();
            })
            .catch(error => {
                console.log('Error', error);
            })
            .finally(() =>{
                this.showLoadingSpinner = false;
            })
    }
}