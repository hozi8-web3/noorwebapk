import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/tasbeeh_preset_model.dart';
import '../tasbeeh/bloc/tasbeeh_bloc.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _pulseController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _tap(BuildContext context) {
    HapticFeedback.heavyImpact();
    context.read<TasbeehBloc>().add(IncrementTasbeeh());
    _pulseController.forward(from: 0.0);
  }

  void _showAddDialog(BuildContext context) {
    final _arabicCtrl = TextEditingController();
    final _englishCtrl = TextEditingController();
    final _targetCtrl = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Dhikr'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _arabicCtrl,
              decoration: const InputDecoration(labelText: 'Arabic Text (optional)'),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _englishCtrl,
              decoration: const InputDecoration(labelText: 'English / Transliteration'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetCtrl,
              decoration: const InputDecoration(labelText: 'Target Count'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_englishCtrl.text.isEmpty) return;
              final preset = TasbeehPresetModel(
                name: _englishCtrl.text.replaceAll(' ', ''),
                arabic: _arabicCtrl.text.isEmpty ? _englishCtrl.text : _arabicCtrl.text,
                target: int.tryParse(_targetCtrl.text) ?? 33,
                transliteration: _englishCtrl.text,
              );
              context.read<TasbeehBloc>().add(AddCustomPreset(preset));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildBead() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF2eb8a6), // Lighter highlight
            AppColors.primary,
            AppColors.primaryDark,
          ],
          center: Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(2, 4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Digital Tasbeeh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TasbeehBloc>().add(ResetTasbeeh()),
          ),
        ],
      ),
      body: BlocConsumer<TasbeehBloc, TasbeehState>(
        listener: (context, state) {
          if (state is TasbeehLoaded && state.cycleComplete) {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Cycle complete! SubhanAllah 🌟'),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! TasbeehLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return _buildContent(context, state, isDark);
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, TasbeehLoaded state, bool isDark) {
    final progress = state.preset.target > 0
        ? state.count / state.preset.target
        : 0.0;

    return Column(
      children: [
        // Preset selector
        Container(
          height: 56,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.allPresets.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              if (i == state.allPresets.length) {
                return GestureDetector(
                  onTap: () => _showAddDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.add, size: 20, color: AppColors.primary),
                  ),
                );
              }

              final preset = state.allPresets[i];
              final selected = preset.name == state.preset.name;
              return GestureDetector(
                onTap: () =>
                    context.read<TasbeehBloc>().add(ChangePreset(preset)),
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    preset.transliteration,
                    style: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Main tap area
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Arabic dhikr
                Text(
                  state.preset.arabic,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textDirection: TextDirection.rtl,
                ).animate().fadeIn(),
                const SizedBox(height: 6),
                Text(
                  state.preset.transliteration,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Counter Text
                Text(
                  '${state.count}',
                  style: GoogleFonts.inter(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'of ${state.preset.target}',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Tap button -> Beads Array
                GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                      _tap(context);
                    }
                  },
                  onTap: () => _tap(context),
                  child: ClipRect(
                    child: SizedBox(
                      height: 180,
                      width: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            width: 3,
                            child: Container(color: AppColors.accent.withOpacity(0.4)),
                          ),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final dy = _pulseController.value * 50.0; // bead spacing
                              return Stack(
                                alignment: Alignment.center,
                                children: List.generate(6, (i) {
                                  final offset = (i - 2) * 50.0 + dy;
                                  // fade out the bottom one as it slides down, fade in the top one
                                  double opacity = 1.0;
                                  if (i == 5) opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);
                                  if (i == 0) opacity = _pulseController.value.clamp(0.0, 1.0);
                                  return Positioned(
                                    top: 90 - 22.5 + offset,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: _buildBead(),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text('Total: ${state.total}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
