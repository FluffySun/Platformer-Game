class Player{
float x,y;
float w=24,h=32;
float vx=0,vy=0;
float speed=3;
float gravity=0.7;
float jumpForce=-10;
boolean onGround=false;
boolean justTeleported=false;
boolean facingRight=true;
Level level;

// animation omitted for brevity (UNCHANGED)
PImage[]idleR=new PImage[2];
PImage idleL,jumpL,jumpR;
PImage[]runR=new PImage[3];
PImage[]runL=new PImage[3];
int frame=0,frameDelay=8,frameCountAnim=0;

Player(float x,float y,Level lvl){
this.x=x;this.y=y;this.level=lvl;
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
boolean onIce=level.isIce(x+w/2,y+h+1);
float accel=onIce?0.15:0.5;
float maxSpeed=onIce?2.2:3;

if(leftKey){vx=max(vx-accel,-maxSpeed);facingRight=false;}
else if(rightKey){vx=min(vx+accel,maxSpeed);facingRight=true;}
else if(!onIce)vx=0;

x+=vx;
if(colliding())x-=vx;

vy+=gravity;
y+=vy;

if(colliding()){
y-=vy;
if(level.isTrampoline(x+w/2,y+h+1))vy=-15;
else vy=0;
onGround=true;
}else onGround=false;

// death tiles
if(level.isDead(x+w/2,y+h/2)){mode=GAMEOVER;return;}

// endpoint
if(level.isEndPoint(x+w/2,y+h/2))level.cleared=true;

// portal
if(level.isPortal(x+w/2,y+h/2)){
if(!justTeleported){
PVector d=level.getNextPortal(new PVector(x+w/2,y+h/2));
if(d!=null){x=d.x;y=d.y-20;vx=vy=0;justTeleported=true;}
}
}else justTeleported=false;

// enemies (unchanged)
for(Enemy e:level.enemies){
if(!e.alive)continue;
if(e.intersects(this)){
if(e.stompedBy(this)){e.alive=false;vy=jumpForce*0.7;}
else{mode=GAMEOVER;return;}
}
}

updateAnimation();
}

void updateAnimation(){
frameCountAnim++;
if(frameCountAnim>=frameDelay){frame++;frameCountAnim=0;}
}

void display(){
PImage img;
if(!onGround)img=facingRight?jumpR:jumpL;
else if(vx>0)img=runR[frame%runR.length];
else if(vx<0)img=runL[frame%runL.length];
else img=facingRight?idleR[frame%idleR.length]:idleL;
image(img,x,y,w,h);
}

void jump(){if(onGround)vy=jumpForce;}

boolean colliding(){
return level.isSolid(x,y+h)||level.isSolid(x+w,y+h);
}
}
