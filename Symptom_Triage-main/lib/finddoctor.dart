import 'package:flutter/material.dart';
import 'package:symtom_checker/doctordetail.dart';
import 'package:symtom_checker/models/doctor_model.dart';
import 'package:symtom_checker/services/doctor_service.dart';
import 'package:symtom_checker/top_doctor.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';
import 'package:symtom_checker/language/app_strings.dart';

class FindDoctorsPage extends StatefulWidget {
  const FindDoctorsPage({super.key});

  @override
  State<FindDoctorsPage> createState() => _FindDoctorsPageState();
}

// Accent colors tuned to match the provided UI (teal + subtle grays)
const Color _teal = Color(0xFF16B3A6);
const Color _tealDark = Color(0xFF0E8D83);
const Color _textPrimary = Color(0xFF0F1A26);
const Color _textSecondary = Color(0xFF7C8A99);
const Color _bg = Colors.white;
const Color _cardBorder = Colors.white;

class _FindDoctorsPageState extends State<FindDoctorsPage> {
  final TextEditingController _searchController = TextEditingController();
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _allDoctors = [];
  bool _isLoading = true;

  List<_CategoryItem> _categories = List.from(_staticCategories);
  bool _isLoadingCategories = true;

  static const List<_CategoryItem> _staticCategories = <_CategoryItem>[
    _CategoryItem(label: 'General', icon: Icons.local_hospital_outlined),
    _CategoryItem(label: 'Lungs Specialist', icon: Icons.health_and_safety),
    _CategoryItem(label: 'Dentist', icon: Icons.medical_services_outlined),
    _CategoryItem(label: 'Psychiatrist', icon: Icons.psychology_alt_outlined),
    _CategoryItem(label: 'Covid-19', icon: Icons.coronavirus_outlined),
    _CategoryItem(label: 'Surgeon', icon: Icons.vaccines_outlined),
    _CategoryItem(label: 'Cardiologist', icon: Icons.monitor_heart_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchCategories();
    _searchController.addListener(() {
      if (_searchController.text.length > 2) {
        _searchDoctors(_searchController.text);
      } else if (_searchController.text.isEmpty) {
        _fetchDoctors();
      }
    });
  }

  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _doctorService.fetchVerifiedDoctors();
      setState(() {
        _allDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching doctors: $e");
      setState(() {
        _allDoctors = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _searchDoctors(String query) async {
    try {
      final doctors = await _doctorService.searchVerifiedDoctors(query);
      setState(() {
        _allDoctors = doctors;
      });
    } catch (e) {
      print("Error searching doctors: $e");
    }
  }
  Future<void> _fetchCategories() async {
    try {
      final specs = await _doctorService.fetchSpecializations();
      if (specs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _categories = specs.map((s) => _CategoryItem(label: s, icon: _getIconFor(s))).toList();
            _isLoadingCategories = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _categories = List.from(_staticCategories);
            _isLoadingCategories = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
      if (mounted) {
        setState(() {
          _categories = List.from(_staticCategories);
          _isLoadingCategories = false;
        });
      }
    }
  }

  IconData _getIconFor(String spec) {
    final s = spec.toLowerCase();
    if (s.contains('heart') || s.contains('cardio')) return Icons.monitor_heart_outlined;
    if (s.contains('lung') || s.contains('pulmo')) return Icons.health_and_safety;
    if (s.contains('tooth') || s.contains('dentist')) return Icons.medical_services_outlined;
    if (s.contains('brain') || s.contains('psych') || s.contains('neuro')) return Icons.psychology_alt_outlined;
    if (s.contains('eye') || s.contains('ophthal')) return Icons.visibility_outlined;
    if (s.contains('skin') || s.contains('derm')) return Icons.face;
    if (s.contains('bone') || s.contains('ortho')) return Icons.accessible;
    if (s.contains('surg')) return Icons.vaccines_outlined;
    if (s.contains('cov') || s.contains('virus')) return Icons.coronavirus_outlined;
    return Icons.local_hospital_outlined;
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.s('find_doctor', 'Find Doctor'),
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isDesktop = width >= 900;
          final double contentMaxWidth = isDesktop ? 720 : 420;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    _fetchDoctors(),
                    _fetchCategories(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Ensure scrollable even if content is short
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(
                      controller: _searchController,
                      hintText: AppStrings.s('search_hint', 'Search doctors, medicine, articles...'),
                    ),
                    const SizedBox(height: 20),
                     Text(
                      AppStrings.s('category', 'Category'),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      items: _categories,
                      isDesktop: isDesktop,
                      onPressed: (item) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopDoctorPage(
                              specialty: item.label,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                     Text(
                      AppStrings.s('recommended_doctors', 'Recommended Doctors'),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._recommendedSection(context),
                    const SizedBox(height: 24),
                     Text(
                      AppStrings.s('recent_doctors', 'Your Recent Doctors'),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _RecentDoctorsRow(
                        doctors: _allDoctors,
                        onPressed: (doctor) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DoctorDetailPage(
                                  doctorId: doctor.id,
                                  doctorName: doctor.fullName,
                                  speciality: doctor.specialization ?? 'General',
                                  rating: doctor.rating,
                                  distanceText: '800${AppStrings.s('m', 'm')} ${AppStrings.s('away', 'away')}',
                                  photoUrl: doctor.photoUrl ?? 'assets/D6.jpg',
                                ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 120,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _cardBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  List<Widget> _recommendedSection(BuildContext context) {
    if (_isLoading) return [const Center(child: CircularProgressIndicator())];
    
    final List<Doctor> filtered = _allDoctors;

    if (filtered.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            AppStrings.s('no_doctors', 'No matching doctors found.'),
            style: const TextStyle(color: _textSecondary),
          ),
        ),
      ];
    }

    return filtered
        .map(
          (Doctor d) => _RecommendedCard(
            doctor: d,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailPage(
                    doctorId: d.id,
                    doctorName: d.fullName,
                    speciality: d.specialization ?? AppStrings.s('general', 'General'),
                    rating: d.rating,
                    distanceText: d.distanceText ?? '800${AppStrings.s('m', 'm')} ${AppStrings.s('away', 'away')}',
                  ),
                ),
              );
            },
          ),
        )
        .toList();
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const _SearchBar({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: _textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<_CategoryItem> items;
  final bool isDesktop;
  final void Function(_CategoryItem) onPressed;
  const _CategoryGrid({
    required this.items,
    required this.isDesktop,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double itemWidth = isDesktop ? 150 : 100;
    final double itemHeight = isDesktop ? 130 : 110;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (e) => SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: _CategoryCard(
                  item: e,
                  label: AppStrings.s(e.label.toLowerCase(), e.label),
                  onPressed: () => onPressed(e),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final String label;
  final VoidCallback onPressed;
  const _CategoryCard({required this.item, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 180,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: _teal, size: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onPressed;
  const _RecommendedCard({required this.doctor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    String spec = doctor.specialization ?? 'General';
    spec = AppStrings.s(spec.toLowerCase(), spec);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double avatarSize = isMobile ? 80 : 106;
        final double spaceBetween = isMobile ? 12 : 52;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0),
                    blurRadius: 1800,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _Avatar(imageUrl: doctor.photoUrl, size: avatarSize),
                  SizedBox(width: spaceBetween),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.fullName,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          spec, // Localized
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _RatingPill(
                              ratingText: doctor.rating.toStringAsFixed(1),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  color: _textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    doctor.distanceText ?? '800${AppStrings.s('m', 'm')} ${AppStrings.s('away', 'away')}',
                                    style: const TextStyle(
                                      color: _textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecentDoctorsRow extends StatelessWidget {
  final List<Doctor> doctors;
  final void Function(Doctor) onPressed;
  const _RecentDoctorsRow({required this.doctors, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: doctors
            .map(
              (Doctor d) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => onPressed(d),
                        customBorder: const CircleBorder(),
                        child: Ink(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 180,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: _Avatar(imageUrl: d.photoUrl, size: 72),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 70,
                      child: Text(
                        d.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  const _Avatar({required this.imageUrl, this.size = 106});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: AvatarImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          borderRadius: size / 2, // making it circular within ClipOval
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final String ratingText;
  const _RatingPill({required this.ratingText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rate_rounded, color: _tealDark, size: 16),
          const SizedBox(width: 4),
          Text(
            ratingText,
            style: const TextStyle(
              color: _tealDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Redundant _Doctor class removed as we use models/doctor_model.dart

class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem({required this.label, required this.icon});
}
