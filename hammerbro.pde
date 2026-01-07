class HammerBro extends Enemy{
ArrayList<Hammer>hammers=new ArrayList<Hammer>();
PImage[]frames=new PImage[2];
int frame=0;
int frameDelay=20;
int frameCount=0;
int jumpTimer=0;
int throwTimer=0;

HammerBro(float x,float y,Level lvl){
super(x,y,28,36,lvl);
frames[0]=loadImage("hammerbro0.png");
frames[1]=loadImage("hammerbro1.png");
}

void update(){
if(!alive)return;
vy+=gravity;
y+=vy;
if(colliding()){
y-=vy;
vy=0;
}
jumpTimer++;
if(jumpTimer>90){
vy=-9;
jumpTimer=0;
}
throwTimer++;
if(throwTimer>60){
throwHammer();
throwTimer=0;
}
for(Hammer h:hammers)h.update();
for(int i=hammers.size()-1;i>=0;i--){
if(!hammers.get(i).alive)hammers.remove(i);
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

void throwHammer(){
float dir=(level.player.x<x)?-1:1;
hammers.add(new Hammer(x+w/2,y,dir*3,-8,level));
}

void display(){
if(!alive)return;
image(frames[frame],x,y,w,h);
for(Hammer h:hammers)h.display();
}

boolean colliding(){
return level.isSolid(x,y+h)||level.isSolid(x+w,y+h);
}

void die(){
alive=false;
}
}
