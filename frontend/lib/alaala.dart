import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AlaalaPage extends StatefulWidget {
  final String username;
  const AlaalaPage({super.key, required this.username});

  @override
  State<AlaalaPage> createState() => _AlaalaPageState();
}

class _AlaalaPageState extends State<AlaalaPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _todayTrivia;
  List<dynamic> _allTrivias = [];
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadTodayTrivia();
  }

  Future<void> _loadTodayTrivia() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final trivia = await ApiService.getAlaalToday();

      if (!mounted) return;

      if (trivia['success'] == true) {
        setState(() => _todayTrivia = trivia);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading trivia: $e')));
    } finally {
      if (!mounted) return;

      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllTrivias() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAllAlaal(limit: 100);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _allTrivias = result['trivias'] ?? []);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading trivias: $e')));
    } finally {
      if (!mounted) return;

      setState(() => _isLoading = false);
    }
  }

  void _toggleShowAll() {
    if (!_showAll) {
      _loadAllTrivias();
    }
    setState(() => _showAll = !_showAll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showAll
          ? _buildAllTriviasView()
          : _buildTodayView(),
    );
  }

  Widget _buildTodayView() {
    if (_todayTrivia == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Walang Alaala ngayong araw',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodayTrivia,
              child: const Text('Mag-retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Center(
            child: Text(
              'Alam mo ba?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Trivia Card
          Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _todayTrivia?['alammoba'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    _todayTrivia?['deskription'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _loadTodayTrivia,
                icon: const Icon(Icons.refresh),
                label: const Text('I-refresh'),
              ),
              ElevatedButton.icon(
                onPressed: _toggleShowAll,
                icon: const Icon(Icons.history),
                label: const Text('Lahat'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllTriviasView() {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.blue[600],
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lahat ng Alaala',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _toggleShowAll,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // Trivias List
        Expanded(
          child: _allTrivias.isEmpty
              ? const Center(child: Text('Walang Alaala'))
              : ListView.builder(
                  itemCount: _allTrivias.length,
                  itemBuilder: (context, index) {
                    final trivia = _allTrivias[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          trivia['alammoba'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          trivia['deskription'] ?? 'N/A',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _showTriviaDetails(trivia),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showTriviaDetails(Map<String, dynamic> trivia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trivia['alammoba'] ?? 'N/A'),
        content: SingleChildScrollView(
          child: Text(trivia['deskription'] ?? 'N/A'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Isara'),
          ),
        ],
      ),
    );
  }
}
