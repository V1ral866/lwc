public inherited sharing class Animals {
    
    private static final String URL = 'https://th-apex-http-callout.herokuapp.com/animals';

    public static List<Animal__c>  getAnimalsFromURL() {
        Object value = getValueFromCache(URL);
        if (value != null) {
            JSONAnimals jsonAnimals = (JSONAnimals) JSON.deserialize((String) value, JSONAnimals.class);
            return objectsMapper(jsonAnimals.animals);
        } else {
            JSONAnimals jsonAnimals = (JSONAnimals) HttpUtils.get(URl, JSONAnimals.class); 
            List<Animal__c> res = objectsMapper(jsonAnimals.animals);
            putValueInCache(URL, jsonAnimals);
            return res;
        }
    }

    public static Animal__c  getAnimalFromURL(String id, Boolean useCache) {
        String url = URL + '/' + id;

        if (useCache) {
            Object value = getValueFromCache(url);
            if (value != null) {
                JSONAnimal jsonAnimal = (JSONAnimal) JSON.deserialize((String)value, JSONAnimal.class);
                return objectMapper(jsonAnimal);
            } else {
                JSONAnimal jsonAnimal = (JSONAnimal) HttpUtils.get(url, JSONAnimal.class);
                Animal__c animal = objectMapper(jsonAnimal);
                putValueInCache(url, jsonAnimal);
                return animal;
            } 
        } else {
            JSONAnimal jsonAnimal = (JSONAnimal) HttpUtils.get(url, JSONAnimal.class);
            return objectMapper(jsonAnimal);
        }
    }

    private static Animal__c objectMapper(JSONAnimal jsonAnimal) {
        Animal__c animal = new Animal__c();
        animal.Name = jsonAnimal.animal.name;
        animal.ExternalId__c = String.valueOf(jsonAnimal.animal.id);
        animal.Says__c = jsonAnimal.animal.says;
        animal.Eats__c = jsonAnimal.animal.eats;
        return animal;
    }

    private static List<Animal__c> objectsMapper(List<String> jsonAnimals) {
        List<Animal__c> res = new List<Animal__c>();
        for (String name : jsonAnimals) {
            res.add(objectMapper(new JSOnAnimal(name)));
        }
        return res;
    }

    private static Object getValueFromCache(String key) {
        List<HttpCache__c> dbCach = [SELECT Key__c, Value__c, Time__c FROM HttpCache__c WHERE Key__c =: key];
        if (dbCach.size() != 0) {
            return dbCach.get(0).Value__c;
        }
        return null;
    }

    private static void putValueInCache(String key, Object value) {
        insert new HttpCache__c(Key__c=key, Value__c=JSON.serialize(value, false), Time__c=DateTime.now());
    }

    //{"animals":["majestic badger","fluffy bunny","scary bear","chicken"]}
    public class JSONAnimals {
        public List<String> animals;
    }

    //{"animal":{"id":1,"name":"chicken","eats":"chicken food","says":"cluck cluck"}}
    public class JSONAnimal {
        public Animal animal;

        public JSONAnimal(String name) {
            animal = new Animal(name);
        }
    }

    public class Animal {

        Integer id;
        String name;
        String eats;
        String says;

        public Animal(String name) {
            this.name = name;
        }
    }
}