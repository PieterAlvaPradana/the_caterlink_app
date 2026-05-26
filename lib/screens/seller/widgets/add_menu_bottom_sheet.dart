import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/app_colors.dart';
import '../../../data/seller_menu_repository.dart';
import '../../../models/seller_menu_item.dart';

/// Daftar kategori menu yang tersedia.
const List<String> _kCategories = [
  'Nasi',
  'Soup',
  'Noodles',
  'Meat',
  'Vegetables',
  'Drinks',
  'Snack',
  'Dessert',
  'Lainnya',
];

/// Daftar emoji per kategori untuk preview visual.
const Map<String, String> _kCategoryEmojis = {
  'Nasi': '🍚',
  'Soup': '🍲',
  'Noodles': '🍜',
  'Meat': '🍖',
  'Vegetables': '🥗',
  'Drinks': '🧋',
  'Snack': '🍿',
  'Dessert': '🍰',
  'Lainnya': '🍽️',
};

/// Bottom sheet untuk menambah atau mengedit menu seller.
///
/// Gunakan [showAddMenuBottomSheet] untuk menampilkan bottom sheet ini.
class AddMenuBottomSheet extends StatefulWidget {
  final String sellerId;
  final SellerMenuRepository repository;

  /// Jika tidak null, berarti mode edit.
  final SellerMenuItem? existingItem;

  const AddMenuBottomSheet({
    super.key,
    required this.sellerId,
    required this.repository,
    this.existingItem,
  });

  @override
  State<AddMenuBottomSheet> createState() => _AddMenuBottomSheetState();
}

class _AddMenuBottomSheetState extends State<AddMenuBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final AnimationController _animationController;

  String _selectedCategory = _kCategories.first;
  bool _isLoading = false;

  bool get _isEditMode => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    final item = widget.existingItem;

    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
    _priceController = TextEditingController(
      text: item != null ? item.price.toStringAsFixed(0) : '',
    );
    _selectedCategory = item?.category ?? _kCategories.first;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      final menuItem = SellerMenuItem(
        id: widget.existingItem?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        imageUrl: _kCategoryEmojis[_selectedCategory] ?? '🍽️',
        category: _selectedCategory,
        isAvailable: widget.existingItem?.isAvailable ?? true,
        createdAt: widget.existingItem?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditMode) {
        await widget.repository.updateMenu(widget.sellerId, menuItem);
      } else {
        await widget.repository.addMenu(widget.sellerId, menuItem);
      }

      if (mounted) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? '✅ Menu berhasil diperbarui'
                  : '✅ Menu berhasil ditambahkan',
            ),
            backgroundColor: kSuccessColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: ${e.message}'),
            backgroundColor: kDangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kTextSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: setOpacity(kPrimaryColor, 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isEditMode ? Icons.edit_rounded : Icons.add_rounded,
                        color: kPrimaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditMode ? 'Edit Menu' : 'Tambah Menu Baru',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kTextSecondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: kTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview kategori
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: setOpacity(kPrimaryColor, 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                _kCategoryEmojis[_selectedCategory] ?? '🍽️',
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Nama Menu
                        _buildLabel('Nama Menu'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Contoh: Nasi Goreng Spesial',
                          icon: Icons.restaurant_menu_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama menu wajib diisi';
                            }
                            if (value.trim().length < 3) {
                              return 'Minimal 3 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Deskripsi
                        _buildLabel('Deskripsi'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          hint: 'Deskripsi singkat menu...',
                          icon: Icons.description_rounded,
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Deskripsi wajib diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Harga
                        _buildLabel('Harga (Rp)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _priceController,
                          hint: 'Contoh: 25000',
                          icon: Icons.payments_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Harga wajib diisi';
                            }
                            final price = double.tryParse(value.trim());
                            if (price == null || price <= 0) {
                              return 'Harga harus lebih dari 0';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Kategori dropdown
                        _buildLabel('Kategori'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.category_rounded,
                                color: kPrimaryColor.withValues(alpha: 0.7),
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            items: _kCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Text(
                                      _kCategoryEmojis[category] ?? '🍽️',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        color: kTextPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCategory = value);
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              disabledBackgroundColor:
                                  setOpacity(kPrimaryColor, 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                              shadowColor: setOpacity(kPrimaryColor, 0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _isEditMode
                                        ? 'Simpan Perubahan'
                                        : 'Tambah Menu',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kTextSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14, color: kTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: kTextSecondary.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: kPrimaryColor.withValues(alpha: 0.7),
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kDangerColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kDangerColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

/// Helper function untuk menampilkan bottom sheet.
Future<bool?> showAddMenuBottomSheet(
  BuildContext context, {
  required String sellerId,
  required SellerMenuRepository repository,
  SellerMenuItem? existingItem,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddMenuBottomSheet(
      sellerId: sellerId,
      repository: repository,
      existingItem: existingItem,
    ),
  );
}
