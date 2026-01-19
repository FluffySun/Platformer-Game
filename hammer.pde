class Hammer {

  float x, y;
  float w = 14;
  float h = 14;

  float vx, vy;
  float gravity = 0.6;

  boolean alive = true;
  Level level;
  PImage img;

  Hammer(float x, float y, float vx, float vy, Level lvl) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.level = lvl;

    if (hammerSharedImage == null) {
      hammerSharedImage = loadImage("hammer.png");
    }
    img = hammerSharedImage;
  }

  void update() {
    if (!alive) return;

    vy += gravity;
    x += vx;
    y += vy;

    if (level.isSolid(x, y) ||
        level.isSolid(x + w - 1, y) ||
        level.isSolid(x, y + h - 1) ||
        level.isSolid(x + w - 1, y + h - 1)) {
      alive = false;
      return;
    }

    // Hit player -> lose a life
    if (hits(level.player)) {
      killPlayer();
      alive = false;
      return;
    }

    if (x + w < camX || x > camX + width + 50) {
      alive = false;
    }
  }

  void display() {
    if (!alive) return;
    image(img, x, y, w, h);
  }

  boolean hits(Player p) {
    return p.x < x + w &&
           p.x + p.w > x &&
           p.y < y + h &&
           p.y + p.h > y;
  }
}
