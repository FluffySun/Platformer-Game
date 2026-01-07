abstract class Enemy{
float x,y,w,h;
float vx=0;
float vy=0;
float gravity=0.7;
boolean alive=true;
Level level;

Enemy(float x,float y,float w,float h,Level lvl){
this.x=x;
this.y=y;
this.w=w;
this.h=h;
this.level=lvl;
}

abstract void update();
abstract void display();

boolean intersects(Player p){
return(p.x<x+w&&p.x+p.w>x&&p.y<y+h&&p.y+p.h>y);
}

boolean stompedBy(Player p){
float pBottomPrev=p.y+p.h-p.vy;
float pBottomNow=p.y+p.h;
boolean falling=p.vy>0;
boolean withinX=(p.x+p.w>x)&&(p.x<x+w);
boolean crossedTop=(pBottomPrev<=y)&&(pBottomNow>=y);
return falling&&withinX&&crossedTop;
}

void cameraCull(){
if(x+w<camX-50){
alive=false;
}
}
}
