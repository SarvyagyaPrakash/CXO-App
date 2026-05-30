class ProjectModel {
  final String id;
  final String title;
  final String companyName;
  final String logoUrl;
  final String industry;
  final String engagementType; // e.g., "Fractional", "Interim", "Board Advisory"
  final String duration;       // e.g., "6 Months", "Ongoing", "12 Months"
  final String timeCommitment; // e.g., "10-15 hrs/week", "Full-time", "2 days/month"
  final String budget;         // e.g., "$15,000/mo", "$120/hr", "Retainer"
  final String location;       // e.g., "Remote (US)", "Hybrid (New York)", "Onsite (London)"
  final String description;
  final List<String> requirements;
  final List<String> techStack;
  final DateTime postedDate;

  ProjectModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.logoUrl,
    required this.industry,
    required this.engagementType,
    required this.duration,
    required this.timeCommitment,
    required this.budget,
    required this.location,
    required this.description,
    required this.requirements,
    required this.techStack,
    required this.postedDate,
  });
}
