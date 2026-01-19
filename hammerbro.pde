class HammerBro extends Enemy {
  ArrayList<Hammer> hammers = new ArrayList<Hammer>();

  // Instance frames (use global shared array)
  PImage[] frames;
  int frame = 0;
  int frameDelay = 20;
  int frameCount = 0;

  int jumpTimer = 0;
  int throwTimer = 0;

  HammerBro(float x, float y, Level lvl) {
    super(x, y, 28, 36, lvl);

    // Lazy-load shared frames using global array
    if (hammerBroSharedFrames == null) {
      hammerBroSharedFrames = new PImage[2];
      hammerBroSharedFrames[0] = loadImage("hammerbro0.png");
      hammerBroSharedFrames[1] = loadImage("hammerbro1.png");
    }
    frames = hammerBroSharedFrames;
  }

  void update() {
    if (!alive) return;

    // Vertical movement
    vy += gravity;
    y += vy;
    if (colliding()) {
      y -= vy;
      vy = 0;
    }

    // Periodic jump
    jumpTimer++;
    if (jumpTimer > 90) {
      vy = -9;
      jumpTimer = 0;
    }

    // Periodic hammer throw
    throwTimer++;
    if (throwTimer > 60) {
      throwHammer();
      throwTimer = 0;
    }

    // Update hammers
    for (Hammer h : hammers) {
      h.update();
    }
    for (int i = hammers.size() - 1; i >= 0; i--) {
      if (!hammers.get(i).alive) {
        hammers.remove(i);
      }
    }

    updateAnimation();
  }

  void updateAnimation() {
    frameCount++;
    if (frameCount >= frameDelay) {
      frame = (frame + 1) % frames.length;
      frameCount = 0;
    }
  }

  void throwHammer() {
    float dir = (level.player.x < x) ? -1 : 1;
    hammers.add(new Hammer(x + w / 2, y, dir * 3, -8, level));
  }

  void display() {
    if (!alive) return;

    image(frames[frame], x, y, w, h);
    for (Hammer h : hammers) {
      h.display();
    }
  }

  boolean colliding() {
    return level.isSolid(x, y + h) ||
           level.isSolid(x + w, y + h);
  }

  void die() {
    alive = false;
  }
}
