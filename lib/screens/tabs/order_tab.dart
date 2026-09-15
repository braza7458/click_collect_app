import 'package:flutter/material.dart';

import '../../data/menu_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_mode_sheet.dart';

class OrderTab extends StatefulWidget {
  const OrderTab({super.key});

  @override
  State<OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text('La carte', style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryChips(
                selected: _selectedCategory,
                onSelected: (i) => setState(() => _selectedCategory = i),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              sliver: SliverList.separated(
                itemCount: menuCategories[_selectedCategory].items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _MenuTile(
                  item: menuCategories[_selectedCategory].items[i],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 16,
          child: ElevatedButton.icon(
            onPressed: () => showOrderModeSheet(context),
            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
            label: const Text('Commander'),
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: menuCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return ChoiceChip(
            label: Text(menuCategories[i].title),
            selected: isSelected,
            onSelected: (_) => onSelected(i),
            selectedColor: AppColors.orange,
            backgroundColor: AppColors.charcoalSoft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppColors.charcoal : AppColors.cream,
                  letterSpacing: 0,
                ),
            side: BorderSide(color: isSelected ? AppColors.orange : AppColors.divider),
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoalSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_outlined, color: AppColors.orange, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                if (item.note != null) ...[
                  const SizedBox(height: 2),
                  Text(item.note!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.creamMuted)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.price,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
