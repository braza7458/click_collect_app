import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

Future<void> showOrderModeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _OrderModeSheetContent(),
  );
}

class _OrderModeSheetContent extends StatefulWidget {
  const _OrderModeSheetContent();

  @override
  State<_OrderModeSheetContent> createState() => _OrderModeSheetContentState();
}

class _OrderModeSheetContentState extends State<_OrderModeSheetContent> {
  OrderMode? _selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.creamMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CHOISISSEZ VOTRE MODE DE COMMANDE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(letterSpacing: 0.4),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Fermer',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...OrderMode.values.map((mode) {
              final isSelected = _selected == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _selected = mode),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.orange.withValues(alpha: 0.14) : AppColors.charcoalSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.orange : AppColors.creamMuted.withValues(alpha: 0.18),
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(mode.icon, color: AppColors.orange),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mode.label, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text(mode.description, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.orange : AppColors.creamMuted.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      AppStateScope.of(context).setOrderMode(_selected!);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mode sélectionné : ${_selected!.label}')),
                      );
                    },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
