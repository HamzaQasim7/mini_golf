import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mini_golf/features/game/presentation/pages/add_player_screen.dart';
import 'package:mini_golf/widgets/custom_button.dart';
import 'package:mini_golf/widgets/shared_dynamic_icon.dart';

import '../../../game/presentation/pages/course_selection_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/mini-golf.jpg',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Gap(16),
              Text(
                'Welcome to Mini Golf',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(8),
              CustomButton(
                text: 'Play Now',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CourseSelectionScreen()),
                  );
                },
                width: 300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
