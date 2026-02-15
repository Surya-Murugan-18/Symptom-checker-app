import 'package:flutter/material.dart';
import 'disease.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class HelpPage extends StatefulWidget {
	const HelpPage({super.key});

	@override
	State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
	static const Color _primary = Color(0xFF199A8E);

	String _searchQuery = '';
	int _tabIndex = 0;
	final Map<String, bool> _expandedState = <String, bool>{};

	@override
	Widget build(BuildContext context) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;
    
    final Map<int, String> tabs = {
      0: AppStrings.s('faq_label', 'FAQ'),
      1: AppStrings.s('disease_label', 'DISEASE'),
    };

    final List<_HelpItem> faqItems = [
      _HelpItem(
        title: AppStrings.s('covid_faq_q1', 'What are Coronaviruses and what is COVID-19?'),
        description: AppStrings.s('covid_faq_a1', 'Coronaviruses (CoV) are a large family of viruses causing illnesses ranging from the common cold to pneumonia (a more severe lung infection).'),
        imagePath: 'assets/D1.png',
        featured: true,
      ),
      _HelpItem(
        title: AppStrings.s('covid_faq_q2', 'How does COVID-19 spread?'),
        description: AppStrings.s('covid_faq_a2', 'The virus spreads mainly from person-to-person through respiratory droplets when an infected person coughs, sneezes, or talks.'),
      ),
      // Add more as needed, potentially using keys like 'covid_faq_q3' etc.
    ];

		return Scaffold(
			backgroundColor: Colors.white,
			appBar: AppBar(
				backgroundColor: Colors.white,
				elevation: 0,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
					onPressed: () => Navigator.of(context).maybePop(),
				),
				centerTitle: true,
				title: Text(
					AppStrings.s('help_title', 'HELP'),
					style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
				),
			),
			floatingActionButton: FloatingActionButton(
				backgroundColor: _primary,
				onPressed: () {},
				child: const Icon(Icons.help_outline, color: Colors.white),
			),
			body: LayoutBuilder(
				builder: (BuildContext context, BoxConstraints constraints) {
					final double maxWidth = constraints.maxWidth < 600 ? constraints.maxWidth : 520;

					final List<_HelpItem> filteredItems = faqItems
							.where(
								(item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase()),
							)
							.toList();

					return Center(
						child: SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: maxWidth),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: <Widget>[
										_buildTabSwitcher(tabs),
										const SizedBox(height: 16),
										_buildSearchField(strings['search_hint'] ?? 'Search'),
										const SizedBox(height: 16),
										...filteredItems.map(_buildItem).toList(),
										const SizedBox(height: 24),
									],
								),
							),
						),
					);
				},
			),
		);
	}

	Widget _buildTabSwitcher(Map<int, String> tabs) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1432323A),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(4),
    child: Row(
      children: tabs.entries.map((MapEntry<int, String> entry) {
        final bool isSelected = _tabIndex == entry.key;

        return Expanded(
          child: TextButton(
            onPressed: () {
              if (entry.key == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const DiseasePage(),
                  ),
                );
              } else {
                setState(() => _tabIndex = entry.key);
              }
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}


	Widget _buildSearchField(String hint) {
		return Container(
			decoration: BoxDecoration(
				color: const Color(0xFFF7F8F9),
				borderRadius: BorderRadius.circular(14),
			),
			padding: const EdgeInsets.symmetric(horizontal: 12),
			child: TextField(
				onChanged: (String value) => setState(() => _searchQuery = value),
				cursorColor: _primary,
				style: const TextStyle(color: Colors.black, fontSize: 14),
				decoration: InputDecoration(
					hintText: hint,
					hintStyle: const TextStyle(color: Color(0xFFB4B6BD)),
					border: InputBorder.none,
					icon: const Icon(Icons.search, color: Color(0xFFB4B6BD)),
				),
			),
		);
	}

	Widget _buildItem(_HelpItem item) {
		if (item.featured) {
			return _buildFeaturedCard(item);
		}
		return _buildAccordion(item);
	}

	Widget _buildFeaturedCard(_HelpItem item) {
		final bool isExpanded = _expandedState[item.title] ?? true;
		return Container(
			width: double.infinity,
			margin: const EdgeInsets.only(bottom: 16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				boxShadow: const <BoxShadow>[
					BoxShadow(color: Color(0x1432323A), blurRadius: 10, offset: Offset(0, 4)),
				],
			),
			child: Theme(
				data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
				child: ExpansionTile(
					key: PageStorageKey<String>(item.title),
					maintainState: true,
					initiallyExpanded: isExpanded,
					onExpansionChanged: (bool expanded) => setState(() => _expandedState[item.title] = expanded),
					tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
					childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
					trailing: AnimatedRotation(
						duration: const Duration(milliseconds: 200),
						turns: isExpanded ? 0.5 : 0.0,
						child: const Icon(Icons.expand_more, color: Colors.black54),
					),
					title: Text(
						item.title,
						style: const TextStyle(
							color: Colors.black,
							fontWeight: FontWeight.w700,
							fontSize: 15,
						),
					),
					children: <Widget>[
						if (item.imagePath != null)
							ClipRRect(
								borderRadius: BorderRadius.circular(12),
								child: AspectRatio(
									aspectRatio: 16 / 9,
									child: Image.asset(
										item.imagePath!,
										fit: BoxFit.cover,
									),
								),
							),
						const SizedBox(height: 12),
						Text(
							item.description,
							style: const TextStyle(
								color: Color(0xFF6B6B7B),
								fontWeight: FontWeight.w500,
								fontSize: 13,
								height: 1.4,
							),
						),
					],
				),
			),
		);
	}

	Widget _buildAccordion(_HelpItem item) {
		final bool isExpanded = _expandedState[item.title] ?? false;
		return Container(
			margin: const EdgeInsets.only(bottom: 12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
				boxShadow: const <BoxShadow>[
					BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 3)),
				],
			),
			child: Theme(
				data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
				child: ExpansionTile(
					key: PageStorageKey<String>(item.title),
					maintainState: true,
					initiallyExpanded: isExpanded,
					onExpansionChanged: (bool expanded) => setState(() => _expandedState[item.title] = expanded),
					tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
					childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
					iconColor: Colors.black54,
					collapsedIconColor: Colors.black54,
					trailing: AnimatedRotation(
						duration: const Duration(milliseconds: 200),
						turns: isExpanded ? 0.5 : 0.0,
						child: const Icon(Icons.expand_more, color: Colors.black54),
					),
					title: Text(
						item.title,
						style: const TextStyle(
							color: Colors.black,
							fontWeight: FontWeight.w600,
							fontSize: 14,
						),
					),
					children: <Widget>[
						Text(
							item.description,
							style: const TextStyle(
								color: Color(0xFF6B6B7B),
								fontWeight: FontWeight.w500,
								fontSize: 13,
								height: 1.4,
							),
						),
					],
				),
			),
		);
	}
}

class _HelpItem {
	const _HelpItem({
		required this.title,
		required this.description,
		this.imagePath,
		this.featured = false,
	});

	final String title;
	final String description;
	final String? imagePath;
	final bool featured;
}
