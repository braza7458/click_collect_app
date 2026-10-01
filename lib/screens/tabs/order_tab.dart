import 'package:flutter/material.dart';

import '../../data/menu_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/item_options_sheet.dart';
import '../../widgets/menu_visuals.dart';
import '../../widgets/ui.dart';
import '../cart_screen.dart';

class OrderTab extends StatefulWidget {
  const OrderTab({super.key});

  @override
  State<OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  int _selectedCategory = 0;

  void _openCart() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final categories = appState.menuCategories;
    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final selected = _selectedCategory.clamp(0, categories.length - 1);
    final category = categories[selected];

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Préparé à la commande'),
                          const SizedBox(height: 4),
                          Text('La carte', style: textTheme.headlineMedium),
                        ],
                      ),
                    ),
                    _CartIconButton(count: appState.cartItemCount, onTap: _openCart),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryChips(
                categories: categories,
                selected: selected,
                onSelected: (i) => setState(() => _selectedCategory = i),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, appState.cart.isEmpty ? 24 : 110),
              sliver: SliverList.separated(
                itemCount: category.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => FadeSlideIn(
                  key: ValueKey('${category.title}-$i'),
                  index: i,
                  child: _MenuTile(item: category.items[i], iconKey: category.iconKey),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: AnimatedSlide(
            offset: appState.cart.isEmpty ? const Offset(0, 1.6) : Offset.zero,
            duration: AppMotion.medium,
            curve: AppMotion.curve,
            child: AnimatedOpacity(
              opacity: appState.cart.isEmpty ? 0 : 1,
              duration: AppMotion.medium,
              child: appState.cart.isEmpty
                  ? const SizedBox(height: 58)
                  : GlowButton(
                      label: '${appState.cartItemCount} article${appState.cartItemCount > 1 ? 's' : ''} · '
                          '${formatPrice(appState.cartTotal)} — Voir le panier',
                      icon: Icons.shopping_bag_rounded,
                      onPressed: _openCart,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'Panier',
      style: IconButton.styleFrom(
        backgroundColor: AppColors.glass,
        side: const BorderSide(color: AppColors.glassBorder),
        fixedSize: const Size(48, 48),
      ),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.orange,
        textColor: AppColors.charcoal,
        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.cream),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.categories, required this.selected, required this.onSelected});

  final List<MenuCategory> categories;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return Pressable(
            child: AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.curve,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orange : AppColors.glass,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: isSelected ? AppColors.orange : AppColors.glassBorder),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.orange.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]
                    : null,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => onSelected(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon(categories[i].iconKey),
                          size: 18,
                          color: isSelected ? AppColors.charcoal : AppColors.creamMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categories[i].title,
                          style: textTheme.labelLarge?.copyWith(color: isSelected ? AppColors.charcoal : AppColors.cream),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.iconKey});

  final MenuItem item;
  final String iconKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final image = menuItemImage(item.name, categoryKey: iconKey);
    return Opacity(
      opacity: item.isOrderable || item.isInfoOnly ? 1 : 0.55,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: item.isOrderable ? () => showItemOptionsSheet(context, item, categoryKey: iconKey) : null,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 74,
                height: 74,
                child: image != null
                    ? Image.asset(image, fit: BoxFit.cover)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.orange.withValues(alpha: 0.30), AppColors.secondary.withValues(alpha: 0.18)],
                          ),
                        ),
                        child: Icon(categoryIcon(iconKey), color: AppColors.orange, size: 32),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: textTheme.titleMedium),
                  if (item.note != null) ...[
                    const SizedBox(height: 3),
                    Text(item.note!, style: textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    item.priceLabel,
                    style: textTheme.titleSmall?.copyWith(
                      color: item.isInfoOnly ? AppColors.creamMuted : AppColors.orange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isOrderable)
              Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.4), blurRadius: 12)],
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.charcoal),
              ),
          ],
        ),
      ),
    );
  }
}
