import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  bool _isUploadingImage = false;
  XFile? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() => _selectedImage = image);
        print("[INFO] Image selected: ${image.name}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Napili: ${image.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("[ERROR] Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error picking image: $e')));
      }
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? uploadedImageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        print("[INFO] Starting image upload...");
        setState(() => _isUploadingImage = true);

        uploadedImageUrl = await Provider.of<PostProvider>(
          context,
          listen: false,
        ).uploadImage(_selectedImage!);

        setState(() => _isUploadingImage = false);
        print("[SUCCESS] Image uploaded: $uploadedImageUrl");
      } else if (_imageUrlController.text.trim().isNotEmpty) {
        uploadedImageUrl = _imageUrlController.text.trim();
        print("[INFO] Using provided image URL: $uploadedImageUrl");
      }

      // Create post
      print("[INFO] Creating post...");
      await Provider.of<PostProvider>(context, listen: false).createPost(
        username: widget.username,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: uploadedImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Matagumpay na nailagay ang post!'),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      print("[ERROR] Error creating post: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ May error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploadingImage = false;
        });
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
                    labelText: 'Pamagat (opsyonal)',
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
                    labelText: 'Ano ang iyong nais isulat?',
                    border: OutlineInputBorder(),
                    hintText: 'Ibahagi ang iyong saloohin...',
                  ),
                  maxLines: 8,
                  maxLength: 10000,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hindi maaaring walang laman ang content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image URL field (as alternative)
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'O maglagay ng image URL (opsyonal)',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/image.jpg',
                  ),
                ),
                const SizedBox(height: 16),

                // Selected image preview
                if (_selectedImage != null)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImage!.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedImage!.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _selectedImage = null),
                            child: const Text('🗑️ Tanggalin ang larawan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Image picker button
                ElevatedButton.icon(
                  onPressed: _isUploadingImage ? null : _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text(
                    _isUploadingImage
                        ? 'Nag-uupload...'
                        : 'Nais mag dagdag ng larawan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting || _isUploadingImage
                      ? null
                      : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _isUploadingImage ? 'Nag-uupload...' : 'Ilaganap',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
