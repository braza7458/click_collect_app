import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_line.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

Future<void> showItemOptionsSheet(BuildContext context, MenuItem item) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ItemOptionsSheetContent(item: item),
  );
}

class _ItemOptionsSheetContent extends StatefulWidget {
  const _ItemOptionsSheetContent({required this.item});

  final MenuItem item;

  @override
  State<_ItemOptionsSheetContent> createState() => _ItemOptionsSheetContentState();
}

class _ItemOptionsSheetContentState extends State<_ItemOptionsSheetContent> {
  int _sizeIndex = 0;
  final Set<String> _selectedSupplements = {};
  int _quantity = 1;

  double get _basePrice =>
      widget.item.hasSizes ? widget.item.sizes[_sizeIndex].price : (widget.item.price ?? 0);

  List<CartSupplement> get _supplements => bowlSupplements
      .where((s) => _selectedSupplements.contains(s.name))
      .map((s) => CartSupplement(name: s.name, price: s.price!))
      .toList();

  double get _unitTotal => _basePrice + _supplements.fold(0.0, (sum, s) => sum + s.price);
  double get _total => _unitTotal * _quantity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.creamMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Text(item.name, style: textTheme.headlineSmall),
              if (item.note != null) ...[
                const SizedBox(height: 4),
                Text(item.note!, style: textTheme.bodySmall),
              ],
              const SizedBox(height: 20),

              if (item.hasSizes) ...[
                Text('TAILLE', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < item.sizes.length; i++)
                      ChoiceChip(
                        label: Text('${item.sizes[i].label} · ${formatPrice(item.sizes[i].price)}'),
                        selected: _sizeIndex == i,
                        onSelected: (_) => setState(() => _sizeIndex = i),
                        selectedColor: AppColors.orange,
                        backgroundColor: AppColors.charcoalSoft,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                        labelStyle: textTheme.labelLarge?.copyWith(
                          color: _sizeIndex == i ? AppColors.charcoal : AppColors.cream,
                          letterSpacing: 0,
                        ),
                        side: BorderSide(color: _sizeIndex == i ? AppColors.orange : AppColors.divider),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
              ],

              if (item.allowsSupplements) ...[
                Text('SUPPLÉMENTS', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                ...bowlSupplements.map((s) {
                  final selected = _selectedSupplements.contains(s.name);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (v) => setState(() {
                      if (v ?? false) {
                        _selectedSupplements.add(s.name);
                      } else {
                        _selectedSupplements.remove(s.name);
                      }
                    }),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(s.name, style: textTheme.bodyLarge),
                    secondary: Text(s.priceLabel, style: textTheme.bodyMedium?.copyWith(color: AppColors.orange)),
                  );
                }),
                const SizedBox(height: 6),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('QUANTITÉ', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      SizedBox(
                        width: 36,
                        child: Text('$_quantity', textAlign: TextAlign.center, style: textTheme.titleMedium),
                      ),
                      _QtyButton(icon: Icons.add, onTap: () => setState(() => _quantity++)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: !item.isOrderable
                      ? null
                      : () {
                          AppStateScope.of(context).addToCart(
                            CartLine(
                              itemName: item.name,
                              sizeLabel: item.hasSizes ? item.sizes[_sizeIndex].label : null,
                              unitPrice: _basePrice,
                              supplements: _supplements,
                              quantity: _quantity,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.name} ajouté au panier')),
                          );
                        },
                  child: Text(
                    item.isOrderable ? 'Ajouter · ${formatPrice(_total)}' : 'Bientôt disponible',
                  ),
                ),
              ),
            ],
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
    return Material(
      color: AppColors.charcoalSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: enabled ? AppColors.cream : AppColors.creamMuted.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
