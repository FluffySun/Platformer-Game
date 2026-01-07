class Hammer{
float x,y;
float w=14;
float h=14;
float vx,vy;
float gravity=0.6;
boolean alive=true;
Level level;
PImage img;

Hammer(float x,float y,float vx,float vy,Level lvl){
this.x=x;
this.y=y;
this.vx=vx;
this.vy=vy;
this.level=lvl;
img=loadImage("hammer.png");
}

void update(){
if(!alive)return;
vy+=gravity;
x+=vx;
y+=vy;
if(level.isSolid(x,y+h)||
level.isSolid(x+w,y+h)||
level.isSolid(x,y)||
level.isSolid(x+w,y)){
alive=false;
}
if(x+w<camX||x>camX+width+50){
alive=false;
}
}

void display(){
if(!alive)return;
image(img,x,y,w,h);
}

boolean hits(Player p){
return(p.x<x+w&&p.x+p.w>x&&p.y<y+h&&p.y+p.h>y);
}
}
