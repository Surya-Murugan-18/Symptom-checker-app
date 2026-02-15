import 'package:flutter/material.dart';

import 'package:symtom_checker/models/article_model.dart';
import 'package:intl/intl.dart';

class ArticleExpandPage extends StatelessWidget {
	final Article article;

	const ArticleExpandPage({Key? key, required this.article}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.white,
			appBar: AppBar(
				backgroundColor: Colors.white,
				elevation: 0,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back, color: Colors.black),
					onPressed: () => Navigator.pop(context),
				),
				title: const Text(
					'Article',
					style: TextStyle(
						color: Colors.black,
						fontSize: 18,
						fontWeight: FontWeight.w600,
					),
				),
				centerTitle: true,
			),
			body: SingleChildScrollView(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						_buildHeaderImage(),
						Padding(
							padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										article.category ?? 'Health',
										style: const TextStyle(
											color: Color(0xFF26B5A8),
											fontSize: 12,
											fontWeight: FontWeight.w600,
										),
									),
									const SizedBox(height: 8),
									Text(
										article.title,
										style: const TextStyle(
											color: Colors.black,
											fontSize: 20,
											fontWeight: FontWeight.w700,
											height: 1.3,
										),
									),
									const SizedBox(height: 8),
									Text(
										'${DateFormat('MMM dd, yyyy').format(article.publishedDate)} • 5 min read',
										style: TextStyle(
											color: Colors.grey[600],
											fontSize: 12,
										),
									),
									const SizedBox(height: 16),
									Text(
										article.content,
										style: TextStyle(
											color: Colors.grey[800],
											fontSize: 14,
											height: 1.6,
										),
									),
								],
							),
						),
					],
				),
			),
		);
	}

	Widget _buildHeaderImage() {
		return SizedBox(
			height: 220,
			width: double.infinity,
			child: Image.asset(
				article.imageUrl ?? 'assets/article1.png',
				fit: BoxFit.cover,
				errorBuilder: (context, error, stackTrace) {
					return Container(
						color: const Color(0xFFE8F5F4),
						child: const Icon(
							Icons.image,
							color: Color(0xFF26B5A8),
							size: 48,
						),
					);
				},
			),
		);
	}
}
