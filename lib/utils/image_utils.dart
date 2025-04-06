// lib/utils/image_utils.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import '../models/project_model.dart';

class ImageUtils {
  static const _uuid = Uuid();
  static const int _maxImageSizeKB = 800; // Maximum size in KB for stored images
  
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
      
      // Check size of image
      final double sizeInKB = imageBytes.length / 1024;
      print('Original image size: ${sizeInKB.toStringAsFixed(2)} KB');
      
      // Compress image to reduce size
      final compressedBytes = await _compressImage(imageBytes, quality);
      final compressedSizeInKB = compressedBytes.length / 1024;
      print('Compressed image size: ${compressedSizeInKB.toStringAsFixed(2)} KB');
      
      // If still too large, reduce quality further
      Uint8List finalBytes = compressedBytes;
      if (compressedSizeInKB > _maxImageSizeKB) {
        final lowerQuality = quality > 70 ? quality - 20 : 50;
        finalBytes = await _compressImage(compressedBytes, lowerQuality);
        print('Further compressed image size: ${(finalBytes.length / 1024).toStringAsFixed(2)} KB');
      }
      
      // Generate unique ID
      final id = _uuid.v4();
      
      // Convert to Base64
      final String base64Image = base64Encode(finalBytes);
      
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
  
  // Compress image bytes with optimized approach
  static Future<Uint8List> _compressImage(Uint8List bytes, int quality) async {
    try {
      // Skip compression for already small images (under 200KB)
      if (bytes.length < 200 * 1024 && quality >= 80) {
        return bytes;
      }
      
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
    
    // Resize image if too large (dimensions greater than 1200px)
    img.Image resizedImage = image;
    if (image.width > 1200 || image.height > 1200) {
      final int maxDimension = image.width > image.height ? image.width : image.height;
      final double scale = 1200 / maxDimension;
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
  
  // Convert Base64 to Image Widget with error handling
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
      
      // Handle corrupted base64 strings
      Uint8List bytes;
      try {
        bytes = base64Decode(base64String);
      } catch (e) {
        print('Error decoding base64: $e');
        return errorWidget ?? const Icon(Icons.broken_image, size: 40);
      }
      
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('Error rendering image: $error');
          return errorWidget ?? const Icon(Icons.broken_image, size: 40);
        },
        // Add fadeIn animation for better UX
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
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