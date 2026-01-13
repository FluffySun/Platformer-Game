class Player {

  float x, y;
  float w = 24, h = 32;

  float vx = 0, vy = 0;
  float speed = 3;
  float gravity = 0.7;
  float jumpForce = -10;

  boolean onGround = false;
  boolean facingRight = true;

  // ===== PORTAL STATE =====
  boolean wasInPortal = false;
  int portalCooldown = 0;

  Level level;

  // ===== ANIMATION =====
  PImage[] idleR = new PImage[2];
  PImage idleL, jumpL, jumpR;
  PImage[] runR = new PImage[3];
  PImage[] runL = new PImage[3];
  int frame = 0;
  int frameDelay = 8;
  int frameCountAnim = 0;

  Player(float x, float y, Level lvl) {
    this.x = x;
    this.y = y;
    this.level = lvl;

    idleR[0] = loadImage("idle0.png");
    idleR[1] = loadImage("idle1.png");
    idleL = loadImage("idle2.png");
    jumpR = loadImage("jump0.png");
    jumpL = loadImage("jump1.png");

    runR[0] = loadImage("runright0.png");
    runR[1] = loadImage("runright1.png");
    runR[2] = loadImage("runright2.png");

    runL[0] = loadImage("runleft0.png");
    runL[1] = loadImage("runleft1.png");
    runL[2] = loadImage("runleft2.png");
  }

  // ==================================================
  void update() {

    if (portalCooldown > 0) {
      portalCooldown--;
    }

    // ===== ICE / MOVEMENT =====
    boolean onIce = level.isIce(x + w / 2, y + h + 1);
    float accel = onIce ? 0.15 : 0.5;
    float maxSpeed = onIce ? 2.2 : 3;

    if (leftKey) {
      vx = max(vx - accel, -maxSpeed);
      facingRight = false;
    } else if (rightKey) {
      vx = min(vx + accel, maxSpeed);
      facingRight = true;
    } else if (!onIce) {
      vx = 0;
    }

    // ===== HORIZONTAL =====
    x += vx;
    if (colliding()) {
      x -= vx;
    }

    // ===== VERTICAL =====
    vy += gravity;
    y += vy;

    if (colliding()) {
      y -= vy;
      if (level.isTrampoline(x + w / 2, y + h + 1)) {
        vy = -15;
      } else {
        vy = 0;
      }
      onGround = true;
    } else {
      onGround = false;
    }

    // ===== DEATH =====
    if (level.isDead(x + w / 2, y + h / 2)) {
      mode = GAMEOVER;
      return;
    }

    // ===== END POINT =====
    if (level.isEndPoint(x + w / 2, y + h / 2)) {
      level.cleared = true;
    }

    // ==================================================
    // ===== PORTAL : EDGE-TRIGGER + TILE-SNAP =====
    // ==================================================

    boolean inPortal =
      level.isPortal(x + 2, y + h / 2) ||
      level.isPortal(x + w - 2, y + h / 2) ||
      level.isPortal(x + w / 2, y + h / 2);

    if (!wasInPortal && inPortal && portalCooldown == 0) {

      float hx = x + w / 2;
      float hy = y + h / 2;

      if (level.isPortal(x + 2, y + h / 2)) {
        hx = x + 2;
      } else if (level.isPortal(x + w - 2, y + h / 2)) {
        hx = x + w - 2;
      }

      int tx = int(hx / level.tileSize);
      int ty = int(hy / level.tileSize);
      PVector curPortalTopLeft = new PVector(tx * level.tileSize, ty * level.tileSize);

      PVector dest = level.getNextPortal(curPortalTopLeft);
      if (dest != null) {
        x = dest.x + level.tileSize / 2 - w / 2;
        y = dest.y - h - 2;
        vx = 0;
        vy = 0;
        portalCooldown = 15;

        // ===== UNSTUCK PATCH =====
        int safety = 0;
        while (colliding() && safety < level.tileSize * 3) {
          y -= 1;
          safety++;
        }

        if (colliding()) {
          x += level.tileSize;
          safety = 0;
          while (colliding() && safety < level.tileSize * 3) {
            y -= 1;
            safety++;
          }
        }
      }
    }

    wasInPortal = inPortal;

    // ===== ENEMIES =====
    for (Enemy e : level.enemies) {
      if (!e.alive) {
        continue;
      }

      if (e.intersects(this)) {
        if (e.stompedBy(this)) {
          e.alive = false;
          vy = jumpForce * 0.7;
        } else {
          mode = GAMEOVER;
          return;
        }
      }
    }

    updateAnimation();
  }

  // ==================================================
  void updateAnimation() {
    frameCountAnim++;
    if (frameCountAnim >= frameDelay) {
      frame++;
      frameCountAnim = 0;
    }
  }

  void display() {
    PImage img;

    if (!onGround) {
      img = facingRight ? jumpR : jumpL;
    } else if (vx > 0) {
      img = runR[frame % runR.length];
    } else if (vx < 0) {
      img = runL[frame % runL.length];
    } else {
      img = facingRight ? idleR[frame % idleR.length] : idleL;
    }

    image(img, x, y, w, h);
  }

  void jump() {
    if (onGround) {
      vy = jumpForce;
    }
  }

  // ==================================================
  // Solid collision, but portal tiles are NOT solid
  // ==================================================
  boolean colliding() {

    // ---- World boundary (invisible wall) ----
    if (x < camX || x + w > camX + width) {
      return true;
    }

    // ---- Solid tiles (ignore portal tiles) ----
    boolean tl = level.isSolid(x, y) && !level.isPortal(x, y);
    boolean tr = level.isSolid(x + w - 1, y) && !level.isPortal(x + w - 1, y);
    boolean bl = level.isSolid(x, y + h - 1) && !level.isPortal(x, y + h - 1);
    boolean br = level.isSolid(x + w - 1, y + h - 1) && !level.isPortal(x + w - 1, y + h - 1);

    return tl || tr || bl || br;
  }
}
