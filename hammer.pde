class Hammer {
  // No static here – we use global hammerSharedImage instead

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

    // Lazy-load the shared hammer image using the global variable
    if (hammerSharedImage == null) {
      hammerSharedImage = loadImage("hammer.png");
    }
    img = hammerSharedImage;
  }

  void update() {
    if (!alive) return;

    // Physics
    vy += gravity;
    x += vx;
    y += vy;

    // Hit solid tiles
    if (level.isSolid(x, y) ||
        level.isSolid(x + w - 1, y) ||
        level.isSolid(x, y + h - 1) ||
        level.isSolid(x + w - 1, y + h - 1)) {
      alive = false;
      return;
    }

    // Hit player
    if (hits(level.player)) {
      mode = GAMEOVER;
      alive = false;
      return;
    }

    // Off-screen cleanup
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
