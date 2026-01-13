class Thwomp extends Enemy {
  // States
  final int WAITING  = 0;
  final int FALLING  = 1;
  final int CRUSHED  = 2;
  final int RISING   = 3;

  float startY;
  float maxFallSpeed = 16;
  float riseSpeed    = -4;
  int   state        = WAITING;
  int   crushedTimer;
  int   crushedDelay = 1000; // ms Thwomp stays crushed on the ground

  // Player detection area
  float sensorW;
  float sensorH;

  // Cooldown so it doesn't immediately re-trigger
  int  cooldownDuration = 800; // ms, tweak this to change difficulty
  int  cooldownEndTime  = 0;   // millis() timestamp when cooldown ends

  // Images (use shared globals)
  PImage idleImg;
  PImage moveImg;

  Thwomp(float x, float y, Level lvl) {
    // x, y are the top-left position, consistent with other enemies
    super(x, y, 64, 64, lvl);

    startY  = y;
    sensorW = w * 2;
    sensorH = 300;
    gravity = 1.2;

    // Lazy-load shared images
    if (thwompIdleSharedImage == null) {
      thwompIdleSharedImage = loadImage("thwomp0.png");
    }
    if (thwompMovingSharedImage == null) {
      thwompMovingSharedImage = loadImage("thwomp1.png");
    }

    idleImg = thwompIdleSharedImage;
    moveImg = thwompMovingSharedImage;
  }

  void update() {
    if (!alive) return;

    switch (state) {

      case WAITING:
        // If still in cooldown, do nothing (cannot trigger yet)
        if (cooldownEndTime > millis()) {
          // Just idle at the top
        } else {
          // Only trigger falling if cooldown ended AND player is in sensor
          if (playerInSensor(level.player.x, level.player.y, level.player.w, level.player.h)) {
            state = FALLING;
            vy = 0;
          }
        }
        break;

      case FALLING:
        // Apply gravity
        vy += gravity;
        vy = min(vy, maxFallSpeed);

        float nextY = y + vy;

        // Check if bottom of Thwomp at nextY hits solid tiles
        if (hitsGround(nextY)) {
          // Move to nextY then nudge up until it's exactly resting on tiles
          y = nextY;
          while (hitsGround(y)) {
            y -= 1;
          }

          state = CRUSHED;
          crushedTimer = millis();
          vy = 0;
        } else {
          // No ground yet, keep falling
          y = nextY;
        }
        break;

      case CRUSHED:
        // Stay on the ground for a while
        if (millis() - crushedTimer > crushedDelay) {
          state = RISING;
          vy = riseSpeed;
        }
        break;

      case RISING:
        // Move back up toward original Y
        y += vy;

        if (y <= startY) {
          // Reached the top
          y = startY;
          vy = 0;

          // Enter WAITING state but start a cooldown period
          state = WAITING;
          cooldownEndTime = millis() + cooldownDuration;
        }
        break;
    }

    cameraCull();
  }

  // Check if bottom edge at testY intersects any solid tiles
  boolean hitsGround(float testY) {
    // Slightly inset horizontally to avoid corner glitches
    float left   = x + 2;
    float right  = x + w - 2;
    float bottom = testY + h;

    return level.isSolid(left, bottom) || level.isSolid(right, bottom);
  }

  // Detection zone below the Thwomp
  boolean playerInSensor(float px, float py, float pw, float ph) {
    // Sensor is a big rectangle below the Thwomp
    float sx = x - (sensorW - w) / 2;
    float sy = y + h;
    float sw = sensorW;
    float sh = sensorH;

    return (px + pw > sx) &&
           (px < sx + sw) &&
           (py + ph > sy) &&
           (py < sy + sh);
  }

  void display() {
    if (!alive) return;

    // x, y are top-left; use default CORNER mode
    image((state == FALLING || state == RISING) ? moveImg : idleImg, x, y, w, h);
  }

  // Thwomp is not stompable by the player
  boolean stompedBy(Player p) {
    return false;
  }
}
