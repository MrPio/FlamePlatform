import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'dart:math' as math;
import '../ember_quest.dart';
import '../objects/explosion.dart';
import '../objects/petard.dart';

class WaterEnemy extends SpriteAnimationComponent
    with CollisionCallbacks,HasGameRef<EmberQuestGame> {
  final Vector2 gridPosition;
  double xOffset;
  bool dying=false;

  final Vector2 velocity = Vector2.zero();

  WaterEnemy({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('dk.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        textureSize: Vector2.all(512),
        stepTime: 0.70,
      ),
    );
    anchor=Anchor.center;
    position = Vector2(
      (gridPosition.x * size.x) + xOffset + (size.x / 2),
      game.size.y - (gridPosition.y * size.y) - (size.y / 2),
    );
    add(RectangleHitbox()..collisionType = CollisionType.active);
    add(
      MoveEffect.by(
        Vector2(-2 * size.x, 0),
        EffectController(
          duration: 1/(0.5+game.starsCollected*0.35),
          alternate: true,
          infinite: true,
        ),
      ),
    );
    scale=Vector2(1.75, 1.75);
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;

    if (position.x < -size.x || game.health <= 0) {
      removeFromParent();
    }

    if ((game.ember.position.y-position.y).abs()<32 && (game.ember.position.x-position.x).abs()<128){
      scale=Vector2(1.85, 1.85);
    }
    else{
      scale=Vector2(1.75, 1.75);

    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!dying && (other is Petard || other is Explosion)){
      dying=true;
      add(
        RotateEffect.by(
          pi*8,
          EffectController(
            duration: 0.5,
          ),
        )..onComplete = () {
          removeFromParent();
        },
      );
    }

    super.onCollision(intersectionPoints, other);
  }

}