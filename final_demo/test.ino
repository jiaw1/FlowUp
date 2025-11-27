// Initialize sensor
int sensorpin1 = A0;

int sensorvalue1 = 0;

void setup() {
  Serial.begin(9600);
  Serial.println("s0");
}

void loop() {
  sensorvalue1 = analogRead(sensorpin1);

  float voltage = 5.0 - ((sensorvalue1 / 1023.0) * 5.0); // Inverted voltage calculation
  //float voltage = 3.3 - ((sensorvalue1 / 4095.0) * 3.3); // Inverted voltage calculation

  // Serial output
  Serial.println(sensorvalue1);

  delay(100); // 10Hz sampling rate
}
