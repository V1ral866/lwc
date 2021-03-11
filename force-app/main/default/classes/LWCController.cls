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
    public static List<AnimalWrapper> saveAnimals(List<AnimalWrapper> animals){
        System.debug(animals);
        List<Animal__c> animalsToInsert = unwrapAnimals(animals);
        insert animalsToInsert;
        System.debug(animalsToInsert);
        return wrapAnimals(animalsToInsert);
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

}