import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

import '../ember_quest.dart';

class Background extends SpriteComponent with HasGameRef<EmberQuestGame> {
  double xOffset;
  final Vector2 velocity = Vector2.zero();

  Background({
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    super.size = Vector2(game.size.y * 12.116129, game.size.y);
    final platformImage = game.images.fromCache('bk.png');
    sprite = Sprite(platformImage);
    position = Vector2(
      0+xOffset,
      game.size.y - 50,
    );
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed*.5;
    position += velocity * dt;
    if (position.x <= -size.x/2 || game.health <= 0) {
      position.x=0;
    }
    super.update(dt);
  }
}
