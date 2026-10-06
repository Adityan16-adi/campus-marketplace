import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../screens/listing/listing_details_screen.dart';
import 'app_helpers.dart';

class ListingCard extends ConsumerWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  const ListingCard({
    super.key,
    required this.doc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = doc.data();

    final title = data['title']?.toString() ?? 'Untitled';
    final category = data['category']?.toString() ?? 'Other';
    final condition = data['condition']?.toString() ?? 'Used';
    final price = data['price'] ?? 0;
    final imageUrl = data['imageUrl']?.toString();

    final wishlist = ref.watch(wishlistProvider);
    final liked = wishlist.contains(doc.id);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailsScreen(
              doc: doc,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 190,
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
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(.92),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        final updated = {...wishlist};

                        if (liked) {
                          updated.remove(doc.id);
                        } else {
                          updated.add(doc.id);
                        }

                        ref.read(wishlistProvider.notifier).state = updated;
                      },
                      icon: Icon(
                        liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: liked ? Colors.redAccent : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '₹$price',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _smallTag(context, category),
                      const SizedBox(width: 6),
                      _smallTag(context, condition),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}