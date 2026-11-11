import 'package:flutter/material.dart';
import 'package:lodbod_app/core/theme/app_colors.dart';

const _accent = Color(0xFFE84012);

Widget profileCard(
  BuildContext context, {
  required String name,
  required String company,
  required String roleLabel,
  required String email,
  required String? photoUrl,
  required VoidCallback onTap,
}) {
  final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Material(
    color: colors.surface,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: isDark ? const [] : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: _accent,
              foregroundImage: photoUrl?.isNotEmpty == true
                  ? NetworkImage(photoUrl!)
                  : null,
              child: photoUrl?.isNotEmpty == true
                  ? null
                  : Text(
                      name.isEmpty ? 'S' : name[0].toUpperCase(),
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    company.isEmpty ? roleLabel : '$company · $roleLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    ),
  );
}
