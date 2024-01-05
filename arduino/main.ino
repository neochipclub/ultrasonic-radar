#include <Stepper.h> 
#define STEPS 2038 // the number of steps in one revolution of your motor (28BYJ-48)
const int stepsPerRevolution = 2038;
const int trigPin = 5;
const int echoPin = 6;

const int buzzerPin = 4;
const int ledPin = 12;

long duration;
int distance;
int roundAngle;
int Angle;
bool clockwise = true;
Stepper stepper(STEPS, 8, 10, 9, 11);
  }

int stepCount = 0;

  Serial.print(Angle);
void setup() {
// nothing to do
 pinMode(trigPin, OUTPUT);
 pinMode(echoPin, INPUT);
 Serial.begin(9600);
 pinMode(buzzerPin, OUTPUT);
 pinMode(ledPin, OUTPUT);
}

void loop() {
  stepper.setSpeed(30);
  distance = calculateDistance();
  if (distance <= 100) {
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  delay(0);
  Angle = stepCount*0.176;
  roundAngle = (int)Angle;
  Serial.print(",");
  Serial.print(distance);
  Serial.print(".");
  if (clockwise == true) {stepCount++; stepper.step(1);}
  if (clockwise == false) {stepCount--; stepper.step(-1);}
  if (stepCount == 2038) {clockwise = false;}
  if (stepCount == 0) {clockwise = true;}

  
}
  int calculateDistance(){

    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    duration = pulseIn(echoPin, HIGH);
    distance = duration*0.034/2;
    
    return distance;
  }
