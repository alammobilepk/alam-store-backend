import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // FORM KEY FOR VALIDATION (Length Increase + Professionalism)
  final _formKey = GlobalKey<FormState>();

  // Controllers for all input fields
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  int currentStep = 1;
  int paymentType = 0; // 0: COD, 1: EasyPaisa, 2: Bank
  bool agreeToTerms = false;
  bool saveInfo = true;

  @override
  void dispose() {
    fNameController.dispose();
    lNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    zipController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: _buildCheckoutAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildModernStepIndicator(),
              _buildSecurityBadge(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Personal Details", Icons.badge_outlined),
                    _buildPersonalFields(),
                    const SizedBox(height: 25),

                    _buildSectionHeader("Shipping Address", Icons.location_on_outlined),
                    _buildAddressFields(),
                    const SizedBox(height: 25),

                    _buildSectionHeader("Payment Method", Icons.payments_outlined),
                    _buildPaymentGrid(),
                    const SizedBox(height: 25),

                    _buildSectionHeader("Order Summary", Icons.receipt_long_outlined),
                    _buildFinalSummaryCard(),
                    const SizedBox(height: 20),

                    _buildAgreements(),
                    const SizedBox(height: 120), // Spacer for bottom sheet
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildPlaceOrderAction(),
    );
  }

  // --- UI PARTS ---

  PreferredSizeWidget _buildCheckoutAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF004AAD), size: 20), onPressed: () => Navigator.pop(context)),
      title: const Column(children: [
        Text("SECURE CHECKOUT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
        Text("Powered by Alam Enterprises", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ]),
      centerTitle: true,
    );
  }

  Widget _buildModernStepIndicator() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepNode(Icons.shopping_cart, "Cart", true),
          _stepConnector(true),
          _stepNode(Icons.local_shipping, "Shipping", true),
          _stepConnector(false),
          _stepNode(Icons.verified, "Review", false),
        ],
      ),
    );
  }

  Widget _stepNode(IconData i, String t, bool active) => Column(children: [
    CircleAvatar(radius: 20, backgroundColor: active ? const Color(0xFF004AAD) : Colors.grey.shade100, child: Icon(i, color: active ? Colors.white : Colors.grey, size: 18)),
    const SizedBox(height: 5),
    Text(t, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.black : Colors.grey)),
  ]);

  Widget _stepConnector(bool active) => Container(width: 50, height: 2, margin: const EdgeInsets.only(bottom: 22), color: active ? const Color(0xFF004AAD) : Colors.grey.shade200);

  Widget _buildSecurityBadge() => Container(
    margin: const EdgeInsets.all(15),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.2))),
    child: Row(children: [const Icon(Icons.shield_outlined, color: Colors.green, size: 20), const SizedBox(width: 12), Expanded(child: Text("Your payment data is processed securely via SSL encryption.", style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold)))]),
  );

  Widget _buildSectionHeader(String t, IconData i) => Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Row(children: [Icon(i, color: const Color(0xFF004AAD)), const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))]));

  Widget _buildPersonalFields() => _cardShell([
    _customInput("First Name", Icons.person_outline, fNameController),
    const SizedBox(height: 12),
    _customInput("Mobile Number", Icons.phone_android_outlined, phoneController),
    const SizedBox(height: 12),
    _customInput("Email Address", Icons.mail_outline, emailController),
  ]);

  Widget _buildAddressFields() => _cardShell([
    _customInput("Full House/Office Address", Icons.map_outlined, addressController, maxL: 2),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _customInput("City", Icons.location_city, cityController)),
      const SizedBox(width: 12),
      Expanded(child: _customInput("Zip Code", Icons.post_add, zipController)),
    ]),
  ]);

  Widget _cardShell(List<Widget> content) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
    child: Column(children: content),
  );

  Widget _customInput(String hint, IconData icon, TextEditingController ctrl, {int maxL = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxL,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF004AAD), size: 20),
        filled: true, fillColor: const Color(0xFFFBFDFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPaymentGrid() {
    return Column(children: [
      _paymentOption(0, "Cash on Delivery", "Pay when you receive", Icons.delivery_dining),
      _paymentOption(1, "EasyPaisa / JazzCash", "Instant mobile transfer", Icons.account_balance_wallet),
      _paymentOption(2, "Bank Transfer", "Direct to Alam Ent. Account", Icons.account_balance),
    ]);
  }

  Widget _paymentOption(int val, String title, String sub, IconData icon) {
    bool isSelected = paymentType == val;
    return GestureDetector(
      onTap: () => setState(() => paymentType = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? const Color(0xFF004AAD) : Colors.transparent, width: 2),
        ),
        child: Row(children: [
          Icon(icon, color: isSelected ? const Color(0xFF004AAD) : Colors.grey, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          ),
          Radio(value: val, groupValue: paymentType, onChanged: (v) => setState(() => paymentType = v as int), activeColor: const Color(0xFF004AAD)),
        ]),
      ),
    );
  }

  Widget _buildFinalSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E1E2C), Color(0xFF232335)]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _summaryRow("Basket Subtotal", "Rs 330,000", Colors.white70),
          _summaryRow("Shipping (Express)", "Rs 500", Colors.white70),
          _summaryRow("Platform Fee", "Rs 150", Colors.white70),
          const Divider(color: Colors.white10, height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ORDER TOTAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Rs 330,650", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }

  // FIXED SUMMARY ROW METHOD
  Widget _summaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAgreements() {
    return Column(children: [
      CheckboxListTile(
        value: agreeToTerms, 
        activeColor: const Color(0xFF004AAD),
        title: const Text("I agree to the Electronic Dukaan Terms and Refund Policy.", style: TextStyle(fontSize: 11)),
        onChanged: (v) => setState(() => agreeToTerms = v!),
      ),
      CheckboxListTile(
        value: saveInfo, 
        activeColor: const Color(0xFF004AAD),
        title: const Text("Save this information for faster checkout next time.", style: TextStyle(fontSize: 11)),
        onChanged: (v) => setState(() => saveInfo = v!),
      ),
    ]);
  }

  Widget _buildPlaceOrderAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 100,
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)]),
      child: Row(
        children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Payable Amount", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text("Rs 330,650", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF004AAD))),
          ]),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: agreeToTerms ? const Color(0xFF004AAD) : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: agreeToTerms ? () {
                if (_formKey.currentState!.validate()) {
                  _showSuccessDialog(); // Ye puranay code ka best feature merge kar diya
                }
              } : null,
              child: const Text("CONFIRM ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  // OLD CODE SUCCESS DIALOG RETAINED
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("ORDER PLACED!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text("Your request for Electronic Dukaan has been submitted.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("BACK TO HOME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}