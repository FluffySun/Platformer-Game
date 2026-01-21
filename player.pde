class Player {

  float x, y;
  float w = 24, h = 32;

  float vx = 0, vy = 0;
  float speed;
  float gravity = 0.7;
  float jumpForce;

  boolean onGround = false;
  boolean facingRight = true;

  boolean wasInPortal = false;
  int portalCooldown = 0;

  Level level;

  PImage[] idleR = new PImage[2];
  PImage idleL, jumpL, jumpR;
  PImage[] runR = new PImage[3];
  PImage[] runL = new PImage[3];
  int frame = 0;
  int frameDelay = 8;
  int frameCountAnim = 0;

  String skin;

  Player(float x, float y, Level lvl) {
    this.x = x;
    this.y = y;
    this.level = lvl;

    //default
    speed = MARIO_SPEED;
    jumpForce = -10;

    //character selection
    if (selectedCharacter == 1) {          //Luigi
      jumpForce = LUIGI_JUMP;
    } 
    else if (selectedCharacter == 2) {     //Toad
      speed = TOAD_SPEED;
    }

    //skin
    skin = getCharacterPrefix();

    idleR[0] = getImg(skin + "_idle0.png");
    idleR[1] = getImg(skin + "_idle1.png");
    idleL    = getImg(skin + "_idle2.png");

    jumpR    = getImg(skin + "_jump0.png");
    jumpL    = getImg(skin + "_jump1.png");

    runR[0]  = getImg(skin + "_runright0.png");
    runR[1]  = getImg(skin + "_runright1.png");
    runR[2]  = getImg(skin + "_runright2.png");

    runL[0]  = getImg(skin + "_runleft0.png");
    runL[1]  = getImg(skin + "_runleft1.png");
    runL[2]  = getImg(skin + "_runleft2.png");
  }

  void update() {
    if (portalCooldown > 0) portalCooldown--;

    boolean onIce = level.isIce(x + w / 2, y + h + 1);
    float accel = onIce ? 0.15 : 0.5;
    float maxSpeed = onIce ? (speed * 0.75) : speed;

    if (leftKey) {
      vx = max(vx - accel, -maxSpeed);
      facingRight = false;
    } else if (rightKey) {
      vx = min(vx + accel, maxSpeed);
      facingRight = true;
    } else if (!onIce) {
      vx = 0;
    }

    x += vx;
    if (colliding()) x -= vx;

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

    if (level.isCheckpoint(x + w / 2, y + h / 2)) {
      level.saveCheckpointAt(x + w / 2, y + h / 2);
    }

    if (level.isDead(x + w / 2, y + h / 2)) {
      killPlayer();
      return;
    }

    if (level.isEndPoint(x + w / 2, y + h / 2)) {
      level.cleared = true;
    }

    boolean inPortal =
      level.isPortal(x + 2, y + h / 2) ||
      level.isPortal(x + w - 2, y + h / 2) ||
      level.isPortal(x + w / 2, y + h / 2);

    if (!wasInPortal && inPortal && portalCooldown == 0) {
      float hx = x + w / 2;
      float hy = y + h / 2;

      if (level.isPortal(x + 2, y + h / 2)) hx = x + 2;
      else if (level.isPortal(x + w - 2, y + h / 2)) hx = x + w - 2;

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

        int safety = 0;
        while (colliding() && safety < level.tileSize * 3) {
          y -= 1;
          safety++;
        }
      }
    }

    wasInPortal = inPortal;

    for (Enemy e : level.enemies) {
      if (!e.alive) continue;
      if (e.intersects(this)) {
        if (e.stompedBy(this)) {
          e.alive = false;
          vy = jumpForce * 0.7;
        } else {
          killPlayer();
          return;
        }
      }
    }

    updateAnimation();
  }

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
    if (onGround) vy = jumpForce;
  }

  boolean colliding() {
    boolean tl = level.isSolid(x, y) && !level.isPortal(x, y);
    boolean tr = level.isSolid(x + w - 1, y) && !level.isPortal(x + w - 1, y);
    boolean bl = level.isSolid(x, y + h - 1) && !level.isPortal(x, y + h - 1);
    boolean br = level.isSolid(x + w - 1, y + h - 1) && !level.isPortal(x + w - 1, y + h - 1);
    return tl || tr || bl || br;
  }
}
