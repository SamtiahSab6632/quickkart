import 'dart:io';

/// Downloads Google's open [Noto Emoji](https://fonts.google.com/noto) PNGs
/// (Apache 2.0 license) for every emoji used by the QuickKart catalog into
/// `assets/products/`.
///
/// The app renders these PNGs instead of relying on the device emoji font, so
/// product and category tiles look crisp and identical on every device.
///
/// Run with: `dart run tool/fetch_product_images.dart`
///
/// Keep the list below in sync with `lib/domain/data/catalog_data.dart`.

const String _baseUrl =
    'https://cdn.jsdelivr.net/gh/googlefonts/noto-emoji@v2.047/png/512';

/// One emoji per category and per product.
const List<String> catalogEmojis = <String>[
  // Category emojis.
  '🥛', '🍎', '🥦', '🍞', '🍫', '🧃', '🧴', '🧹',
  '🌾', '🧂', '🥩', '🥟', '🍵', '🍼', '🐾', '💊',
  // Dairy & bakery.
  '🥚', '🥣', '🧀', '🧈', '🥐', '🧁', '🥯', '🍩', '🍰',
  // Fruits & vegetables.
  '🍌', '🥭', '🍅', '🥔', '🍇', '🍉', '🍊', '🧅', '🧄',
  '🍋', '🥒', '🥕', '🥬', '🌽',
  // Snacks & drinks.
  '🍟', '🍪', '🥜', '🍿', '💧', '🥤', '☕',
  // Staples, spices & meat.
  '🍚', '🫙', '\u{1F6E2}', '🫘', '🍶', '🍗', '🐟',
  // Frozen, care & home.
  '🍜', '🍨', '🚿', '🧼', '🧺', '🧻', '🪣', '🪥', '🧽',
  // Baby, pets & pharmacy.
  '👶', '🛁', '🐱', '🐶', '🩹',
];

/// Asset file name (without path) for an emoji, e.g. `e_1f95b.png`.
String emojiFileName(String emoji) {
  final codepoints = emoji.runes
      .map((code) => code.toRadixString(16).padLeft(4, '0'))
      .join('-');
  return 'e_$codepoints.png';
}

Future<void> main() async {
  final folder = Directory('assets/products');
  if (!folder.existsSync()) folder.createSync(recursive: true);

  final unique = <String, String>{
    for (final emoji in catalogEmojis) emojiFileName(emoji): emoji,
  };

  final client = HttpClient();
  var saved = 0;
  final failed = <String>[];

  for (final entry in unique.entries) {
    final codepoints = entry.key
        .substring(2, entry.key.length - 4) // strip 'e_' and '.png'
        .split('-')
        .join('_');
    final url = '$_baseUrl/emoji_u$codepoints.png';
    final target = File('${folder.path}${Platform.pathSeparator}${entry.key}');

    if (target.existsSync() && target.lengthSync() > 0) {
      saved++;
      continue;
    }

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        failed.add('${entry.key} ($url) -> HTTP ${response.statusCode}');
        continue;
      }
      await response.pipe(target.openWrite());
      saved++;
      stdout.writeln('OK   ${entry.key}');
    } catch (error) {
      failed.add('${entry.key} ($url) -> $error');
    }
  }

  client.close();

  if (failed.isNotEmpty) {
    for (final line in failed) {
      stderr.writeln('FAIL $line');
    }
    stderr.writeln(
      '\n${failed.length} of ${unique.length} images failed to download.',
    );
    exit(1);
  }

  stdout.writeln('\nDone: $saved images in assets/products/.');
}
