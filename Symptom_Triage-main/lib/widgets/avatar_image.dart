import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;

  const AvatarImage({
    Key? key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.borderRadius = 12,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey[200],
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildPlaceholder();
    }

    final String url = imageUrl!.trim();

    // Base64 Image
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    // HTTP / HTTPS URL
    if (url.toLowerCase().startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Asset path
    if (url.toLowerCase().startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Local file path (fallback for local uploads/testing)
    if (!kIsWeb) {
      try {
        final file = File(url);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
      } catch (e) {
        // ignore
      }
    }

    // Fallback placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    // Select a placeholder from available assets based on hash if possible, or just default to D6
    // We can use the hash of the imageUrl or a random one to make it feel "dynamic"
    final List<String> placeholders = [
      'assets/D2.png',
      'assets/D3.png',
      'assets/D4.png',
      'assets/D5.png',
      'assets/D6.jpg',
    ];

    final int index = (imageUrl?.hashCode ?? 0) % placeholders.length;
    final String selectedPlaceholder = placeholders[index.abs()];

    return Image.asset(
      selectedPlaceholder,
      fit: BoxFit.cover,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.person,
            size: width * 0.5,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
