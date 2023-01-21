import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'dart:math' as math;
import '../ember_quest.dart';
import 'explosion.dart';

class Petard extends SpriteAnimationComponent
    with CollisionCallbacks,HasGameRef<EmberQuestGame> {
  final Vector2 startPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();
  double get  speed=>6 + game.starsCollected*2;
  double horizontalSpeed=math.Random().nextDouble()*300-200;

  Petard({
    required this.startPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('petard.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        textureSize: Vector2.all(256),
        stepTime: 0.10,
      ),
    );
    anchor=Anchor.center;
    position = Vector2(
      (startPosition.x) + xOffset + (size.x / 2),
      (startPosition.y) + (size.y / 2),
    );
    add(RectangleHitbox()..collisionType = CollisionType.active);
    add(
      RotateEffect.by(
        180+30.0*game.starsCollected,
        EffectController(
          duration: math.Random().nextInt(10)+3,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    velocity.x = horizontalSpeed+game.objectSpeed;
    velocity.y += speed;
    position += velocity * dt;

    if (position.y < -size.y || game.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    game.add(Explosion(startPosition: position));
    removeFromParent();

    super.onCollision(intersectionPoints, other);
  }
}