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
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CHOISISSEZ VOTRE MODE DE COMMANDE',
                    style: textTheme.titleMedium?.copyWith(letterSpacing: 0.4),
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close_rounded, color: AppColors.cream),
                    tooltip: 'Fermer',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...OrderMode.values.map((mode) {
              final isSelected = _selected == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => setState(() => _selected = mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceAlt : AppColors.charcoalSoft,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: isSelected ? AppColors.orange : AppColors.divider,
                        width: isSelected ? 1.6 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.orangeDark.withValues(alpha: 0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(mode.icon, color: AppColors.orange, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mode.label, style: textTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text(mode.description, style: textTheme.bodySmall),
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
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
