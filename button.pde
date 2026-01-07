class Button{
float x,y,w,h;
String label;

Button(float x,float y,float w,float h,String label){
this.x=x;
this.y=y;
this.w=w;
this.h=h;
this.label=label;
}

boolean isHover(){
return mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+h;
}

void display(){
if(isHover())fill(220);
else fill(180);
rect(x,y,w,h,10);
fill(0);
textAlign(CENTER,CENTER);
text(label,x+w/2,y+h/2);
}

boolean isClicked(){
return isHover()&&mousePressed;
}
}
