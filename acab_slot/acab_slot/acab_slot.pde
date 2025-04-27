PImage[] images = new PImage[4];
String[] symbols = {"Marul", "1312", "Kelepçe", "Kamera"};
int[] slots = new int[4];
float[] offsets = new float[4];
float[] speeds = new float[4];
boolean[] spinning = {false, false, false, false};
int[] stopTimers = {0, 0, 0, 0};
int stopDelay = 60;

long balance = -128000000000L;
int spinCost = 10000;

PFont font;

ArrayList<Particle> particles = new ArrayList<Particle>();
boolean flashScreen = false;
color flashColor;
int flashTimer = 0;

void setup() {
  fullScreen();
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  
  font = createFont("Arial", 32);
  textFont(font);

  images[0] = loadImage("marul.png");
  images[1] = loadImage("1312.png");
  images[2] = loadImage("kelepce.png");
  images[3] = loadImage("kamera.png");
  
  for (int i = 0; i < 4; i++) {
    slots[i] = parseInt(random(symbols.length));
    offsets[i] = 0;
    speeds[i] = 0;
  }
}

void draw() {
  drawBackground();
  
  int slotWidth = width / 6;
  int slotHeight = height / 3;
  
  for (int i = 0; i < 4; i++) {
    float x = (i+1.5) * slotWidth;
    float y = height/2;
    
    pushMatrix();
    translate(x, y + offsets[i]);
    
    image(images[slots[i]], 0, 0, slotWidth * 0.6, slotHeight * 0.6);
    image(images[(slots[i]+1)%images.length], 0, -slotHeight, slotWidth * 0.6, slotHeight * 0.6);
    
    popMatrix();
    
    drawSlotFrame(x, y, slotWidth, slotHeight, spinning[i]);
  }
  
  drawParticles();
  drawFlash();
  updateSpinning();
  drawBalance();
}

void keyPressed() {
  if (key == ' ' && !isAnySpinning()) {
    balance -= spinCost;
    for (int i = 0; i < 4; i++) {
      spinning[i] = true;
      speeds[i] = random(30, 40); // sabit hızlar
      stopTimers[i] = (i+1) * stopDelay;
    }
  }
}

void updateSpinning() {
  for (int i = 0; i < 4; i++) {
    if (spinning[i]) {
      offsets[i] += speeds[i];
      
      if (offsets[i] >= height/3) {
        offsets[i] = 0;
        slots[i] = parseInt(random(symbols.length));
      }
      
      stopTimers[i]--;
      if (stopTimers[i] <= 0) {
        spinning[i] = false;
        offsets[i] = 0;
      }
    }
  }
  
  if (!isAnySpinning()) {
    checkWin();
  }
}

void checkWin() {
  if (symbols[slots[0]] == "Marul" && symbols[slots[1]] == "Marul" &&
      symbols[slots[2]] == "Marul" && symbols[slots[3]] == "Marul") {
    balance += 5000000;
    flashEffect(color(0, 255, 0));
  }
  else if (countSymbol("Marul") == 3) {
    balance += 500000;
    flashEffect(color(0, 200, 0));
  }
  else if (allSame()) {
    balance += 1000000;
    flashEffect(color(255, 215, 0));
  }
  else if (anyThreeSame()) {
    balance += 100000;
    flashEffect(color(100, 100, 255));
  }
}

boolean anyThreeSame() {
  for (int i = 0; i < symbols.length; i++) {
    int count = 0;
    for (int j = 0; j < 4; j++) {
      if (symbols[slots[j]] == symbols[i]) {
        count++;
      }
    }
    if (count == 3) {
      return true;
    }
  }
  return false;
}

boolean allSame() {
  return (symbols[slots[0]] == symbols[slots[1]] &&
          symbols[slots[1]] == symbols[slots[2]] &&
          symbols[slots[2]] == symbols[slots[3]]);
}

int countSymbol(String symbol) {
  int count = 0;
  for (int i = 0; i < 4; i++) {
    if (symbols[slots[i]] == symbol) {
      count++;
    }
  }
  return count;
}

boolean isAnySpinning() {
  for (boolean s : spinning) {
    if (s) return true;
  }
  return false;
}

void flashEffect(color c) {
  flashScreen = true;
  flashColor = c;
  flashTimer = 10;

  for (int i = 0; i < 100; i++) {
    particles.add(new Particle(random(width), random(height/2), random(-5,5), random(-5,5), color(255, 215, 0)));
  }
}

void drawFlash() {
  if (flashScreen) {
    fill(flashColor, map(flashTimer, 10, 0, 150, 0));
    rect(0, 0, width, height);
    flashTimer--;
    if (flashTimer <= 0) {
      flashScreen = false;
    }
  }
}

void drawParticles() {
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
}

class Particle {
  float x, y;
  float vx, vy;
  color c;
  float lifespan = 255;

  Particle(float x, float y, float vx, float vy, color c) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.c = c;
  }

  void update() {
    x += vx;
    y += vy;
    lifespan -= 5;
  }

  void display() {
    noStroke();
    fill(c, lifespan);
    ellipse(x, y, 8, 8);
  }

  boolean isDead() {
    return lifespan < 0;
  }
}

void drawSlotFrame(float x, float y, int w, int h, boolean glow) {
  strokeWeight(6);
  if (glow) {
    stroke(255, 215, 0, 200); 
  } else {
    stroke(255, 215, 0, 100);
  }
  noFill();
  rectMode(CENTER);
  rect(x, y, w * 0.8, h, 20);
}


void drawBackground() {
  noFill();
  for (int i = 0; i < height; i++) {
    stroke(lerpColor(color(30,0,50), color(0,0,0), float(i)/height));
    line(0, i, width, i);
  }
}


void drawBalance() {
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Bakiye: " + balance + " TL", width/2, height - 40);
  
  textSize(20);
  text("! HER SPIN 10.000₺ !", width/2, height - 10);
}
