import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'package:idle_cutter/actors/water_enemy.dart';
import 'package:idle_cutter/objects/explosion.dart';
import 'package:idle_cutter/objects/petard.dart';

import '../ember_quest.dart';
import '../objects/ground_block.dart';
import '../objects/platform_block.dart';
import '../objects/star.dart';
import 'chicchetto.dart';

class EmberPlayer extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<EmberQuestGame> {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  int horizontalDirection = 0;
  final Vector2 velocity = Vector2.zero();

  double get moveSpeed => 200 + game.starsCollected * 50;
  bool isOnGround = false;
  bool hasJumped = false;
  final double gravity = 16;
  final double jumpSpeed = 1175;
  final double terminalVelocity = 650;
  bool hitByEnemy = false;
  final SpriteAnimationData animationDataWalk = SpriteAnimationData.range(
    start: 2,
    end: 3,
    amount: 4,
    textureSize: Vector2.all(512),
    stepTimes: [0.5, 0.5, 0.16, 0.16],
  );
  final SpriteAnimationData animationDataJump = SpriteAnimationData.range(
    start: 0,
    end: 1,
    amount: 4,
    textureSize: Vector2.all(512),
    stepTimes: [0.3, 0.3, 0.16, 0.16],
  );

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('pacman.png'), animationDataWalk);
    add(
      CircleHitbox(),
    );
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    if (hasJumped) {
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('pacman.png'), animationDataJump)
        ..onFrame = (frame) {
          if (frame == 1) {
            animation = SpriteAnimation.fromFrameData(
                game.images.fromCache('pacman.png'), animationDataWalk);
          }
        };
    }
    return true;
  }

  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;

    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }

// Apply basic gravity
    velocity.y += gravity;

// Determine if ember has jumped
    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }

// Prevent ember from jumping to crazy fast as well as descending too fast and
// crashing through the ground or a platform.
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

    //==OFF SCREEN MOVEMENT===================================
    game.objectSpeed = 0;
    game.meters += velocity.x * dt / 64;

// Prevent ember from going backwards at screen edge.
    if (position.x - 36 <= 0 && horizontalDirection < 0) {
      velocity.x = 0;
    }
// Prevent ember from going beyond half screen.
    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      game.objectSpeed = -moveSpeed;
    }
    position += velocity * dt;

    // If ember fell in pit, then game over.
    if (position.y > game.size.y + size.y) {
      game.health = 0;
    }

    if (game.health <= 0) {
      removeFromParent();
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // If collision normal is almost upwards,
        // ember must be on ground.
        if (Vector2(0, -1).dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }

        // Resolve collision by moving ember along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }

    if (other is Star) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is WaterEnemy) {
      hit();
    }

    if (other is Petard || other is Explosion || other is Chicchetto){
      hit();
    }


    super.onCollision(intersectionPoints, other);
  }

  // This method runs an opacity effect on ember
// to make it blink.
  void hit() {
    if (!hitByEnemy) {
      game.health--;
      hitByEnemy = true;
    }
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 6,
        ),
      )..onComplete = () {
          hitByEnemy = false;
        },
    );
  }
}
