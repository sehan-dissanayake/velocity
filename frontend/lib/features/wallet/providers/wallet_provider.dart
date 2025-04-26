import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/api_with_auth_service.dart';

class WalletProvider extends ChangeNotifier {
  String? _cardNumber;
  double? _balance;
  List<dynamic>? _transactions;
  bool _isLoading = false;
  String _error = '';
  
  // Stream controller for broadcasting wallet updates
  final _walletUpdateController = StreamController<void>.broadcast();
  
  // Getters
  String? get cardNumber => _cardNumber;
  double? get balance => _balance;
  List<dynamic>? get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  Stream<void> get walletUpdates => _walletUpdateController.stream;
  
  // Load wallet data
  Future<void> loadWalletData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final walletData = await ApiWithAuthService.get('wallet');
      final transactions = await ApiWithAuthService.get('wallet/transactions');
      
      _cardNumber = walletData['card_number'];
      _balance = double.parse(walletData['balance'].toString());
      _transactions = transactions;
      _error = '';
      
      // Notify all listeners (UI components) that wallet data has changed
      notifyListeners();
      
      // Broadcast wallet update event to any components listening to the stream
      _walletUpdateController.add(null);
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Directly update balance from a notification (temporary update until full refresh)
  void updateBalanceFromNotification(double newBalance) {
    _balance = newBalance;
    notifyListeners();
    
    // Also trigger a full refresh to get updated transaction history
    loadWalletData();
  }
  
  // Transfer money to another user
  Future<Map<String, dynamic>> transferMoney(String recipientCardNumber, double amount) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiWithAuthService.post('wallet/transfer', {
        'recipient_card_number': recipientCardNumber,
        'amount': amount,
      });
      
      // Update wallet data after successful transfer
      await loadWalletData();
      
      return {
        'success': true,
        'message': 'Transfer successful',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Dispose of resources
  void dispose() {
    _walletUpdateController.close();
    super.dispose();
  }
}