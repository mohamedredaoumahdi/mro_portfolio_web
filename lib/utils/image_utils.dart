// lib/utils/image_utils.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this package to pubspec.yaml
import 'package:uuid/uuid.dart'; // Add this package to pubspec.yaml
import 'package:image/image.dart' as img; // Add this package to pubspec.yaml
import '../models/project_model.dart';

class ImageUtils {
  static const _uuid = Uuid();
  
  // Pick an image from device and convert to base64
  static Future<ProjectScreenshot?> pickImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 800,
    int maxHeight = 600,
    int quality = 85,
    String caption = '',
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Pick image
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );
      
      if (pickedFile == null) {
        return null;
      }
      
      // Get image data
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      
      // Compress image to reduce size
      final compressedBytes = await _compressImage(imageBytes, quality);
      
      // Generate unique ID
      final id = _uuid.v4();
      
      // Convert to Base64
      final String base64Image = base64Encode(compressedBytes);
      
      return ProjectScreenshot(
        id: id,
        imageBase64: base64Image,
        caption: caption,
      );
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
  
  // Compress image bytes
  static Future<Uint8List> _compressImage(Uint8List bytes, int quality) async {
    try {
      // Use compute to run in a separate isolate for better performance
      return await compute(_compressImageImpl, {
        'bytes': bytes,
        'quality': quality,
      });
    } catch (e) {
      print('Error compressing image: $e');
      // Return original bytes if compression fails
      return bytes;
    }
  }
  
  // Implementation of image compression (runs in isolate)
  static Uint8List _compressImageImpl(Map<String, dynamic> params) {
    final Uint8List bytes = params['bytes'];
    final int quality = params['quality'];
    
    // Decode image using image package
    final img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      return bytes;
    }
    
    // Resize image if too large (dimensions greater than 1600px)
    img.Image resizedImage = image;
    if (image.width > 1600 || image.height > 1600) {
      final int maxDimension = image.width > image.height ? image.width : image.height;
      final double scale = 1600 / maxDimension;
      resizedImage = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.average,
      );
    }
    
    // Encode as JPEG with specified quality
    final Uint8List compressedBytes = Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: quality),
    );
    
    return compressedBytes;
  }
  
  // Convert Base64 to Image Widget
  static Widget base64ToImage(String base64String, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    try {
      if (base64String.isEmpty) {
        return errorWidget ?? const Icon(Icons.broken_image);
      }
      
      final Uint8List bytes = base64Decode(base64String);
      
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.broken_image, size: 40);
        },
      );
    } catch (e) {
      print('Error converting base64 to image: $e');
      return errorWidget ?? const Icon(Icons.broken_image, size: 40);
    }
  }
  
  // Calculate size of Base64 string in KB
  static double getBase64SizeInKB(String base64String) {
    return base64String.length * 3 / 4 / 1024;
  }
}