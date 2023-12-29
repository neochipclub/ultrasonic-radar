import java.text.SimpleDateFormat;
import java.util.*;

import processing.serial.*; 
import java.awt.event.KeyEvent;
import java.io.IOException;
import ddf.minim.*;

Serial myPort;

//window settings
int height = 700; 
int width = 1200;
float vc = height / 2;
float hc = width / 2;

// assets
PImage radarImg;
String radarImgPath = "./assets/images/radar-2.jpg";
PImage logoImg;
String logoImgPath = "./assets/images/logo.png";
PImage currentWeatherImg;
PImage noInternetImg;
String noInternetImgPath = "./assets/images/dark-mode.png";

final String DEGREE_SYMBOL = "°";
int objectsCount = 0;

// API settings
String APIBaseURL = "http://api.weatherapi.com/v1/";
String APIKey = "key=bc4d97f8339748d1bf2131225230112";

CurrentWeather currentWeatherData;

int iAngle = 0;
int iDistance;
float pixsDistance;
String angle = "";
String distance = "";
String data = "";
String noObject;
int index1 = 0;
int index2 = 0;
float radarOriginX;
float radarOriginY;
int lastDistance = 0;
int lastAngle = 0;
int maxDistance = 200;
ArrayList<Object> objects;

Minim minim;
AudioPlayer near, far;

// Refresh Weather Button
int rwButtonHeight = 22;
int rwButtonWidth = 62;
float rwButtonX = width - rwButtonWidth - 15;
float rwButtonY = (height * 0.46) - rwButtonHeight - 15;
color rwButtonBackground;
color rwButtonColor;
boolean rwButtonPressed = false;

boolean isLoading = false;

Area objectInfo;
Area history;
Area footer;
Area weatherInfo;
Area location;
Area timeAndDate;

float sideWidth;


void settings() {
    size(width, height);
    
    
    radarImg = loadImage(radarImgPath);
    logoImg = loadImage(logoImgPath);
    logoImg.resize(45, 45);
    noInternetImg = loadImage(noInternetImgPath);
    noInternetImg.resize(110, 110);
    
    rwButtonBackground = color(255);
    rwButtonColor = color(0);
    
    color backgroundColor = color(0);
    sideWidth = ((width / 2) - (radarImg.width / 2));
    
    // Areas 
    objectInfo = new Area(0, 0, sideWidth, height * 0.29, backgroundColor, margin(3, 1, 0, 1));
    history = new Area(0, objectInfo.getAreaHeight(), sideWidth, radarImg.height - objectInfo.getContentHeight(), backgroundColor, margin(1, 1, 0, 1));
    footer = new Area(0, objectInfo.getAreaHeight() + history.getAreaHeight(), width, height - (objectInfo.getAreaHeight() + history.getAreaHeight()), backgroundColor, margin(1, 1, 1, 1));
    weatherInfo = new Area((width + radarImg.width) / 2, 0, sideWidth, height * 0.46, backgroundColor, margin(3, 1, 0, 1));
    location = new Area((width + radarImg.width) / 2, weatherInfo.getAreaHeight(), sideWidth, 134, backgroundColor, margin(1, 1, 0, 1));
    timeAndDate = new Area((width + radarImg.width) / 2, weatherInfo.getAreaHeight() + location.getAreaHeight(), sideWidth, radarImg.height - weatherInfo.getContentHeight() - location.getAreaHeight(), backgroundColor, margin(1, 1, 0, 1));
    
    
    thread("getWeatherData");
    
    myPort = new Serial(this,"COM7", 9600);
    myPort.bufferUntil('.');
    
    radarOriginX = width / 2;
    radarOriginY = (height / 2) - ((height - radarImg.height) / 2) + 2;
    
    objects = new ArrayList<Object>();
    minim = new Minim(this);
    far = minim.loadFile("./assets/music/sonor-far.mp3");
    near = minim.loadFile("./assets/music/sonor-near.mp3");
}

void getWeatherData() {
    println("fetshed");
    isLoading = true;
    try {
        
        JSONObject res = loadJSONObject(APIBaseURL + "current.json?" + APIKey + "&q=Souk-Ahras");
        JSONObject current = res.getJSONObject("current");
        JSONObject condition = current.getJSONObject("condition");
        
        String description = condition.getString("text");
        int temperature = (int) current.getFloat("feelslike_c");
        int preciption = (int) current.getFloat("precip_mm");
        int humidity = (int) current.getFloat("humidity");
        int wind = (int) current.getFloat("wind_kph");
        int visibiity = (int) current.getFloat("vis_km");
        int pressure = (int) current.getFloat("pressure_in");
        PImage img = loadImage("https:" + condition.getString("icon"));
        
        currentWeatherData = new CurrentWeather(description, temperature, preciption, humidity, wind, visibiity, pressure, img);
        currentWeatherImg = currentWeatherData.getImage();
        
    } catch(Exception e) {
        println(e);
        currentWeatherData = null;
    }
    isLoading = false;
    println("done");
}

void serialEvent(Serial myPort) { // starts reading data from the Serial Port
    //reads the data from the Serial Port up to the character '.' and puts it into the String variable "data".
    data = myPort.readStringUntil('.');
    data = data.substring(0,data.length() - 1);
    
    index1 = data.indexOf(","); // find the character ',' and puts it into the variable "index1"
    angle = data.substring(0, index1); // read the data from position "0" to position of the variable index1 or thats the value of the angle the Arduino Board sent into the Serial Port
    distance = data.substring(index1 + 1, data.length()); // read the data from position "index1" to the end of the data pr thats the value of the distance
    
    //converts the String variables into Integer
    iAngle = int(angle);
    iDistance = int(distance);
    println(iDistance);
    
    if (iDistance <= maxDistance) {
        lastDistance = iDistance;
        lastAngle = iAngle;
        
        if (objects.size() > 6) {
            objects.remove(0);
        }
        objectsCount++;
        objects.add(new Object(iDistance, iAngle, getCurrentTime(), getCurrentDate()));
        
        
        if (iDistance >= 100 && !far.isPlaying()) {
            near.pause();
            far.rewind();
            far.play();
        }
        
        if (iDistance < 100 && !near.isPlaying()) {
            // If not playing, rewind and play the sound
            far.pause();
            near.rewind();
            near.play();
        }
    }
    
}

void mousePressed() {
    if (mouseX > rwButtonX && mouseX < rwButtonX + rwButtonWidth && mouseY > rwButtonY && mouseY < rwButtonY + rwButtonHeight) {
        rwButtonPressed = true;
        rwButtonBackground = color(146, 146, 146);
        rwButtonColor = color(255, 255, 255);
    }
}

void mouseReleased() {
    if (rwButtonPressed) {
        rwButtonBackground = color(255);
        rwButtonColor = color(0);
        rwButtonPressed = false;
        thread("getWeatherData");
    }
}

void draw() {
    drawLayout();
    drawRadar();
    drawLine();
    drawObject();
    
    showObjectInfo();
    showHistory();
    showWeatherInfo();
    showLocation();
    showDateAndTime();
    showFooter();
}

void drawRefreshButton(float buttonX, float buttonY) {
    pushMatrix();
    translate(buttonX, buttonY);
    
    fill(rwButtonBackground);
    stroke(rwButtonColor);
    strokeWeight(1.1);
    rect(0, 0, rwButtonWidth, rwButtonHeight);
    fill(rwButtonColor);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Refresh", rwButtonWidth / 2,(rwButtonHeight / 2) - 2);
    textAlign(LEFT);
    
    popMatrix();
}

void drawLayout() {
    pushMatrix();
    
    drawArea(objectInfo);
    drawArea(history);
    drawArea(footer);
    drawArea(weatherInfo);
    drawArea(location);
    drawArea(timeAndDate);
    
    popMatrix();
}

void drawRadar() {
    pushMatrix();
    translate( -radarImg.width / 2, -radarImg.height / 2);
    tint(255, 10);
    image(radarImg, radarOriginX, radarOriginY);
    noTint();
    popMatrix();
}

void drawLine() {
    pushMatrix();
    strokeWeight(1);
    stroke(30,250,60);
    translate(radarOriginX, radarOriginY);
    line(0,0,((radarImg.width / 2) - (radarImg.width / 2) * 0.15) * cos(radians(iAngle)), -((radarImg.height / 2) - (radarImg.height / 2) * 0.15) * sin(radians(iAngle)));
    popMatrix();
}

void drawObject() {
    pushMatrix();
    translate(radarOriginX , radarOriginY);
    strokeWeight(19);
    stroke(255,10,10); // red color
    pixsDistance = iDistance * ((radarImg.width / 2) - (radarImg.width / 2) * 0.15) / maxDistance;
    //limiting the range to 40 cms
    if (iDistance <= maxDistance) {
        point(pixsDistance * cos(radians(iAngle)), -pixsDistance * sin(radians(iAngle))); 
    }
    popMatrix();
}

void showObjectInfo() {
    float x = objectInfo.getX();
    float y = objectInfo.getY();
    pushMatrix();
    translate(x, y);
    translate(20, objectInfo.getContentHeight() / 2);
    
    fill(255);
    textSize(58);
    int hSpace = 18;
    
    text("DIST: " + lastDistance, 0, -hSpace);
    textAlign(LEFT, TOP);
    text("ANG: " + lastAngle + DEGREE_SYMBOL, 0, textBase("top") + hSpace);
    textAlign(LEFT);
    popMatrix();
}

void showHistory() {
    float x = history.getX();
    float y = history.getY();
    
    pushMatrix();
    translate(x + 20, y + 20);
    
    stroke(255);
    strokeWeight(1);
    
    textSize(16);
    textAlign(LEFT, TOP);
    text("Detected Objects(" + + objectsCount + ")", 0, textBase("top"));
    textSize(14);
    for (int i = 0; i < objects.size(); i++) {
        if (objects.get(i).distance < 100) {
            fill(255, 0, 0);
        } else {
            fill(30,250,60);
        }
        text("• Object detected in " + objects.get(i).distance + ", " + objects.get(i).angle + DEGREE_SYMBOL + "\n   at " + objects.get(i).time + " on " + objects.get(i).date, 0, textBase("top") + 25 + 52 * i);
    }
    textAlign(LEFT);
    
    popMatrix();
}

int scalar = 0;
int speed = 9;

void drawLoadingSpinner(float x, float y, float size) {
    noFill();
    stroke(53);
    strokeWeight(4.4);
    arc(x, y, size, size, 0, TWO_PI);
    strokeWeight(3.2);
    stroke(255);
    float deg = PI / 180;
    if (scalar == 360) {
        scalar = 0;
    }
    arc(x, y, size, size, -HALF_PI + scalar * deg, scalar * deg);
}

void showWeatherInfo() {
    float x = weatherInfo.getX();
    float y = weatherInfo.getY();
    
    pushMatrix();
    translate(x, y);
    fill(255);
    
    if (isLoading) {
        drawLoadingSpinner(weatherInfo.getContentWidth() / 2, weatherInfo.getContentHeight() / 2, 33);
        scalar += speed;
        popMatrix();
        return;
    }
    
    if (currentWeatherData != null) {
        translate(20, 53);
        fill(255);
        textSize(25);
        text(currentWeatherData.getDescription(), 0, 0);
        println(currentWeatherImg);
        image(currentWeatherImg, 0, 10);
        textSize(56);
        text(currentWeatherData.getTemperature(), currentWeatherImg.width + 7,(currentWeatherImg.height / 2) + 16 + 10);
        textSize(19);
        text("Preciption: " + currentWeatherData.getPreciption(), 0,(currentWeatherImg.height) + 40);
        text("Humidity: " + currentWeatherData.getHumidity(), 0,(currentWeatherImg.height) + 65);
        text("Wind: " + currentWeatherData.getWind(), 0,(currentWeatherImg.height) + 90);
        text("Visibility: " + currentWeatherData.getVisibility(), 0,(currentWeatherImg.height) + 115);
        text("Pressure: " + currentWeatherData.getPressure(), 0,(currentWeatherImg.height) + 140);
    } else {
        imageMode(CENTER);
        image(noInternetImg, weatherInfo.getContentWidth() / 2, weatherInfo.getContentHeight() / 2);
        imageMode(CORNER);
    }
    popMatrix();
    drawRefreshButton(rwButtonX, rwButtonY);
}

void showLocation() {
    float x = location.getX();
    float y = location.getY();
    pushMatrix();
    translate(x, y);
    float hSpace = 13;
    
    fill(255);
    textSize(23);
    textAlign(CENTER, BOTTOM);
    text("Africa, Algeria", location.getContentWidth() / 2, textBase("bottom") - hSpace + location.getContentHeight() / 2);
    textAlign(CENTER, TOP);
    text("Souk - Ahras, Souk - Ahras", location.getContentWidth() / 2, textBase("top") + hSpace + location.getContentHeight() / 2);
    textAlign(LEFT);
    popMatrix();
}

void drawCross(Area area) {
    pushMatrix();
    translate(area.getX(), area.getY());
    stroke(255);
    strokeWeight(1);
    line(0, area.getContentHeight() / 2, area.getContentWidth(), area.getContentHeight() / 2);
    line(area.getContentWidth() / 2, 0, area.getContentWidth() / 2, area.getContentHeight());
    popMatrix();
}

void showDateAndTime() {
    float x = timeAndDate.getX();
    float y = timeAndDate.getY();
    float hSpace = 16;
    
    pushMatrix();
    translate(x, y);
    translate(timeAndDate.getContentWidth() / 2, timeAndDate.getContentHeight() / 2);
    
    fill(255);
    textSize(58);
    textAlign(CENTER, BOTTOM);
    text(getCurrentTime(), 0, textBase("bottom") - hSpace);
    textSize(34);
    textAlign(CENTER, TOP);
    text(getCurrentDate(), 0, textBase("top") + hSpace);
    textAlign(LEFT);
    popMatrix();
}

void showFooter() {
    float x = footer.getX();
    float y = footer.getY();
    
    pushMatrix();
    translate(x, y);
    translate(footer.getContentWidth() / 2, footer.getContentHeight() / 2);
    
    fill(255);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Copyright © 2023 NeoChip Club. Allrights reserved.", 0, textBase("center"));
    textAlign(RIGHT, CENTER);
    text("https :/ /www.neochip.tech", footer.getContentWidth() / 2 - 20, textBase("center"));
    textAlign(LEFT, CENTER);
    textSize(36);
    imageMode(CENTER);
    image(logoImg, -footer.getContentWidth() / 2 + logoImg.width / 2 + 20, 0);
    imageMode(CORNER);
    text("NeoChip", -footer.getContentWidth() / 2 + logoImg.width + 20 + 4, textBase("center"));
    textAlign(LEFT);
    popMatrix();
}

void drawArea(Area area) {
    noStroke();
    fill(area.getBackground());
    rectMode(CORNER);
    rect(area.getX(), area.getY(), area.getContentWidth(), area.getContentHeight());
}

Margin margin(float top, float right, float bottom, float left) {
    return new Margin(top, right, bottom, left);
}
