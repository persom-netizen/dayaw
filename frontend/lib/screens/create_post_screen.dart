import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/image_preview_widget.dart';

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

  final List<String> _categories = ['Paskil', 'Kard', 'Pod', 'Tunog'];
  String _selectedCategory = 'Paskil';

  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  XFile? _selectedImage;

  // Colors based on your Dayaw theme
  static const Color primaryGold = Color(0xFFFFDF00);
  static const Color darkText = Color(0xFF554141);
  static const Color softBg = Color(0xFFFFF9F4);

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'Paskil': 
      return Icons.auto_awesome_outlined; // Sparkles for new posts
    case 'Kard': 
      return Icons.style_outlined; // Corrected lowercase 's' for card/style icon
    case 'Pod': 
      return Icons.podcasts_rounded; // Specific podcast icon
    case 'Tunog': 
      return Icons.music_note_rounded; // Music note for sounds
    default: 
      return Icons.grid_view_rounded;
  }
}

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      String? uploadedImageUrl;
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        uploadedImageUrl = await Provider.of<PostProvider>(context, listen: false)
            .uploadImage(_selectedImage!);
      }

      await Provider.of<PostProvider>(context, listen: false).createPost(
        username: widget.username,
        category: _selectedCategory.toLowerCase(),
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: uploadedImageUrl,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: softBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bagong Likha',
          style: GoogleFonts.playfairDisplay(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: darkText,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isSubmitting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Ibahagi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CATEGORY SELECTOR ---
              Text("KATEGORYA", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: darkText.withOpacity(0.5), letterSpacing: 1.2)),
              const SizedBox(height: 12),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryGold : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: isSelected ? primaryGold : Colors.grey.withOpacity(0.2)),
                          boxShadow: isSelected ? [BoxShadow(color: primaryGold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                        ),
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(cat), size: 18, color: darkText),
                            const SizedBox(width: 8),
                            Text(cat, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: darkText)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // --- TITLE INPUT ---
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
                decoration: InputDecoration(
                  hintText: _selectedCategory == 'Kard' ? 'Pamagat ng Pananaliksik...' : 'Isulat ang Pamagat...',
                  hintStyle: TextStyle(color: darkText.withOpacity(0.3)),
                  border: InputBorder.none,
                ),
              ),
              const Divider(thickness: 1),

              // --- CONTENT INPUT ---
              TextFormField(
                controller: _contentController,
                maxLines: null,
                minLines: 6,
                style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: darkText),
                decoration: InputDecoration(
                  hintText: _selectedCategory == 'Paskil' ? 'Ano ang iyong balita?' : 'Ibahagi ang iyong kaalaman...',
                  hintStyle: TextStyle(color: darkText.withOpacity(0.3)),
                  border: InputBorder.none,
                ),
                validator: (val) => val == null || val.isEmpty ? 'Hindi maaaring walang laman...' : null,
              ),

              const SizedBox(height: 20),

              // --- IMAGE PREVIEW ---
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ImagePreviewWidget(
                        imageFile: _selectedImage!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      // --- BOTTOM MEDIA TOOLBAR ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10, left: 20, right: 20, top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            _actionIconButton(Icons.image_outlined, "Larawan", _pickImage),
            const SizedBox(width: 15),
            if (_selectedCategory == 'Pod' || _selectedCategory == 'Tunog')
              _actionIconButton(Icons.mic_none_rounded, "Boses", () {}),
            const Spacer(),
            Text("${_contentController.text.length} / ${_selectedCategory == 'Paskil' ? 280 : 5000}", 
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _actionIconButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: darkText),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: darkText)),
          ],
        ),
      ),
    );
  }
}