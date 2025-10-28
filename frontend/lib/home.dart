// home.dart
import 'package:flutter/material.dart';
import 'main.dart';
import 'services/api_service.dart';

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

  Future<void> _testDbConnection() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.testDbConnection();
      setState(() => _dbStatus = result['ok'] ? 'Connected' : 'Error: ${result['error']}');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
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
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${widget.username}")),
      body: Padding(
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
                      Text("Hello, ${widget.username}!", 
                           style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainPage()),
                        ),
                        child: const Text("Logout"),
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
                      const Text("API Testing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        ...(_users.take(3).map((user) => ListTile(
                          title: Text(user['username']),
                          subtitle: Text(user['email']),
                        ))),
                      ],
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _askOpenAI,
                        child: const Text("Ask OpenAI"),
                      ),
                      if (_openAIResponse.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text("OpenAI Response:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_openAIResponse),
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
      ),
    );
  }
}
