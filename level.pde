class Level {
  int id;
  boolean cleared = false;

  //Tile Types
  final int TILE_EMPTY = 0;
  final int TILE_SOLID = 1;
  final int TILE_SPAWN = 2;
  final int TILE_GOAL = 3;
  final int TILE_CHECKPOINT = 5;
  final int TILE_PORTAL = 6;

  final int TILE_LAVA = 7;
  final int TILE_TRAMPOLINE = 8;
  final int TILE_ICE = 9;
  final int TILE_SPIKE = 10;
  final int TILE_TREE = 11;
  final int TILE_WATER = 12;

  final int TILE_BRIDGE = 13;
  final int TILE_SWITCH = 14;     
  final int TILE_SWITCH_BLOCK = 15; 

  //NPC+KEY+DORR
  final int TILE_NPC = 20;
  final int TILE_DOOR = 21;

  int[][] tiles;
  //reset tiles after collapse rbidge disappear
  int[][] baseTiles;

  int mapW, mapH;
  int tileSize = 32;

  //store map->files
  String mapFile;

  //checkpoint/spwn here if die
  float spawnX = 50;
  float spawnY = 50;

  float checkpointX = -1;
  float checkpointY = -1;

  //objects
  Player player;
  ArrayList<PVector> portals = new ArrayList<PVector>();
  ArrayList<Enemy> enemies = new ArrayList<Enemy>();
  ArrayList<PVector> goombaSpawns = new ArrayList<PVector>();
  ArrayList<PVector> hammerBroSpawns = new ArrayList<PVector>();
  ArrayList<PVector> thwompSpawns = new ArrayList<PVector>();

  //colors
  final color C_SOLID = color(0);
  final color C_SPAWN = color(0, 0, 255);
  final color C_GOAL = color(0, 255, 0);
  final color C_CHECKPOINT = color(255, 255, 0);

  final color C_PORTAL = color(0, 255, 255);

  final color C_GOOMBA = color(255, 0, 255);
  final color C_HAMMERBRO = color(255, 128, 0);
  final color C_THWOMP = color(120, 120, 120);

  final color C_LAVA = color(0xFFD4FFBD);
  final color C_TRAMP = color(0xFF6BD5FF);
  final color C_ICE = color(0xFFBDF3EF);
  final color C_SPIKE = color(0xFF46992F);
  final color C_TREE = color(0xFF36FC8F);
  final color C_WATER = color(0xFF2F3E99);

  final color C_BRIDGE = color(0xFFCBA3E9);
  final color C_SWITCH = color(255, 0, 0);
  final color C_SWITCH_BLOCK = color(128, 0, 0);

  //quest+storylines
  final color C_NPC_PIXEL  = color(0xFFFFB000);
  final color C_KEY_PIXEL  = color(0xFF00E5FF);
  final color C_DOOR_PIXEL = color(0xFF6A00FF);

  //imgs to load
  PImage groundTile, portalTile, goalTile;

  PImage checkpoint0Img, checkpoint1Img;

  PImage trampolineImg, iceImg, spikeImg;

  PImage[] lavaFrames = new PImage[6];
  PImage[] waterFrames = new PImage[4];
  int lavaFrame = 0, waterFrame = 0, animTimer = 0;

  PImage treeTrunk, treeMid, treeTL, treeTC, treeTR;

  PImage bridgeE, bridgeC, bridgeW;
  PImage railE, railC, railW;

  boolean[][] bridgeTriggered;
  int[][] bridgeTimer;

  //states+positions
  boolean switchActive = false;
  int switchX = -1, switchY = -1;
  int switchBlockX = -1, switchBlockY = -1;
  PImage switchImg, switchedImg;

  //specifically
  int npcX = -1, npcY = -1;
  int keyX = -1, keyY = -1;
  boolean keyVisible = false;
  boolean keyCollected = false;

  int doorX = -1, doorY = -1;
  boolean doorOpened = false;

  boolean npcTalkedOnce = false;
  boolean npcTalkedAfterKey = false;

  Level(int id) {
    this.id = id;

    mapFile = "map" + id + ".png";

    PImage img = loadImage(mapFile);
    loadMapFromImage(img);

    groundTile = loadImage("ground.png");
    portalTile = loadImage("portal.png");
    goalTile = loadImage("goal.png");

    checkpoint0Img = loadImage("checkpoint0.png");
    checkpoint1Img = loadImage("checkpoint1.png");

    trampolineImg = loadImage("trampoline.png");
    iceImg = loadImage("ice.png");
    spikeImg = loadImage("spike.png");
    switchImg = loadImage("switch.png");
    switchedImg = loadImage("switched.png");

    for (int i = 0; i < 6; i++) {
      lavaFrames[i] = loadImage("lava" + (i + 1) + ".png");
    }
    for (int i = 0; i < 4; i++) {
      waterFrames[i] = loadImage("water" + (i + 1) + ".png");
    }

    treeTrunk = loadImage("tree_trunk.png");
    treeMid = loadImage("tree_mid.png");
    treeTL = loadImage("treetop_left.png");
    treeTC = loadImage("treetop_center.png");
    treeTR = loadImage("treetop_right.png");

    bridgeE = loadImage("bridge_e.png");
    bridgeC = loadImage("bridge_center.png");
    bridgeW = loadImage("bridge_w.png");

    railE = loadImage("bridgeRails_e.png");
    railC = loadImage("bridgeRails_center.png");
    railW = loadImage("bridgeRails_w.png");

    scanMap();
  }

  //load map
  void loadMapFromImage(PImage img) {
    mapW = img.width;
    mapH = img.height;

    tiles = new int[mapH][mapW];
    bridgeTriggered = new boolean[mapH][mapW];
    bridgeTimer = new int[mapH][mapW];

    goombaSpawns.clear();
    hammerBroSpawns.clear();
    thwompSpawns.clear();

    //reset switch+coordinates
    switchActive = false;
    switchX = switchY = -1;
    switchBlockX = switchBlockY = -1;

    //reset npcs
    npcX = npcY = -1;
    keyX = keyY = -1;
    keyVisible = false;
    keyCollected = false;
    doorX = doorY = -1;
    doorOpened = false;
    npcTalkedOnce = false;
    npcTalkedAfterKey = false;

    img.loadPixels();
    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        color c = img.pixels[y * mapW + x];

        if (c == C_SOLID) {
          tiles[y][x] = TILE_SOLID;
        } else if (c == C_SPAWN) {
          tiles[y][x] = TILE_SPAWN;
        } else if (c == C_GOAL) {
          tiles[y][x] = TILE_GOAL;
        } else if (c == C_CHECKPOINT) {
          tiles[y][x] = TILE_CHECKPOINT;
        } else if (c == C_PORTAL) {
          tiles[y][x] = TILE_PORTAL;
        } else if (c == C_LAVA) {
          tiles[y][x] = TILE_LAVA;
        } else if (c == C_TRAMP) {
          tiles[y][x] = TILE_TRAMPOLINE;
        } else if (c == C_ICE) {
          tiles[y][x] = TILE_ICE;
        } else if (c == C_SPIKE) {
          tiles[y][x] = TILE_SPIKE;
        } else if (c == C_TREE) {
          tiles[y][x] = TILE_TREE;
        } else if (c == C_WATER) {
          tiles[y][x] = TILE_WATER;
        } else if (c == C_BRIDGE) {
          tiles[y][x] = TILE_BRIDGE;

        } else if (c == C_SWITCH) {
          tiles[y][x] = TILE_SWITCH;
          switchX = x;
          switchY = y;

        } else if (c == C_SWITCH_BLOCK) {
          tiles[y][x] = TILE_SWITCH_BLOCK;
          switchBlockX = x;
          switchBlockY = y;

        } else if (c == C_NPC_PIXEL) {
          tiles[y][x] = TILE_NPC;
          npcX = x;
          npcY = y;

        } else if (c == C_KEY_PIXEL) {
          tiles[y][x] = TILE_EMPTY;
          keyX = x;
          keyY = y;

        } else if (c == C_DOOR_PIXEL) {
          tiles[y][x] = TILE_DOOR;
          doorX = x;
          doorY = y;

        } else if (c == C_GOOMBA) {
          tiles[y][x] = TILE_EMPTY;
          goombaSpawns.add(new PVector(x * tileSize, y * tileSize));

        } else if (c == C_HAMMERBRO) {
          tiles[y][x] = TILE_EMPTY;
          hammerBroSpawns.add(new PVector(x * tileSize, y * tileSize));

        } else if (c == C_THWOMP) {
          tiles[y][x] = TILE_EMPTY;
          thwompSpawns.add(new PVector(x * tileSize, y * tileSize));

        } else {
          tiles[y][x] = TILE_EMPTY;
        }
      }
    }

    //bridge times
    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        bridgeTriggered[y][x] = false;
        bridgeTimer[y][x] = 0;
      }
    }

    //bridge reset on death
    baseTiles = new int[mapH][mapW];
    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        baseTiles[y][x] = tiles[y][x];
      }
    }
  }

  void scanMap() {
    portals.clear();
    enemies.clear();

    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        float wx = x * tileSize;
        float wy = y * tileSize;

        if (tiles[y][x] == TILE_SPAWN) {
          spawnX = wx;
          spawnY = wy;
        }
        if (tiles[y][x] == TILE_PORTAL) {
          portals.add(new PVector(wx, wy));
        }
      }
    }

    for (PVector sp : goombaSpawns) {
      enemies.add(new Goomba(sp.x, sp.y - 10, this));
    }
    for (PVector sp : hammerBroSpawns) {
      enemies.add(new HammerBro(sp.x, sp.y - 10, this));
    }
    for (PVector sp : thwompSpawns) {
      enemies.add(new Thwomp(sp.x, sp.y, this));
    }

    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        bridgeTriggered[y][x] = false;
        bridgeTimer[y][x] = 0;
      }
    }
  }

  //reset
  void reset() {
    cleared = false;
    checkpointX = -1;
    checkpointY = -1;

    loadMapFromImage(loadImage(mapFile));
    scanMap();

    player = new Player(spawnX, spawnY, this);
  }

  //reset only bridges after life X
  void resetBridges() {
    if (baseTiles == null) return;

    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        if (baseTiles[y][x] == TILE_BRIDGE) {
          // restore bridge tile if it was collapsed
          tiles[y][x] = TILE_BRIDGE;
          bridgeTriggered[y][x] = false;
          bridgeTimer[y][x] = 0;
        }
      }
    }
  }

  //checkpoint spawn
  void saveCheckpointAt(float wx, float wy) {
    int tx = int(wx / tileSize);
    int ty = int(wy / tileSize);
    if (tx < 0 || ty < 0 || tx >= mapW || ty >= mapH) return;
    if (tiles[ty][tx] != TILE_CHECKPOINT) return;

    checkpointX = tx * tileSize;
    checkpointY = ty * tileSize;
  }

  void respawnPlayer() {
    resetBridges();

    if (checkpointX >= 0 && checkpointY >= 0) {
      player.x = checkpointX + tileSize / 2 - player.w / 2;
      player.y = checkpointY - player.h - 2;
    } else {
      player.x = spawnX;
      player.y = spawnY;
    }
    player.vx = 0;
    player.vy = 0;
    player.portalCooldown = 10;
    player.wasInPortal = false;
  }

  void spawnKey() {
    if (keyX < 0 || keyY < 0) return;
    if (keyCollected) return;
    keyVisible = true;
  }

  void openDoor() {
    doorOpened = true;
    if (doorX >= 0 && doorY >= 0) {
      tiles[doorY][doorX] = TILE_EMPTY;
    }
  }

  boolean playerTouchingNPC() {
    if (npcX < 0 || npcY < 0) return false;

    float nx = npcX * tileSize;
    float ny = npcY * tileSize;

    return rectsIntersect(player.x, player.y, player.w, player.h, nx, ny, tileSize, tileSize);
  }

  void tryCollectKey() {
    if (!keyVisible || keyCollected) return;
    if (keyX < 0 || keyY < 0) return;

    float kx = keyX * tileSize;
    float ky = keyY * tileSize;

    if (rectsIntersect(player.x, player.y, player.w, player.h, kx, ky, tileSize, tileSize)) {
      keyCollected = true;
      keyVisible = false;
    }
  }

  boolean rectsIntersect(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
    return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by;
  }

  //trigger bridge when player clld
  void triggerBridgeUnderPlayer() {
    float footY = player.y + player.h + 1;
    int ty = int(footY / tileSize);
    if (ty < 0 || ty >= mapH) return;

    int left = int(player.x / tileSize);
    int right = int((player.x + player.w - 1) / tileSize);

    for (int tx = left; tx <= right; tx++) {
      if (tx < 0 || tx >= mapW) continue;

      if (tiles[ty][tx] == TILE_BRIDGE) {
        if (!bridgeTriggered[ty][tx]) {
          bridgeTriggered[ty][tx] = true;
          bridgeTimer[ty][tx] = 0;
        }
      }
    }
  }

  //update
  void update() {
    animTimer++;
    if (animTimer % 10 == 0) {
      lavaFrame = (lavaFrame + 1) % lavaFrames.length;
      waterFrame = (waterFrame + 1) % waterFrames.length;
    }

    //switch trigger
    if (!switchActive) {
      int left = int(player.x / tileSize);
      int right = int((player.x + player.w) / tileSize);
      int top = int(player.y / tileSize);
      int bottom = int((player.y + player.h) / tileSize);

      for (int ty = top; ty <= bottom; ty++) {
        for (int tx = left; tx <= right; tx++) {
          if (tx >= 0 && ty >= 0 && tx < mapW && ty < mapH) {
            if (tiles[ty][tx] == TILE_SWITCH) {
              switchActive = true;
              if (switchBlockX >= 0 && switchBlockY >= 0) {
                tiles[switchBlockY][switchBlockX] = TILE_EMPTY;
              }
              break;
            }
          }
        }
      }
    }

    //player physics
    player.update();

    //decay timer
    triggerBridgeUnderPlayer();

    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        if (tiles[y][x] == TILE_BRIDGE && bridgeTriggered[y][x]) {
          bridgeTimer[y][x]++;
          if (bridgeTimer[y][x] > 30) {
            tiles[y][x] = TILE_EMPTY;
          }
        }
      }
    }

    //key pickup check
    tryCollectKey();

    //enemies
    for (Enemy e : enemies) {
      e.update();
    }
    for (int i = enemies.size() - 1; i >= 0; i--) {
      if (!enemies.get(i).alive) {
        enemies.remove(i);
      }
    }
  }

  //draw
  void display() {
    drawTiles();
    for (Enemy e : enemies) {
      e.display();
    }
    player.display();
  }

  void drawTiles() {
    int startCol = int(camX / tileSize);
    int endCol = startCol + width / tileSize + 2;
    startCol = max(0, startCol);
    endCol = min(mapW, endCol);

    for (int y = 0; y < mapH; y++) {
      for (int x = startCol; x < endCol; x++) {
        float sx = x * tileSize;
        float sy = y * tileSize;

        int t = tiles[y][x];

        if (t == TILE_SOLID) {
          image(groundTile, sx, sy, tileSize, tileSize);

        } else if (t == TILE_GOAL) {
          image(goalTile, sx, sy, tileSize, tileSize);

        } else if (t == TILE_CHECKPOINT) {
          boolean active = (checkpointX == sx && checkpointY == sy);
          image(active ? checkpoint1Img : checkpoint0Img, sx, sy, tileSize, tileSize);

        } else if (t == TILE_PORTAL) {
          image(portalTile, sx, sy, tileSize, tileSize);

        } else if (t == TILE_LAVA) {
          image(lavaFrames[lavaFrame], sx, sy, tileSize, tileSize);

        } else if (t == TILE_TRAMPOLINE) {
          image(trampolineImg, sx, sy, tileSize, tileSize);

        } else if (t == TILE_ICE) {
          image(iceImg, sx, sy, tileSize, tileSize);

        } else if (t == TILE_SPIKE) {
          image(spikeImg, sx, sy, tileSize, tileSize);

        } else if (t == TILE_WATER) {
          image(waterFrames[waterFrame], sx, sy, tileSize, tileSize);

        } else if (t == TILE_TREE) {
          image(treeTrunk, sx, sy, tileSize, tileSize);
          image(treeMid, sx, sy - tileSize, tileSize, tileSize);
          image(treeTL, sx - tileSize, sy - 2 * tileSize, tileSize, tileSize);
          image(treeTC, sx, sy - 2 * tileSize, tileSize, tileSize);
          image(treeTR, sx + tileSize, sy - 2 * tileSize, tileSize, tileSize);

        } else if (t == TILE_SWITCH_BLOCK) {
          noStroke();
          fill(128, 0, 0);
          rect(sx, sy, tileSize, tileSize);

        } else if (t == TILE_SWITCH) {
          image(switchActive ? switchedImg : switchImg, sx, sy, tileSize, tileSize);

        } else if (t == TILE_BRIDGE) {
          int mod = x % 3;
          if (mod == 0) image(bridgeW, sx, sy, tileSize, tileSize);
          else if (mod == 1) image(bridgeC, sx, sy, tileSize, tileSize);
          else image(bridgeE, sx, sy, tileSize, tileSize);

          float ry = sy - tileSize;
          if (mod == 0) image(railW, sx, ry, tileSize, tileSize);
          else if (mod == 1) image(railC, sx, ry, tileSize, tileSize);
          else image(railE, sx, ry, tileSize, tileSize);

        } else if (t == TILE_NPC) {
          noStroke();
          fill(255, 215, 0);
          rect(sx + 4, sy + 4, tileSize - 8, tileSize - 8, 8);
          fill(0);
          textAlign(CENTER, CENTER);
          textSize(12);
          text("NPC", sx + tileSize/2, sy + tileSize/2);
          textSize(22);

        } else if (t == TILE_DOOR) {
          noStroke();
          fill(0, 0, 128);
          rect(sx, sy, tileSize, tileSize);
          fill(255);
          textAlign(CENTER, CENTER);
          textSize(12);
          text("DOOR", sx + tileSize/2, sy + tileSize/2);
          textSize(22);
        }

        //key draw
        if (keyVisible && !keyCollected && keyX == x && keyY == y) {
          noStroke();
          fill(0, 255, 0);
          rect(sx + 8, sy + 8, tileSize - 16, tileSize - 16, 6);
          fill(0);
          textAlign(CENTER, CENTER);
          textSize(12);
          text("KEY", sx + tileSize/2, sy + tileSize/2);
          textSize(22);
        }
      }
    }
  }

  int getWorldWidthPx() {
    return mapW * tileSize;
  }

  int getTileAt(float wx, float wy) {
    int tx = int(wx / tileSize);
    int ty = int(wy / tileSize);
    if (tx < 0 || ty < 0 || tx >= mapW || ty >= mapH) return TILE_EMPTY;
    return tiles[ty][tx];
  }

  boolean isSolid(float x, float y) {
    int t = getTileAt(x, y);
    if (t == TILE_DOOR && !doorOpened) return true;

    return t == TILE_SOLID || t == TILE_ICE || t == TILE_TRAMPOLINE || t == TILE_BRIDGE ||
           t == TILE_SWITCH_BLOCK;
  }

  boolean isDead(float x, float y) {
    int t = getTileAt(x, y);
    return t == TILE_LAVA || t == TILE_SPIKE || t == TILE_WATER;
  }

  boolean isIce(float x, float y) {
    return getTileAt(x, y) == TILE_ICE;
  }

  boolean isTrampoline(float x, float y) {
    return getTileAt(x, y) == TILE_TRAMPOLINE;
  }

  boolean isEndPoint(float x, float y) {
    return getTileAt(x, y) == TILE_GOAL;
  }

  boolean isPortal(float x, float y) {
    return getTileAt(x, y) == TILE_PORTAL;
  }

  boolean isCheckpoint(float x, float y) {
    return getTileAt(x, y) == TILE_CHECKPOINT;
  }

  PVector getNextPortal(PVector current) {
    if (portals.size() < 2) return null;
    for (int i = 0; i < portals.size(); i++) {
      if (PVector.dist(portals.get(i), current) < 20) {
        return portals.get((i + 1) % portals.size());
      }
    }
    return null;
  }
}
