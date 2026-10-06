import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../widgets/app_helpers.dart';

class ListingDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  const ListingDetailsScreen({
    super.key,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();

    final title = data['title']?.toString() ?? 'Untitled';
    final description = data['description']?.toString() ?? '';
    final category = data['category']?.toString() ?? 'Other';
    final condition = data['condition']?.toString() ?? 'Used';
    final sellerName =
        data['sellerName']?.toString() ?? 'Campus seller';
    final sellerEmail = data['sellerEmail']?.toString() ?? '';
    final price = data['price'] ?? 0;
    final imageUrl = data['imageUrl']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final liked =
                  ref.watch(wishlistProvider).contains(doc.id);

              return IconButton(
                onPressed: () {
                  final current =
                      {...ref.read(wishlistProvider)};

                  if (liked) {
                    current.remove(doc.id);
                  } else {
                    current.add(doc.id);
                  }

                  ref.read(wishlistProvider.notifier).state = current;
                },
                icon: Icon(
                  liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: liked ? Colors.redAccent : null,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            imagePlaceholder(context),
                      )
                    : imagePlaceholder(context),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title,
              style:
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
            ),

            const SizedBox(height: 8),

            Text(
              '₹$price',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                _detailTag(context, category),
                const SizedBox(width: 8),
                _detailTag(context, condition),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'Description',
              style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
            ),

            const SizedBox(height: 10),

            Text(
              description.isEmpty
                  ? 'No description provided.'
                  : description,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Seller',
              style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      child: Text(
                        sellerName.isNotEmpty
                            ? sellerName[0].toUpperCase()
                            : 'S',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          if (sellerEmail.isNotEmpty)
                            Text(
                              sellerEmail,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}