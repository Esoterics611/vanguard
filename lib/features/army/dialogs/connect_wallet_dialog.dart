import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/providers/army_provider.dart';

/// Dialog for connecting wallet with private key
class ConnectWalletDialog extends ConsumerStatefulWidget {
  const ConnectWalletDialog({super.key});

  @override
  ConsumerState<ConnectWalletDialog> createState() => _ConnectWalletDialogState();
}

class _ConnectWalletDialogState extends ConsumerState<ConnectWalletDialog> {
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureKey = true;
  String? _error;
  String? _connectedAddress;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _connectWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final walletService = WalletService();
      final success = await walletService.connectWithPrivateKey(_keyController.text);

      if (!success) {
        setState(() {
          _error = 'Invalid private key format';
          _isLoading = false;
        });
        return;
      }

      _connectedAddress = walletService.address;

      // Now enlist with Firebase using the wallet address
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.connectWithWallet(walletAddress: _connectedAddress!);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _generateNewWallet() {
    final wallet = WalletService.generateWallet();
    _keyController.text = wallet.privateKey;
    setState(() {
      _error = null;
    });

    // Show info dialog about saving key
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CyberColors.cardBackground,
        title: Text('New Wallet Generated', style: CyberTextStyles.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SAVE THIS PRIVATE KEY SECURELY!',
              style: CyberTextStyles.labelMedium.copyWith(color: CyberColors.combatRed),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.darkPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address:', style: CyberTextStyles.labelSmall),
                  SelectableText(
                    wallet.address,
                    style: CyberTextStyles.bodySmall.copyWith(color: CyberColors.electricCyan),
                  ),
                  const SizedBox(height: 8),
                  Text('Private Key:', style: CyberTextStyles.labelSmall),
                  SelectableText(
                    wallet.privateKey,
                    style: CyberTextStyles.bodySmall.copyWith(color: CyberColors.militaryAmber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This key will not be shown again. Copy it now.',
              style: CyberTextStyles.bodySmall.copyWith(color: CyberColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: wallet.privateKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Private key copied to clipboard')),
              );
            },
            child: Text('Copy Key', style: TextStyle(color: CyberColors.militaryAmber)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('I Saved It', style: TextStyle(color: CyberColors.electricCyan)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CyberColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CyberColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: CyberColors.electricCyan),
                  const SizedBox(width: 12),
                  Text('Connect Wallet', style: CyberTextStyles.headlineSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your Base Sepolia private key to connect',
                style: CyberTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),

              // Private key input
              TextFormField(
                controller: _keyController,
                obscureText: _obscureKey,
                style: CyberTextStyles.bodyMedium.copyWith(
                  fontFamily: 'monospace',
                  color: CyberColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Private Key',
                  labelStyle: CyberTextStyles.labelMedium,
                  hintText: '0x...',
                  hintStyle: CyberTextStyles.bodySmall.copyWith(color: CyberColors.textMuted),
                  filled: true,
                  fillColor: CyberColors.darkPanel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.electricCyan),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? Icons.visibility_off : Icons.visibility,
                      color: CyberColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your private key';
                  }
                  final clean = value.startsWith('0x') ? value.substring(2) : value;
                  if (clean.length != 64) {
                    return 'Private key must be 64 hex characters';
                  }
                  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(clean)) {
                    return 'Invalid hex characters';
                  }
                  return null;
                },
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: CyberTextStyles.bodySmall.copyWith(color: CyberColors.combatRed),
                ),
              ],

              const SizedBox(height: 24),

              // Connect button
              ElevatedButton(
                onPressed: _isLoading ? null : _connectWallet,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: CyberColors.electricCyan,
                  foregroundColor: CyberColors.spaceBlack,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Connect Wallet'),
              ),

              const SizedBox(height: 12),

              // Generate new wallet
              OutlinedButton(
                onPressed: _isLoading ? null : _generateNewWallet,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: CyberColors.officerGold),
                  foregroundColor: CyberColors.officerGold,
                ),
                child: const Text('Generate New Wallet'),
              ),

              const SizedBox(height: 16),

              Text(
                'Network: Base Sepolia (Chain ID: 84532)',
                style: CyberTextStyles.labelSmall.copyWith(color: CyberColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
