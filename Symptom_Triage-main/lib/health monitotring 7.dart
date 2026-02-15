import 'package:flutter/material.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class HealthMonitoring7Page extends StatefulWidget {
	const HealthMonitoring7Page({super.key});

	static const Color _brandColor = Color(0xFF199A8E);

	@override
	State<HealthMonitoring7Page> createState() => _HealthMonitoring7PageState();
}

class _HealthMonitoring7PageState extends State<HealthMonitoring7Page> {
	int _selectedRange = 0;

	@override
	Widget build(BuildContext context) {
		final strings = AppStrings.data[AppState.selectedLanguage]!;
		return Scaffold(
			backgroundColor: Colors.white,
			appBar: AppBar(
				backgroundColor: Colors.white,
				elevation: 0,
				centerTitle: false,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
					onPressed: () => Navigator.maybePop(context),
				),
				title: Text(
					strings['vitals_history_title'] ?? 'Vitals History',
					style: const TextStyle(
						color: Colors.black,
						fontSize: 20,
						fontWeight: FontWeight.w600,
					),
				),
			),
			body: LayoutBuilder(
				builder: (context, constraints) {
					final double maxWidth = constraints.maxWidth > 520
							? 520
							: constraints.maxWidth;
					return Center(
						child: ConstrainedBox(
							constraints: BoxConstraints(maxWidth: maxWidth),
							child: SingleChildScrollView(
								padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
								child: Column(
									children: [
										_RangeTabs(
											strings: strings,
											selectedIndex: _selectedRange,
											onSelected: (index) {
												setState(() => _selectedRange = index);
											},
										),
										const SizedBox(height: 16),
										_VitalsCard(
											title: strings['heart_rate'] ?? 'Heart Rate',
											average: '${strings['average'] ?? 'Avg'}: 72 ${strings['bpm'] ?? 'bpm'}',
										),
										const SizedBox(height: 16),
										_VitalsCard(
											title: strings['spo2'] ?? 'SpO₂ Level',
											average: '${strings['average'] ?? 'Avg'}: 98%',
										),
										const SizedBox(height: 16),
										_VitalsCard(
											title: strings['blood_pressure'] ?? 'Blood Pressure',
											average: '${strings['average'] ?? 'Avg'}: 120/80',
										),
										const SizedBox(height: 18),
										const _InfoNote(),
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

class _RangeTabs extends StatelessWidget {
	const _RangeTabs({required this.strings, required this.selectedIndex, required this.onSelected});

	final Map<String, String> strings;
	final int selectedIndex;
	final ValueChanged<int> onSelected;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(4),
			decoration: BoxDecoration(
				color: const Color(0xFFF2F4F5),
				borderRadius: BorderRadius.circular(14),
			),
			child: Row(
				children: [
					_TabItem(
						label: strings['daily'] ?? 'Daily',
						selected: selectedIndex == 0,
						onTap: () => onSelected(0),
					),
					_TabItem(
						label: strings['weekly'] ?? 'Weekly',
						selected: selectedIndex == 1,
						onTap: () => onSelected(1),
					),
					_TabItem(
						label: strings['monthly'] ?? 'Monthly',
						selected: selectedIndex == 2,
						onTap: () => onSelected(2),
					),
				],
			),
		);
	}
}

class _TabItem extends StatelessWidget {
	const _TabItem({
		required this.label,
		required this.selected,
		required this.onTap,
	});

	final String label;
	final bool selected;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					borderRadius: BorderRadius.circular(12),
					onTap: onTap,
					child: Container(
						padding: const EdgeInsets.symmetric(vertical: 10),
						decoration: BoxDecoration(
							color: selected ? Colors.white : Colors.transparent,
							borderRadius: BorderRadius.circular(12),
						),
						child: Text(
							label,
							textAlign: TextAlign.center,
							style: TextStyle(
								color: selected
										? HealthMonitoring7Page._brandColor
										: Colors.black54,
								fontWeight: FontWeight.w600,
							),
						),
					),
				),
			),
		);
	}
}

class _VitalsCard extends StatelessWidget {
	const _VitalsCard({required this.title, required this.average});

	final String title;
	final String average;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				boxShadow: const [
					BoxShadow(
						color: Color(0x11000000),
						blurRadius: 10,
						offset: Offset(0, 4),
					),
				],
			),
			child: Column(
				children: [
					Row(
						children: [
							Expanded(
								child: Text(
									title,
									style: const TextStyle(
										color: Colors.black,
										fontWeight: FontWeight.w600,
										fontSize: 16,
									),
								),
							),
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
								decoration: BoxDecoration(
									color: const Color(0xFFF2F4F5),
									borderRadius: BorderRadius.circular(12),
								),
								child: Text(
									average,
									style: const TextStyle(
										color: Colors.black54,
										fontSize: 12,
										fontWeight: FontWeight.w600,
									),
								),
							),
						],
					),
					const SizedBox(height: 14),
					const _BarChart(),
					const SizedBox(height: 10),
					const Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							_ChartLabel('12 AM'),
							_ChartLabel('6 AM'),
							_ChartLabel('12 PM'),
							_ChartLabel('6 PM'),
						],
					),
				],
			),
		);
	}
}

class _BarChart extends StatelessWidget {
	const _BarChart();

	static const List<double> _values = [
		0.38,
		0.58,
		0.46,
		0.72,
		0.54,
		0.68,
		0.50,
		0.62,
		0.44,
		0.57,
		0.70,
		0.64,
	];

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			height: 84,
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.end,
				children: List.generate(_values.length, (index) {
					final bool highlight = index == _values.length - 1;
					return Expanded(
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 3),
							child: Container(
								height: 84 * _values[index],
								decoration: BoxDecoration(
									color: highlight
											? HealthMonitoring7Page._brandColor
											: const Color(0xFFD6ECEA),
									borderRadius: BorderRadius.circular(6),
								),
							),
						),
					);
				}),
			),
		);
	}
}

class _ChartLabel extends StatelessWidget {
	const _ChartLabel(this.text);

	final String text;

	@override
	Widget build(BuildContext context) {
		return Text(
			text,
			style: const TextStyle(
				color: Colors.black45,
				fontSize: 11,
				fontWeight: FontWeight.w500,
			),
		);
	}
}

class _InfoNote extends StatelessWidget {
	const _InfoNote();

	@override
	Widget build(BuildContext context) {
		final strings = AppStrings.data[AppState.selectedLanguage]!;
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
			decoration: BoxDecoration(
				color: const Color(0xFFEAF6FF),
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: const Color(0xFFD1E7FF)),
			),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF2F80ED)),
					const SizedBox(width: 10),
					Expanded(
						child: Text(
							strings['trends_note'] ?? 'Trends help track changes over time, not diagnose conditions. Consult a doctor for medical advice.',
							style: const TextStyle(
								color: Color(0xFF2F5DA3),
								fontSize: 14,
								height: 1.4,
								fontWeight: FontWeight.w500,
							),
						),
					),
				],
			),
		);
	}
}
