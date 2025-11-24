import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  final String username;

  const CreatePostScreen({super.key, required this.username});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Note: Local file paths cannot be used with NetworkImage
      // In a production app, you would upload this to a server and get a URL back
      // For now, we'll clear the field and show a helpful message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected. Upload functionality requires backend implementation. Please enter an image URL instead.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Provider.of<PostProvider>(context, listen: false).createPost(
        username: widget.username,
        title: _titleController.text.trim().isEmpty 
            ? null 
            : _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty 
            ? null 
            : _imageUrlController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matagumpay na nailagay ang post!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('May error sa paglikha ng post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lumikha ng Post'),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field (optional)
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'pamagat (opsyonal)',
                    border: OutlineInputBorder(),
                    hintText: 'Maglagay ng pamagat',
                  ),
                  maxLength: 255,
                ),
                const SizedBox(height: 16),
                
                // Content field (required)
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'ano ang iyong nais isulat?',
                    border: OutlineInputBorder(),
                    hintText: 'Ibahagi ang iyong saloobin...',
                  ),
                  maxLines: 10,
                  maxLength: 10000,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hindi maaaring walang laman';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Image URL field
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'nais mag dagdag ng larawan (opsyonal)',
                    border: const OutlineInputBorder(),
                    hintText: 'Ilagay ang URL ng larawan',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: _pickImage,
                      tooltip: 'Pumili mula sa gallery',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'ilaganap',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
