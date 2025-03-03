import 'package:flame/game.dart';
import 'package:flame/flame.dart';

class KlondikeGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprines.png');
  }
}
