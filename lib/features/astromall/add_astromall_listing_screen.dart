import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class AddAstromallListingScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialPrice;
  final String? initialCategory;
  final bool isEditing;

  const AddAstromallListingScreen({
    super.key,
    this.initialTitle,
    this.initialPrice,
    this.initialCategory,
    this.isEditing = false,
  });

  @override
  State<AddAstromallListingScreen> createState() => _AddAstromallListingScreenState();
}

class _AddAstromallListingScreenState extends State<AddAstromallListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  File? _selectedImage;

  final List<String> _categories = [
    'Gemstone',
    'Vastu',
    'Rudraksha',
    'Puja Service',
    'Astrology Service'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _titleController.text = widget.initialTitle ?? '';
      _priceController.text = widget.initialPrice ?? '';
      if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
        _selectedCategory = widget.initialCategory;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.isEditing ? 'Edit Listing' : 'Add New Listing',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Placeholder
              Center(
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.grey.shade400, size: 30),
                              const SizedBox(height: 8),
                              AppText('Add Photo', color: Colors.grey.shade500, fontSize: 12),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Title Field
              _buildLabel('Listing Title'),
              _buildTextField(
                controller: _titleController,
                hintText: 'e.g., Vastu Consultation for Home',
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              _buildLabel('Category'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: AppText('Select Category', color: Colors.grey.shade400, fontSize: 14),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: AppText(category, fontSize: 14, color: Colors.black87),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Price Field
              _buildLabel('Price (₹)'),
              _buildTextField(
                controller: _priceController,
                hintText: 'e.g., 500',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.currency_rupee, size: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Description Field
              _buildLabel('Description'),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Describe your listing...',
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // if (_formKey.currentState!.validate()) { ... }
                    Get.back();
                    Get.snackbar(
                      'Success',
                      widget.isEditing ? 'Listing updated successfully' : 'Listing added successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade600,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: AppText(widget.isEditing ? 'Update Item' : 'List Item', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: AppText(text, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: prefixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
        ),
      ),
    );
  }
}
