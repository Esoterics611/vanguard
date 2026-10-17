import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';
import 'app/theme/army_theme.dart';
import 'app/app_shell.dart';
import 'core/services/wallet_service.dart';
import 'core/services/army_service.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to emulators in debug mode
  if (kDebugMode) {
    const host = 'localhost';
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }

  runApp(
    const ProviderScope(
      child: VanguardApp(),
    ),
  );
}

class VanguardApp extends StatelessWidget {
  const VanguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vanguard DAO',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

/// Checks auth and wallet state to decide initial screen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _hasWallet = false;
  bool _hasSoldier = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final wallet = WalletService();
      final hasStoredWallet = await wallet.initFromStorage();

      if (hasStoredWallet && wallet.isConnected) {
        // Check if they have a soldier record
        final army = ArmyService();
        final result = await army.connectWithWallet(walletAddress: wallet.address!);

        // Check if soldier has a squad
        final soldier = await army.getSoldierById(result.soldierId);

        setState(() {
          _hasWallet = true;
          _hasSoldier = soldier?.squadId != null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasWallet = false;
          _hasSoldier = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      setState(() {
        _hasWallet = false;
        _hasSoldier = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E17),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
              ),
              const SizedBox(height: 16),
              Text(
                'INITIALIZING...',
                style: TextStyle(
                  color: const Color(0xFF00F0FF).withValues(alpha: 0.7),
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If has wallet and soldier with squad, go to main app
    if (_hasWallet && _hasSoldier) {
      return const AppShell();
    }

    // Otherwise, show onboarding
    return const OnboardingScreen();
  }
}
