import 'phrase_card.dart';

class Player {
  final String name;
  int score;
  List<PhraseCard> completedCards;

  Player({
    required this.name,
    this.score = 0,
    this.completedCards = const [],
  });
}
