import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';

import '../screens/footer.dart';

class EIdentityScreen extends StatefulWidget {
  const EIdentityScreen({super.key});

  @override
  State<EIdentityScreen> createState() => _EIdentityScreenState();
}

class _EIdentityScreenState extends State<EIdentityScreen> {
  String? barcodeData;

  @override
  void initState() {
    super.initState();
    _loadBarcode();
  }

  Future<void> _loadBarcode() async {
    const storage = FlutterSecureStorage();
    final username = await storage.read(key: 'stored_username');
    if (username != null && username.length > 3) {
      setState(() {
        barcodeData = username.substring(0, username.length - 3);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF141840),
                    Color(0xFF020617),
                    Color(0xFF1C1736),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Text(
                        'E-Identity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Barcode card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1.5,
                          ),
                        ),
                        child: barcodeData == null
                            ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF2E9E5B)),
                        )
                            : Column(
                          children: [
                            // Label
                            Text(
                              'STUDENT ID',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.45),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Barcode on white background for scannability
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: BarcodeWidget(
                                barcode: Barcode.code39(),
                                data: barcodeData!,
                                width: double.infinity,
                                height: 100,
                                drawText: false,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Barcode number
                            Text(
                              barcodeData!,
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 2,
                                color: Colors.white.withOpacity(0.55),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),
                const AppFooter(),
                const SizedBox(height: 100,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}