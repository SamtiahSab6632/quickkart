import 'package:flutter/material.dart';

/// Asset path of the bundled Noto Emoji PNG for an [emoji] string, for
/// example `🥛` -> `assets/products/e_1f95b.png`.
///
/// The catalog renders these PNG images instead of the device emoji font so
/// product and category tiles look crisp and identical everywhere. The PNGs
/// are Google Noto Emoji (Apache 2.0), fetched with
/// `dart run tool/fetch_product_images.dart`.
String emojiAssetPath(String emoji) {
  final codepoints = emoji.runes
      .map((code) => code.toRadixString(16).padLeft(4, '0'))
      .join('-');
  return 'assets/products/e_$codepoints.png';
}

class Category {
  const Category({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String title;
  final String emoji;
  final Color color;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.emoji,
    required this.price,
    required this.tint,
    required this.categoryId,
    this.description = '',
  });

  final String id;
  final String name;
  final String unit;
  final String emoji;
  final int price;
  final Color tint;
  final String categoryId;

  /// One- to two-line marketing blurb shown on the product details screen.
  final String description;
}
