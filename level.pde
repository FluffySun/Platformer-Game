class Level{
int id;
boolean cleared=false;
final int TILE_EMPTY=0;
final int TILE_SOLID=1;
final int TILE_SPAWN=2;
final int TILE_GOAL=3;
final int TILE_DEAD=4;
final int TILE_CHECKPOINT=5;
final int TILE_PORTAL=6;
int[][]tiles;
int mapW,mapH;
int tileSize=32;
float spawnX=50;
float spawnY=50;
float checkpointX=-1;
float checkpointY=-1;
Player player;
ArrayList<PVector>portals=new ArrayList<PVector>();
ArrayList<Enemy>enemies=new ArrayList<Enemy>();
ArrayList<PVector>goombaSpawns=new ArrayList<PVector>();
ArrayList<PVector>hammerBroSpawns=new ArrayList<PVector>();
final color C_GOOMBA=color(255,0,255);
final color C_HAMMERBRO=color(255,128,0);
PImage groundTile;
PImage portalTile;
PImage goalTile;
PImage deadTile;
PImage checkpointTile;

Level(int id){
this.id=id;
PImage img=loadImage("map"+id+".png");
loadMapFromImage(img);
groundTile=loadImage("ground.png");
portalTile=loadImage("portal.png");
goalTile=loadImage("goal.png");
deadTile=loadImage("dead.png");
checkpointTile=loadImage("checkpoint.png");
scanMap();
player=new Player(spawnX,spawnY,this);
}

void loadMapFromImage(PImage img){
mapW=img.width;
mapH=img.height;
tiles=new int[mapH][mapW];
goombaSpawns.clear();
hammerBroSpawns.clear();
img.loadPixels();
for(int y=0;y<mapH;y++){
for(int x=0;x<mapW;x++){
color c=img.pixels[y*mapW+x];
if(c==color(0,0,0))tiles[y][x]=TILE_SOLID;
else if(c==color(0,0,255))tiles[y][x]=TILE_SPAWN;
else if(c==color(0,255,0))tiles[y][x]=TILE_GOAL;
else if(c==color(255,0,0))tiles[y][x]=TILE_DEAD;
else if(c==color(255,255,0))tiles[y][x]=TILE_CHECKPOINT;
else if(c==color(0,255,255))tiles[y][x]=TILE_PORTAL;
else if(c==C_GOOMBA){
tiles[y][x]=TILE_EMPTY;
goombaSpawns.add(new PVector(x*tileSize,y*tileSize));
}
else if(c==C_HAMMERBRO){
tiles[y][x]=TILE_EMPTY;
hammerBroSpawns.add(new PVector(x*tileSize,y*tileSize));
}
else tiles[y][x]=TILE_EMPTY;
}
}
}

void scanMap(){
portals.clear();
enemies.clear();
for(int y=0;y<mapH;y++){
for(int x=0;x<mapW;x++){
float wx=x*tileSize;
float wy=y*tileSize;
if(tiles[y][x]==TILE_SPAWN){
spawnX=wx;
spawnY=wy;
}
if(tiles[y][x]==TILE_PORTAL){
portals.add(new PVector(wx,wy));
}
}
}
for(PVector sp:goombaSpawns){
enemies.add(new Goomba(sp.x,sp.y-10,this));
}
for(PVector sp:hammerBroSpawns){
enemies.add(new HammerBro(sp.x,sp.y-10,this));
}
}

void update(){
player.update();
for(Enemy e:enemies)e.update();
for(int i=enemies.size()-1;i>=0;i--){
if(!enemies.get(i).alive)enemies.remove(i);
}
}

void display(){
drawTiles();
for(Enemy e:enemies)e.display();
player.display();
}

void reset(){
cleared=false;
checkpointX=-1;
checkpointY=-1;
scanMap();
player=new Player(spawnX,spawnY,this);
}

void drawTiles(){
int startCol=int(camX/tileSize);
int endCol=startCol+width/tileSize+2;
startCol=max(0,startCol);
endCol=min(mapW,endCol);
for(int y=0;y<mapH;y++){
for(int x=startCol;x<endCol;x++){
float sx=x*tileSize;
float sy=y*tileSize;
switch(tiles[y][x]){
case TILE_SOLID:image(groundTile,sx,sy,tileSize,tileSize);break;
case TILE_CHECKPOINT:image(checkpointTile,sx,sy,tileSize,tileSize);break;
case TILE_PORTAL:image(portalTile,sx,sy,tileSize,tileSize);break;
case TILE_GOAL:image(goalTile,sx,sy,tileSize,tileSize);break;
case TILE_DEAD:image(deadTile,sx,sy,tileSize,tileSize);break;
}
}
}
}

int getTileAt(float wx,float wy){
int tx=int(wx/tileSize);
int ty=int(wy/tileSize);
if(tx<0||ty<0||tx>=mapW||ty>=mapH)return TILE_EMPTY;
return tiles[ty][tx];
}

boolean isSolid(float x,float y){return getTileAt(x,y)==TILE_SOLID;}
boolean isDead(float x,float y){return getTileAt(x,y)==TILE_DEAD;}
boolean isEndPoint(float x,float y){return getTileAt(x,y)==TILE_GOAL;}
boolean isCheckpoint(float x,float y){return getTileAt(x,y)==TILE_CHECKPOINT;}
boolean isPortal(float x,float y){return getTileAt(x,y)==TILE_PORTAL;}

PVector getNextPortal(PVector current){
if(portals.size()<2)return null;
for(int i=0;i<portals.size();i++){
if(PVector.dist(portals.get(i),current)<20){
return portals.get((i+1)%portals.size());
}
}
return null;
}
}
