//switch

class Level {
  int id;
  boolean cleared = false;

  // ===== TILE TYPES =====
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

  final int TILE_BRIDGE = 13; // collapsing bridge

  int[][] tiles;
  int[][] originalTiles;   // ✅ NEW: backup of the original tiles (so bridges can reset)

  int mapW, mapH;
  int tileSize = 32;

  // ===== SPAWN =====
  float spawnX = 50;
  float spawnY = 50;
  float checkpointX = -1;
  float checkpointY = -1;

  // ===== OBJECTS =====
  Player player;
  ArrayList<PVector> portals = new ArrayList<PVector>();
  ArrayList<Enemy> enemies = new ArrayList<Enemy>();
  ArrayList<PVector> goombaSpawns = new ArrayList<PVector>();
  ArrayList<PVector> hammerBroSpawns = new ArrayList<PVector>();
  ArrayList<PVector> thwompSpawns = new ArrayList<PVector>();

  // ===== COLORS =====
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

  final color C_BRIDGE = color(0xFFCBA3E9); // collapsing bridge

  // ===== IMAGES =====
  PImage groundTile, portalTile, goalTile, checkpointTile;
  PImage trampolineImg, iceImg, spikeImg;

  // lava + water animation
  PImage[] lavaFrames = new PImage[6];
  PImage[] waterFrames = new PImage[4];
  int lavaFrame = 0, waterFrame = 0, animTimer = 0;

  // tree pieces
  PImage treeTrunk, treeMid, treeTL, treeTC, treeTR;

  // bridge pieces + rails (decor)
  PImage bridgeE, bridgeC, bridgeW;
  PImage railE, railC, railW;

  // collapsing state arrays
  boolean[][] bridgeTriggered;
  int[][] bridgeTimer;

  Level(int id) {
    this.id = id;

    PImage img = loadImage("map" + id + ".png");
    loadMapFromImage(img);   // ✅ this now also creates originalTiles backup

    // base tiles
    groundTile = loadImage("ground.png");
    portalTile = loadImage("portal.png");
    goalTile = loadImage("goal.png");
    checkpointTile = loadImage("checkpoint.png");

    // terrain tiles
    trampolineImg = loadImage("trampoline.png");
    iceImg = loadImage("ice.png");
    spikeImg = loadImage("spike.png");

    // lava frames
    for (int i = 0; i < 6; i++) {
      lavaFrames[i] = loadImage("lava" + (i + 1) + ".png");
    }
    // water frames
    for (int i = 0; i < 4; i++) {
      waterFrames[i] = loadImage("water" + (i + 1) + ".png");
    }

    // tree
    treeTrunk = loadImage("tree_trunk.png");
    treeMid = loadImage("tree_mid.png");
    treeTL = loadImage("treetop_left.png");
    treeTC = loadImage("treetop_center.png");
    treeTR = loadImage("treetop_right.png");

    // bridge
    bridgeE = loadImage("bridge_e.png");
    bridgeC = loadImage("bridge_center.png");
    bridgeW = loadImage("bridge_w.png");

    railE = loadImage("bridgeRails_e.png");
    railC = loadImage("bridgeRails_center.png");
    railW = loadImage("bridgeRails_w.png");

    scanMap();
    player = new Player(spawnX, spawnY, this);
  }

  // ===== MAP LOAD =====
  void loadMapFromImage(PImage img) {
    mapW = img.width;
    mapH = img.height;

    tiles = new int[mapH][mapW];
    originalTiles = new int[mapH][mapW]; // ✅ NEW

    bridgeTriggered = new boolean[mapH][mapW];
    bridgeTimer = new int[mapH][mapW];

    goombaSpawns.clear();
    hammerBroSpawns.clear();
    thwompSpawns.clear();

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

        // ✅ NEW: backup the original tile layout (bridges will restore)
        originalTiles[y][x] = tiles[y][x];
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

    // reset collapsing bridge arrays
    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        bridgeTriggered[y][x] = false;
        bridgeTimer[y][x] = 0;
      }
    }
  }

  // ✅ FIXED RESET: restores the map tiles (bridges come back every retry)
  void reset() {
    cleared = false;
    checkpointX = -1;
    checkpointY = -1;

    // RESTORE ALL TILES from backup
    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        tiles[y][x] = originalTiles[y][x];
        bridgeTriggered[y][x] = false;
        bridgeTimer[y][x] = 0;
      }
    }

    // rebuild portals + enemies based on restored tiles
    scanMap();

    // respawn player
    player = new Player(spawnX, spawnY, this);
  }

  // ===== UPDATE =====
  void update() {
    // animate lava/water
    animTimer++;
    if (animTimer % 10 == 0) {
      lavaFrame = (lavaFrame + 1) % lavaFrames.length;
      waterFrame = (waterFrame + 1) % waterFrames.length;
    }

    // collapsing bridge trigger: player feet tile
    int px = int((player.x + player.w / 2) / tileSize);
    int py = int((player.y + player.h + 1) / tileSize);
    if (px >= 0 && py >= 0 && px < mapW && py < mapH) {
      if (tiles[py][px] == TILE_BRIDGE) {
        bridgeTriggered[py][px] = true;
      }
    }

    // collapsing bridge countdown
    for (int y = 0; y < mapH; y++) {
      for (int x = 0; x < mapW; x++) {
        if (tiles[y][x] == TILE_BRIDGE && bridgeTriggered[y][x]) {
          bridgeTimer[y][x]++;
          if (bridgeTimer[y][x] > 30) {
            tiles[y][x] = TILE_EMPTY; // bridge falls away
          }
        }
      }
    }

    player.update();

    for (Enemy e : enemies) {
      e.update();
    }
    for (int i = enemies.size() - 1; i >= 0; i--) {
      if (!enemies.get(i).alive) {
        enemies.remove(i);
      }
    }
  }

  // ===== DRAW =====
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
          image(checkpointTile, sx, sy, tileSize, tileSize);
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
          // no collision, just draw stacked tree
          image(treeTrunk, sx, sy, tileSize, tileSize);
          image(treeMid, sx, sy - tileSize, tileSize, tileSize);
          image(treeTL, sx - tileSize, sy - 2 * tileSize, tileSize, tileSize);
          image(treeTC, sx, sy - 2 * tileSize, tileSize, tileSize);
          image(treeTR, sx + tileSize, sy - 2 * tileSize, tileSize, tileSize);
        } else if (t == TILE_BRIDGE) {
          // draw bridge piece (pattern repeats every 3 tiles)
          int mod = x % 3;
          if (mod == 0) {
            image(bridgeW, sx, sy, tileSize, tileSize);
          } else if (mod == 1) {
            image(bridgeC, sx, sy, tileSize, tileSize);
          } else {
            image(bridgeE, sx, sy, tileSize, tileSize);
          }

          // draw rails above bridge (decorative, no collision)
          float ry = sy - tileSize;
          if (mod == 0) {
            image(railW, sx, ry, tileSize, tileSize);
          } else if (mod == 1) {
            image(railC, sx, ry, tileSize, tileSize);
          } else {
            image(railE, sx, ry, tileSize, tileSize);
          }
        }
      }
    }
  }

  // ===== QUERIES =====
  int getTileAt(float wx, float wy) {
    int tx = int(wx / tileSize);
    int ty = int(wy / tileSize);
    if (tx < 0 || ty < 0 || tx >= mapW || ty >= mapH) {
      return TILE_EMPTY;
    }
    return tiles[ty][tx];
  }

  boolean isSolid(float x, float y) {
    int t = getTileAt(x, y);
    return t == TILE_SOLID || t == TILE_ICE || t == TILE_TRAMPOLINE || t == TILE_BRIDGE;
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
