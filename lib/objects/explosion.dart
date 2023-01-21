import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'dart:math' as math;
import '../ember_quest.dart';

class Explosion extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame> {
  final Vector2 startPosition;

  final Vector2 velocity = Vector2.zero();

  Explosion({
    required this.startPosition,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('explosion.png'),
      SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2.all(192),
          stepTime: 0.1,
          loop: false),
    )..onComplete = () {
        removeFromParent();
      };
    anchor = Anchor.center;
    position = Vector2(
      (startPosition.x) + (size.x / 2),
      (startPosition.y) + (size.y / 2),
    );
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    scale=Vector2(1.5, 1.5);
    add(
      ScaleEffect.by(
        Vector2(1.75, 1.75),
        EffectController(
          duration: 0.7,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;

    super.update(dt);
  }
}
