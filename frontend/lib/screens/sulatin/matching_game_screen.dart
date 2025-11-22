import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatchingGameScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;

  const MatchingGameScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen>
    with TickerProviderStateMixin {
  // Game state
  late List<GameCard> _cards;
  List<int> _selectedIndices = [];
  Set<int> _matchedIndices = {};
  int _score = 0;
  int _attempts = 0;
  late DateTime _startTime;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  bool _isProcessing = false;

  // Animation controllers
  final Map<int, AnimationController> _flipControllers = {};

  // Card pairs - Katinig with Patinig
  static const List<Map<String, String>> _cardPairs = [
    {'katinig': 'K', 'combined': 'KA'},
    {'katinig': 'P', 'combined': 'PA'},
    {'katinig': 'T', 'combined': 'TA'},
    {'katinig': 'N', 'combined': 'NA'},
    {'katinig': 'D', 'combined': 'DA'},
    {'katinig': 'B', 'combined': 'BA'},
    {'katinig': 'M', 'combined': 'MA'},
    {'katinig': 'L', 'combined': 'LA'},
    {'katinig': 'G', 'combined': 'GA'},
    {'katinig': 'S', 'combined': 'SA'},
    {'katinig': 'H', 'combined': 'HA'},
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeGame();
    _startTimer();
  }

  void _initializeGame() {
    // Take first 6 pairs for the game
    final selectedPairs = _cardPairs.take(6).toList();
    
    // Create cards from pairs
    List<GameCard> cards = [];
    for (int i = 0; i < selectedPairs.length; i++) {
      final pair = selectedPairs[i];
      cards.add(GameCard(
        id: i * 2,
        value: pair['katinig']!,
        pairId: i,
        type: CardType.katinig,
      ));
      cards.add(GameCard(
        id: i * 2 + 1,
        value: pair['combined']!,
        pairId: i,
        type: CardType.combined,
      ));
    }

    // Shuffle cards
    cards.shuffle(Random());
    _cards = cards;

    // Initialize flip controllers
    for (int i = 0; i < _cards.length; i++) {
      _flipControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    for (var controller in _flipControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCardTap(int index) {
    if (_isProcessing ||
        _matchedIndices.contains(index) ||
        _selectedIndices.contains(index)) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _selectedIndices.add(index);
      _flipControllers[index]!.forward();
    });

    if (_selectedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isProcessing = true;
    _attempts++;

    final firstIndex = _selectedIndices[0];
    final secondIndex = _selectedIndices[1];
    final firstCard = _cards[firstIndex];
    final secondCard = _cards[secondIndex];

    Future.delayed(const Duration(milliseconds: 500), () {
      if (firstCard.pairId == secondCard.pairId) {
        // Match found!
        HapticFeedback.heavyImpact();
        setState(() {
          _matchedIndices.add(firstIndex);
          _matchedIndices.add(secondIndex);
          _score += 10;
          _selectedIndices.clear();
          _isProcessing = false;
        });

        // Check if game is complete
        if (_matchedIndices.length == _cards.length) {
          _gameTimer?.cancel();
          _showWinDialog();
        }
      } else {
        // No match
        HapticFeedback.lightImpact();
        _flipControllers[firstIndex]!.reverse();
        _flipControllers[secondIndex]!.reverse();
        setState(() {
          _selectedIndices.clear();
          _isProcessing = false;
        });
      }
    });
  }

  void _showWinDialog() {
    final totalTime = _elapsedSeconds;
    final minutes = totalTime ~/ 60;
    final seconds = totalTime % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber[700], size: 32),
            const SizedBox(width: 12),
            const Text(
              'Natapos mo!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mahusay! Natapos mo ang laro!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Iskor:'),
                      Text(
                        '$_score puntos',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mga pagsubok:'),
                      Text(
                        '$_attempts',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Oras:'),
                      Text(
                        '${minutes}m ${seconds}s',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Maglaro Muli'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {
                'completed': true,
                'score': _score,
                'attempts': _attempts,
                'time': _elapsedSeconds,
              });
            },
            child: const Text('Ipagpatuloy'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    _gameTimer?.cancel();
    setState(() {
      _matchedIndices.clear();
      _selectedIndices.clear();
      _score = 0;
      _attempts = 0;
      _elapsedSeconds = 0;
      _isProcessing = false;
      _initializeGame();
      _startTimer();
    });
  }

  String _formatTime() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.orange[600],
      ),
      body: Column(
        children: [
          // Game stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border(
                bottom: BorderSide(color: Colors.orange[200]!, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.star, 'Iskor', '$_score'),
                _buildStatItem(Icons.refresh, 'Mga Pagsubok', '$_attempts'),
                _buildStatItem(Icons.timer, 'Oras', _formatTime()),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Itugma ang katinig sa tamang kombinasyon',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Game grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange[900],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    final isMatched = _matchedIndices.contains(index);
    final isSelected = _selectedIndices.contains(index);
    final isFlipped = isMatched || isSelected;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedBuilder(
        animation: _flipControllers[index]!,
        builder: (context, child) {
          final angle = _flipControllers[index]!.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < pi / 2
                ? _buildCardBack(isMatched)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFront(card, isMatched),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack(bool isMatched) {
    return Container(
      decoration: BoxDecoration(
        color: isMatched ? Colors.green[100] : Colors.orange[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched ? Colors.green : Colors.orange[700]!,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isMatched ? Icons.check_circle : Icons.extension,
          size: 40,
          color: isMatched ? Colors.green[700] : Colors.white,
        ),
      ),
    );
  }

  Widget _buildCardFront(GameCard card, bool isMatched) {
    final color = card.type == CardType.katinig
        ? Colors.blue[100]
        : Colors.purple[100];
    final borderColor = card.type == CardType.katinig
        ? Colors.blue[700]
        : Colors.purple[700];

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched ? Colors.green : borderColor!,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.type == CardType.katinig ? 'Katinig' : 'Kombinasyon',
            style: TextStyle(
              fontSize: 10,
              color: borderColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

enum CardType {
  katinig,
  combined,
}

class GameCard {
  final int id;
  final String value;
  final int pairId;
  final CardType type;

  GameCard({
    required this.id,
    required this.value,
    required this.pairId,
    required this.type,
  });
}
