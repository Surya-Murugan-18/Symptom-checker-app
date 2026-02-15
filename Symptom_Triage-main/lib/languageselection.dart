import 'package:flutter/material.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_language.dart';
import 'package:symtom_checker/loadingpage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Selection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'SF Pro',
      ),
      home: const LanguageSelectionPage(),
    );
  }
}

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? selectedLanguage;

  final List<LanguageOption> languages = [
    LanguageOption(
      name: 'தமிழ்',
      displayChar: 'த',
      lightColor: const Color(0xFFB8DDD9),
      darkColor: const Color(0xFF2D6B66),
    ),
    LanguageOption(
      name: 'English',
      displayChar: 'E',
      lightColor: const Color(0xFFB8DDD9),
      darkColor: const Color(0xFF2D6B66),
    ),
    LanguageOption(
      name: 'हिन्दी',
      displayChar: 'हि',
      lightColor: const Color(0xFFB8DDD9),
      darkColor: const Color(0xFF2D6B66),
    ),
    LanguageOption(
      name: 'తెలుగు',
      displayChar: 'తె',
      lightColor: const Color(0xFFB8DDD9),
      darkColor: const Color(0xFF2D6B66),
    ),

     LanguageOption(
      name: 'മലയാളം',
      displayChar: 'മ',
      lightColor: const Color(0xFFB8DDD9),
      darkColor: const Color(0xFF2D6B66),
    ),

     LanguageOption(
      name: 'मराठी',
      displayChar: 'म',
      lightColor: const Color(0xFFB8DDD9),
      darkColor: const Color(0xFF2D6B66),
    ),
    
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A9B8E),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(280),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 32, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ).createShader(bounds),
                        child: const Text(
                          'Language',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Language Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    return LanguageCard(
                      language: languages[index],
                      isSelected: selectedLanguage == languages[index].name,
                      onTap: () {
                        setState(() {
                          if (selectedLanguage == languages[index].name) {
                            selectedLanguage = null;
                          } else {
                            selectedLanguage = languages[index].name;
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: selectedLanguage != null
    ? () {
        if (selectedLanguage == 'தமிழ்') {
          AppState.selectedLanguage = AppLanguage.tamil;
        } else if (selectedLanguage == 'English') {
          AppState.selectedLanguage = AppLanguage.english;
        } else if (selectedLanguage == 'हिन्दी') {
          AppState.selectedLanguage = AppLanguage.hindi;
        } else if (selectedLanguage == 'తెలుగు') {
          AppState.selectedLanguage = AppLanguage.telugu;
        } else if (selectedLanguage == 'മലയാളം') {
          AppState.selectedLanguage = AppLanguage.malayalam;
        } else if (selectedLanguage == 'मराठी') {
          AppState.selectedLanguage = AppLanguage.marathi;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LanguageLoadingPage(),
          ),
        );
      }
    : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A9B8E),
                    disabledBackgroundColor:
                        const Color(0xFF1A9B8E).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF1A9B8E).withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String name;
  final String displayChar;
  final Color lightColor;
  final Color darkColor;

  LanguageOption({
    required this.name,
    required this.displayChar,
    required this.lightColor,
    required this.darkColor,
  });
}

class LanguageCard extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    Key? key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isSelected ? language.darkColor : language.lightColor;
    Color textColor =
        isSelected ? Colors.white : (language.lightColor == const Color(0xFF4A9B9B) ? Colors.white : Colors.black87);
    Color charColor = isSelected
        ? Colors.white.withOpacity(0.3)
        : const Color(0xFF455A64).withOpacity(0.5);
    Color iconColor = isSelected ? Colors.white.withOpacity(0.6) : (language.lightColor == const Color(0xFF4A9B9B) ? Colors.white.withOpacity(0.7) : Colors.black54);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language name at top
              Text(
                language.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),

              // Spacing between name and character
              const SizedBox(height: 10),

              // Large character with proper sizing
              Expanded(
                child: Center(
                  child: Text(
                    language.displayChar,
                    style: TextStyle(
                      color: charColor,
                      fontSize: 90,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),

              // Play icon at bottom left
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
