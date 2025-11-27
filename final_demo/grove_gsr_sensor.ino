const int sensorPin = A0;
unsigned long lastRead = 0;
const unsigned long interval = 10; // ms between reads (10ms = 100Hz)

void setup() {
  Serial.begin(9600);
}

void loop() { 
  unsigned long now = millis();
  if (now - lastRead >= interval) {
    lastRead = now;
    int sensorValue = analogRead(sensorPin);
    Serial.println(sensorValue);
  }
}
