import 'package:flutter/material.dart';
import 'package:symtom_checker/articles.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({Key? key}) : super(key: key);

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final TextEditingController _searchController = TextEditingController();
  int _cartCount = 0;

  final List<ProductItem> popularProducts = [
    ProductItem(
      name: 'Panadol',
      quantity: '20pcs',
      price: '\$15.99',
      image: 'assets/P1.png',
    ),
    ProductItem(
      name: 'Bodrex Herbal',
      quantity: '100mg',
      price: '\$7.99',
      image: 'assets/P2.png',
    ),
    ProductItem(
      name: 'Konidin',
      quantity: '8pcs',
      price: '\$5.99',
      image: 'assets/P3.png',
    ),
  ];

  final List<ProductItem> saleProducts = [
    ProductItem(
      name: 'OBH Combi',
      quantity: '100ml',
      price: '\$9.99',
      originalPrice: '\$11.99',
      image: 'assets/P4.png',
      isOnSale: true,
    ),
    ProductItem(
      name: 'Betadine',
      quantity: '50ml',
      price: '\$6.99',
      originalPrice: '\$8.99',
      image: 'assets/P1.png',
      isOnSale: true,
    ),
    ProductItem(
      name: 'Bodrexin',
      quantity: '100ml',
      price: '\$7.99',
      originalPrice: '\$9.99',
      image: 'assets/P2.png',
      isOnSale: true,
    ),
    
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart() {
    setState(() {
      _cartCount++;
    });
   
  }

  void _uploadPrescription() {
   
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Pharmacy',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cart items: 0'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  if (_cartCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17A697),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Body Content
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.only(
                  left: isMobile ? 16 : (isTablet ? 24 : 32),
                  right: isMobile ? 16 : (isTablet ? 24 : 32),
                  top: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    _buildSearchBar(isMobile),
                    const SizedBox(height: 24),
                    // Prescription Section
                    _buildPrescriptionSection(isMobile),
                    const SizedBox(height: 32),
                    // Popular Products Section
                  _buildSectionTitle(
  'Popular Product',
  'See all',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticlesPage(),
      ),
    );
  },
),

                    const SizedBox(height: 16),
                    _buildProductGrid(popularProducts, isMobile, isTablet, isDesktop),
                    const SizedBox(height: 32),
                    // Product on Sale Section
                    _buildSectionTitle('Product on Sale', 'See all', onPressed: () {

                       Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticlesPage(),
      ),
    );
                      // Add navigation or action for "See all" on sale products
                    }),
                    const SizedBox(height: 16),
                    _buildProductGrid(saleProducts, isMobile, isTablet, isDesktop),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 12 : 14,
          ),
          hintText: 'Search drugs, category...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: isMobile ? 14 : 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildPrescriptionSection(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD4F3F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order quickly with\nPrescription',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _uploadPrescription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17A697),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Upload Prescription',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 140,
              child: Image.asset(
                'assets/med.jpeg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.local_pharmacy, size: 60),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildSectionTitle(
  String title,
  String actionText, {
  VoidCallback? onPressed,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      TextButton(
        onPressed: onPressed, // works only if not null
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          actionText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: onPressed == null
                ? Colors.grey
                : const Color(0xFF17A697),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildProductGrid(
    List<ProductItem> products,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 3;
    } else if (isTablet) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 5;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      clipBehavior: Clip.hardEdge,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 16 : 20,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], isMobile);
      },
    );
  }

  Widget _buildProductCard(ProductItem product, bool isMobile) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.medication,
                        size: isMobile ? 40 : 50,
                        color: Colors.grey[400],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.quantity,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.price,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (product.isOnSale)
                              Text(
                                product.originalPrice ?? '',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),

                        /// ADD BUTTON
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          iconSize: isMobile ? 14 : 16,
                          onPressed: _addToCart,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF17A697),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}

class ProductItem {
  final String name;
  final String quantity;
  final String price;
  final String image;
  final String? originalPrice;
  final bool isOnSale;

  ProductItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
    this.originalPrice,
    this.isOnSale = false,
  });
}
