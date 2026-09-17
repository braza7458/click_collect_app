import 'package:flutter/material.dart';

import '../data/loyalty_data.dart';
import '../data/menu_data.dart';
import '../data/restaurant_data.dart';
import '../models/cart_line.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/restaurant_picker_sheet.dart';
import 'order_confirmation_screen.dart';
import 'stripe_checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  OrderMode _mode = OrderMode.clickCollect;
  RestaurantLocation? _restaurant;
  DateTime? _pickupTime;
  final _addressController = TextEditingController();
  final _tableController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  bool _submitting = false;
  RewardTier? _selectedReward;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final appState = AppStateScope.of(context);
      _mode = appState.lastOrderMode ?? OrderMode.clickCollect;
      final favorite = appState.favoriteRestaurantName;
      if (favorite != null) {
        final matches = appState.restaurants.where((r) => r.name == favorite);
        if (matches.isNotEmpty) _restaurant = matches.first;
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _tableController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  DateTime _roundUpToFive(DateTime dt) {
    final base = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
    final remainder = base.minute % 5;
    return remainder == 0 ? base : base.add(Duration(minutes: 5 - remainder));
  }

  List<DateTime> get _quickSlots {
    final now = DateTime.now();
    return [20, 45, 70].map((m) => _roundUpToFive(now.add(Duration(minutes: m)))).toList();
  }

  String _formatSlot(DateTime dt) {
    final now = DateTime.now();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
    if (sameDay(dt, now)) return 'Aujourd\'hui · $hh:$mm';
    if (sameDay(dt, now.add(const Duration(days: 1)))) return 'Demain · $hh:$mm';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} · $hh:$mm';
  }

  Future<void> _pickCustomTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null || !mounted) return;
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
    setState(() => _pickupTime = dt);
  }

  Future<void> _pickRestaurant() async {
    final picked = await showRestaurantPickerSheet(context);
    if (picked != null && mounted) setState(() => _restaurant = picked);
  }

  Future<void> _confirmClearCart(AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les articles ajoutés seront retirés.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
    if (confirmed == true) appState.clearCart();
  }

  String? get _fulfillmentDetail {
    switch (_mode) {
      case OrderMode.clickCollect:
        if (_restaurant == null || _pickupTime == null) return null;
        return 'Retrait chez ${_restaurant!.name} · ${_formatSlot(_pickupTime!)}';
      case OrderMode.delivery:
        final address = _addressController.text.trim();
        return address.isEmpty ? null : 'Livraison à : $address';
      case OrderMode.tableService:
        final table = _tableController.text.trim();
        return table.isEmpty ? null : 'Table n° $table';
    }
  }

  bool _canSubmit(AppState appState) {
    if (appState.cart.isEmpty) return false;
    if (_phoneController.text.trim().isEmpty) return false;
    switch (_mode) {
      case OrderMode.clickCollect:
        return _restaurant != null && _restaurant!.isOpenNow && _pickupTime != null;
      case OrderMode.delivery:
        return _addressController.text.trim().isNotEmpty;
      case OrderMode.tableService:
        return _tableController.text.trim().isNotEmpty;
    }
  }

  String? get _orderRestaurantName =>
      _mode == OrderMode.clickCollect ? _restaurant?.name : AppStateScope.of(context).favoriteRestaurantName;

  Future<void> _payInStore(AppState appState) async {
    setState(() => _submitting = true);
    final order = await appState.placeOrder(
      mode: _mode,
      customerPhone: _phoneController.text.trim(),
      restaurantName: _orderRestaurantName,
      fulfillmentDetail: _fulfillmentDetail,
      reward: _selectedReward,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: order)),
    );
  }

  void _payOnline() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StripeCheckoutScreen(
          mode: _mode,
          customerPhone: _phoneController.text.trim(),
          restaurantName: _orderRestaurantName,
          fulfillmentDetail: _fulfillmentDetail,
          reward: _selectedReward,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        actions: [
          if (appState.cart.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearCart(appState),
              child: const Text('Vider'),
            ),
        ],
      ),
      body: appState.cart.isEmpty
          ? _EmptyCart(onBrowse: () => Navigator.of(context).pop())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                ...appState.cart.map((line) => _CartLineTile(line: line)),
                const SizedBox(height: 24),

                Text('MODE DE COMMANDE', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: OrderMode.values.map((mode) {
                    final selected = _mode == mode;
                    return ChoiceChip(
                      label: Text(mode.label),
                      avatar: Icon(mode.icon, size: 16, color: selected ? AppColors.charcoal : AppColors.creamMuted),
                      selected: selected,
                      onSelected: (_) => setState(() => _mode = mode),
                      selectedColor: AppColors.orange,
                      backgroundColor: AppColors.charcoalSoft,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                      labelStyle: textTheme.labelLarge?.copyWith(
                        color: selected ? AppColors.charcoal : AppColors.cream,
                        letterSpacing: 0,
                      ),
                      side: BorderSide(color: selected ? AppColors.orange : AppColors.divider),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),

                Text(_mode.fulfillmentLabel.toUpperCase(), style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                const SizedBox(height: 10),
                if (_mode == OrderMode.clickCollect) ..._buildClickCollectFields(textTheme),
                if (_mode == OrderMode.delivery)
                  TextField(
                    controller: _addressController,
                    onChanged: (_) => setState(() {}),
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.cream),
                    decoration: const InputDecoration(
                      labelText: 'Adresse complète',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                if (_mode == OrderMode.tableService)
                  TextField(
                    controller: _tableController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.cream),
                    decoration: const InputDecoration(
                      labelText: 'Numéro de table',
                      prefixIcon: Icon(Icons.table_bar_outlined),
                    ),
                  ),

                const SizedBox(height: 24),
                Text('NUMÉRO DE TÉLÉPHONE', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.phone,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.cream),
                  decoration: const InputDecoration(
                    labelText: 'Pour le SMS de confirmation',
                    prefixIcon: Icon(Icons.sms_outlined),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Utilisé uniquement pour vous prévenir par SMS que la commande est confirmée puis prête — jamais enregistré sur votre compte.',
                  style: textTheme.bodySmall,
                ),
                if (!appState.isGuest && appState.rewardTiers.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('RÉCOMPENSE (FACULTATIF)', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  _RewardPicker(
                    tiers: appState.rewardTiers,
                    points: appState.points,
                    selected: _selectedReward,
                    onSelected: (tier) => setState(() => _selectedReward = _selectedReward == tier ? null : tier),
                  ),
                ],
                const SizedBox(height: 24),
                _SummaryCard(appState: appState, selectedReward: _selectedReward),
                const SizedBox(height: 16),
                const SizedBox(height: 4),
                Text(
                  'Payez dès maintenant par carte, ou réglez sur place à la récupération de votre commande.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _canSubmit(appState) && !_submitting ? _payOnline : null,
                    icon: const Icon(Icons.credit_card, size: 20),
                    label: Text('Payer ${formatPrice(appState.cartTotal)} par carte'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _canSubmit(appState) && !_submitting ? () => _payInStore(appState) : null,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Commander — payer sur place'),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildClickCollectFields(TextTheme textTheme) {
    return [
      InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: _pickRestaurant,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.charcoalSoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(Icons.storefront_outlined, color: AppColors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _restaurant?.name ?? 'Choisir un restaurant',
                  style: textTheme.bodyLarge?.copyWith(
                    color: _restaurant == null ? AppColors.creamMuted.withValues(alpha: 0.7) : AppColors.cream,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.creamMuted),
            ],
          ),
        ),
      ),
      if (_restaurant != null && !_restaurant!.isOpenNow) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, size: 18, color: AppColors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ce restaurant est actuellement fermé — choisissez-en un autre pour commander.',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.red),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final slot in _quickSlots)
            ActionChip(
              label: Text(_formatSlot(slot)),
              onPressed: () => setState(() => _pickupTime = slot),
              backgroundColor: AppColors.charcoalSoft,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill), side: const BorderSide(color: AppColors.divider)),
              labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.cream, letterSpacing: 0),
            ),
          ActionChip(
            label: const Text('Autre heure'),
            avatar: const Icon(Icons.schedule_outlined, size: 16, color: AppColors.orange),
            onPressed: _pickCustomTime,
            backgroundColor: AppColors.charcoalSoft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill), side: const BorderSide(color: AppColors.divider)),
            labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.orange, letterSpacing: 0),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        _pickupTime == null ? 'Aucun créneau choisi' : 'Créneau choisi : ${_formatSlot(_pickupTime!)}',
        style: textTheme.bodySmall?.copyWith(color: _pickupTime == null ? AppColors.creamMuted : AppColors.orange),
      ),
    ];
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.creamMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Votre panier est vide', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des plats depuis la carte pour préparer votre commande.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onBrowse, child: const Text('Découvrir la carte')),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoalSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.sizeLabel != null ? '${line.itemName} (${line.sizeLabel})' : line.itemName,
                  style: textTheme.titleMedium,
                ),
                if (line.supplements.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+ ${line.supplements.map((s) => s.name).join(', ')}',
                    style: textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StepperButton(
                      icon: Icons.remove,
                      onTap: () => appState.updateCartQuantity(line.id, line.quantity - 1),
                    ),
                    SizedBox(width: 32, child: Text('${line.quantity}', textAlign: TextAlign.center, style: textTheme.bodyLarge)),
                    _StepperButton(
                      icon: Icons.add,
                      onTap: () => appState.updateCartQuantity(line.id, line.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatPrice(line.lineTotal), style: textTheme.titleSmall?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => appState.removeFromCart(line.id),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 20, color: AppColors.creamMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: AppColors.cream),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.appState, this.selectedReward});

  final AppState appState;
  final RewardTier? selectedReward;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final earned = appState.isGuest ? 0 : appState.cartTotal.floor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Sous-total', style: textTheme.bodyLarge)),
              Text(formatPrice(appState.cartTotal), style: textTheme.titleMedium),
            ],
          ),
          if (selectedReward != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.card_giftcard, size: 16, color: AppColors.orange),
                const SizedBox(width: 6),
                Expanded(child: Text(selectedReward!.label, style: textTheme.bodySmall?.copyWith(color: AppColors.orange))),
                Text('−${selectedReward!.points} pts', style: textTheme.bodySmall?.copyWith(color: AppColors.orange)),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  appState.isGuest ? 'Connectez-vous pour cumuler des points' : 'Points fidélité à gagner',
                  style: textTheme.bodySmall,
                ),
              ),
              Text('+$earned pts', style: textTheme.bodySmall?.copyWith(color: AppColors.badgeAmber)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardPicker extends StatelessWidget {
  const _RewardPicker({
    required this.tiers,
    required this.points,
    required this.selected,
    required this.onSelected,
  });

  final List<RewardTier> tiers;
  final int points;
  final RewardTier? selected;
  final void Function(RewardTier) onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: tiers.map((tier) {
        final unlocked = points >= tier.points;
        final isSelected = selected == tier;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: unlocked ? () => onSelected(tier) : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orange.withValues(alpha: 0.12) : AppColors.charcoalSoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: isSelected ? AppColors.orange : AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : (unlocked ? Icons.radio_button_unchecked : Icons.lock_outline),
                    color: unlocked ? AppColors.orange : AppColors.creamMuted.withValues(alpha: 0.5),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tier.label,
                      style: textTheme.bodyLarge?.copyWith(
                        color: unlocked ? AppColors.cream : AppColors.creamMuted.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Text(
                    unlocked ? '${tier.points} pts' : 'encore ${tier.points - points} pts',
                    style: textTheme.bodySmall?.copyWith(
                      color: unlocked ? AppColors.creamMuted : AppColors.creamMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
