import 'package:flutter/material.dart';

import '../data/loyalty_data.dart';
import '../data/menu_data.dart';
import '../data/restaurant_data.dart';
import '../models/cart_line.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'order_confirmation_screen.dart';
import 'stripe_checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  OrderMode _mode = OrderMode.clickCollect;
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
      final last = AppStateScope.of(context).lastOrderMode;
      _mode = OrderMode.appModes.contains(last) ? last! : OrderMode.clickCollect;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _tableController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  RestaurantLocation get _restaurant => AppStateScope.of(context).restaurant;

  String _formatSlot(DateTime dt) {
    final now = DateTime.now();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
    if (sameDay(dt, now)) return 'Aujourd\'hui · $hh:$mm';
    if (sameDay(dt, now.add(const Duration(days: 1)))) return 'Demain · $hh:$mm';
    return '${weekdayNames[dt.weekday - 1]} · $hh:$mm';
  }

  Future<void> _pickCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickupTime ?? DateTime.now().add(const Duration(minutes: 30))),
      helpText: 'Heure de retrait',
    );
    if (picked == null || !mounted) return;
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    if (dt.isBefore(now.add(const Duration(minutes: 15)))) dt = dt.add(const Duration(days: 1));
    if (!_restaurant.acceptsPickupAt(dt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le restaurant est fermé à cette heure-là (${weekdayNames[dt.weekday - 1].toLowerCase()} : '
            '${_restaurant.hoursLabelFor(dt.weekday - 1)}).',
          ),
        ),
      );
      return;
    }
    setState(() => _pickupTime = dt);
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
        if (_pickupTime == null) return null;
        return 'Retrait · ${_formatSlot(_pickupTime!)}';
      case OrderMode.delivery:
        final address = _addressController.text.trim();
        return address.isEmpty ? null : 'Livraison à : $address';
      case OrderMode.tableService:
        final table = _tableController.text.trim();
        return table.isEmpty ? null : 'Table n° $table';
      case OrderMode.dineIn || OrderMode.takeaway:
        return null; // modes de la borne, jamais choisis ici
    }
  }

  /// Ce qui manque encore pour commander — affiché sous les boutons plutôt
  /// que de laisser l'utilisateur deviner pourquoi ils sont grisés.
  String? _missing(AppState appState) {
    if (appState.cart.isEmpty) return 'Votre panier est vide.';
    switch (_mode) {
      case OrderMode.clickCollect:
        if (_pickupTime == null) return 'Choisissez un créneau de retrait.';
      case OrderMode.delivery:
        if (!_restaurant.isOpenNow) return 'La livraison n\'est possible que pendant les heures d\'ouverture.';
        if (_addressController.text.trim().isEmpty) return 'Indiquez votre adresse de livraison.';
      case OrderMode.tableService:
        if (!_restaurant.isOpenNow) return 'Le service à table n\'est possible que pendant les heures d\'ouverture.';
        if (_tableController.text.trim().isEmpty) return 'Indiquez votre numéro de table.';
      case OrderMode.dineIn || OrderMode.takeaway:
        break;
    }
    if (_phoneController.text.trim().isEmpty) return 'Indiquez un numéro de téléphone pour le SMS.';
    return null;
  }

  Future<void> _payInStore(AppState appState) async {
    setState(() => _submitting = true);
    final order = await appState.placeOrder(
      mode: _mode,
      customerPhone: _phoneController.text.trim(),
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
    final missing = _missing(appState);
    final canSubmit = missing == null && !_submitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon panier'),
        actions: [
          if (appState.cart.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearCart(appState),
              style: TextButton.styleFrom(foregroundColor: AppColors.creamMuted),
              child: const Text('Vider'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: appState.cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Votre panier est vide',
                  message: 'Ajoutez des plats depuis la carte pour préparer votre commande.',
                  action: SizedBox(
                    width: 240,
                    child: GlowButton(label: 'Découvrir la carte', onPressed: () => Navigator.of(context).pop()),
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Column(
                    children: [
                      for (var i = 0; i < appState.cart.length; i++) ...[
                        if (i > 0) const Divider(),
                        _CartLineTile(line: appState.cart[i]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Eyebrow('Mode de commande'),
                const SizedBox(height: 10),
                _ModeSelector(selected: _mode, onSelected: (m) => setState(() => _mode = m)),
                const SizedBox(height: 22),
                Eyebrow(_mode.fulfillmentLabel),
                const SizedBox(height: 10),
                if (_mode == OrderMode.clickCollect) _buildPickupPicker(textTheme),
                if (_mode == OrderMode.delivery)
                  TextField(
                    controller: _addressController,
                    onChanged: (_) => setState(() {}),
                    style: textTheme.bodyLarge,
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
                    style: textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de table',
                      prefixIcon: Icon(Icons.table_bar_outlined),
                    ),
                  ),
                const SizedBox(height: 24),
                const Eyebrow('Numéro de téléphone'),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.phone,
                  style: textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Pour le SMS de confirmation',
                    prefixIcon: Icon(Icons.sms_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uniquement pour vous prévenir par SMS que la commande est confirmée puis prête — jamais enregistré sur votre compte.',
                  style: textTheme.bodySmall,
                ),
                if (!appState.isGuest && appState.rewardTiers.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const Eyebrow('Récompense fidélité (facultatif)', color: AppColors.honey),
                  const SizedBox(height: 10),
                  _RewardPicker(
                    tiers: appState.rewardTiers,
                    points: appState.points,
                    selected: _selectedReward,
                    onSelected: (tier) => setState(() => _selectedReward = _selectedReward == tier ? null : tier),
                  ),
                ],
                const SizedBox(height: 26),
                _SummaryCard(appState: appState, selectedReward: _selectedReward),
                const SizedBox(height: 18),
                GlowButton(
                  icon: Icons.credit_card_rounded,
                  label: 'Payer ${formatPrice(appState.cartTotal)} par carte',
                  onPressed: canSubmit ? _payOnline : null,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: canSubmit ? () => _payInStore(appState) : null,
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Commander — payer sur place'),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: AppMotion.medium,
                  child: missing == null
                      ? Row(
                          key: const ValueKey('ok'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, size: 14, color: AppColors.creamMuted),
                            const SizedBox(width: 6),
                            Text('Paiement sécurisé par Stripe', style: textTheme.bodySmall),
                          ],
                        )
                      : Row(
                          key: ValueKey(missing),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.honey),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                missing,
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(color: AppColors.honey),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  /// "Aujourd'hui" / "Demain" / "Mercredi" → créneaux de ce jour.
  Map<String, List<DateTime>> _groupByDay(List<DateTime> slots) {
    final groups = <String, List<DateTime>>{};
    for (final slot in slots) {
      groups.putIfAbsent(_formatSlot(slot).split(' · ').first, () => []).add(slot);
    }
    return groups;
  }

  Widget _buildPickupPicker(TextTheme textTheme) {
    final restaurant = _restaurant;
    final slots = restaurant.pickupSlots(DateTime.now());
    final status = restaurant.statusAt(DateTime.now());
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(Icons.storefront_rounded, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: textTheme.titleMedium),
                    Text(restaurant.address, style: textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusPill(label: status.headline, color: status.isOpen ? AppColors.green : AppColors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(status.detail, style: textTheme.bodySmall)),
            ],
          ),
          const SizedBox(height: 16),
          // Créneaux regroupés par jour : "Aujourd'hui" puis les heures.
          for (final day in _groupByDay(slots).entries) ...[
            Text(day.key, style: textTheme.labelMedium?.copyWith(color: AppColors.cream)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in day.value)
                  ChoiceChip(
                    label: Text(
                      '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                    ),
                    selected: _pickupTime == slot,
                    onSelected: (_) => setState(() => _pickupTime = slot),
                    labelStyle: textTheme.labelLarge?.copyWith(
                      color: _pickupTime == slot ? AppColors.charcoal : AppColors.cream,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          ActionChip(
            avatar: const Icon(Icons.schedule_rounded, size: 18, color: AppColors.orange),
            label: const Text('Autre heure'),
            onPressed: _pickCustomTime,
            labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.orange),
          ),
          if (_pickupTime != null && !slots.contains(_pickupTime)) ...[
            const SizedBox(height: 12),
            Text('Créneau choisi : ${_formatSlot(_pickupTime!)}', style: textTheme.bodySmall?.copyWith(color: AppColors.orange)),
          ],
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onSelected});

  final OrderMode selected;
  final ValueChanged<OrderMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        for (final mode in OrderMode.appModes) ...[
          if (mode.index > 0) const SizedBox(width: 8),
          Expanded(
            child: Pressable(
              child: AnimatedContainer(
                duration: AppMotion.medium,
                curve: AppMotion.curve,
                decoration: BoxDecoration(
                  color: selected == mode ? AppColors.orange : AppColors.glass,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: selected == mode ? AppColors.orange : AppColors.glassBorder),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () => onSelected(mode),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                      child: Column(
                        children: [
                          Icon(mode.icon, color: selected == mode ? AppColors.charcoal : AppColors.creamMuted),
                          const SizedBox(height: 6),
                          Text(
                            mode.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(
                              color: selected == mode ? AppColors.charcoal : AppColors.cream,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.sizeLabel != null ? '${line.itemName} · ${line.sizeLabel}' : line.itemName,
                  style: textTheme.titleMedium,
                ),
                if (line.supplements.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('+ ${line.supplements.map((s) => s.name).join(', ')}', style: textTheme.bodySmall),
                ],
                const SizedBox(height: 4),
                Text(
                  formatPrice(line.lineTotal),
                  style: textTheme.titleSmall?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.charcoal.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                _StepperButton(
                  icon: line.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                  onTap: () => appState.updateCartQuantity(line.id, line.quantity - 1),
                ),
                SizedBox(width: 24, child: Text('${line.quantity}', textAlign: TextAlign.center, style: textTheme.titleMedium)),
                _StepperButton(icon: Icons.add_rounded, onTap: () => appState.updateCartQuantity(line.id, line.quantity + 1)),
              ],
            ),
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
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Icon(icon, size: 18, color: AppColors.cream),
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
    return GlassCard(
      color: AppColors.glassStrong,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Total', style: textTheme.titleLarge)),
              Text(formatPrice(appState.cartTotal), style: textTheme.headlineSmall?.copyWith(color: AppColors.orange)),
            ],
          ),
          if (selectedReward != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, size: 16, color: AppColors.honey),
                const SizedBox(width: 8),
                Expanded(child: Text('${selectedReward!.label} offert', style: textTheme.bodySmall?.copyWith(color: AppColors.honey))),
                Text('−${selectedReward!.points} pts', style: textTheme.bodySmall?.copyWith(color: AppColors.honey)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 16, color: AppColors.honey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appState.isGuest ? 'Connectez-vous pour cumuler des points' : 'Points fidélité gagnés',
                  style: textTheme.bodySmall,
                ),
              ),
              Text('+$earned pts', style: textTheme.labelLarge?.copyWith(color: AppColors.honey)),
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
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          borderColor: isSelected ? AppColors.honey : null,
          color: isSelected ? AppColors.honey.withValues(alpha: 0.12) : null,
          onTap: unlocked ? () => onSelected(tier) : null,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : (unlocked ? Icons.radio_button_unchecked : Icons.lock_outline_rounded),
                color: unlocked ? AppColors.honey : AppColors.creamMuted.withValues(alpha: 0.5),
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
                style: textTheme.bodySmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
