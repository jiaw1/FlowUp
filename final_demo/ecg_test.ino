int inputPin = A0;
int sensorvalue = 0;
float x = 0;
float x_new = 0;
float lambda = 0.1;
float x_old = 0;

void setup() {
  // put your setup code here, to run once:
  Serial . begin (9600);
}

void loop() {
  // send the value of the analog input
  Serial . print(x_new);
  Serial.print(" ");
  Serial . println ( analogRead ( inputPin ));
  x = analogRead(inputPin);
  x_new = (1-lambda)*x_new + (lambda)*x;
  // wait a bit for the analog -to - digital converter to
  // stabilize after the last reading :
  delay (20);
}
