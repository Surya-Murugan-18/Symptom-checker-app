import 'package:flutter/material.dart';
import 'package:symtom_checker/chatscreen.dart';
import 'package:symtom_checker/health%20monitotring%205.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class HealthMonitoring8Page extends StatelessWidget {
	const HealthMonitoring8Page({super.key});

	static const Color _primaryColor = Color(0xFF199A8E);

	@override
	Widget build(BuildContext context) {
		final strings = AppStrings.data[AppState.selectedLanguage]!;
		final Size size = MediaQuery.of(context).size;
		final double horizontalPadding = size.width < 600 ? 24 : 32;
		final double contentMaxWidth = size.width < 900 ? 420 : 480;
		final double titleFontSize = size.width < 600 ? 22 : 24;
		final double bodyFontSize = size.width < 600 ? 14.5 : 15.5;
		final double buttonHeight = size.width < 600 ? 52 : 56;

		return Scaffold(
			backgroundColor: Colors.white,
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: EdgeInsets.symmetric(
							horizontal: horizontalPadding,
							vertical: size.width < 600 ? 40 : 56,
						),
						child: ConstrainedBox(
							constraints: BoxConstraints(maxWidth: contentMaxWidth),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: <Widget>[
									_IconCard(size: size),
									const SizedBox(height: 24),
									Text(
										strings['check_symptoms_title'] ?? 'Check Your Symptoms',
										textAlign: TextAlign.center,
										style: TextStyle(
											fontSize: titleFontSize,
											fontWeight: FontWeight.w700,
											color: Colors.black,
										),
									),
									const SizedBox(height: 12),
									Text(
										strings['check_symptoms_desc']?.replaceAll('\\n', '\n') ?? 
										'Would you like to check symptoms related to\nyour recent vitals readings? Our AI assistant\ncan help triage your condition.',
										textAlign: TextAlign.center,
										style: TextStyle(
											fontSize: bodyFontSize,
											height: 1.45,
											color: const Color(0xFF7A7A7A),
										),
									),
									const SizedBox(height: 28),
									SizedBox(
										width: double.infinity,
										height: buttonHeight,
										child: ElevatedButton(
											onPressed: () {
                          Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatScreen()),
                              );
                      },
											style: ElevatedButton.styleFrom(
												backgroundColor: _primaryColor,
												elevation: 0,
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(12),
												),
											),
											child: Row(
												mainAxisAlignment: MainAxisAlignment.center,
												mainAxisSize: MainAxisSize.min,
												children: <Widget>[
													Text(
														strings['start_symptom_check'] ?? 'Start Symptom Check',
														style: const TextStyle(
															color: Colors.white,
															fontSize: 16,
															fontWeight: FontWeight.w600,
														),
													),
													const SizedBox(width: 10),
													const Icon(
														Icons.arrow_forward,
														color: Colors.white,
														size: 18,
													),
												],
											),
										),
									),
									const SizedBox(height: 20),
									TextButton(
										onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HealthVitalsPage()),
                              );
                    },
										style: TextButton.styleFrom(
											foregroundColor: const Color(0xFF6C6C6C),
											textStyle: const TextStyle(
												fontSize: 15,
												fontWeight: FontWeight.w500,
											),
										),
										child: Text(strings['skip_for_now'] ?? 'Skip for now'),
									),
								],
							),
						),
					),
				),
			),
		);
	}
}

class _IconCard extends StatelessWidget {
	const _IconCard({required this.size});

	final Size size;

	@override
	Widget build(BuildContext context) {
		final double cardSize = size.width < 600 ? 72 : 80;
		final double iconSize = size.width < 600 ? 30 : 32;

		return Container(
			width: cardSize,
			height: cardSize,
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				boxShadow: const <BoxShadow>[
					BoxShadow(
						color: Color(0x14000000),
						blurRadius: 16,
						offset: Offset(0, 8),
					),
				],
			),
			child: Center(
				child: Container(
					width: iconSize,
					height: iconSize,
					decoration: BoxDecoration(
						color: const Color(0xFFE8F5F3),
						borderRadius: BorderRadius.circular(iconSize / 2),
					),
					child: Center(
					  child: FaIcon(
					  FontAwesomeIcons.stethoscope,
					  color: HealthMonitoring8Page._primaryColor,
					  size: iconSize * 0.8,
					),
					),

				),
			),
		);
	}
}
