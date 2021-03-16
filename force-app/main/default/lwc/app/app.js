import { LightningElement, wire, api } from 'lwc';
import findExternalAnimals from '@salesforce/apex/LWCController.findExternalAnimals';
import saveAnimals from '@salesforce/apex/LWCController.saveAnimals';
import getAnimals from '@salesforce/apex/LWCController.getAnimals';

const COLS=[  
    {label:'Id', fieldName:'id', type:'text'},  
    {label:'Name', fieldName:'name', type:'text'},  
    {label:'Says', fieldName:'says', type:'text'},  
    {label:'Eats', fieldName:'eats', type:'text'},  
    {label:'ExternalId', fieldName:'externalId', type:'text'},  
  ];  

export default class App extends LightningElement {
        
    @api externalAnimals;
    @api animals;
    cols=COLS;

    connectedCallback() {
        this.getAnimals();
    }

    handleClick(event) {
        var idFrom = this.template.querySelector('[data-id="externalIdFfom"]');
        console.log('Test' + idFrom.value);
        var idTo = this.template.querySelector('[data-id="externalIdTo"]');
        console.log('Test' + idTo.value);

        findExternalAnimals({ idFrom: idFrom.value, idTo: idTo.value })
            .then((result) => {
                this.externalAnimals = result;
            });
    }

   saveAnimals() {
        var selectedAnimals = this.template.querySelector("lightning-datatable").getSelectedRows();  
        saveAnimals({animals: selectedAnimals})
            .then(result => {  
                console.log('Result: ' + result.isSuccess);
                console.log('Result: ' + result.result);
                if (result.isSuccess) {
                    this.getAnimals();
                }
            }).catch(error => {  
                
            })  
   }
   
   getAnimals() {
        getAnimals()
            .then((result) => {
              this.animals = result;
        });
   }
}