// EMG
int emgPin = A0;
float x = 0;
float x_new = 0;
float lambda = 0.1;

// GSR
const int gsrPin = A1;

// RSP
int rspPin = A2;

// Timing
unsigned long lastRead = 0;
// ms between reads
const unsigned long interval = 10; // 10ms = 100Hz sampling rate

void setup() {
  Serial.begin(9600);
}

void loop() {
  unsigned long now = millis();

  if (now - lastRead >= interval) {
    lastRead = now;

    // Read sensors
    x = analogRead(emgPin); 
    x_new = (1 - lambda) * x_new + lambda * x; 
    float emg = x_new;

    int gsr = analogRead(gsrPin);
    
    int rsp = analogRead(rspPin);

    // Print data
    Serial.print(emg);
    Serial.print(", ");
    Serial.print(gsr);
    Serial.print(", ");
    Serial.println(rsp);
  }
}
