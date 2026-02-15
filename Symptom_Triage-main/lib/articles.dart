import 'package:flutter/material.dart';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/models/article_model.dart';
import 'package:symtom_checker/artcile_expand.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({Key? key}) : super(key: key);

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Article> _articles = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles({String? category}) async {
    setState(() => _isLoading = true);
    try {
      String url = ApiConfig.baseUrl + "/articles";
      if (category != null && category != 'All') {
        url = "${ApiConfig.baseUrl}/articles/category/$category";
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _articles = data.map((json) => Article.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching articles: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['articles_page_title'] ?? 'Articles',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : (isTablet ? 24 : 20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search Bar
              _buildSearchBar(strings),
              const SizedBox(height: 24),
              
              // Popular Articles Section
              _buildPopularArticles(isDesktop, isTablet, strings),
              const SizedBox(height: 32),
              
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Trending Articles Section
                      _buildTrendingArticles(_articles.take(3).toList(), isDesktop, isTablet, strings),
                      const SizedBox(height: 32),
                      
                      // Related Articles Section
                      _buildRelatedArticles(_articles.skip(3).toList(), isDesktop, isTablet, strings),
                    ],
                  ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleExpandPage(article: article),
      ),
    );
  }

  Widget _buildSearchBar(Map<String, String> strings) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: strings['search_articles_hint'] ?? 'Search articles, news...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPopularArticles(bool isDesktop, bool isTablet, Map<String, String> strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings['popular_articles_title'] ?? 'Popular Articles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCategoryChip('All', strings['all_category'] ?? 'All'),
            _buildCategoryChip('Covid-19', 'Covid-19'),
            _buildCategoryChip('Diet', strings['diet_category'] ?? 'Diet'),
            _buildCategoryChip('Fitness', strings['fitness_category'] ?? 'Fitness'),
            _buildCategoryChip('Mental Health', strings['mental_health_category'] ?? 'Mental Health'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, String displayLabel) {
    bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        _fetchArticles(category: category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26B5A8) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingArticles(List<Article> articles, bool isDesktop, bool isTablet, Map<String, String> strings) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings['trending_articles_title'] ?? 'Trending Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                strings['see_all_btn'] ?? 'See all',
                style: TextStyle(
                  color: Color(0xFF26B5A8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _buildTrendingCard(articles[index], strings);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(Article article, Map<String, String> strings) {
    return InkWell(
      onTap: () => _openArticle(article),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with bookmark
            Stack(
              children: [
                Container(
                  height: 140,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF26B5A8),
                        Color(0x8026B5A8),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                  child: AvatarImage(
                    imageUrl: article.imageUrl ?? 'assets/article1.png',
                    width: 160,
                    height: 140,
                    borderRadius: 12,
                  ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bookmark_outline,
                      size: 16,
                      color: Color(0xFF26B5A8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Category
            Text(
              article.category ?? 'Health',
              style: const TextStyle(
                color: Color(0xFF26B5A8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            // Date and read time
            Text(
              '${DateFormat('MMM dd, yyyy').format(article.publishedDate)} • 5 ${strings['min_read_suffix'] ?? 'min read'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedArticles(List<Article> articles, bool isDesktop, bool isTablet, Map<String, String> strings) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings['related_articles_title'] ?? 'Related Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                strings['see_all_btn'] ?? 'See all',
                style: TextStyle(
                  color: Color(0xFF26B5A8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return _buildRelatedArticleCard(articles[index], strings);
          },
        ),
      ],
    );
  }

  Widget _buildRelatedArticleCard(Article article, Map<String, String> strings) {
    return InkWell(
      onTap: () => _openArticle(article),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF26B5A8),
                    Color(0x8026B5A8),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AvatarImage(
                  imageUrl: article.imageUrl ?? 'assets/R1.png',
                  width: 60,
                  height: 60,
                  borderRadius: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(article.publishedDate)} • 5 ${strings['min_read_suffix'] ?? 'min read'}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark icon
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.bookmark,
                color: Color(0xFF26B5A8),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
