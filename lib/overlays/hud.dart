import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../ember_quest.dart';
import 'heart.dart';

class Hud extends PositionComponent with HasGameRef<EmberQuestGame> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  }) {
    positionType = PositionType.viewport;
  }

  late TextComponent _scoreTextComponent;
  late TextComponent _metersTextComponent;

  @override
  Future<void>? onLoad() async {
    for (var i = 1; i <= game.health; i++) {
      final positionX = 40 * i;
      await add(
        HeartHealthComponent(
          heartNumber: i,
          position: Vector2(positionX.toDouble(), 20),
          size: Vector2.all(32),
        ),
      );
    }

    var meters = game.meters.toInt();
    _metersTextComponent = TextComponent(
      text: '${meters - meters % 5}m',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'poxel-font',
          fontSize: 44,
          color: Color.fromRGBO(34, 34, 34, 1),
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(game.size.x / 2, 20),
    );
    add(_metersTextComponent);

    final starSprite = await game.loadSprite('star.png');
    add(
      SpriteComponent(
        sprite: starSprite,
        position: Vector2(game.size.x - 100, 20),
        size: Vector2.all(32),
        anchor: Anchor.center,
      ),
    );
    _scoreTextComponent = TextComponent(
      text: '${game.starsCollected}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'poxel-font',
          fontSize: 36,
          color: Color.fromRGBO(34, 34, 34, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x - 60, 20),
    );
    add(_scoreTextComponent);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    var meters = game.meters.toInt();
    _metersTextComponent.text = '${meters - meters % 5}m';
    _scoreTextComponent.text = '${game.starsCollected}';
    super.update(dt);
  }
}
