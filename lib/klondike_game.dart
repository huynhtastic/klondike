import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show RRect, Rect, Radius;

import 'components/card.dart';
import 'components/foundation_pile.dart';
import 'components/tableau_pile.dart';
import 'components/stock_pile.dart';
import 'components/waste_pile.dart';

const spriteFile = 'klondike-sprites.png';

class KlondikeGame extends FlameGame {
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  @override
  Future<void> onLoad() async {
    await Flame.images.load(spriteFile);
    final stock =
        StockPile()
          ..size = cardSize
          ..position = Vector2(cardGap, cardGap);

    final waste =
        WastePile()
          ..size = cardSize
          ..position = Vector2(cardWidth + 2 * cardGap, cardGap);

    final foundations = List.generate(
      4,
      (i) =>
          FoundationPile(i)
            ..size = cardSize
            ..position = Vector2(
              (i + 3) * (cardWidth + cardGap) + cardGap,
              cardGap,
            ),
    );

    final piles = List.generate(
      7,
      (i) =>
          TableauPile()
            ..size = cardSize
            ..position = Vector2(
              cardGap + i * (cardWidth + cardGap),
              cardHeight + 2 * cardGap,
            ),
    );

    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);

    final worldWidth = cardWidth * 7 + cardGap * 8;
    final worldHeight = 4 * cardHeight + 3 * cardGap;

    camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight);
    camera.viewfinder.position = Vector2(worldWidth / 2, 0);
    camera.viewfinder.anchor = Anchor.topCenter;

    // this was only used to generate the initial layout for debugging
    // final random = Random();
    // for (var i = 0; i < 7; i++) {
    //   for (var j = 0; j < 4; j++) {
    //     final card =
    //         Card(random.nextInt(13) + 1, random.nextInt(4))
    //           ..position = Vector2(100 + i * 1150, 100 + j * 1500)
    //           ..addToParent(world);
    //     if (random.nextDouble() < 0.9) {
    //       // flip face up with 90% probability
    //       card.flip();
    //     }
    //   }
    // }
    final cards = [
      for (var rank = 1; rank <= 13; rank++)
        for (var suit = 0; suit < 4; suit++) Card(rank, suit),
    ];
    cards.shuffle();
    world.addAll(cards);

    int cardToDeal = cards.length - 1;
    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        piles[j].acquireCard(cards[cardToDeal--]);
      }
      piles[i].flipTopCard();
    }
    for (int n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache(spriteFile),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
