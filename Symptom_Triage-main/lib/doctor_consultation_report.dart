import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorConsultationReportPage extends StatelessWidget {
	const DoctorConsultationReportPage({super.key});

	static const Color _primary = Color(0xFF199A8E);
	static const Color _border = Color(0xFFE7EEF0);
	static const Color _cardBg = Colors.white;
	static const Color _warningBg = Color(0xFFFFF5F4);
	static const Color _warningBorder = Color(0xFFFFB5B5);
	static const Color _disclaimerBg = Color(0xFFFFE7BF);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.white,
			body: SafeArea(
				child: LayoutBuilder(
					builder: (context, constraints) {
						final double maxWidth = constraints.maxWidth >= 700 ? 520 : constraints.maxWidth;

						return Center(
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: maxWidth),
								child: Column(
									children: [
										_buildTopBar(context),
										Expanded(
											child: SingleChildScrollView(
												padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
												child: Column(
													children: [
														_buildHeaderCard(),
														const SizedBox(height: 12),
														_buildSectionCard(
															icon: FontAwesomeIcons.fileLines,
															title: 'Consultation Summary',
															child: const Text(
																'Patient presented with persistent headaches lasting\n'
																'one week, accompanied by mild fever and fatigue.\n'
																'Symptoms appear to be consistent with tension-\n'
																'type headaches, possibly stress-related.',
																style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF6A7B7D)),
															),
														),
														const SizedBox(height: 12),
														_buildSectionCard(
															icon: FontAwesomeIcons.circleCheck,
															title: 'Advice & Guidance',
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.start,
																children: const [
																	_NumberedLine(index: 1, text: 'Maintain regular sleep schedule (7-8 hours)'),
																	_NumberedLine(index: 2, text: 'Stay hydrated (8 glasses of water daily)'),
																	_NumberedLine(index: 3, text: 'Practice stress management techniques'),
																	_NumberedLine(index: 4, text: 'Over-the-counter pain relief as needed'),
																	_NumberedLine(index: 5, text: 'Limit screen time, especially before bed'),
																],
															),
														),
														const SizedBox(height: 12),
														_buildWarningCard(),
														const SizedBox(height: 12),
														_buildSectionCard(
															icon: FontAwesomeIcons.calendarDays,
															title: 'Follow-up Notes',
															child: const Text(
																'If symptoms persist beyond 2 weeks or worsen,\n'
																'schedule a follow-up consultation. Consider\n'
																'keeping a headache diary to track triggers.',
																style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF6A7B7D)),
															),
														),
														const SizedBox(height: 12),
														_buildDisclaimer(),
														const SizedBox(height: 16),
													],
												),
											),
										),
										_buildBottomButton(context),
									],
								),
							),
						);
					},
				),
			),
		);
	}

	Widget _buildTopBar(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
			child: Row(
				children: [
					IconButton(
						onPressed: () => Navigator.of(context).maybePop(),
						icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 18, color: Colors.black),
					),
					const Expanded(
						child: Text(
							'Consultation Report',
							textAlign: TextAlign.center,
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
						),
					),
					const SizedBox(width: 40),
				],
			),
		);
	}

	Widget _buildHeaderCard() {
		return Container(
			decoration: BoxDecoration(
				color: _cardBg,
				border: Border.all(color: _border),
				borderRadius: BorderRadius.circular(14),
			),
			padding: const EdgeInsets.all(12),
			child: Row(
				children: [
					Container(
						width: 44,
						height: 44,
						decoration: BoxDecoration(
							color: const Color(0xFFE8F4F2),
							borderRadius: BorderRadius.circular(12),
						),
						child: const Center(
							child: Text(
								'SJ',
								style: TextStyle(
									color: _primary,
									fontWeight: FontWeight.w700,
								),
							),
						),
					),
					const SizedBox(width: 12),
					const Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Sarah Johnson',
									style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
								),
								SizedBox(height: 2),
								Text('32 yrs, Female', style: TextStyle(fontSize: 12, color: Color(0xFF6A7B7D))),
								SizedBox(height: 2),
								Text('Jan 15, 2024 - 10:30 AM', style: TextStyle(fontSize: 11, color: Color(0xFF9AA8AA))),
							],
						),
					),
				],
			),
		);
	}

	Widget _buildSectionCard({
		required IconData icon,
		required String title,
		required Widget child,
	}) {
		return Container(
			width: double.infinity,
			decoration: BoxDecoration(
				color: _cardBg,
				border: Border.all(color: _border),
				borderRadius: BorderRadius.circular(14),
			),
			padding: const EdgeInsets.all(12),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							FaIcon(icon, size: 16, color: _primary),
							const SizedBox(width: 8),
							Text(
								title,
								style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
							),
						],
					),
					const SizedBox(height: 10),
					child,
				],
			),
		);
	}

	Widget _buildWarningCard() {
		return Container(
			width: double.infinity,
			decoration: BoxDecoration(
				color: Colors.white,
				border: Border.all(color: _warningBorder),
				borderRadius: BorderRadius.circular(14),
			),
			padding: const EdgeInsets.all(12),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: const [
					Row(
						children: [
							FaIcon(FontAwesomeIcons.triangleExclamation, size: 16, color: Color(0xFFE65B5B)),
							SizedBox(width: 8),
							Text(
								'Warning Signs to Watch',
								style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
							),
						],
					),
					SizedBox(height: 10),
					  _BulletLine(text: 'Sudden severe headache ("thunderclap")'),
					  _BulletLine(text: 'Vision changes or blurred vision'),
					  _BulletLine(text: 'Neck stiffness with fever'),
					  _BulletLine(text: 'Confusion or difficulty speaking'),
					  _BulletLine(text: 'Numbness or weakness'),
				],
			),
		);
	}

	Widget _buildDisclaimer() {
		return Container(
			width: double.infinity,
			decoration: BoxDecoration(
				color: _disclaimerBg,
				borderRadius: BorderRadius.circular(12),
			),
			padding: const EdgeInsets.all(12),
			child: const Text(
				'Medical Disclaimer: This report is for guidance purposes and does not\n'
				'constitute a medical diagnosis. The patient should seek in-person medical\n'
				'attention if symptoms worsen or new symptoms develop.',
				style: TextStyle(fontSize: 11, height: 1.35, color: Color(0xFF9A6B21)),
			),
		);
	}

	Widget _buildBottomButton(BuildContext context) {
		return SafeArea(
			top: false,
			child: Padding(
				padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
				child: SizedBox(
					width: double.infinity,
					height: 46,
					child: ElevatedButton.icon(
						onPressed: () {
							_showReportSentDialog(context);
						},
						style: ElevatedButton.styleFrom(
							backgroundColor: _primary,
							elevation: 0,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
						),
						icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 16, color: Colors.white),
						label: const Text(
							'Send Report to Patient',
							style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
						),
					),
				),
			),
		);
	}

	void _showReportSentDialog(BuildContext context) {
		showDialog(
			context: context,
			barrierColor: Colors.black.withOpacity(0.5),
			builder: (BuildContext context) {
				return Dialog(
					backgroundColor: Colors.white,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
					child: Padding(
						padding: const EdgeInsets.all(24),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Container(
									width: 64,
									height: 64,
									decoration: const BoxDecoration(
										color: Color(0xFFE8F4F2),
										shape: BoxShape.circle,
									),
									child: const Center(
										child: FaIcon(
											FontAwesomeIcons.circleCheck,
											size: 32,
											color: _primary,
										),
									),
								),
								const SizedBox(height: 20),
								const Text(
									'Report Sent Successfully',
									style: TextStyle(
										fontSize: 18,
										fontWeight: FontWeight.w600,
										color: Colors.black,
									),
								),
								const SizedBox(height: 10),
								const Text(
									'The consultation report has been sent to the patient.',
									textAlign: TextAlign.center,
									style: TextStyle(
										fontSize: 14,
										color: Color(0xFF6A7B7D),
										height: 1.4,
									),
								),
								const SizedBox(height: 24),
								SizedBox(
									width: double.infinity,
									height: 44,
									child: ElevatedButton(
										onPressed: () => Navigator.of(context).pop(),
										style: ElevatedButton.styleFrom(
											backgroundColor: _primary,
											elevation: 0,
											shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
										),
										child: const Text(
											'OK',
											style: TextStyle(
												fontSize: 14,
												fontWeight: FontWeight.w600,
												color: Colors.white,
											),
										),
									),
								),
							],
						),
					),
				);
			},
		);
	}
}

class _BulletLine extends StatelessWidget {
	final String text;

	const _BulletLine({required this.text});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 6),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Padding(
						padding: EdgeInsets.only(top: 5),
						child: FaIcon(FontAwesomeIcons.circle, size: 6, color: Color(0xFF6A7B7D)),
					),
					const SizedBox(width: 8),
					Expanded(
						child: Text(
							text,
							style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF6A7B7D)),
						),
					),
				],
			),
		);
	}
}

class _NumberedLine extends StatelessWidget {
	final int index;
	final String text;

	const _NumberedLine({required this.index, required this.text});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 6),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('$index. ', style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF6A7B7D))),
					Expanded(
						child: Text(
							text,
							style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF6A7B7D)),
						),
					),
				],
			),
		);
	}
}
