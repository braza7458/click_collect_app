import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_theme.dart';
import '../widgets/order_summary_card.dart';
import 'dashboard_shell.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withValues(alpha: 0.14),
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.green, size: 44),
                ),
              ),
              const SizedBox(height: 20),
              Text('Commande confirmée', textAlign: TextAlign.center, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                order.paid ? 'Votre paiement a bien été reçu.' : 'Réglez-la sur place à la récupération.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: OrderSummaryCard(order: order),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardShell()),
                  (route) => false,
                ),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
