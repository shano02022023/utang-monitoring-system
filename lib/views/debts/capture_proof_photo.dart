import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utang_monitoring_system/controller/debts_controller.dart';
import 'package:utang_monitoring_system/views/debts/debts.dart';

class CaptureProofPhoto extends StatefulWidget {
  final String id;

  const CaptureProofPhoto({super.key, required this.id});

  @override
  State<CaptureProofPhoto> createState() => _CaptureProofPhotoState();
}

class _CaptureProofPhotoState extends State<CaptureProofPhoto> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      setState(() {
        _error = "Camera permission denied.";
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = "No camera found.";
        });
        return;
      }

      _controller = CameraController(_cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to initialize camera: $e";
      });
    }
  }

  Future<void> _takePicture(BuildContext context) async {
    if (!_controller!.value.isInitialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = join(directory.path, fileName);

      final file = await _controller!.takePicture();
      final savedImage = await File(file.path).copy(filePath);

      // Show preview dialog
      final shouldSubmit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Confirm Photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      savedImage,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Do you want to submit this photo as proof?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Retake',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            ),
      );

      if (shouldSubmit == true) {
        final response =
            await DebtsController.uploadProofAndUpdateStatusToPaid(
              savedImage.path,
              widget.id,
            );

        if (response == 1) {
          Get.snackbar(
            'Success',
            'Proof photo uploaded and status updated successfully.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAll(() => const DebtsPage());
        } else {
          Get.snackbar(
            'Error',
            'Error uploading proof photo or updating status.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
      // If "Retake", just return and allow user to take another picture
    } catch (e) {
      print("Error taking picture: $e");
      Get.snackbar(
        'Error',
        'Failed to capture photo.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Capture Proof Photo")),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Capture Proof Photo ${widget.id}')),
      body:
          _isCameraInitialized
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade400),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _takePicture(context);
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Capture Photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
