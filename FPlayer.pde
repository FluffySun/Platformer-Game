//Mario Game 

//Some problems (1.7 after add terrains):
/*
1) Portal X Work anymore, redeem it
2) Dead pink skull gone+X work anymore, redeem it
3) Tree center image should not be needed because the tree mid is enough, so instead of 5 pixels, 4 pixels enough (T shape), delete
png named "treetop_center"
4) How to set friction higher than default for ground.png and if it is already relatively high compared to ice then
->no need to change anything
5) The requirements are "a trampoline has higher restitution", what does that mean and am I already doing it?
6) Fancy Terrain will require a new class that extends FBox, and all the Fancy Terrain objects will need to
be put into an arrayList and processed by a loop. :
This includes 2 things:
1. (Right now, write this code for me) Collapsing Bridge: This simulates the classic platform that falls when the player jumps on it. 
When the player touches a collapsing bridge, it sets its static property to false, and therefore it falls.
-> I am using the color #cba3e9 to represent this 3 pixel set of bridges (there can be multiple sets, but all will be multiples
of 3 pixels so it looks complete, repeat same pattern order)
-> load those pictures of rails that do not collide with players on top of the bridges in the pattern of 3 pngs as well
-> the color i use to represent the rails that you should detect are #
-> names of those are from left to right: "bridgeRails_e.png", "bridgeRails_center.png", "bridgeRails_w.png".
-> The png pictures that your should load are in the below names in the order of from left to right:
-> "bridge_e.png", "bridge_center.png", "bridge_w.png".
-> here is demo code of what my friend used to do the bridges:
"class FBridge extends FGameobject {
FHammerBro
FBridge (float x, float y) {
super ();
setPosition(X, y) ; setName ("bridge");
attachImage (bridgeCenter);
setstatic (true);
FLava
FPlayer
FThwomp
void act) {
if (isTouching ("player")) (
setStatic(false);
setSensor (true);
}}}"
-> End here.

2. (I already have this, but not sure if it matches the requirements)
Lava: Lava is a kind of animated block - it should cycle through a particular set of images 
(perhaps stored in a global array), attaching the images sequentially over time to create the bubbling lava animation. 
Make each lava block start at a random index in the array so as to offset the animations. 
Lava is dangerous terrain, regardless of the current image attached.

More Problems (1.8 detected):
Basic Terrain does not require a new class nor does it have any unique code; 
it is just a standard FBox with specific properties set. 
For all properties, be sure to use setName() to make collision detection easy in the future.

i want to finish all terrains first

Idea (New):
1) Dirt boxes that are sideways/upside down can be used for level 2/3 if i want player to move in anti-gravity way

*/

//character selection 
/*
select the button
set the run/idle to the character name
*/

//suggestions for savepoint:
/*
spawn x y point whenever detect touch the block,
make the block change colors/flash to make it known
->another png copy

use true/false to set the before blocks off
->so even if go back, spawn at latest block

.getX(), .getY()
+gridSize

X is for when detect under
Y is for avoid when player on top of block

5X gridSize

setStatic back to true when rising
set mode back to waiting again

if mouseX/rectangle statements that detect the place
player replace the .X

*/

//1.5:
/*
1. Finish all terrains 
1)lava move/kill
->i have multiple pictures of lava
with numbers of the sequence
from 1-6 named like lava1.png...
->i use this color #d4ffbd for lava,
please help me incorporate this so when it
detects this color, load the image of the moving lava

2)tramploline should exhibit the behavior of
->when player steps on it it should bounce the player
up vertically.
->i used this color #6bd5ff
->the png is named just trampoline.png

3)ice slippery
->when player step and move on it the friction
should be less than if on the ground
->i used color #bdf3ef
->image called ice.png

4)Spike
->attaching an image
same function as the death thing for now
i used this color #46992f in the map so when detect it
->load the image called spike.png

5) tree
tree has different pngs that make it up
im using the color #36fc8f in the map to help you detect where to put it
tree mid is the middle part
tree trunk is the bottom
treetop_left, treetop_center, treetop_right are the top parts
put them all in one (doesn't have to be 1 pixel
can be slightly bigger, i put 5 pixels together in a T shape for this)
note: tree shouldn't collide with player, all others should

6) water
flowing images, recurring the loop to make it look like
the water is moving
there are 4 images connected
named like water1.png to water4.png
->i used the color #2f3e99
->there will be functions of water "sinking" but for now
just set it to same function as dead to make it simpler

7) collapsing bridge
not do yet

2. Finish all enemies
face change thwomp 
moving hammer bro?

Thwomp->
own mode framework
2X tall+wide as block
thwompMode
waiting=0
falling=1
rising=2

3. Advanced
Level select?
Or level advance 1 by 1
>=2 levels

->REQUIREMENT
Focus on >= 3 bullet points
GO DEEP

NPC ideas:
- retrieve object
*/

float camX=0;

//Modes
final int INTRO= 0;
final int GAME= 1;
final int PAUSE = 2;
final int GAMEOVER = 3;

int mode= INTRO;

//Level system
Level[] levels;
int currentLevel= 0;

//Character Select
int selectedCharacter=-1;
Button charBtn1, charBtn2, charBtn3, startBtn;

//UI
Button nextLevelBtn;
Button restartBtn;

//Input
boolean leftKey, rightKey;

//Setup
void setup() {
  size(800, 500);
  textSize(22);
  rectMode(CORNER);

  charBtn1= new Button(150, 260, 140, 50, "MARIO");
  charBtn2= new Button(330, 260, 140, 50, "LUIGI");
  charBtn3= new Button(510, 260, 140, 50, "TOAD");
  startBtn= new Button(width/2 - 75, 330, 150, 50, "START");

  levels= new Level[3];
  levels[0]= new Level(1);
  levels[1]= new Level(2);
  levels[2]= new Level(3);

  nextLevelBtn= new Button(width/2 - 90, height/2 + 60, 180, 50, "NEXT LEVEL");
  restartBtn= new Button(width/2 - 100, height/2 + 60, 200, 50, "BACK TO INTRO");
}

//Draw
void draw() {
  if (mode==INTRO) introScreen();
  else if (mode==GAME) gameScreen();
  else if (mode==PAUSE) pauseScreen();
  else if (mode==GAMEOVER) gameOverScreen();
}

//Intro
void introScreen() {
  background(100, 180, 255);
  fill(0);
  textAlign(CENTER);

  text("MARIO GAME", width/2, 80);
  text("Select Your Character", width/2, 140);

  charBtn1.display();
  charBtn2.display();
  charBtn3.display();

  if (charBtn1.isClicked()) { 
  selectedCharacter= 0; delay(150); 
  }
  if (charBtn2.isClicked()) { 
  selectedCharacter= 1; delay(150); 
  }
  if (charBtn3.isClicked()) { 
  selectedCharacter= 2; delay(150); }

  stroke(255, 0, 0);
  noFill();
  if (selectedCharacter== 0) rect(charBtn1.x, charBtn1.y, charBtn1.w, charBtn1.h, 10);
  if (selectedCharacter== 1) rect(charBtn2.x, charBtn2.y, charBtn2.w, charBtn2.h, 10);
  if (selectedCharacter== 2) rect(charBtn3.x, charBtn3.y, charBtn3.w, charBtn3.h, 10);
  noStroke();

  if (selectedCharacter!= -1) {
    startBtn.display();
    if (startBtn.isClicked()) {
      currentLevel= 0;
      camX= 0;   
      levels[currentLevel].reset();
      mode= GAME;
      delay(200);
    }
  }
}

//Game
void gameScreen() {
  background(135, 206, 235);

  Level lvl= levels[currentLevel];

//camera follow
  float playerCenterX= lvl.player.x+lvl.player.w/2;
  float pushLine=camX + width * 0.6;

  if (playerCenterX>pushLine) {
    camX=playerCenterX-width*0.6;
  }

  camX=max(camX, 0);

//draw world
  pushMatrix();
  translate(-camX, 0);

  lvl.display();
  lvl.update();

  popMatrix();

//UI
  fill(0);
  textAlign(CENTER);
  text("LEVEL "+lvl.id, width/2, 30);
  text("Press SPACE to Pause", width/2, 55);

  if (lvl.cleared) {
    fill(0, 160);
    rect(0, 0, width, height);
    fill(255);
    text("LEVEL CLEARED!", width/2, height/2-40);

    if (currentLevel < levels.length-1) {
      nextLevelBtn.display();
      if (nextLevelBtn.isClicked()) {
        currentLevel++;
        camX=0;                
        levels[currentLevel].reset();
        delay(200);
      }
    } else {
      mode= GAMEOVER;
      delay(300);
    }
  }

  if (keyPressed && key == ' ') {
    mode=PAUSE;
    delay(200);
  }
}

void pauseScreen() {
  background(0, 160);
  fill(255);
  textAlign(CENTER);

  text("PAUSED", width/2, height/2);
  text("Press SPACE to Resume", width/2, height/2+40);

  if (keyPressed && key==' ') {
    mode=GAME;
    delay(200);
  }
}

//GAME OVER
void gameOverScreen() {
  background(0);
  fill(255, 0, 0);
  textAlign(CENTER);

  text("GAME OVER", width/2, height/2-80);

  restartBtn.display();
  if (restartBtn.isClicked()) {
    selectedCharacter=-1;
    currentLevel=0;
    camX=0;                   
    mode=INTRO;
    delay(200);
  }
}

//INPUT
void keyPressed() {
  if (key=='a'||key=='A'||keyCode==LEFT)  
  leftKey=true;
  if (key=='d'||key=='D'||keyCode==RIGHT) 
  rightKey=true;
  if ((key=='w'||key=='W'||keyCode==UP) && mode==GAME) {
    levels[currentLevel].player.jump();
  }
}

void keyReleased() {
  if (key=='a'||key=='A'||keyCode==LEFT)  
  leftKey=false;
  if (key=='d'||key=='D'||keyCode==RIGHT) 
  rightKey=false;
}
