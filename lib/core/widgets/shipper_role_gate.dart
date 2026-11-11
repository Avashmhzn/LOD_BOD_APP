import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';
import 'package:lodbod_app/features/auth/presentation/pages/login_page.dart';


class ShipperRoleGate extends StatefulWidget {
  const ShipperRoleGate({
    required this.child,
    this.allowedRoles = const {'shipper'},
    this.carrierDestination,
    super.key,
  });

  final Widget child;
  final Set<String> allowedRoles;
  final String? carrierDestination;

  @override
  State<ShipperRoleGate> createState() => _ShipperRoleGateState();
}

class _ShipperRoleGateState extends State<ShipperRoleGate> {
  late Future<String> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = _loadRole();
  }

  Future<String> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'signed_out';
    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!profile.exists) return 'unassigned';
    return profile.data()?['role'] as String? ?? 'shipper';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.child;
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not verify account access.'),
                  TextButton(
                    onPressed: () => setState(() => _roleFuture = _loadRole()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.data == 'signed_out') return const LoginPage();
        if (!widget.allowedRoles.contains(snapshot.data)) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 36),
                    const SizedBox(height: 12),
                    const Text(
                      'This area is not available to your account type.',
                      textAlign: TextAlign.center,
                    ),
                    if (snapshot.data == 'carrier' &&
                        widget.carrierDestination != null)
                      TextButton(
                        onPressed: () => context.go(widget.carrierDestination!),
                        child: const Text('View open shipments'),
                      ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) context.go(Routes.login);
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return widget.child;
      },
    );
  }
}
