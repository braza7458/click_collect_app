import 'package:flutter/material.dart';

class RewardTier {
  const RewardTier({required this.points, required this.label, required this.icon});

  final int points;
  final String label;
  final IconData icon;
}

const rewardTiers = [
  RewardTier(points: 100, label: 'Un dessert offert', icon: Icons.cake_outlined),
  RewardTier(points: 200, label: 'Un bowl offert', icon: Icons.ramen_dining_outlined),
  RewardTier(points: 400, label: 'Un menu complet offert', icon: Icons.set_meal_outlined),
];
