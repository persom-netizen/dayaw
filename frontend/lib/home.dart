// frontend/lib/pages/home.dart
import 'package:flutter/material.dart';
import 'main.dart';
import 'services/api_service.dart';
import 'pages/ai.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String _dbStatus = '';
  List<dynamic> _users = [];
  String _openAIResponse = '';
  int _currentIndex = 0;

  Future<void> _testDbConnection() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.testDbConnection();
      setState(
        () => _dbStatus = result['ok']
            ? 'Connected'
            : 'Error: ${result['error']}',
      );
    } catch (e) {
      setState(() => _dbStatus = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await ApiService.getUsers();
      setState(() => _users = users);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _askOpenAI() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask OpenAI'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your question'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Ask'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.askOpenAI(result);
        setState(() => _openAIResponse = response['answer'] ?? 'No response');
      } catch (e) {
        setState(() => _openAIResponse = 'Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildBahayPage(), // Index 0
      _buildAlaalaPage(), // Index 1
      _buildSalitaPage(), // Index 2
      _buildGaleriyaPage(), // Index 3
      _buildSulatinPage(), // Index 4
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${widget.username}")),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bahay'),
          BottomNavigationBarItem(icon: Icon(Icons.memory), label: 'Alaala'),
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'Salita'),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeriya',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Sulatin'),
        ],
      ),
    );
  }

  Widget _buildBahayPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Hello, ${widget.username}!",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainPage()),
                      ),
                      child: const Text("Logout"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIPage(username: widget.username),
                        ),
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text("Chat with AI"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "API Testing",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testDbConnection,
                      child: const Text("Test Database Connection"),
                    ),
                    if (_dbStatus.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text("DB Status: $_dbStatus"),
                    ],
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loadUsers,
                      child: const Text("Load Users"),
                    ),
                    if (_users.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text("Users loaded: ${_users.length}"),
                    ],
                    if (_isLoading) ...[
                      const SizedBox(height: 10),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlaalaPage() {
    return const Center(child: Text('Alaala (Trivia) Page - Coming Soon'));
  }

  Widget _buildSalitaPage() {
    return const Center(child: Text('Salita (Daily Words) Page - Coming Soon'));
  }

  Widget _buildGaleriyaPage() {
    return const Center(child: Text('Galeriya (Gallery) Page - Coming Soon'));
  }

  Widget _buildSulatinPage() {
    return const Center(child: Text('Sulatin (Writing) Page - Coming Soon'));
  }
}
