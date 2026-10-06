import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../widgets/app_helpers.dart';
import '../../widgets/listing_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final search = ref.watch(searchProvider).toLowerCase();
    final category = ref.watch(categoryProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _homeHeader(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _searchBox(context, ref),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _categoryChips(context, ref),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Fresh on Campus',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          listings.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: emptyState(
                context,
                Icons.cloud_off_outlined,
                'Could not load listings',
                'Check your Firebase connection.',
              ),
            ),
            data: (docs) {
              final filtered = docs.where((doc) {
                final data = doc.data();

                final title =
                    (data['title'] ?? '').toString().toLowerCase();

                final description =
                    (data['description'] ?? '').toString().toLowerCase();

                final itemCategory =
                    (data['category'] ?? 'Other').toString();

                final matchesSearch = search.isEmpty ||
                    title.contains(search) ||
                    description.contains(search);

                final matchesCategory =
                    category == 'All' || itemCategory == category;

                return matchesSearch && matchesCategory;
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: emptyState(
                    context,
                    Icons.search_off_rounded,
                    'No listings found',
                    'Try another search or category.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ListingCard(
                        doc: filtered[index],
                      );
                    },
                    childCount: filtered.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 345,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _homeHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.split(' ').first ?? 'there';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day, $name ??',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                'Find something useful.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchBox(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(searchProvider),
    );

    return TextField(
      controller: controller,
      onChanged: (value) {
        ref.read(searchProvider.notifier).state = value;
      },
      decoration: InputDecoration(
        hintText: 'Search books, electronics, furniture...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
            ref.read(searchProvider.notifier).state = '';
          },
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }

  Widget _categoryChips(BuildContext context, WidgetRef ref) {
    const categories = [
      'All',
      'Books',
      'Electronics',
      'Furniture',
      'Notes',
      'Other',
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = categories[index];
          final selected = ref.watch(categoryProvider) == item;

          return ChoiceChip(
            label: Text(item),
            selected: selected,
            onSelected: (_) {
              ref.read(categoryProvider.notifier).state = item;
            },
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          );
        },
      ),
    );
  }
}
