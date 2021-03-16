public with sharing class LWCController {
    
    @AuraEnabled
    public static List<AnimalWrapper> findExternalAnimals(Integer idFrom, Integer idTo) {
        List<AnimalWrapper> res = new List<AnimalWrapper>();

        for (Integer i = idFrom; i <= idTo ; i++ ) {
            res.add(wrapAnimal(Animals.getAnimalFromURL(String.valueOf(i), false)));
        }
        return res;
    }

    @AuraEnabled
    public static List<AnimalWrapper> getAnimals() {
        List<AnimalWrapper> wrappers = new List<AnimalWrapper>();

        try {
            wrappers = wrapAnimals([SELECT Id, Name, Says__c, Eats__c, ExternalId__c FROM Animal__c ORDER BY CreatedDate DESC LIMIT 10]);
            System.debug('Wrappers: ' + wrappers);
        } catch (Exception e) {
            System.debug('Wrappers: ' + e.getMessage());
        }
        return wrappers;
    }

    @AuraEnabled
    public static Response saveAnimals(List<AnimalWrapper> animals){
        try {
            System.debug(animals);
            List<Animal__c> animalsToInsert = unwrapAnimals(animals);
            insert animalsToInsert;
            System.debug(animalsToInsert);
            sendEmail(animalsToInsert);
            return new Response(true, wrapAnimals(animalsToInsert));
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }

    private static void sendEmail(List<Animal__c> animals) {
        EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE Name = 'External Animal HTML'];
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(UserInfo.getUserId()); 
        message.setSenderDisplayName('Animal INC'); 
        message.setReplyTo('no-reply@company.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.setTemplateID(emailTemplate.Id); 
        String htmlBody = '<html><body><h1>External animals</h1>';
        for (Animal__c animal : animals) {
            htmlBody += '<div><a href="' + URL.getOrgDomainUrl().toExternalForm() + '/' + animal.Id + '">' + animal.Name + '</a></div>';
        }
        htmlBody += '</body></html>';
        message.setHtmlBody(htmlBody);
        message.toAddresses = new String[] {UserInfo.getUserEmail()};
        messages.add(message);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        System.debug('Email sended ' + results[0].isSuccess());
    }

    private static List<Animal__c> unwrapAnimals(List<AnimalWrapper> wrapers) {
        List<Animal__c> animals = new List<Animal__c>();

        for (AnimalWrapper wrapper : wrapers) {
            animals.add(unwrapAnimal(wrapper));
        }
        return animals;
    }

    private static Animal__c unwrapAnimal(AnimalWrapper wrapper) {
        Animal__c animal = new Animal__c();

        animal.Name = wrapper.name;
        animal.Says__c = wrapper.says;
        animal.Eats__c = wrapper.eats;
        animal.ExternalId__c = wrapper.extrenalId;
        return animal;
    }

    private static List<AnimalWrapper> wrapAnimals(List<Animal__c> animals) {
        List<AnimalWrapper> wrappers = new List<AnimalWrapper>();

        for (Animal__c animal : animals) {
            wrappers.add(wrapAnimal(animal));
        }
        return wrappers;
    }

    private static AnimalWrapper wrapAnimal(Animal__c animal) {
        AnimalWrapper wrapper = new AnimalWrapper();

        wrapper.id = animal.Id;
        wrapper.name = animal.Name;
        wrapper.says = animal.Says__c;
        wrapper.eats = animal.Eats__c;
        wrapper.extrenalId = animal.ExternalId__c;
        return wrapper;
    }

    public class AnimalWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String says {get;set;}
        @AuraEnabled
        public String eats {get;set;}
        @AuraEnabled
        public String extrenalId {get;set;}

        public AnimalWrapper() {}    
    }

    public class Response {
        @AuraEnabled
        public Boolean isSuccess {get;set;}
        @AuraEnabled
        public Object result {get;set;}

        public Response(Boolean success, Object result) {
            this.isSuccess = success;   
            this.result = result;
        }
    }

}