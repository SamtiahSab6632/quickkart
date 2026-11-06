import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/catalog_data.dart';
import 'package:quick_kart/domain/models/catalog.dart';
import 'package:quick_kart/repository/widgets/productcard.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.products, required this.onAdd});

  final List<Product> products;
  final ValueChanged<Product> onAdd;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<String> _popularSearches = [
    'Milk',
    'Eggs',
    'Bananas',
    'Bread',
    'Juice',
    'Chocolate',
  ];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late final List<Category> _availableCategories;

  String _query = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final categoryIds = widget.products
        .map((product) => product.categoryId)
        .toSet();
    _availableCategories = appCategories
        .where((category) => categoryIds.contains(category.id))
        .toList(growable: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String _categoryTitle(String categoryId) {
    for (final category in _availableCategories) {
      if (category.id == categoryId) return category.title;
    }
    return '';
  }

  List<Product> get _results {
    final query = _query.trim().toLowerCase();
    final categoryId = _selectedCategoryId;

    return widget.products
        .where((product) {
          if (categoryId != null && product.categoryId != categoryId) {
            return false;
          }
          if (query.isEmpty) return true;

          final searchable =
              '${product.name} ${product.unit} '
                      '${_categoryTitle(product.categoryId)}'
                  .toLowerCase();
          final tokens = query.split(RegExp(r'\s+'));
          return tokens.every(searchable.contains);
        })
        .toList(growable: false);
  }

  void _applyQuickSearch(String term) {
    _searchController.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
    setState(() {
      _query = term;
      _selectedCategoryId = null;
    });
    _searchFocus.unfocus();
  }

  void _selectCategory(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategoryId = null;
    });
    _searchFocus.requestFocus();
  }

  void _handleAdd(Product product) {
    widget.onAdd(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} added to cart',
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final query = _query.trim();
    final showPopularSearches = query.isEmpty && _selectedCategoryId == null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              const SizedBox(height: 6),
              _buildCategoryFilters(),
              Expanded(
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    if (showPopularSearches)
                      SliverToBoxAdapter(child: _buildPopularSearches()),
                    SliverToBoxAdapter(
                      child: _buildResultsHeader(results.length, query),
                    ),
                    if (results.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(query),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 224,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = results[index];
                            return ProductCard(
                              product: product,
                              onAdd: () => _handleAdd(product),
                            );
                          }, childCount: results.length),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.border),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 21,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A101828),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                key: const ValueKey('search-field'),
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  fontFamily: 'Regular',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: (_) => _searchFocus.unfocus(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search in QuickKart...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 21,
                    color: AppColors.primary,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 42,
                    minHeight: 0,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _clearFilters,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 19,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  contentPadding: const EdgeInsets.only(top: 14, bottom: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    if (_availableCategories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _availableCategories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip(
              label: 'All',
              selected: _selectedCategoryId == null,
              onTap: () => _selectCategory(null),
            );
          }

          final category = _availableCategories[index - 1];
          return _buildFilterChip(
            label: '${category.emoji} ${category.title}',
            selected: _selectedCategoryId == category.id,
            onTap: () => _selectCategory(category.id),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'bold',
            fontSize: 12,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSearches() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular searches',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches
                .map((term) {
                  return GestureDetector(
                    onTap: () => _applyQuickSearch(term),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            term,
                            style: const TextStyle(
                              fontFamily: 'bold',
                              fontSize: 11.5,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(int total, String query) {
    final categoryTitle = _selectedCategoryId == null
        ? null
        : _categoryTitle(_selectedCategoryId!);

    final String title;
    if (query.isNotEmpty) {
      title = 'Results for "$query"';
    } else if (categoryTitle != null) {
      title = categoryTitle;
    } else {
      title = 'All products';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 17,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$total ${total == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 10.5,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    final categoryTitle = _selectedCategoryId == null
        ? null
        : _categoryTitle(_selectedCategoryId!);

    final String message;
    if (query.isNotEmpty && categoryTitle != null) {
      message =
          'We could not find "$query" in $categoryTitle. '
          'Try another keyword or category.';
    } else if (query.isNotEmpty) {
      message =
          'We could not find anything for "$query". '
          'Try a different keyword.';
    } else if (categoryTitle != null) {
      message = 'No products are available in $categoryTitle yet.';
    } else {
      message = 'No products are available right now. Please check again soon.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 38,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No products found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Regular',
                fontSize: 12.5,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Clear search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(fontFamily: 'bold', fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
