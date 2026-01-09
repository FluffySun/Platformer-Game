class Goomba extends Enemy{
PImage[]frames=new PImage[2];
int frame=0;
int frameDelay=15;
int frameCount=0;

Goomba(float x,float y,Level lvl){
super(x,y,26,26,lvl);
vx=-1.2;
frames[0]=loadImage("goomba0.png");
frames[1]=loadImage("goomba1.png");
}

void update(){
if(!alive)return;
vy+=gravity;
x+=vx;
if(colliding()){
x-=vx;
vx*=-1;
}
y+=vy;
if(colliding()){
y-=vy;
vy=0;
}
float frontX=(vx>0)?(x+w+1):(x-1);
float footY=y+h+1;
if(!level.isSolid(frontX,footY)){
vx*=-1;
}
updateAnimation();
cameraCull();
}

void updateAnimation(){
frameCount++;
if(frameCount>=frameDelay){
frame=(frame+1)%frames.length;
frameCount=0;
}
}

void display(){
if(!alive)return;
image(frames[frame],x,y,w,h);
}

boolean colliding(){
return level.isSolid(x,y+h)||
level.isSolid(x+w,y+h)||
level.isSolid(x,y)||
level.isSolid(x+w,y);
}

void die(){
alive=false;
}
}
