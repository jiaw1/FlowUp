import processing.serial.*;

// GLOBAL STATE
String screen = "menu";  // "menu", "resp", "emg"

// images
PImage bg;
PImage breathBtn;
PImage emgBtn;
PImage breathBG;    // rsp bg
PImage breathChar;  // rsp char

PImage emgBG;       // EMG bg
PImage emgChar;     // EMG char

// button size
int btnW = 250;
int btnH = 320;

int respX, respY;
int emgX, emgY;

// rsp floating bg state
float bgX = 0;

// rsp char state
float charX;
float charY;
float velocityY = 0;
float gravity = 0.5;
float jumpStrength = -20;

float charTop = 100;     // ceiling limit
float charBottom = 500;  // ground limit

// rsp obs state
float obsX;
float obsY = 450;
float obsW = 80;
float obsH = 200;
float obsSpeed = 10;

// rsp game state
boolean respGameOver = false;

// EMG game state
int emgTotal = 10;
int emgRemaining = emgTotal;
boolean emgDone = false;

// --- SERIAL ---
Serial myPort;
int sensorValue = 0;

// thresholds
int breathThreshold = 240; // rsp: jump if value > threshold
int emgThreshold    = 360; // EMG: remove if value > threshold

// EMG edge detection
boolean emgCanRemove = true;

void setup() {
  size(1200, 800);

  // load images
  bg = loadImage("bg.png");
  breathBtn = loadImage("breath_play.png");
  emgBtn = loadImage("emg_play.png");
  breathBG = loadImage("breath_bg.png");
  breathChar = loadImage("breath_char.png");

  emgBG = loadImage("emg_bg.png");
  emgChar = loadImage("emg_char.png");

  // resize buttons
  breathBtn.resize(btnW, btnH);
  emgBtn.resize(btnW, btnH);

  // resize bg
  breathBG.resize(width, height);
  emgBG.resize(width, height);

  // resize chars
  breathChar.resize(150, 150);
  emgChar.resize(120, 120);

  // button positions
  respX = 100;
  respY = 300;

  emgX = 850;
  emgY = 300;

  // rsp char starting position
  charX = width/2 - 200;
  charY = charBottom;

  // initialize rsp obs
  resetObstacle();

  // initialize EMG game
  resetEmgGame();

  // SERIAL SETUP
  myPort = new Serial(this, "COM15", 9600);
  myPort.bufferUntil('\n');  // one reading per line
}

void draw() {
  // draw menu bg
  image(bg, 0, 0, width, height);

  if (screen.equals("menu")) {
    drawMenu();
  } 
  else if (screen.equals("resp")) {
    respirationGame();
  } 
  else if (screen.equals("emg")) {
    emgGame();
  }
}

// MAIN MENU
void drawMenu() {
  drawImageButton(respX, respY, breathBtn);
  drawImageButton(emgX, emgY, emgBtn);
}

void drawImageButton(int x, int y, PImage btnImg) {
  // hover effect
  if (overButton(x, y, btnW, btnH)) {
    tint(220);   // light highlight
  } else {
    noTint();
  }
  image(btnImg, x, y);
  noTint();
}

boolean overButton(int x, int y, int w, int h) {
  return mouseX > x && mouseX < x + w &&
         mouseY > y && mouseY < y + h;
}

void mousePressed() {
  if (screen.equals("menu")) {
    if (overButton(respX, respY, btnW, btnH)) {
      // reset rsp game state
      resetRespirationGame();
      screen = "resp";
    }
    if (overButton(emgX, emgY, btnW, btnH)) {
      // reset EMG game state
      resetEmgGame();
      screen = "emg";
    }
  } else {
    // click back to menu
    screen = "menu";
  }
}

// SERIAL EVENT – read one analog value
void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line != null) {
    line = trim(line);
    if (line.length() > 0) {
      try {
        sensorValue = int(line);
        // println("Sensor: " + sensorValue); // debug
      } catch (Exception e) {
        // ignore malformed lines
      }
    }
  }
}

// RESET RSP OBSTACLE
void resetObstacle() {
  obsX = width + 100;  // just off the right side
}

// RESET RSP GAME STATE
void resetRespirationGame() {
  bgX = 0;
  charX = width/2 - 200;
  charY = charBottom;
  velocityY = 0;
  respGameOver = false;
  resetObstacle();
}

// RSP GAME — FLOATING BG + CHAR + OBS
void respirationGame() {
  // scroll bg
  bgX -= 5;
  if (bgX <= -width) {
    bgX = 0;
  }

  image(breathBG, bgX, 0, width, height);
  image(breathBG, bgX + width, 0, width, height);

  if (!respGameOver) {

    // breath control
    if (sensorValue > breathThreshold) {
      velocityY = jumpStrength;
    }

    // char gravity
    velocityY += gravity;
    charY += velocityY;

    // clamp to top/bottom
    if (charY > charBottom) {
      charY = charBottom;
      velocityY = 0;
    }
    if (charY < charTop) {
      charY = charTop;
      velocityY = 0;
    }

    // move obs
    obsX -= obsSpeed;

    // respawn obs
    if (obsX + obsW < 0) {
      resetObstacle();
    }

    // collision detection
    if (checkCollision()) {
      respGameOver = true;
    }
  }

  // draw obs
  fill(100, 100, 100);
  noStroke();
  rect(obsX, obsY, obsW, obsH, 10);

  // draw char
  image(breathChar, charX, charY);

  // instructions
  fill(0);
  textAlign(LEFT, TOP);
  textSize(15);
  String instructions = 
    "Respiration Game\n" +
    "Inhale → character jumps\n" +
    "Exhale → character falls with gravity\n" +
    "(click to go back)";
  text(instructions, 20, 20);

  // game over message
  if (respGameOver) {
    fill(0, 100);
    rect(0, 0, width, height);  // dark overlay

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("GAME OVER\n(click to return to menu)", width/2, height/2);
  }
}

// RSP COLLISION CHECK
boolean checkCollision() {
  float charW = breathChar.width;
  float charH = breathChar.height;

  // Axis-aligned bounding box collision
  boolean overlapX = charX < obsX + obsW && charX + charW > obsX;
  boolean overlapY = charY < obsY + obsH && charY + charH > obsY;

  return overlapX && overlapY;
}

// EMG GAME
void resetEmgGame() {
  emgRemaining = emgTotal;
  emgDone = false;
  emgCanRemove = true;
}

void emgGame() {
  // EMG bg
  image(emgBG, 0, 0, width, height);

  // EMG control
  if (!emgDone) {
    if (sensorValue > emgThreshold && emgCanRemove) {
      emgRemaining--;
      emgCanRemove = false;

      if (emgRemaining <= 0) {
        emgRemaining = 0;
        emgDone = true;
      }
    }

    if (sensorValue <= emgThreshold) {
      emgCanRemove = true;
    }
  }

  // draw remaining chars
  int spacing = 90;
  int startX = (width - (emgTotal * spacing)) / 2;
  int y = height/2;

  for (int i = 0; i < emgRemaining; i++) {
    int x = startX + i * spacing;
    image(emgChar, x, y);
  }

  // instructions
  fill(0);
  textAlign(CENTER, TOP);
  textSize(18);
  String instructions = 
    "EMG Game\n" +
    "Bend your arm → removes 1 character\n" +
    "(click to go back)";
  text(instructions, 600, 40);

  // completion message
  if (emgDone) {
    fill(0, 120);
    rect(0, 0, width, height);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("WELL DONE!\nAll EMG characters cleared\n(click to return to menu)", width/2, height/2);
  }
}
