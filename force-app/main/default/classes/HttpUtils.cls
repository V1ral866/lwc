public inherited sharing class HttpUtils {

    public class HttpException extends Exception {}

    public static Object get(String url, System.Type jsonClass) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return JSON.deserialize(response.getBody(), jsonClass);        
        } else {
            throw new HttpException();
        }
    }
}