import 'package:flutter/material.dart';
import 'package:frontend/core/utils/api_with_auth_service.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/utils/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? _cardNumber;
  double? _balance;
  List<dynamic>? _transactions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final walletData = await ApiWithAuthService.get('wallet');
      final transactions = await ApiWithAuthService.get('wallet/transactions');
      setState(() {
        _cardNumber = walletData['card_number'];
        _balance = double.parse(walletData['balance'].toString());
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load wallet data')));
    }
  }

  void _showTransferDialog() {
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Transfer Money'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Card Number',
                  ),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final recipient = recipientController.text;
                  final amount = double.tryParse(amountController.text);
                  if (recipient.isEmpty || amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid input')),
                    );
                    return;
                  }
                  try {
                    await ApiWithAuthService.post('wallet/transfer', {
                      'recipient_card_number': recipient,
                      'amount': amount,
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfer successful')),
                    );
                    _loadWalletData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transfer failed: $e')),
                    );
                  }
                },
                child: const Text('Transfer'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Digital Card
            Card(
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'VeloCiti Digital Travel Card',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cardNumber ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Balance: Rs. ${_balance?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showTransferDialog,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text('Transfer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            // Payment History
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions?.length ?? 0,
              itemBuilder: (context, index) {
                final transaction = _transactions![index];
                final type = transaction['type'];
                final isIncoming =
                    type == 'recharge' || type == 'transfer_received';
                final typeColor = isIncoming ? Colors.green : Colors.red;
                final typeText =
                    {
                      'recharge': 'Recharge',
                      'payment': 'Payment',
                      'transfer_sent': 'Transfer Sent',
                      'transfer_received': 'Transfer Received',
                    }[type] ??
                    type;
                final date = DateFormat(
                  'dd/MM/yy',
                ).format(DateTime.parse(transaction['transaction_date']));
                final amount = double.parse(
                  transaction['amount'].toString(),
                ).abs().toStringAsFixed(2);
                final balanceAfter = double.parse(
                  transaction['balance_after'].toString(),
                ).toStringAsFixed(2);
                return ListTile(
                  tileColor: Colors.black54,
                  title: Text(typeText, style: TextStyle(color: typeColor)),
                  subtitle: Text(
                    date,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. $amount',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Balance - Rs. $balanceAfter',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
