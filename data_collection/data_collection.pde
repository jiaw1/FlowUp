import processing.serial.*;
PrintWriter output;
Serial myPort;
String dataString = "";

void setup() {
  size(600, 400);
  
  // Set COM port
  String portName = "COM15"; 
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n'); // Read until newline character
    // Open file for writing
  //output = createWriter("C:/Users/jiawe/Desktop/data.csv");
  output = createWriter("C:/Users/jiawe/Desktop/datacsv");
  
  // Print header
  String header = "emg, gsr, rsp";
  println(header); 
  output.println(header); 
  output.flush();
}

void draw() {
  background(0);
  fill(255);
  textSize(16);
  text("Reading Serial Data from COM...", 20, 50);
  text("Collected Data: " + dataString, 20, 100);
}

void serialEvent(Serial myPort) {
  String received = myPort.readStringUntil('\n');
  
  if (received != null) {
    received = received.trim(); // Remove whitespace
    dataString = received;
    println(received); // Print to console
    
    // Append data to file
    output.println(received);
    output.flush();
  }
}

void keyPressed() {
  if (key == 's') {
    output.flush(); // Ensure all data is written
    output.close(); // Close file
    println("File saved!");
    exit();
  }
}
