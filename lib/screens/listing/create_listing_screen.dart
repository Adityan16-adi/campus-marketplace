import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/app_text_field.dart';
class CreateListingScreen extends ConsumerStatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? existing;

  const CreateListingScreen({
    super.key,
    this.existing,
  });

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState
    extends ConsumerState<CreateListingScreen> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  String category = 'Books';
  String condition = 'Good';

  Uint8List? imageBytes;
  String? imageName;
  String? existingImageUrl;

  bool loading = false;

  final categories = [
    'Books',
    'Electronics',
    'Furniture',
    'Notes',
    'Other',
  ];

  final conditions = [
    'New',
    'Like New',
    'Good',
    'Used',
  ];

  bool get editing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final data = widget.existing?.data();

    if (data != null) {
      titleController.text = data['title']?.toString() ?? '';
      priceController.text = data['price']?.toString() ?? '';
      descriptionController.text =
          data['description']?.toString() ?? '';

      category = data['category']?.toString() ?? 'Books';
      condition = data['condition']?.toString() ?? 'Good';

      existingImageUrl = data['imageUrl']?.toString();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      imageBytes = bytes;
      imageName = file.name;
    });
  }

  Future<String?> uploadImage() async {
    if (imageBytes == null) {
      return existingImageUrl;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child('listings')
        .child(uid)
        .child(
          '${DateTime.now().millisecondsSinceEpoch}_$imageName',
        );

    await ref.putData(
      imageBytes!,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }

  Future<void> saveListing() async {
    if (titleController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      _message('Please enter a title and price.');
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      final imageUrl = await uploadImage();

      final data = <String, dynamic>{
        'title': titleController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0,
        'description': descriptionController.text.trim(),
        'category': category,
        'condition': condition,
        'sellerId': user.uid,
        'sellerName': user.displayName ?? 'Campus Seller',
        'sellerEmail': user.email ?? '',
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (editing) {
        await FirebaseFirestore.instance
            .collection('listings')
            .doc(widget.existing!.id)
            .update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('listings')
            .add(data);
      }

      if (mounted) {
        _message(
          editing
              ? 'Listing updated successfully!'
              : 'Listing published successfully!',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      _message('Could not save listing. Please try again.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? 'Edit Listing' : 'Sell an Item',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagePicker(context),

                const SizedBox(height: 24),

                AppTextField(
                  controller: titleController,
                  label: 'What are you selling?',
                  hint: 'e.g. Engineering Mathematics Book',
                  icon: Icons.shopping_bag_outlined,
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: priceController,
                  label: 'Price',
                  hint: 'Enter price',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                _dropdown(
                  context,
                  label: 'Category',
                  value: category,
                  items: categories,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => category = value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                _dropdown(
                  context,
                  label: 'Condition',
                  value: condition,
                  items: conditions,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => condition = value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'Tell buyers something useful about your item...',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: loading ? null : saveListing,
                    icon: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.publish_rounded),
                    label: Text(
                      loading
                          ? 'Publishing...'
                          : editing
                              ? 'Update Listing'
                              : 'Publish Listing',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _imagePicker(BuildContext context) {
    return InkWell(
      onTap: pickImage,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(.18),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageBytes != null
            ? Image.memory(
                imageBytes!,
                fit: BoxFit.cover,
              )
            : existingImageUrl != null &&
                    existingImageUrl!.isNotEmpty
                ? Image.network(
                    existingImageUrl!,
                    fit: BoxFit.cover,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 52,
                        color:
                            Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Add Photos',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tap to choose an image',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_outlined),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}





