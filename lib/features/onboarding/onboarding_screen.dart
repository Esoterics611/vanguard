import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/cyber_colors.dart';
import '../../core/services/wallet_service.dart';
import '../../core/services/army_service.dart';
import '../army/widgets/cyber_card.dart';
import 'squad_browser_screen.dart';

/// Onboarding screen for new users
/// Flow: Welcome -> Connect Wallet/Enter Key -> Browse Squads -> Apply
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _privateKeyController = TextEditingController();
  bool _isLoading = false;
  bool _showPrivateKeyInput = false;
  String? _error;
  bool _obscureKey = true;

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  Future<void> _connectWithPrivateKey() async {
    final key = _privateKeyController.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Please enter your private key');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final wallet = WalletService();
      final success = await wallet.connectWithPrivateKey(key);

      if (!success) {
        setState(() {
          _error = 'Invalid private key format';
          _isLoading = false;
        });
        return;
      }

      // Connect to backend with wallet address
      final army = ArmyService();
      await army.connectWithWallet(walletAddress: wallet.address!);

      if (mounted) {
        // Navigate to squad browser
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SquadBrowserScreen(walletAddress: wallet.address!),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to connect: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateNewWallet() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Generate new wallet
      final newWallet = WalletService.generateWallet();

      // Show the private key to user (important - they need to save it!)
      if (mounted) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _NewWalletDialog(
            privateKey: newWallet.privateKey,
            address: newWallet.address,
          ),
        );

        if (shouldContinue == true) {
          // Connect with the new wallet
          final wallet = WalletService();
          await wallet.connectWithPrivateKey(newWallet.privateKey);

          // Connect to backend
          final army = ArmyService();
          await army.connectWithWallet(walletAddress: newWallet.address);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SquadBrowserScreen(walletAddress: newWallet.address),
              ),
            );
          }
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to generate wallet: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _browseAsGuest() async {
    // Just go to squad browser without wallet
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SquadBrowserScreen(walletAddress: null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo/Title
              _buildHeader(),
              const SizedBox(height: 48),

              // Main options
              if (!_showPrivateKeyInput) ...[
                _buildMainOptions(),
              ] else ...[
                _buildPrivateKeyInput(),
              ],

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberColors.combatRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.combatRed.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: CyberColors.combatRed,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 48),
              _buildLiveStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Military-style banner
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: CyberColors.electricCyan, width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CyberColors.electricCyan.withValues(alpha: 0.1),
                CyberColors.spaceBlack,
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                'VANGUARD DAO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CyberColors.electricCyan,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join the Revolution',
                style: TextStyle(
                  fontSize: 14,
                  color: CyberColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Anonymous soldiers, transparent missions, shared victory',
          style: TextStyle(
            fontSize: 13,
            color: CyberColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainOptions() {
    return Column(
      children: [
        // Generate new wallet (recommended)
        CyberCard(
          onTap: _isLoading ? null : _generateNewWallet,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CyberColors.tacticalGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: CyberColors.tacticalGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Generate New Wallet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: CyberColors.tacticalGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 10,
                                color: CyberColors.tacticalGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a fresh wallet for Vanguard',
                        style: TextStyle(
                          fontSize: 13,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: CyberColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Enter private key
        CyberCard(
          onTap: _isLoading ? null : () => setState(() => _showPrivateKeyInput = true),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CyberColors.militaryAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.key,
                    color: CyberColors.militaryAmber,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Private Key',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use an existing wallet',
                        style: TextStyle(
                          fontSize: 13,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: CyberColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Browse as guest
        CyberCard(
          onTap: _isLoading ? null : _browseAsGuest,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CyberColors.textMuted.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.visibility_outlined,
                    color: CyberColors.textMuted,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View squads without joining',
                        style: TextStyle(
                          fontSize: 13,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: CyberColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateKeyInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _showPrivateKeyInput = false;
              _error = null;
            }),
            icon: Icon(Icons.arrow_back, color: CyberColors.textMuted, size: 18),
            label: Text(
              'Back',
              style: TextStyle(color: CyberColors.textMuted),
            ),
          ),
        ),
        const SizedBox(height: 16),

        CyberCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter Private Key',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your private key is stored securely on this device only.',
                  style: TextStyle(
                    fontSize: 13,
                    color: CyberColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),

                // Private key input
                Container(
                  decoration: BoxDecoration(
                    color: CyberColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.borderSubtle),
                  ),
                  child: TextField(
                    controller: _privateKeyController,
                    obscureText: _obscureKey,
                    style: TextStyle(
                      color: CyberColors.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: '0x...',
                      hintStyle: TextStyle(color: CyberColors.textMuted),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey ? Icons.visibility : Icons.visibility_off,
                          color: CyberColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Security note
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: CyberColors.tacticalGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Never shared. Stored encrypted on device.',
                      style: TextStyle(
                        fontSize: 12,
                        color: CyberColors.tacticalGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Connect button
                ElevatedButton(
                  onPressed: _isLoading ? null : _connectWithPrivateKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberColors.electricCyan,
                    foregroundColor: CyberColors.spaceBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(CyberColors.spaceBlack),
                          ),
                        )
                      : const Text(
                          'CONNECT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: CyberColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            'LIVE STATS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CyberColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(icon: Icons.people, value: '247', label: 'Soldiers'),
              _StatItem(icon: Icons.token, value: '1.2M', label: 'VGRD'),
              _StatItem(icon: Icons.task_alt, value: '892', label: 'Tasks'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: CyberColors.electricCyan, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CyberColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: CyberColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Dialog shown when a new wallet is generated
class _NewWalletDialog extends StatefulWidget {
  final String privateKey;
  final String address;

  const _NewWalletDialog({
    required this.privateKey,
    required this.address,
  });

  @override
  State<_NewWalletDialog> createState() => _NewWalletDialogState();
}

class _NewWalletDialogState extends State<_NewWalletDialog> {
  bool _hasCopied = false;
  bool _hasConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CyberColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning header
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: CyberColors.militaryAmber, size: 28),
                const SizedBox(width: 12),
                Text(
                  'SAVE YOUR KEY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.militaryAmber,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'This is your only chance to save your private key. If you lose it, you lose access to your wallet forever.',
              style: TextStyle(
                fontSize: 14,
                color: CyberColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Address
            _KeyBox(
              label: 'Wallet Address',
              value: widget.address,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: widget.address));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address copied')),
                );
              },
            ),
            const SizedBox(height: 12),

            // Private key
            _KeyBox(
              label: 'Private Key (KEEP SECRET!)',
              value: widget.privateKey,
              isSecret: true,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: widget.privateKey));
                setState(() => _hasCopied = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Private key copied - store it safely!')),
                );
              },
            ),

            const SizedBox(height: 20),

            // Confirmation checkbox
            GestureDetector(
              onTap: () => setState(() => _hasConfirmed = !_hasConfirmed),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _hasConfirmed ? CyberColors.tacticalGreen : CyberColors.textMuted,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: _hasConfirmed
                          ? CyberColors.tacticalGreen.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                    child: _hasConfirmed
                        ? Icon(Icons.check, size: 16, color: CyberColors.tacticalGreen)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I have saved my private key securely',
                      style: TextStyle(
                        fontSize: 14,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: CyberColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_hasCopied && _hasConfirmed)
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.tacticalGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: CyberColors.textMuted.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isSecret;
  final VoidCallback onCopy;

  const _KeyBox({
    required this.label,
    required this.value,
    this.isSecret = false,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSecret ? CyberColors.combatRed : CyberColors.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CyberColors.spaceBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSecret ? CyberColors.combatRed.withValues(alpha: 0.5) : CyberColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: CyberColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onCopy,
                icon: Icon(Icons.copy, size: 18, color: CyberColors.electricCyan),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
