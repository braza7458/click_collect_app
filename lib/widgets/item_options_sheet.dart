import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_line.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'menu_visuals.dart';
import 'ui.dart';

Future<void> showItemOptionsSheet(BuildContext context, MenuItem item, {String? categoryKey}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ItemOptionsSheetContent(item: item, categoryKey: categoryKey),
  );
}

class _ItemOptionsSheetContent extends StatefulWidget {
  const _ItemOptionsSheetContent({required this.item, this.categoryKey});

  final MenuItem item;

  /// Catégorie du plat (pour choisir sa photo) — voir menu_visuals.dart.
  final String? categoryKey;

  @override
  State<_ItemOptionsSheetContent> createState() => _ItemOptionsSheetContentState();
}

class _ItemOptionsSheetContentState extends State<_ItemOptionsSheetContent> {
  int _sizeIndex = 0;
  final Set<String> _selectedSupplements = {};
  int _quantity = 1;

  double get _basePrice => widget.item.hasSizes ? widget.item.sizes[_sizeIndex].price : (widget.item.price ?? 0);

  List<CartSupplement> _supplements(List<MenuItem> bowlSupplements) => bowlSupplements
      .where((s) => _selectedSupplements.contains(s.name))
      .map((s) => CartSupplement(name: s.name, price: s.price!))
      .toList();

  double _unitTotal(List<MenuItem> bowlSupplements) =>
      _basePrice + _supplements(bowlSupplements).fold(0.0, (sum, s) => sum + s.price);
  double _total(List<MenuItem> bowlSupplements) => _unitTotal(bowlSupplements) * _quantity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    final bowlSupplements = AppStateScope.of(context).bowlSupplements;
    final image = menuItemImage(item.name);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (image != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: AspectRatio(aspectRatio: 16 / 9, child: Image.asset(image, fit: BoxFit.cover)),
                        ),
                        const SizedBox(height: 18),
                      ],
                      Text(item.name, style: textTheme.headlineSmall),
                      if (item.note != null) ...[
                        const SizedBox(height: 4),
                        Text(item.note!, style: textTheme.bodyMedium),
                      ],
                      if (item.hasSizes) ...[
                        const SizedBox(height: 22),
                        const Eyebrow('Taille'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (var i = 0; i < item.sizes.length; i++) ...[
                              if (i > 0) const SizedBox(width: 10),
                              Expanded(
                                child: _SizeOption(
                                  label: item.sizes[i].label,
                                  price: formatPrice(item.sizes[i].price),
                                  selected: _sizeIndex == i,
                                  onTap: () => setState(() => _sizeIndex = i),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      if (item.allowsSupplements && bowlSupplements.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const Eyebrow('Suppléments'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in bowlSupplements)
                              FilterChip(
                                selected: _selectedSupplements.contains(s.name),
                                onSelected: (v) => setState(() {
                                  if (v) {
                                    _selectedSupplements.add(s.name);
                                  } else {
                                    _selectedSupplements.remove(s.name);
                                  }
                                }),
                                avatar: _selectedSupplements.contains(s.name)
                                    ? const Icon(Icons.check_rounded, size: 18, color: AppColors.charcoal)
                                    : (menuItemImage(s.name) != null
                                        ? CircleAvatar(backgroundImage: AssetImage(menuItemImage(s.name)!))
                                        : null),
                                label: Text('${s.name}  ${s.priceLabel}'),
                                labelStyle: textTheme.labelLarge?.copyWith(
                                  color: _selectedSupplements.contains(s.name) ? AppColors.charcoal : AppColors.cream,
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(child: Eyebrow('Quantité')),
                          _QtyButton(
                            icon: Icons.remove_rounded,
                            onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          ),
                          SizedBox(
                            width: 48,
                            child: Text('$_quantity', textAlign: TextAlign.center, style: textTheme.headlineSmall),
                          ),
                          _QtyButton(icon: Icons.add_rounded, onTap: () => setState(() => _quantity++)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: GlowButton(
                  icon: Icons.shopping_bag_rounded,
                  label: item.isOrderable ? 'Ajouter · ${formatPrice(_total(bowlSupplements))}' : 'Bientôt disponible',
                  onPressed: !item.isOrderable
                      ? null
                      : () {
                          AppStateScope.of(context).addToCart(
                            CartLine(
                              itemName: item.name,
                              sizeLabel: item.hasSizes ? item.sizes[_sizeIndex].label : null,
                              unitPrice: _basePrice,
                              supplements: _supplements(bowlSupplements),
                              quantity: _quantity,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 2),
                              content: Text('${item.name} ajouté au panier'),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({required this.label, required this.price, required this.selected, required this.onTap});

  final String label;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: selected ? AppColors.orange.withValues(alpha: 0.16) : AppColors.glass,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.orange : AppColors.glassBorder, width: selected ? 1.6 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  Text('Taille $label', style: textTheme.titleMedium?.copyWith(color: selected ? AppColors.orange : AppColors.cream)),
                  const SizedBox(height: 2),
                  Text(price, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: enabled ? AppColors.glass : Colors.transparent,
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      icon: Icon(icon, color: enabled ? AppColors.cream : AppColors.creamMuted.withValues(alpha: 0.4)),
    );
  }
}
