import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing wallet operations on Base Sepolia
class WalletService {
  static const String _rpcUrl = 'https://sepolia.base.org';
  static const String _walletKey = 'vanguard_wallet_address';
  static const String _privateKeyKey = 'vanguard_private_key_encrypted';

  Web3Client? _client;
  EthPrivateKey? _credentials;
  EthereumAddress? _address;

  // Singleton
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  Web3Client get client {
    _client ??= Web3Client(_rpcUrl, http.Client());
    return _client!;
  }

  bool get isConnected => _credentials != null && _address != null;
  String? get address => _address?.hexEip55;
  EthPrivateKey? get credentials => _credentials;

  /// Initialize wallet from stored private key
  Future<bool> initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedKey = prefs.getString(_privateKeyKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        return connectWithPrivateKey(storedKey, persist: false);
      }
    } catch (e) {
      debugPrint('Failed to init wallet from storage: $e');
    }
    return false;
  }

  /// Connect wallet using private key
  Future<bool> connectWithPrivateKey(String privateKey, {bool persist = true}) async {
    try {
      // Clean the key
      String cleanKey = privateKey.trim();
      if (cleanKey.startsWith('0x')) {
        cleanKey = cleanKey.substring(2);
      }

      // Validate hex - must be valid hex chars
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanKey)) {
        throw Exception('Invalid private key format - not valid hex');
      }

      // Pad with leading zeros if shorter than 64 chars
      if (cleanKey.length < 64) {
        cleanKey = cleanKey.padLeft(64, '0');
      } else if (cleanKey.length > 64) {
        throw Exception('Invalid private key format - too long');
      }

      _credentials = EthPrivateKey.fromHex(cleanKey);
      _address = _credentials!.address;

      if (persist) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_privateKeyKey, cleanKey);
        await prefs.setString(_walletKey, _address!.hexEip55);
      }

      debugPrint('Wallet connected: ${_address!.hexEip55}');
      return true;
    } catch (e) {
      debugPrint('Failed to connect wallet: $e');
      _credentials = null;
      _address = null;
      return false;
    }
  }

  /// Disconnect and clear stored wallet
  Future<void> disconnect() async {
    _credentials = null;
    _address = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privateKeyKey);
    await prefs.remove(_walletKey);
  }

  /// Get ETH balance
  Future<double> getBalance() async {
    if (_address == null) return 0;
    try {
      final balance = await client.getBalance(_address!);
      return balance.getValueInUnit(EtherUnit.ether);
    } catch (e) {
      debugPrint('Failed to get balance: $e');
      return 0;
    }
  }

  /// Sign a message
  Future<String?> signMessage(String message) async {
    if (_credentials == null) return null;
    try {
      final messageBytes = utf8.encode(message);
      final signature = _credentials!.signPersonalMessageToUint8List(
        Uint8List.fromList(messageBytes),
      );
      return bytesToHex(signature, include0x: true);
    } catch (e) {
      debugPrint('Failed to sign message: $e');
      return null;
    }
  }

  /// Generate a new random wallet
  static ({String privateKey, String address}) generateWallet() {
    final credentials = EthPrivateKey.createRandom(Random.secure());
    // privateKey is Uint8List, need to ensure it's 32 bytes (64 hex chars)
    final keyBytes = credentials.privateKey;
    // Pad to 32 bytes if needed (leading zeros can be stripped)
    final paddedKey = Uint8List(32);
    final offset = 32 - keyBytes.length;
    for (var i = 0; i < keyBytes.length; i++) {
      paddedKey[offset + i] = keyBytes[i];
    }
    return (
      privateKey: bytesToHex(paddedKey, include0x: true),
      address: credentials.address.hexEip55,
    );
  }
}
