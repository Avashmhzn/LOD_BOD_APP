import 'package:flutter/material.dart';

class PostLoadBannerWidget extends StatelessWidget {
  const PostLoadBannerWidget({
    super.key,
    required this.used,
    required this.requestLimit,
    required this.onPostLoad,
  });

  final int used;
  final int requestLimit;
  final Future<void> Function() onPostLoad;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF3B2925), Color(0xFF302422)]
              : const [Color(0xFFFFEFE9), Color(0xFFFFF7F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFFFB49E)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ship something new',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'Mobile requests used: '),
                          TextSpan(
                            text: '$used of $requestLimit',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  await onPostLoad();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE84012),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Post Load',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used / requestLimit,
              minHeight: 5,
              color: const Color(0xFFE84012),
              backgroundColor: const Color(0xFFE6D9D5),
            ),
          ),
        ],
      ),
    );
  }
}
