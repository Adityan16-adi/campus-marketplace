import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../widgets/app_helpers.dart';
import '../../widgets/listing_card.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final search = ref.watch(searchProvider).toLowerCase();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find exactly what you need.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              onChanged: (value) {
                ref.read(searchProvider.notifier).state = value;
              },
              decoration: const InputDecoration(
                hintText: 'Search listings...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: listings.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Unable to load listings.')),
                data: (docs) {
                  final filtered = docs.where((doc) {
                    if (search.isEmpty) return true;

                    final data = doc.data();

                    final text =
                        '${data['title'] ?? ''} ${data['description'] ?? ''}'
                            .toLowerCase();

                    return text.contains(search);
                  }).toList();

                  if (filtered.isEmpty) {
                    return emptyState(
                      context,
                      Icons.search_off,
                      'Nothing found',
                      'Try a different keyword.',
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisExtent: 345,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      return ListingCard(doc: filtered[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
