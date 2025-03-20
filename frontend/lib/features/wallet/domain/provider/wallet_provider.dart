import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/api_service.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  List<dynamic> _transactions = [];
  String _errorMessage = '';
  bool _isLoading = false;

  double get balance => _balance;
  List<dynamic> get transactions => _transactions;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadWalletData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load balance
      final balanceResponse = await ApiService.get('wallet/balance');
      _balance = balanceResponse['balance'].toDouble();

      // Load transactions
      final transactionsResponse = await ApiService.get('wallet/transactions');
      _transactions = transactionsResponse;

      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> transferFunds(String recipientEmail, double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post('wallet/transfer', {
        'recipientEmail': recipientEmail,
        'amount': amount,
      });

      // Refresh data after transfer
      await loadWalletData();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
