import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';

/// Onboarding screen where MoneyCA introduces users to the app
/// and learns about their financial situation and goals
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;
  
  final List<OnboardingStep> steps = [
    OnboardingStep(
      title: "Meet MoneyCA",
      description: "Your AI-powered financial assistant is here to help you manage your money smarter",
      icon: Icons.psychology,
    ),
    OnboardingStep(
      title: "Tell Us About You",
      description: "Help MoneyCA understand your financial goals and spending habits",
      icon: Icons.person,
    ),
    OnboardingStep(
      title: "Set Your Goals",
      description: "Whether it's saving, investing, or budgeting - we'll help you achieve them",
      icon: Icons.flag,
    ),
    OnboardingStep(
      title: "Ready to Start!",
      description: "Your personalized financial journey begins now",
      icon: Icons.rocket_launch,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (currentStep + 1) / steps.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 40),
              
              // Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      steps[currentStep].icon,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      steps[currentStep].title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      steps[currentStep].description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Navigation buttons
              Row(
                children: [
                  if (currentStep > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 60),
                  
                  const Spacer(),
                  
                  ElevatedButton(
                    onPressed: () {
                      if (currentStep < steps.length - 1) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        // Complete onboarding - navigate to main app
                        context.go(AppRoutes.home);
                      }
                    },
                    child: Text(currentStep < steps.length - 1 ? 'Next' : 'Get Started'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}