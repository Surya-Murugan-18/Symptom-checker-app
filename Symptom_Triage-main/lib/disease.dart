import 'package:flutter/material.dart';
import 'help.dart';

class DiseasePage extends StatefulWidget {
	const DiseasePage({super.key});

	@override
	State<DiseasePage> createState() => _DiseasePageState();
}

class _DiseasePageState extends State<DiseasePage> {
	static const Color _primary = Color(0xFF199A8E);

	final List<_Disease> _diseases = <_Disease>[
		const _Disease('Heart Disease', 'assets/heart.png', _heartSymptoms, _heartActions),
		const _Disease('Lung Disease', 'assets/lungs.png', _lungSymptoms, _lungActions),
		const _Disease('Kidney Disease', 'assets/kidney.png', _kidneySymptoms, _kidneyActions),
		const _Disease('Skin Disease', 'assets/skin.png', _skinSymptoms, _skinActions),
		const _Disease('Eye Disease', 'assets/eye.png', _eyeSymptoms, _eyeActions),
		const _Disease('Fever Disease', 'assets/fever.png', _feverSymptoms, _feverActions),
		const _Disease('Covid Disease', 'assets/covid.png', _covidSymptoms, _covidActions),
		const _Disease('Breast Disease', 'assets/breast.png', _breastSymptoms, _breastActions),
	];

	int _tabIndex = 1; // default to DISEASE
	final Map<int, String> _tabs = const <int, String>{0: 'FAQ', 1: 'DISEASE'};

	@override
	Widget build(BuildContext context) {
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
				title: const Text(
					'DISEASE',
					style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 17),
				),
			),
			body: LayoutBuilder(
				builder: (BuildContext context, BoxConstraints constraints) {
					final double maxWidth = constraints.maxWidth < 700 ? constraints.maxWidth : 560;
					final int crossAxisCount = constraints.maxWidth > 900
							? 4
							: constraints.maxWidth > 600
									? 3
									: 2;

					return Center(
						child: SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: maxWidth),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: <Widget>[
										_buildTabSwitcher(),
										const SizedBox(height: 18),
										GridView.builder(
											shrinkWrap: true,
											physics: const NeverScrollableScrollPhysics(),
											gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
												crossAxisCount: crossAxisCount,
												crossAxisSpacing: 14,
												mainAxisSpacing: 14,
												childAspectRatio: 0.95,
											),
											itemCount: _diseases.length,
											itemBuilder: (BuildContext context, int index) {
												final _Disease disease = _diseases[index];
												return _buildDiseaseTile(disease);
											},
										),
										const SizedBox(height: 12),
									],
								),
							),
						),
					);
				},
			),
		);
	}

	Widget _buildTabSwitcher() {
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(30),
				boxShadow: const <BoxShadow>[
					BoxShadow(color: Color(0x1432323A), blurRadius: 8, offset: Offset(0, 4)),
				],
			),
			padding: const EdgeInsets.all(4),
			child: Row(
				children: _tabs.entries.map((MapEntry<int, String> entry) {
					final bool isSelected = _tabIndex == entry.key;
					return Expanded(
						child: TextButton(
							onPressed: () {
								if (entry.key == 0) {
									Navigator.of(context).push(
										MaterialPageRoute<void>(
											builder: (BuildContext context) => const HelpPage(),
										),
									);
								} else {
									setState(() => _tabIndex = entry.key);
								}
							},
							style: TextButton.styleFrom(
								padding: EdgeInsets.zero,
								backgroundColor: Colors.transparent,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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

	Widget _buildDiseaseTile(_Disease disease) {
		return MouseRegion(
			cursor: SystemMouseCursors.click,
			child: TextButton(
				onPressed: () {
					Navigator.of(context).push(
						MaterialPageRoute<void>(
							builder: (BuildContext context) => DiseaseDetailPage(disease: disease),
						),
					);
				},
				style: ButtonStyle(
  padding: WidgetStateProperty.all(EdgeInsets.zero),
  backgroundColor: WidgetStateProperty.all(Colors.white),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  overlayColor: WidgetStateProperty.all(Colors.transparent),
),

				child: Container(
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(16),
						boxShadow: const <BoxShadow>[
							BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 4)),
						],
					),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Container(
								width: 174,
								height: 174,
								decoration: BoxDecoration(
									color: const Color(0xFFF7F8F9),
									borderRadius: BorderRadius.circular(18),
								),
								child: Padding(
									padding: const EdgeInsets.all(12),
									child: Image.asset(
										disease.imagePath,
										fit: BoxFit.contain,
									),
								),
							),
							const SizedBox(height: 12),
							Text(
								disease.name,
								textAlign: TextAlign.center,
								style: const TextStyle(
									color: Colors.black,
									fontWeight: FontWeight.w600,
									fontSize: 13,
								),
							),
						],
					),
				),
			),
		);
	}
}

class DiseaseDetailPage extends StatelessWidget {
	const DiseaseDetailPage({super.key, required this.disease});

	final _Disease disease;

	static const Color _primary = Color(0xFF199A8E);

	@override
	Widget build(BuildContext context) {
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
				title: const Text(
					'DISEASE',
					style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 17),
				),
			),
			body: LayoutBuilder(
				builder: (BuildContext context, BoxConstraints constraints) {
					final double maxWidth = constraints.maxWidth < 700 ? constraints.maxWidth : 560;
					return Center(
						child: SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: maxWidth),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: <Widget>[
										ClipRRect(
											borderRadius: BorderRadius.circular(12),
											child: AspectRatio(
												aspectRatio: 16 / 9,
												child: Image.asset(
													disease.imagePath,
													fit: BoxFit.cover,
												),
											),
										),
										const SizedBox(height: 18),
										_SectionHeader(title: '${disease.name} Symptoms.'),
										const SizedBox(height: 10),
										...disease.symptoms.map((String text) => _Bullet(text: text, color: Colors.redAccent)).toList(),
										const SizedBox(height: 18),
										const _SectionHeader(title: 'What to do if you or someone else may be having a heart attack.'),
										const SizedBox(height: 10),
										...disease.actions.map((String text) => _Bullet(text: text, color: _primary)).toList(),
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
}

class _SectionHeader extends StatelessWidget {
	const _SectionHeader({required this.title});

	final String title;

	@override
	Widget build(BuildContext context) {
		return Text(
			title,
			style: const TextStyle(
				color: Colors.black,
				fontWeight: FontWeight.w700,
				fontSize: 15,
			),
		);
	}
}

class _Bullet extends StatelessWidget {
	const _Bullet({required this.text, required this.color});

	final String text;
	final Color color;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 10),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Container(
						width: 10,
						height: 10,
						margin: const EdgeInsets.only(top: 5, right: 10),
						decoration: BoxDecoration(color: color, shape: BoxShape.circle),
					),
					Expanded(
						child: Text(
							text,
							style: const TextStyle(
								color: Color(0xFF4A4A4A),
								fontWeight: FontWeight.w500,
								fontSize: 13,
								height: 1.45,
							),
						),
					),
				],
			),
		);
	}
}

class _Disease {
	const _Disease(this.name, this.imagePath, this.symptoms, this.actions);

	final String name;
	final String imagePath;
	final List<String> symptoms;
	final List<String> actions;
}

const List<String> _heartSymptoms = <String>[
	'Pressure, tightness, pain, or a squeezing or aching sensation in your chest or arms that may spread to your neck, jaw or back.',
	'Nausea, indigestion, heartburn or abdominal pain.',
	'Shortness of breath.',
	'Cold sweat.',
	'Fatigue.',
	'Lightheadedness or sudden dizziness.',
];

const List<String> _heartActions = <String>[
	'Call 911 or your local emergency number.',
	'Chew and swallow an aspirin.',
	'Take nitroglycerin.',
	'Begin CPR if the person is unconscious.',
];

const List<String> _lungSymptoms = <String>[
	'Persistent cough or shortness of breath.',
	'Chest discomfort that worsens with breathing.',
	'Wheezing or noisy breathing.',
	'Fatigue with reduced exercise tolerance.',
];

const List<String> _lungActions = <String>[
	'Seek medical evaluation for imaging and lung function tests.',
	'Avoid smoke exposure and follow prescribed inhalers.',
	'Stay hydrated and rest during flare-ups.',
	'Call emergency services if breathing becomes severely difficult.',
];

const List<String> _kidneySymptoms = <String>[
	'Swelling in legs, ankles, or feet due to fluid retention.',
	'Changes in urination frequency or appearance.',
	'Fatigue and difficulty concentrating.',
	'Nausea or loss of appetite.',
];

const List<String> _kidneyActions = <String>[
	'Consult a doctor for blood and urine tests.',
	'Follow a kidney-friendly diet with reduced sodium.',
	'Take medications as prescribed to manage underlying causes.',
	'Seek urgent care if urine output drops suddenly.',
];

const List<String> _skinSymptoms = <String>[
	'Redness, itching, or rash on the skin.',
	'Dry or scaly patches that may crack or bleed.',
	'Blisters or bumps that change appearance.',
];

const List<String> _skinActions = <String>[
	'Keep the area clean and moisturized.',
	'Use prescribed topical treatments.',
	'Avoid known allergens and irritants.',
	'See a dermatologist if symptoms persist or worsen.',
];

const List<String> _eyeSymptoms = <String>[
	'Blurred or double vision.',
	'Eye redness, pain, or discharge.',
	'Light sensitivity and headaches.',
];

const List<String> _eyeActions = <String>[
	'Avoid rubbing the eyes and remove contact lenses if worn.',
	'Use sterile eye drops as directed.',
	'Seek urgent ophthalmic care for sudden vision changes.',
];

const List<String> _feverSymptoms = <String>[
	'Elevated body temperature with chills.',
	'Body aches and weakness.',
	'Sweating or dehydration.',
];

const List<String> _feverActions = <String>[
	'Rest and drink plenty of fluids.',
	'Use antipyretics like acetaminophen as advised.',
	'Consult a doctor if fever persists more than 3 days or exceeds 103°F.',
];

const List<String> _covidSymptoms = <String>[
	'Fever or chills.',
	'Cough and shortness of breath.',
	'Loss of taste or smell.',
	'Muscle aches and fatigue.',
];

const List<String> _covidActions = <String>[
	'Isolate and get tested.',
	'Wear a mask and practice hand hygiene.',
	'Follow medical advice and monitor oxygen levels.',
	'Seek emergency care if breathing worsens.',
];

const List<String> _breastSymptoms = <String>[
	'New lump or thickening in the breast or underarm.',
	'Change in breast size, shape, or skin appearance.',
	'Nipple discharge or inversion.',
];

const List<String> _breastActions = <String>[
	'Schedule a clinical breast exam and imaging.',
	'Discuss biopsy if recommended.',
	'Follow treatment guidance from oncology specialists.',
	'Report rapid changes promptly.',
];
