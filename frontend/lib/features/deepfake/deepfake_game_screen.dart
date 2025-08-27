import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/image_analysis.dart';

class DeepfakeGameScreen extends StatefulWidget {
  const DeepfakeGameScreen({super.key});
  @override
  State<DeepfakeGameScreen> createState() => _DeepfakeGameScreenState();
}

class _DeepfakeGameScreenState extends State<DeepfakeGameScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  XFile? _imageFile;
  ImageAnalysis? _analysisResult;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickAndAnalyzeImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selectedImage == null) return;

    setState(() {
      _imageFile = selectedImage;
      _isLoading = true;
      _analysisResult = null;
      _error = null;
    });

    try {
      final result = await _apiService.analyzeImage(selectedImage);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _error =
            "Analysis failed. The image might be unsupported or the server is busy. Please try again.";
      });
      print("Analysis Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _imageFile = null;
      _analysisResult = null;
      _error = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- MAIN CONTENT AREA ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _buildContent(), // Logic is now in a helper method
              ),
            ),

            // --- ACTION BUTTON ---
            // This button is now persistent and changes its function
            const SizedBox(height: 20),
            if (_imageFile == null)
              ElevatedButton.icon(
                onPressed: _pickAndAnalyzeImage,
                icon: const Icon(Iconsax.document_upload),
                label: const Text('Select Image to Analyze'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Analyze Another Image'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to decide which view to show
  Widget _buildContent() {
    if (_imageFile == null) {
      return _buildInitialView();
    } else if (_isLoading) {
      return _buildAnalyzingView();
    } else {
      return _buildResultsView();
    }
  }

  Widget _buildInitialView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeInDown(child: const Icon(Iconsax.scan_barcode, size: 80)),
        const SizedBox(height: 20),
        FadeInUp(
          child: Text(
            'AI Image Analyzer',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: const Text(
            'Our AI will check for signs of manipulation like unnatural textures, inconsistent lighting, and other artifacts.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text('Analyzing...', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Please wait while our AI scans the image.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Analysis Complete',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(File(_imageFile!.path)),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          if (_analysisResult != null)
            FadeIn(
              duration: const Duration(milliseconds: 500),
              child: _ResultCard(result: _analysisResult!),
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ImageAnalysis result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isFake = result.isLikelyFake;
    final Color color = isFake ? Colors.orange.shade800 : Colors.green.shade600;
    final IconData icon = isFake ? Iconsax.warning_2 : Iconsax.verify;

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  isFake ? 'Likely Manipulated' : 'Likely Authentic',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%',
            ),
            const Divider(height: 24),
            Text(
              'Key Observations:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.analysisPoints.map(
              (point) => ListTile(
                leading: Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(point),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
