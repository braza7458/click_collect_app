import 'package:flutter/material.dart';

const _rewardIcons = {
  'dessert': Icons.cake_outlined,
  'bowl': Icons.ramen_dining_outlined,
  'meal': Icons.set_meal_outlined,
};

class RewardTier {
  const RewardTier({required this.points, required this.label, required this.iconKey});

  final int points;
  final String label;

  /// One of [_rewardIcons]'s keys — Firestore can't store an [IconData]
  /// directly, so the reward document carries a small string key instead.
  final String iconKey;

  IconData get icon => _rewardIcons[iconKey] ?? Icons.loyalty;

  Map<String, dynamic> toMap() => {'points': points, 'label': label, 'icon': iconKey};

  factory RewardTier.fromMap(Map<String, dynamic> map) => RewardTier(
        points: map['points'] as int,
        label: map['label'] as String,
        iconKey: map['icon'] as String? ?? 'meal',
      );
}
