import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:quick_kart/domain/data/ai_store.dart';
import 'package:quick_kart/domain/data/catalog_data.dart';
import 'package:quick_kart/domain/models/catalog.dart';

/// One message in the assistant conversation.
class AiChatTurn {
  const AiChatTurn({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

/// The assistant's answer: a short reply plus suggested catalog products.
class AiAssistantResult {
  const AiAssistantResult({
    required this.reply,
    required this.products,
    this.isDemo = false,
    this.hadError = false,
  });

  final String reply;
  final List<Product> products;

  /// True when the answer came from the local demo matcher (no API key or a
  /// failed request) instead of the real model.
  final bool isDemo;
  final bool hadError;
}

/// The QuickKart AI shopping assistant.
///
/// With a free Gemini API key (Google AI Studio) it asks the real model and
/// returns structured product suggestions. Without a key — or if the request
/// fails — it falls back to a local demo matcher so the feature always works.
class AiAssistant {
  AiAssistant._();

  static const String _model = 'gemini-2.5-flash';
  static const String _host = 'generativelanguage.googleapis.com';
  static const Duration _timeout = Duration(seconds: 20);

  static final Map<String, Product> _productById = {
    for (final product in appProducts) product.id: product,
  };

  static final Map<String, Category> _categoryById = {
    for (final category in appCategories) category.id: category,
  };

  static HttpClient? _client;

  static Future<AiAssistantResult> ask({
    required String message,
    required List<AiChatTurn> history,
  }) async {
    final prompt = message.trim();
    if (prompt.isEmpty) {
      return const AiAssistantResult(
        reply: 'What are you looking for? Type a product name or a budget.',
        products: <Product>[],
        isDemo: true,
      );
    }

    if (!AiStore.hasKey) {
      return _demoReply(prompt);
    }

    try {
      final raw = await _callGemini(prompt, history);
      return _parseModelReply(raw);
    } catch (_) {
      return AiAssistantResult(
        reply:
            'Could not reach the AI server (network or key problem). Here '
            'are demo matches instead:',
        products: _matchProducts(prompt),
        isDemo: true,
        hadError: true,
      );
    }
  }

  static String _categoryTitle(String categoryId) {
    return _categoryById[categoryId]?.title ?? '';
  }

  static String _systemPrompt() {
    final catalog = StringBuffer();
    for (final product in appProducts) {
      catalog.write(
        '${product.id} | ${product.name} | ${product.unit} | '
        'Rs ${product.price} | ${_categoryTitle(product.categoryId)}\n',
      );
    }

    return '''
You are the QuickKart AI shopping assistant inside a Pakistani quick-commerce app.
Only these products exist in the catalog (id | name | unit | price | category):

$catalog
Reply with ONLY a JSON object in this exact shape and nothing else:
{"reply":"<short helpful reply in English, 1-3 sentences>","products":[{"id":"<catalog id>"}]}

Rules:
- "products" holds 0 to 6 catalog ids that best match the user's request.
- If the user mentions a budget (for example "Rs 300"), only include items
  priced within it.
- Never invent products, ids or prices.
- Always answer in English, even if the user writes in another language.
- If the request does not fit the catalog, suggest the closest products.
''';
  }

  static Future<String> _callGemini(
    String message,
    List<AiChatTurn> history,
  ) async {
    final client = _client ??= HttpClient();

    // The key travels in the x-goog-api-key header — the documented auth
    // style of the current Gemini API (works for both classic AIza keys and
    // the newer AQ.-prefixed keys).
    final uri = Uri.https(_host, '/v1beta/models/$_model:generateContent');

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt()},
        ],
      },
      'contents': [
        for (final turn in history.take(10))
          {
            'role': turn.isUser ? 'user' : 'model',
            'parts': [
              {'text': turn.text},
            ],
          },
        {
          'role': 'user',
          'parts': [
            {'text': message},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 700,
        'responseMimeType': 'application/json',
      },
    });

    final request = await client.postUrl(uri).timeout(_timeout);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set('x-goog-api-key', AiStore.apiKey);
    request.add(utf8.encode(body));

    final response = await request.close().timeout(_timeout);
    final text = await response
        .transform(utf8.decoder)
        .join()
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Gemini API returned ${response.statusCode}');
    }

    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected Gemini response');
    }

    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Gemini response has no candidates');
    }

    final content = (candidates.first as Map)['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) {
      throw Exception('Gemini response has no parts');
    }

    final output = ((parts.first as Map)['text'] as String?) ?? '';
    if (output.trim().isEmpty) {
      throw Exception('Gemini response is empty');
    }
    return output;
  }

  static AiAssistantResult _parseModelReply(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```[a-zA-Z]*'), '')
          .replaceAll('```', '')
          .trim();
    }

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(cleaned) as Map<String, dynamic>?;
    } catch (_) {
      data = null;
    }
    if (data == null) {
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start >= 0 && end > start) {
        try {
          data =
              jsonDecode(cleaned.substring(start, end + 1))
                  as Map<String, dynamic>?;
        } catch (_) {
          data = null;
        }
      }
    }

    if (data == null) {
      return AiAssistantResult(reply: cleaned, products: const <Product>[]);
    }

    final replyText = ((data['reply'] as String?) ?? '').trim();
    final ids = <String>[];
    final productsRaw = (data['products'] as List?) ?? <dynamic>[];
    for (final item in productsRaw) {
      if (item is! Map) continue;
      final id = ((item['id'] as String?) ?? '').trim();
      if (id.isNotEmpty && !ids.contains(id)) ids.add(id);
    }

    final products = <Product>[];
    for (final id in ids) {
      final product = _productById[id];
      if (product != null) products.add(product);
      if (products.length >= 6) break;
    }

    return AiAssistantResult(
      reply: replyText.isEmpty ? 'Here are some options for you:' : replyText,
      products: products,
    );
  }

  /// Local fallback used when no key is set or the request failed.
  static AiAssistantResult _demoReply(String message) {
    final products = _matchProducts(message);

    if (products.isEmpty) {
      return const AiAssistantResult(
        reply:
            'I could not understand that. Try a product name — like '
            '"cheap milk" or "fruits under Rs 300".',
        products: <Product>[],
        isDemo: true,
      );
    }

    final budgetMatch = RegExp(r'\b\d{3,5}\b').firstMatch(message);
    final budget = budgetMatch == null
        ? null
        : int.parse(budgetMatch.group(0)!);

    final reply = budget == null
        ? 'Here are my suggestions for your request:'
        : 'Here are the best options within Rs $budget:';

    return AiAssistantResult(reply: reply, products: products, isDemo: true);
  }

  static List<Product> _matchProducts(String message) {
    final clean = message.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    final tokens = clean
        .split(RegExp(r'\s+'))
        .where((token) => token.length >= 3)
        .toSet();

    final budgetMatch = RegExp(r'\b\d{3,5}\b').firstMatch(message);
    final budget = budgetMatch == null
        ? null
        : int.parse(budgetMatch.group(0)!);

    final scored = <MapEntry<Product, int>>[];
    for (final product in appProducts) {
      final haystack =
          '${product.name} ${product.unit} '
                  '${_categoryTitle(product.categoryId)}'
              .toLowerCase();

      var score = 0;
      for (final token in tokens) {
        if (haystack.contains(token)) {
          score += product.name.toLowerCase().contains(token) ? 2 : 1;
        }
      }
      if (score > 0) scored.add(MapEntry(product, score));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    var picked = scored.map((entry) => entry.key).toList();
    if (budget != null && budget >= 100) {
      final affordable = picked
          .where((product) => product.price <= budget)
          .toList();
      if (affordable.isNotEmpty) picked = affordable;
    }

    if (picked.isEmpty) {
      final defaults = {'amul-milk', 'bananas', 'wheat-bread', 'toothpaste'};
      picked = appProducts
          .where((product) => defaults.contains(product.id))
          .toList();
      if (budget != null && budget >= 100) {
        final affordable = picked
            .where((product) => product.price <= budget)
            .toList();
        if (affordable.isNotEmpty) picked = affordable;
      }
    }

    return picked.take(6).toList(growable: false);
  }
}
