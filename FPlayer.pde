// Mario Game

// ================== Shared images (enemies) ==================
PImage hammerSharedImage;
PImage[] goombaSharedFrames;

PImage thwompIdleSharedImage;
PImage thwompMovingSharedImage;

PImage[] hammerBroSharedFrames;

// ================== Camera ==================
float camX = 0;

// ================== Character image cache ==================
import java.util.HashMap;

HashMap<String, PImage> imgCache = new HashMap<String, PImage>();

PImage getImg(String filename) {
  PImage img = imgCache.get(filename);
  if (img == null) {
    img = loadImage(filename);
    imgCache.put(filename, img);
  }
  return img;
}

// 0 = mario, 1 = luigi, 2 = toad
String getCharacterPrefix() {
  if (selectedCharacter == 1) return "luigi";
  if (selectedCharacter == 2) return "toad";
  return "mario";
}

// ================== Character tuning (optional) ==================
final float MARIO_SPEED = 3;
final float LUIGI_JUMP = -12;
final float TOAD_SPEED = 4.5;

// ================== Lives ==================
final int MAX_LIVES = 3;
int lives = MAX_LIVES;

// ================== Modes ==================
final int INTRO = 0;
final int GAME = 1;
final int PAUSE = 2;
final int GAMEOVER = 3;

int mode = INTRO;

// ================== Level system ==================
Level[] levels;
int currentLevel = 0;

// ================== Character select ==================
int selectedCharacter = -1;
Button charBtn1, charBtn2, charBtn3, startBtn;

// ================== UI ==================
Button nextLevelBtn;
Button restartBtn;

// ================== Input ==================
boolean leftKey, rightKey;

// ==================================================
// SETUP
// ==================================================
void setup() {
  size(800, 500);
  textSize(22);
  rectMode(CORNER);

  charBtn1 = new Button(150, 260, 140, 50, "MARIO");
  charBtn2 = new Button(330, 260, 140, 50, "LUIGI");
  charBtn3 = new Button(510, 260, 140, 50, "TOAD");
  startBtn = new Button(width / 2 - 75, 330, 150, 50, "START");

  levels = new Level[3];
  levels[0] = new Level(1);
  levels[1] = new Level(2);
  levels[2] = new Level(3);

  nextLevelBtn = new Button(width / 2 - 90, height / 2 + 60, 180, 50, "NEXT LEVEL");
  restartBtn = new Button(width / 2 - 100, height / 2 + 60, 200, 50, "BACK TO INTRO");
}

// ==================================================
// DRAW
// ==================================================
void draw() {
  resetMatrix();

  if (mode == INTRO) {
    introScreen();
  } else if (mode == GAME) {
    gameScreen();
  } else if (mode == PAUSE) {
    pauseScreen();
  } else if (mode == GAMEOVER) {
    gameOverScreen();
  }
}

// ==================================================
// INTRO
// ==================================================
void introScreen() {
  camX = 0;

  background(100, 180, 255);
  fill(0);
  textAlign(CENTER);

  text("MARIO GAME", width / 2, 80);
  text("Select Your Character", width / 2, 140);

  charBtn1.display();
  charBtn2.display();
  charBtn3.display();

  if (charBtn1.isClicked()) {
    selectedCharacter = 0;
    delay(150);
  }
  if (charBtn2.isClicked()) {
    selectedCharacter = 1;
    delay(150);
  }
  if (charBtn3.isClicked()) {
    selectedCharacter = 2;
    delay(150);
  }

  stroke(255, 0, 0);
  noFill();
  if (selectedCharacter == 0) rect(charBtn1.x, charBtn1.y, charBtn1.w, charBtn1.h, 10);
  if (selectedCharacter == 1) rect(charBtn2.x, charBtn2.y, charBtn2.w, charBtn2.h, 10);
  if (selectedCharacter == 2) rect(charBtn3.x, charBtn3.y, charBtn3.w, charBtn3.h, 10);
  noStroke();

  if (selectedCharacter != -1) {
    startBtn.display();
    if (startBtn.isClicked()) {
      currentLevel = 0;
      lives = MAX_LIVES;
      camX = 0;

      levels[currentLevel].reset();
      syncCameraToPlayer(levels[currentLevel]);

      mode = GAME;
      delay(200);
    }
  }
}

// ==================================================
// KILL / RESPAWN
// ==================================================
void killPlayer() {
  if (mode != GAME) return;

  lives--;

  if (lives <= 0) {
    mode = GAMEOVER;
    return;
  }

  Level lvl = levels[currentLevel];
  lvl.respawnPlayer();
  syncCameraToPlayer(lvl);
}

void syncCameraToPlayer(Level lvl) {
  float playerCenterX = lvl.player.x + lvl.player.w / 2.0;
  float targetCamX = playerCenterX - width * 0.5;
  float maxCamX = max(0, lvl.getWorldWidthPx() - width);
  camX = constrain(targetCamX, 0, maxCamX);
}

// ==================================================
// GAME
// ==================================================
void gameScreen() {
  background(135, 206, 235);

  Level lvl = levels[currentLevel];

  // -------- CAMERA FOLLOW (free left/right) --------
  float playerCenterX = lvl.player.x + lvl.player.w / 2;
  float targetCamX = playerCenterX - width * 0.5;
  float maxCamX = max(0, lvl.getWorldWidthPx() - width);
  camX = constrain(targetCamX, 0, maxCamX);

  // -------- WORLD --------
  pushMatrix();
  translate(-camX, 0);

  lvl.update();
  lvl.display();

  popMatrix();

  // -------- UI --------
  fill(0);
  textAlign(LEFT);
  text("Lives: " + lives, 12, 28);

  textAlign(CENTER);
  text("LEVEL " + lvl.id, width / 2, 30);
  text("Press SPACE to Pause", width / 2, 55);

  if (lvl.cleared) {
    fill(0, 160);
    rect(0, 0, width, height);
    fill(255);
    text("LEVEL CLEARED!", width / 2, height / 2 - 40);

    if (currentLevel < levels.length - 1) {
      nextLevelBtn.display();
      if (nextLevelBtn.isClicked()) {
        currentLevel++;
        camX = 0;
        levels[currentLevel].reset();
        syncCameraToPlayer(levels[currentLevel]);
        delay(200);
      }
    } else {
      mode = GAMEOVER;
      delay(300);
    }
  }

  if (keyPressed && key == ' ') {
    mode = PAUSE;
    delay(200);
  }
}

// ==================================================
// PAUSE
// ==================================================
void pauseScreen() {
  background(0, 160);
  fill(255);
  textAlign(CENTER);

  text("PAUSED", width / 2, height / 2);
  text("Press SPACE to Resume", width / 2, height / 2 + 40);

  if (keyPressed && key == ' ') {
    mode = GAME;
    delay(200);
  }
}

// ==================================================
// GAME OVER
// ==================================================
void gameOverScreen() {
  camX = 0;

  background(0);
  fill(255, 0, 0);
  textAlign(CENTER);

  text("GAME OVER", width / 2, height / 2 - 80);

  restartBtn.display();
  if (restartBtn.isClicked()) {
    selectedCharacter = -1;
    currentLevel = 0;
    camX = 0;
    mode = INTRO;
    delay(200);
  }
}

// ==================================================
// INPUT
// ==================================================
void keyPressed() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) leftKey = true;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) rightKey = true;

  if ((key == 'w' || key == 'W' || keyCode == UP) && mode == GAME) {
    levels[currentLevel].player.jump();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) leftKey = false;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) rightKey = false;
}
