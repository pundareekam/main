import { LightningElement, track } from 'lwc';

export default class OnloadLWC extends LightningElement {

    @track greeting;  
   
    connectedCallback() {
        this.greeting = 'Hello World!';
    }
}