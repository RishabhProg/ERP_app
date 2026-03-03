import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';

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
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          // Lottie background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Lottie.asset(
                'assets/night.json',
                frameRate: FrameRate(30),
                fit: BoxFit.cover,
                repeat: true,
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFF1A1A2E), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'E-Identity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 8,),

                // Barcode card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: barcodeData == null
                        ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2E9E5B)),
                    )
                        : Column(
                      children: [
                        const Text(
                          'Student ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 24),
                        BarcodeWidget(
                          barcode: Barcode.code39(),
                          data: barcodeData!,
                          width: double.infinity,
                          height: 100,
                          drawText: false,
                          color: const Color(0xFF1A1A2E),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          barcodeData!,
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2,
                            color: const Color(0xFF1A1A2E).withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 10,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}