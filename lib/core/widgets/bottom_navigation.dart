import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';


class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.selectedIndex,
    this.onShipmentChanged,
    super.key,
  });

  final int selectedIndex;
  final VoidCallback? onShipmentChanged;

  static const _orange = Color(0xFFE84012);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.35
                    : 1,
              ),
            ),
          ),
        ),
        child: Row(
          children: [
            _item(context, 0, Icons.home_rounded, 'Home', Routes.dashboard),
            _item(
              context,
              1,
              Icons.local_shipping_outlined,
              'Shipments',
              Routes.shipments,
            ),
            Expanded(
              child: SizedBox(
                height: 66,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -18,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: FloatingActionButton(
                            heroTag: 'post-load-bottom-nav',
                            elevation: 3,
                            backgroundColor: _orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            onPressed: () async {
                              final created = await context.push<bool>(
                                Routes.createShipment,
                              );
                              if (created == true) onShipmentChanged?.call();
                            },
                            child: const Icon(Icons.add_rounded, size: 30),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 14,
                      child: Text(
                        'Post Load',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          color: _orange,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _item(
              context,
              2,
              Icons.bar_chart_rounded,
              'Analytics',
              Routes.analytics,
            ),
            _item(
              context,
              3,
              Icons.person_outline_rounded,
              'Account',
              Routes.account,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    String route,
  ) {
    final colors = Theme.of(context).colorScheme;
    final selected = selectedIndex == index;
    final color = selected ? _orange : colors.onSurfaceVariant;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () {
            if (!selected) context.go(route);
          },
          child: SizedBox(
            height: 66,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 25,
                  decoration: BoxDecoration(
                    color: selected
                        ? _orange.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 9.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
