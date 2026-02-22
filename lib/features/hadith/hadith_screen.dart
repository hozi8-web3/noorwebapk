import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/hadith_model.dart';
import '../hadith/bloc/hadith_bloc.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedBookIndex = 0;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBook(0);
  }

  void _loadBook(int index) {
    setState(() => _selectedBookIndex = index);
    final book = AppConstants.hadithBooks[index];
    context.read<HadithBloc>().add(LoadHadiths(book['key']!, book['name']!));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          // Pinned App Bar with Search & Book Selector
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            toolbarHeight: 140, // Height for title + search box
            elevation: 0,
            backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF0F4F8),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(isDark),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(68),
              child: Container(
                color: isDark ? AppColors.darkBackground : const Color(0xFFF0F4F8),
                child: _buildBookSelector(isDark),
              ),
            ),
          ),
          // Content
          BlocBuilder<HadithBloc, HadithState>(
            builder: (context, state) {
              if (state is HadithLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Loading hadiths...'),
                      ],
                    ),
                  ),
                );
              }
              if (state is HadithError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _loadBook(_selectedBookIndex),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (state is HadithLoaded) {
                final filtered = state.hadiths.where((h) {
                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  if (h.hadithnumber.toString() == q) return true;
                  return h.text.toLowerCase().contains(q) || 
                         (h.arabic != null && h.arabic!.toLowerCase().contains(q));
                }).toList();

                if (filtered.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No hadiths found for your search',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HadithCard(
                                hadith: filtered[i],
                                index: i,
                                isDark: isDark)
                            .animate()
                            .fadeIn(
                                delay: Duration(
                                    milliseconds: 40 * (i > 8 ? 8 : i))),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B3FA0), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text('Hadith Collection',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              // Search Field
              SizedBox(
                height: 44,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search concepts or keywords...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: AppConstants.hadithBooks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final book = AppConstants.hadithBooks[i];
            final selected = i == _selectedBookIndex;
            return GestureDetector(
              onTap: () => _loadBook(i),
              child: AnimatedContainer(
                duration: 250.ms,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF7B3FA0), Color(0xFF4A148C)])
                      : null,
                  color: selected
                      ? null
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: const Color(0xFF7B3FA0).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]
                      : null,
                ),
                child: Text(
                  book['name']!,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? AppColors.darkText : AppColors.lightText),
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HadithCard extends StatefulWidget {
  final HadithModel hadith;
  final int index;
  final bool isDark;
  const _HadithCard(
      {required this.hadith, required this.index, required this.isDark});

  @override
  State<_HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<_HadithCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.hadith.text;
    final isLong = text.length > 200;

    return GestureDetector(
      onTap: () {
        if (isLong) setState(() => _expanded = !_expanded);
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
              left: BorderSide(color: const Color(0xFF7B3FA0), width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF7B3FA0), Color(0xFF4A148C)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#${widget.hadith.hadithnumber}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  if (isLong)
                    Text(
                      _expanded ? 'Show less ▲' : 'Read more ▼',
                      style: const TextStyle(
                          color: Color(0xFF7B3FA0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Arabic text (collapsible)
              if (widget.hadith.arabic != null && widget.hadith.arabic!.isNotEmpty) ...[
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Text(
                    widget.hadith.arabic!,
                    style: GoogleFonts.scheherazadeNew(
                        fontSize: 22, color: const Color(0xFFC8A951), height: 1.8),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: 300.ms,
                ),
                if (_expanded) const SizedBox(height: 16),
              ],
              // Urdu Translation
              AnimatedCrossFade(
                firstChild: Text(
                  isLong ? '${text.substring(0, 100)}...' : text, // Shorter preview
                  style: GoogleFonts.notoNastaliqUrdu(fontSize: 16, height: 2.2),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                secondChild: Text(
                  text,
                  style: GoogleFonts.notoNastaliqUrdu(fontSize: 16, height: 2.2),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: 300.ms,
              ),
              if (widget.hadith.reference.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B3FA0).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.hadith.reference,
                    style: const TextStyle(
                        color: Color(0xFF7B3FA0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
