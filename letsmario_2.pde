// Mario Game

//Notes 1.12:
/*
1.13:

//
fix the collasping bridges function
- the bridges disappears and does not reset after the 1st try when i return, I want to make it so it resets every time i return to start again
//

LEFT:

1.
Mode framework: Create an intro screen, game over screen, and pause screen for this project. 
Use animated gifs, custom fonts, and tactile buttons to navigate.

Sound effects: Games are always made more immersive by adding sound effects for jumping, dying, bopping enemies, and the like.

Level design: Create interesting levels that inspire fun game play! Levels can be puzzles (think Fire Boy and Water Girl), tell a story, challenging and fun but not too frustrating.

Code Quality: Find ways to improve your class design, break your code into functions, and write DRY code.

Read my code attached and now i want to add 2 things:
New 'fancy' terrain features such as:

1) A switch block function (I am using the color: #520091 for the blocking object to load the png named "switch.png" and the color #7d0075 to load the png named "switched.png" that represents what you detect on the map as switches (connected to the blocking object named "door.png" which collides with player like the ground), i want the function to be that once the player interacts (collides) with the switch object and the image switches from "switch.png" to "switched.png", then the blocking object disappears (don't forget to reset all of this back).

A switch block that the player can activate and deactivate. 
The state of the switch controls some other aspect of the world (alters gravity, changes the state of another FBox, etc). 
Switches can also become part of an interesting puzzle, like in Fire Boy and Water Girl. 

Switchblocks:
- lever
-> reverse image+change color
- door open close
- sensor 
-> 2 for loops
-> if statements
- could link this to quests+storylines

2)
A savepoint block that, when you touch it, becomes active and all other savepoint blocks become inactive. 
I already have the png and the object in place, just that the object is not working, the color detected on the map is "#ffff00", the load picture is called "checkpoint.png".
If you die, you will reappear at the location of the last savepoint block you touched. 
- you can use the spawn location x and y to do this, 
and don't forget to deactivate the previous checkpoints the player has already passed before they hit the current checkpoint
so the player can spawn at the most recent (most to the right) savepoint block that they collided with 
-> you can use detection of where the savepoint block is to make the judgement if the player touched it or not
- also remember to spawn a little higher than the ground, so it looks like the player dropped from the top.
//
3.
Quests and Storylines: 
Create NPCs that display text on the screen when you interact with them. 
They might ask you to fetch something for them. 
You can create items that can be collected when you touch them, and if you have the item, 
interacting with the NPC will do something new (give you a new item, unlock a door, etc)

Quests+Storylines:
- 1 character interaction
-> similar to enemies
- like finding lost dog
-> similar to hopping Goomba
- Collect in character backpack? or attach to player image?

- detect how far it was from someone
- zoom in scale
- type out letters
- just get a box to show up is amazing
- sensors on the side and up and down to see if it fits

4. New Modes: 
Add in new modes that affect gameplay. 
Maybe you invent a character selection screen that allows you to pick between different heroes 
that have different features in play. 
Or maybe you have a store mode that lets you spend coins that you collect to enhance your character.

5. Unique function (js make sure terrains+quest is good and do other stuff add up to 4 complex)
I can probably do an award treasure item using "treasure.png" load picture
and using the color # to represent on the map to be detected
I should also have a function in the end that counts the amt of coins the player collects
then generate an achievement
with a png/gif in the end of the game that determines which gif result to pull
based on the range of coins points the player is in

6. Notes on 1.16:
- make the checkpoint disappear after past it? (similar to collapse bridges function)

*/

// Shared images (used by enemies)
PImage hammerSharedImage;
PImage[] goombaSharedFrames;

PImage thwompIdleSharedImage;
PImage thwompMovingSharedImage;

PImage[] hammerBroSharedFrames;

float camX = 0;

// ---------------- MODES ----------------
final int INTRO = 0;
final int GAME = 1;
final int PAUSE = 2;
final int GAMEOVER = 3;

int mode = INTRO;

// ---------------- LEVEL SYSTEM ----------------
Level[] levels;
int currentLevel = 0;

// ---------------- CHARACTER SELECT ----------------
int selectedCharacter = -1;
Button charBtn1, charBtn2, charBtn3, startBtn;

// ---------------- UI ----------------
Button nextLevelBtn;
Button restartBtn;

// ---------------- INPUT ----------------
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
// DRAW (Important: resetMatrix call)
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
  if (selectedCharacter == 0) {
    rect(charBtn1.x, charBtn1.y, charBtn1.w, charBtn1.h, 10);
  }
  if (selectedCharacter == 1) {
    rect(charBtn2.x, charBtn2.y, charBtn2.w, charBtn2.h, 10);
  }
  if (selectedCharacter == 2) {
    rect(charBtn3.x, charBtn3.y, charBtn3.w, charBtn3.h, 10);
  }
  noStroke();

  if (selectedCharacter != -1) {
    startBtn.display();
    if (startBtn.isClicked()) {
      currentLevel = 0;
      camX = 0;
      levels[currentLevel].reset();
      mode = GAME;
      delay(200);
    }
  }
}

// ==================================================
// GAME
// ==================================================
void gameScreen() {
  background(135, 206, 235);

  Level lvl = levels[currentLevel];

  // -------- CAMERA FOLLOW --------
  float playerCenterX = lvl.player.x + lvl.player.w / 2;
  float pushLine = camX + width * 0.6;

  if (playerCenterX > pushLine) {
    camX = playerCenterX - width * 0.6;
  }
  camX = max(camX, 0);

  // -------- WORLD --------
  pushMatrix();
  translate(-camX, 0);

  lvl.update();
  lvl.display();

  popMatrix();

  // -------- UI --------
  fill(0);
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
  camX = 0;

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
  if (key == 'a' || key == 'A' || keyCode == LEFT) {
    leftKey = true;
  }
  if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    rightKey = true;
  }

  if ((key == 'w' || key == 'W' || keyCode == UP) && mode == GAME) {
    levels[currentLevel].player.jump();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) {
    leftKey = false;
  }
  if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    rightKey = false;
  }
}
