public class CurrentWeather {
    private String description;
    private int temperature;
    private int preciption;
    private int humidity;
    private int wind;
    private int visibility;
    private int pressure; 
    private PImage img;
    
    CurrentWeather(String description, int temperature, int preciption, int humidity, int wind, int visibility, int pressure, PImage img) {
        this.description = description;
        this.temperature = temperature;
        this.preciption = preciption;
        this.humidity = humidity;
        this.wind = wind;
        this.visibility = visibility;
        this.preciption = pressure;
        this.img = img;
    }
    
    String getDescription() {
        return this.description;
    }
    
    String getTemperature() {
        return this.temperature + "°";
    }
    
    String getPreciption() {
        return this.preciption + " mm";
    }
    
    String getHumidity() {
        return this.humidity + "%";
    }
    
    String getWind() {
        return this.wind + " km/h";
    }
    
    String getVisibility() {
        return this.visibility + " km";
    }
    
    String getPressure() {
        return this.pressure + " in";
    }
    
    PImage getImage() {
        return this.img;
    }
}