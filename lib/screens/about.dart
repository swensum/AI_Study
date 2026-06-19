import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_assistant/widgets/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Logo
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  // Animated gradient container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary,
                          colors.primary.withOpacity(0.6),
                          Colors.purple.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI Study Assistant',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Description Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? colors.card : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.border.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'About This App',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your personal AI tutor powered by advanced language models. Get instant answers, summarize text, and enhance your learning experience with cutting-edge artificial intelligence technology.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: colors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Feature Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Key Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        context,
                        icon: Icons.chat_bubble_outline,
                        title: 'AI Chat',
                        description: 'Ask anything',
                        color: Colors.blue,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.summarize_outlined,
                        title: 'Summarize',
                        description: 'Text summarization',
                        color: Colors.green,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.translate_outlined,
                        title: 'Translate',
                        description: 'Multi-language',
                        color: Colors.purple,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.lightbulb_outline,
                        title: 'Smart Tips',
                        description: 'Study suggestions',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Why Choose Us Section (Replacing Powered By)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.08),
                      colors.primary.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.primary.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_outline,
                          color: colors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Why Choose Us',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWhyChooseItem(
                      context,
                      icon: Icons.speed,
                      title: 'Fast & Accurate',
                      description: 'Get instant responses with high accuracy powered by cutting-edge AI.',
                    ),
                    _buildWhyChooseItem(
                      context,
                      icon: Icons.security,
                      title: 'Privacy First',
                      description: 'Your data is secure and never shared with third parties.',
                    ),
                    _buildWhyChooseItem(
                      context,
                      icon: Icons.school,
                      title: 'Smart Learning',
                      description: 'Adaptive learning techniques to help you understand better.',
                    ),
                    _buildWhyChooseItem(
                      context,
                      icon: Icons.devices,
                      title: 'Cross-Platform',
                      description: 'Access your study assistant anywhere, anytime.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.1),
                      colors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      number: '10K+',
                      label: 'Users',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colors.border,
                    ),
                    _buildStatItem(
                      context,
                      number: '50K+',
                      label: 'Questions',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colors.border,
                    ),
                    _buildStatItem(
                      context,
                      number: '95%',
                      label: 'Satisfaction',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.background,
                    colors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Made with ❤️ by Study Assistant Team',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.subtext,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 All Rights Reserved',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.hint,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? colors.card : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: colors.subtext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.subtext,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String number,
    required String label,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;

    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colors.subtext,
          ),
        ),
      ],
    );
  }
}