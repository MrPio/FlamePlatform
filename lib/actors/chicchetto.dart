import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:idle_cutter/objects/petard.dart';

import '../ember_quest.dart';

class Chicchetto extends SpriteComponent
    with HasGameRef<EmberQuestGame> {
  double xOffset;

  final Vector2 velocity = Vector2.zero();
  double get  speed=>-250.0 - game.starsCollected*30;
  bool dropped=false;
  double get dropOffset=>Random().nextDouble()*(max(2,60-game.starsCollected*5));

  Chicchetto({
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    sprite=Sprite(game.images.fromCache('chicchetto.png'));

    anchor=Anchor.center;
    position = Vector2(
      game.size.x,
      Random().nextInt(100)+50,
    );
    // add(RectangleHitbox()..collisionType = CollisionType.passive);
    add(
      MoveEffect.by(
        Vector2(0, -.5 * size.x),
        EffectController(
          duration: .5,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut
        ),
      ),
    );
    scale=Vector2(1.5, 1.5);
  }

  @override
  void update(double dt) {
    velocity.x = speed+game.objectSpeed;
    position += velocity * dt;

    if(!dropped &&
        (position.x-game.ember.position.x).abs()<dropOffset){
      dropPetard();dropped=true;
    }

    if (position.x < -size.x || game.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }

  void dropPetard(){
    game.add(Petard(startPosition: position, xOffset: 0));
  }
}