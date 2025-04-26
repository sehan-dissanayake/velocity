import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/utils/api_with_auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/wallet/providers/wallet_provider.dart';
import 'dart:async';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _currentDateTime = "2025-03-22 20:18:44";
  String _currentUser = "ASHIDU DISSANAYAKE"; // Replace with actual user data
  StreamSubscription? _walletUpdateSubscription;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _updateCurrentDateTime();
    
    // Load wallet data via provider
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    walletProvider.loadWalletData().then((_) {
      _animationController.forward();
    });
    
    // Listen for wallet updates and refresh animation
    _walletUpdateSubscription = walletProvider.walletUpdates.listen((_) {
      _updateCurrentDateTime();
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _updateCurrentDateTime() {
    // Update the current date time in the specified format
    final now = DateTime.now().toLocal();
    setState(() {
      _currentDateTime = "${now.year}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _walletUpdateSubscription?.cancel();
    super.dispose();
  }
  
  // This function will be called when pull-to-refresh is triggered
  Future<void> _handleRefresh() async {
    _updateCurrentDateTime();
    
    // Show loading animation
    setState(() {});
    
    try {
      await Provider.of<WalletProvider>(context, listen: false).loadWalletData();      
      // Reset and play animation
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Failed to refresh wallet',
                style: GoogleFonts.montserrat(),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showTransferDialog() {
    final TextEditingController recipientController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isProcessing = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2126),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Send Money",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: recipientController,
                      style: GoogleFonts.montserrat(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Recipient Card Number",
                        labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade400),
                        hintText: "XXXX XXXX XXXX XXXX",
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.credit_card, color: Colors.grey.shade400),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter recipient card number';
                        }
                        // Basic validation for card number format
                        final cardNumber = value.replaceAll(' ', '');
                        if (cardNumber.length != 16) {
                          return 'Card number must be 16 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      style: GoogleFonts.montserrat(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount (Rs.)",
                        labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade400),
                        hintText: "0.00",
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.attach_money, color: Colors.grey.shade400),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        
                        // Check if user has sufficient balance
                        final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                        if (walletProvider.balance != null && amount > walletProvider.balance!) {
                          return 'Insufficient balance';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (isProcessing)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.montserrat(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isProcessing = true;
                            });
                            
                            try {
                              final recipientCardNumber = recipientController.text.replaceAll(' ', '');
                              final amount = double.parse(amountController.text);
                              
                              // Make API call to transfer money
                              final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                              final result = await walletProvider.transferMoney(recipientCardNumber, amount);
                              
                              // Close dialog
                              Navigator.of(context).pop();
                              
                              if (result['success']) {
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Text(
                                          result['message'],
                                          style: GoogleFonts.montserrat(),
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.green.shade700,
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              } else {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Transfer failed: ${result['message']}',
                                          style: GoogleFonts.montserrat(),
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.red.shade700,
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                isProcessing = false;
                              });
                              
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Transfer failed: ${e.toString()}',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red.shade700,
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "Send",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        if (walletProvider.isLoading && walletProvider.balance == null) {
          return _buildLoadingView();
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF101114),
                Color(0xFF15171A),
                Color(0xFF1A1D22),
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                "My Wallet",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                // Display current date/time and user
                
              ],
            ),
            body: RefreshIndicator(
              key: _refreshKey,
              onRefresh: _handleRefresh,
              color: Colors.amber,
              backgroundColor: const Color(0xFF1A1D22),
              strokeWidth: 2.5,
              displacement: 40,
              edgeOffset: 20,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Current date/time indicator
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync,
                          size: 14,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Last updated: $_currentDateTime",
                          style: GoogleFonts.montserrat(
                            color: Colors.grey.shade300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ).animate(controller: _animationController)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.2, end: 0, duration: 300.ms),
                  
                  const SizedBox(height: 8),
                  
                  // Pull to refresh hint text
                  Center(
                    child: Text(
                      "↓ Pull down to refresh wallet ↓",
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ).animate(controller: _animationController)
                    .fadeIn(duration: 500.ms, delay: 200.ms),
                    
                  const SizedBox(height: 20),
                  
                  // Wallet card
                  _buildWalletCard(walletProvider),
                  
                  const SizedBox(height: 30),
                  
                  // Transaction buttons row
                  _buildActionButtonsRow(),
                  
                  const SizedBox(height: 30),
                  
                  // Transactions history
                  _buildTransactionsSection(walletProvider),
                  
                  // Extra space at bottom for comfort
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Build digital wallet card
  Widget _buildWalletCard(WalletProvider walletProvider) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF232529),
            const Color(0xFF1C1E22),
            Colors.black.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Card content
      child: Stack(
        children: [
          // Subtle pattern background
          Positioned.fill(
            child: Opacity(
              opacity: 0.07,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          
          // Card content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: Colors.amber.shade400,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "VELOCITI",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "DIGITAL TRAVEL CARD",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Card number
                Text(
                  _formatCardNumber(walletProvider.cardNumber ?? ""),
                  style: GoogleFonts.robotoMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Balance and holder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BALANCE",
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "RS. ${walletProvider.balance?.toStringAsFixed(2) ?? '0.00'}",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CARD HOLDER",
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentUser.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Highlight effect on refresh
          if (walletProvider.isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Colors.amber.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ).animate()
              .fadeIn(duration: 300.ms)
              .fadeOut(duration: 800.ms),
        ],
      ),
    ).animate(controller: _animationController)
      .fadeIn(duration: 600.ms, delay: 300.ms)
      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms);
  }
  
  // Build action buttons row
  Widget _buildActionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.arrow_upward_rounded,
          label: "Send",
          color: Colors.amber,
          onPressed: _showTransferDialog,
          delay: 500,
        ),
        _buildActionButton(
          icon: Icons.arrow_downward_rounded,
          label: "Request",
          color: Colors.lightBlue,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Feature coming soon',
                  style: GoogleFonts.montserrat(),
                ),
                backgroundColor: Colors.grey.shade800,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          },
          delay: 600,
        ),
        _buildActionButton(
          icon: Icons.qr_code_scanner_rounded,
          label: "Scan",
          color: Colors.green,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Feature coming soon',
                  style: GoogleFonts.montserrat(),
                ),
                backgroundColor: Colors.grey.shade800,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          },
          delay: 700,
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    ).animate(controller: _animationController)
     .fadeIn(duration: 400.ms, delay: delay.ms)
     .scale(
       begin: const Offset(0.8, 0.8),
       end: const Offset(1.0, 1.0),
       duration: 500.ms, 
       delay: delay.ms,
       curve: Curves.easeOutBack,
     );
  }
  
  // Build transactions section
  Widget _buildTransactionsSection(WalletProvider walletProvider) {
    final transactions = walletProvider.transactions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Transaction History",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all transactions
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "View All",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ).animate(controller: _animationController)
         .fadeIn(duration: 500.ms, delay: 800.ms),
        
        const SizedBox(height: 16),
        
        // Transactions list
        if (transactions == null || transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No transactions yet",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your transaction history will appear here",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ).animate(controller: _animationController)
           .fadeIn(duration: 500.ms, delay: 900.ms),
        if (transactions != null && transactions.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final type = transaction['type'];
              final isIncoming = type == 'recharge' || type == 'transfer_received';
              
              return _buildTransactionItem(
                type: type,
                amount: double.parse(transaction['amount'].toString()),
                date: DateFormat('dd MMM yyyy, HH:mm').format(
                  DateTime.parse(transaction['transaction_date']),
                ),
                balanceAfter: double.parse(transaction['balance_after'].toString()),
                isIncoming: isIncoming,
                delay: 900 + (index * 100),
              );
            },
          ),
      ],
    );
  }
  
  // Build a transaction item
  Widget _buildTransactionItem({
    required String type,
    required double amount,
    required String date,
    required double balanceAfter,
    required bool isIncoming,
    required int delay,
  }) {
    final typeMap = {
      'recharge': 'Recharge',
      'payment': 'Payment',
      'transfer_sent': 'Transfer Sent',
      'transfer_received': 'Transfer Received',
    };
    
    final typeText = typeMap[type] ?? type;
    final iconMap = {
      'recharge': Icons.account_balance_wallet,
      'payment': Icons.shopping_cart_outlined,
      'transfer_sent': Icons.arrow_upward_rounded,
      'transfer_received': Icons.arrow_downward_rounded,
    };
    
    final icon = iconMap[type] ?? Icons.receipt_long;
    final color = isIncoming ? Colors.green : Colors.red.shade400;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E2126).withOpacity(0.6),
            const Color(0xFF15171A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          
          const SizedBox(width: 14),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeText,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isIncoming ? "+" : "-"} Rs. ${amount.abs().toStringAsFixed(2)}",
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Balance: Rs. ${balanceAfter.toStringAsFixed(2)}",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(controller: _animationController)
     .fadeIn(duration: 500.ms, delay: delay.ms)
     .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: delay.ms);
  }
  
  // Build loading view
  Widget _buildLoadingView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF101114),
            Color(0xFF15171A),
            Color(0xFF1A1D22),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Loading your wallet...",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentDateTime,
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatCardNumber(String cardNumber) {
    // Format card number as XXXX XXXX XXXX XXXX
    if (cardNumber.isEmpty) return "";
    
    // Remove any existing spaces
    cardNumber = cardNumber.replaceAll(' ', '');
    
    // Add spaces every 4 characters
    final buffer = StringBuffer();
    for (int i = 0; i < cardNumber.length; i++) {
      buffer.write(cardNumber[i]);
      if ((i + 1) % 4 == 0 && i != cardNumber.length - 1) {
        buffer.write(' ');
      }
    }
    
    return buffer.toString();
  }
}