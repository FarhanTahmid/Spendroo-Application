import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/ui.dart';

/// What a goal is for: its icon, a colour to go with it, and its name in the
/// user's language. The key is what a goal stores in `icon`.
class GoalTemplate {
  const GoalTemplate(this.key, this.icon, this.color);

  final String key;
  final IconData icon;
  final Color color;

  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (key) {
      'emergency' => l10n.goalTemplateEmergency,
      'gadget' => l10n.goalTemplateGadget,
      'trip' => l10n.goalTemplateTrip,
      'festival' => l10n.goalTemplateFestival,
      'education' => l10n.goalTemplateEducation,
      'wedding' => l10n.goalTemplateWedding,
      'vehicle' => l10n.goalTemplateVehicle,
      'home' => l10n.goalTemplateHome,
      'gift' => l10n.goalTemplateGift,
      _ => l10n.goalTemplateCustom,
    };
  }
}

/// In the order the new-goal screen offers them; the last one is a goal of the user's own.
const goalTemplates = [
  GoalTemplate('emergency', Icons.health_and_safety_rounded, Color(0xFF1FA6A0)),
  GoalTemplate('gadget', Icons.laptop_mac_rounded, Color(0xFF3B9EE5)),
  GoalTemplate('trip', Icons.flight_takeoff_rounded, Color(0xFFF08A3C)),
  GoalTemplate('festival', Icons.celebration_rounded, Color(0xFFE05C9A)),
  GoalTemplate('education', Icons.school_rounded, Color(0xFF7A5AF8)),
  GoalTemplate('wedding', Icons.favorite_rounded, Color(0xFFD9485F)),
  GoalTemplate('vehicle', Icons.two_wheeler_rounded, Color(0xFF4C63D2)),
  GoalTemplate('home', Icons.home_rounded, Color(0xFFA9793E)),
  GoalTemplate('gift', Icons.card_giftcard_rounded, Color(0xFF8BBF3F)),
  GoalTemplate('', Icons.savings_rounded, Color(0xFF2DB86F)),
];

GoalTemplate goalTemplateOf(String key) =>
    goalTemplates.firstWhere((template) => template.key == key, orElse: () => goalTemplates.last);

IconData goalIcon(SavingsGoal goal) => goalTemplateOf(goal.icon).icon;

/// The colour the goal is drawn in: the one chosen, else its template's.
Color goalColor(SavingsGoal goal) => parseHexColor(goal.color) ?? goalTemplateOf(goal.icon).color;

extension GoalColorContext on BuildContext {
  /// [goalColor] made legible as text and icons on this theme's sheet.
  Color goalTint(SavingsGoal goal) => categoryTint(goal.color ?? toHexColor(goalColor(goal)), goal.id);
}
