import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:idle_cutter/actors/chicchetto.dart';
import 'package:idle_cutter/objects/background.dart';

import 'Managers/segment_manager.dart';
import 'actors/ember.dart';
import 'actors/water_enemy.dart';
import 'objects/ground_block.dart';
import 'objects/platform_block.dart';
import 'objects/star.dart';
import 'overlays/hud.dart';

class EmberQuestGame extends FlameGame
    with  HasKeyboardHandlerComponents, HasCollisionDetection {
  EmberQuestGame();

  late EmberPlayer ember;
  double objectSpeed = 0.0;
  double meters = 0.0;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;
  int starsCollected = 0;
  int health = 3;
  var lastChichetto = DateTime.now().millisecondsSinceEpoch;
  var nextChichetto = 5000;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
      'dk.png',
      'pacman.png',
      'chicchetto.png',
      'petard.png',
      'explosion.png',
      'bk.png',
    ]);
    initializeGame(true);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255,66, 148, 237);
  }

  void initializeGame(bool loadHud) {
    add(Background(xOffset: 0));
    // add(Background(xOffset: size.y * 1.6344-3));
    // Assume that size.x < 3200
    final segmentsToLoad = (size.x / 640).ceil();

    loadGameSegments(0, 0.0);
    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(
          Random().nextInt(segments.length), (640 * (i + 1)).toDouble());
    }
    ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 128),
    );
    add(ember);
    if (loadHud) {
      add(Hud());
    }
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {

    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          add(GroundBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case PlatformBlock:
          add(PlatformBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case Star:
          add(Star(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case WaterEnemy:
          add(WaterEnemy(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
      }
    }
  }

  void reset() {
    meters = 0;
    starsCollected = 0;
    health = 3;
    initializeGame(false);
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    }

    if (DateTime.now().millisecondsSinceEpoch - lastChichetto >=
        nextChichetto) {
      nextChichetto =
          Random().nextInt(max(1000, 12000 - (starsCollected * 400))) + 1000;
      lastChichetto = DateTime.now().millisecondsSinceEpoch;
      add(Chicchetto(xOffset: 0));
    }

    super.update(dt);
  }
}
