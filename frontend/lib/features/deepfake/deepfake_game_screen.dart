import 'dart:io';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageFile == null)
                _buildInitialView()
              else
                _buildAnalysisView(),
              const SizedBox(height: 20),
              if (!_isLoading)
                ElevatedButton.icon(
                  onPressed: _pickAndAnalyzeImage,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _imageFile == null
                        ? 'Select Image to Analyze'
                        : 'Analyze Another Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        const Icon(Icons.image_search, size: 80),
        const SizedBox(height: 20),
        Text(
          'AI Image Analyzer',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Select an image from your gallery and our AI will check it for signs of manipulation.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnalysisView() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
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
            if (_analysisResult != null) _buildResultCard(_analysisResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ImageAnalysis result) {
    final bool isFake = result.isLikelyFake;
    final Color color = isFake ? Colors.orange.shade800 : Colors.green.shade600;
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              isFake ? 'Likely AI-Generated / Manipulated' : 'Likely Authentic',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%',
            ),
            const Divider(height: 24),
            Text(
              'Key Observations:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...result.analysisPoints.map(
              (point) => ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
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
