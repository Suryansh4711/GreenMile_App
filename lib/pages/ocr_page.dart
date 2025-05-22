import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import '../models/emission_result.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  final OcrService _ocrService = OcrService();
  EmissionResult? _lastScanResult;

  Future<void> _scanEmissions(bool fromCamera) async {
    final result = fromCamera 
      ? await _ocrService.processImageFromCamera()
      : await _ocrService.processImageFromGallery();
    
    if (result != null) {
      setState(() => _lastScanResult = result);
      _showResultDialog(result);
    }
  }

  void _showResultDialog(EmissionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Scan Results',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow('CO₂ Saved', '${result.co2Saved.toStringAsFixed(2)} kg'),
            _buildResultRow('NOx Saved', '${result.noxSaved.toStringAsFixed(2)} g'),
            _buildResultRow('SO₂ Saved', '${result.so2Saved.toStringAsFixed(2)} g'),
            _buildResultRow('Fuel Saved', '${result.fuelSaved.toStringAsFixed(2)} L'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _scanEmissions(true),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _scanEmissions(false),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
