import { LightningElement, wire, api } from 'lwc';
import findExternalAnimals from '@salesforce/apex/LWCController.findExternalAnimals';
import saveAnimals from '@salesforce/apex/LWCController.saveAnimals';

const COLS=[  
    {label:'Id', fieldName:'id', type:'text'},  
    {label:'Name', fieldName:'name', type:'text'},  
    {label:'Says', fieldName:'says', type:'text'},  
    {label:'Eats', fieldName:'eats', type:'text'},  
    {label:'ExternalId', fieldName:'externalId', type:'text'},  
  ];  

export default class App extends LightningElement {
        
    @api animals;
    cols=COLS;

    handleClick(event) {
        var idFrom = this.template.querySelector('[data-id="externalIdFfom"]');
        console.log('Test' + idFrom.value);
        var idTo = this.template.querySelector('[data-id="externalIdTo"]');
        console.log('Test' + idTo.value);

        findExternalAnimals({ idFrom: idFrom.value, idTo: idTo.value })
            .then((result) => {
                this.animals = result;
            });
    }

   saveAnimals() {
        var selectedAnimals = this.template.querySelector("lightning-datatable").getSelectedRows();  
        saveAnimals({animals: selectedAnimals})
            .then(result => {  
            }).catch(error => {  
            })  
   }  
}