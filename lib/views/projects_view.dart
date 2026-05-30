import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';
import '../models/project_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';

class ProjectsView extends ConsumerWidget {
  const ProjectsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController(text: ref.watch(projectSearchProvider));
    final currentFilter = ref.watch(projectFilterProvider);
    final projects = ref.watch(filteredProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Engagement Marketplace',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Browse active enterprise scopes and fractional roles.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: searchController,
                  onChanged: (val) {
                    ref.read(projectSearchProvider.notifier).setSearch(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title, technology, or company...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textMuted),
                            onPressed: () {
                              searchController.clear();
                              ref.read(projectSearchProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Filters Chips Scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: ProjectFilter.values.map((filter) {
                      final isSelected = currentFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(
                            filter.name[0].toUpperCase() + filter.name.substring(1),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.backgroundDark : AppColors.textSecondary,
                            ),
                          ),
                          selectedColor: AppColors.primaryTeal,
                          backgroundColor: AppColors.backgroundMidnight,
                          checkmarkColor: AppColors.backgroundDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryTeal : AppColors.cardBorder,
                              width: 1.0,
                            ),
                          ),
                          onSelected: (_) {
                            ref.read(projectFilterProvider.notifier).setFilter(filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Project List
          Expanded(
            child: projects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return _ProjectCard(project: projects[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_outlined, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'No Engagements Found',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters or search keywords.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard({required this.project, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title, company and badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.companyName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Engagement Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlueDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    project.engagementType.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Metadata: Budget, Commitment, Location
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildMetaItem(Icons.payments_outlined, project.budget),
                _buildMetaItem(Icons.schedule_outlined, project.timeCommitment),
                _buildMetaItem(Icons.location_on_outlined, project.location),
              ],
            ),
            const SizedBox(height: 14),

            // Description
            Text(
              project.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),

            // Tech Stack / Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.techStack.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tech,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Apply Button
            CustomButton(
              text: 'Review Details & Apply',
              height: 40,
              onTap: () {
                _showApplyModal(context);
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryTeal, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showApplyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundMidnight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apply for Engagement',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                project.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Your Full Name',
                        hintText: 'Sarah Jenkins',
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'LinkedIn or Portfolio URL',
                        hintText: 'https://linkedin.com/in/sarahjenkins',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please provide link';
                        if (!val.contains('http')) return 'Please provide a valid URL';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Brief Pitch (Why are you a fit?)',
                        hintText: 'Outline your scaling experience relevant to this core architecture mandate...',
                      ),
                      maxLines: 3,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a pitch' : null,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Application',
                      isLoading: isSubmitting,
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          setModalState(() => isSubmitting = true);
                          await Future.delayed(const Duration(milliseconds: 1500));
                          setModalState(() => isSubmitting = false);
                          if (context.mounted) {
                            Navigator.pop(context);
                            Forms.showSuccessToast(
                              context,
                              'Application submitted! The company will review and schedule an introduction call.',
                            );
                          }
                        }
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
