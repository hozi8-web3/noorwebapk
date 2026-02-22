import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/prophet_story_model.dart';

class ProphetStoriesScreen extends StatelessWidget {
  const ProphetStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prophet Stories')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: prophetStories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final story = prophetStories[i];
          return _ProphetCard(story: story, index: i)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 80 * i));
        },
      ),
    );
  }
}

class _ProphetCard extends StatelessWidget {
  final ProphetStoryModel story;
  final int index;
  const _ProphetCard({required this.story, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppColors.darkCard : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ProphetDetailScreen(story: story),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    story.arabicName[0],
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 28,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${story.name} (${story.suffix})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      story.arabicName,
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      story.lesson,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProphetDetailScreen extends StatelessWidget {
  final ProphetStoryModel story;
  const _ProphetDetailScreen({required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${story.name} (${story.suffix})')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    story.arabicName,
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${story.name} (${story.suffix})',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2),
            const SizedBox(height: 24),
            Text('Story', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              story.story,
              style: GoogleFonts.inter(fontSize: 15, height: 1.8),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lesson',
                            style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(story.lesson,
                            style: GoogleFonts.inter(fontSize: 14, height: 1.6)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
