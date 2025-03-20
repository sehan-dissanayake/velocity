import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/wallet/domain/provider/wallet_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _transferFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWalletData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: RefreshIndicator(
        onRefresh: () => walletProvider.loadWalletData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance Card
              _buildBalanceCard(walletProvider),
              const SizedBox(height: 20),

              // Transfer Section
              _buildTransferForm(walletProvider),
              const SizedBox(height: 20),

              // Transaction History
              _buildTransactionList(walletProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Current Balance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Rs. ${provider.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferForm(WalletProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _transferFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter valid amount';
                  }
                  if (amount > provider.balance) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    provider.isLoading
                        ? null
                        : () {
                          if (_transferFormKey.currentState!.validate()) {
                            provider.transferFunds(
                              _emailController.text.trim(),
                              double.parse(_amountController.text),
                            );
                          }
                        },
                child: const Text('Transfer Funds'),
              ),
              if (provider.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    provider.errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(WalletProvider provider) {
    if (provider.transactions.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.transactions[index];
            return _buildTransactionItem(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isCredit = transaction['amount'] > 0;
    final date = DateTime.parse(transaction['created_at']).toLocal();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isCredit ? Icons.arrow_circle_up : Icons.arrow_circle_down,
          color: isCredit ? Colors.green : Colors.red,
        ),
        title: Text(transaction['description']),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rs. ${transaction['amount'].abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Balance: Rs. ${transaction['balance_after'].toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
