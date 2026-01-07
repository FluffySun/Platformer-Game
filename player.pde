class Player{
float x,y;
float w=24;
float h=32;
float vx=0;
float vy=0;
float speed=3;
float gravity=0.7;
float jumpForce=-10;
boolean onGround=false;
boolean justTeleported=false;
boolean facingRight=true;
Level level;
PImage[]idleR=new PImage[2];
PImage idleL;
PImage jumpL,jumpR;
PImage[]runR=new PImage[3];
PImage[]runL=new PImage[3];
int frame=0;
int frameDelay=8;
int frameCountAnim=0;

Player(float x,float y,Level lvl){
this.x=x;
this.y=y;
this.level=lvl;
idleR[0]=loadImage("idle0.png");
idleR[1]=loadImage("idle1.png");
idleL=loadImage("idle2.png");
jumpR=loadImage("jump0.png");
jumpL=loadImage("jump1.png");
runR[0]=loadImage("runright0.png");
runR[1]=loadImage("runright1.png");
runR[2]=loadImage("runright2.png");
runL[0]=loadImage("runleft0.png");
runL[1]=loadImage("runleft1.png");
runL[2]=loadImage("runleft2.png");
}

void update(){
if(leftKey){
vx=-speed;
facingRight=false;
}else if(rightKey){
vx=speed;
facingRight=true;
}else{
vx=0;
}
x+=vx;
if(colliding())x-=vx;
if(x<camX)x=camX;
vy+=gravity;
y+=vy;
if(colliding()){
y-=vy;
vy=0;
onGround=true;
}else onGround=false;
float cx=x+w/2;
float cy=y+h/2;
if(level.isDead(cx,cy)){
mode=GAMEOVER;
return;
}
if(level.isEndPoint(cx,cy)){
level.cleared=true;
}
if(level.isPortal(cx,cy)){
if(!justTeleported){
PVector dest=level.getNextPortal(new PVector(cx,cy));
if(dest!=null){
x=dest.x;
y=dest.y-20;
vx=0;
vy=0;
justTeleported=true;
}
}
}else justTeleported=false;
for(Enemy e:level.enemies){
if(!e.alive)continue;
if(e.intersects(this)){
if(e.stompedBy(this)){
if(e instanceof Goomba)((Goomba)e).die();
if(e instanceof HammerBro)((HammerBro)e).die();
vy=jumpForce*0.7;
}else{
mode=GAMEOVER;
return;
}
}
}
for(Enemy e:level.enemies){
if(e instanceof HammerBro){
HammerBro hb=(HammerBro)e;
for(Hammer hm:hb.hammers){
if(hm.alive&&hm.hits(this)){
mode=GAMEOVER;
return;
}
}
}
}
updateAnimation();
}

void updateAnimation(){
frameCountAnim++;
if(frameCountAnim>=frameDelay){
frame++;
frameCountAnim=0;
}
}

void display(){
PImage img;
if(!onGround){
img=facingRight?jumpR:jumpL;
}else if(vx>0){
img=runR[frame%runR.length];
}else if(vx<0){
img=runL[frame%runL.length];
}else{
img=facingRight?idleR[frame%idleR.length]:idleL;
}
image(img,x,y,w,h);
}

void jump(){
if(onGround)vy=jumpForce;
}

boolean colliding(){
return level.isSolid(x,y+h)||
level.isSolid(x+w,y+h)||
level.isSolid(x,y)||
level.isSolid(x+w,y);
}

void resetToSpawn(){
if(level.checkpointX!=-1){
x=level.checkpointX;
y=level.checkpointY-20;
}else{
x=level.spawnX;
y=level.spawnY-20;
}
vx=0;
vy=0;
justTeleported=false;
}
}
