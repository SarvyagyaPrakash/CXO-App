class AdvisorModel {
  final String id;
  final String name;
  final String role;             // e.g., "Former CTO at Stripe", "VP of Marketing at Airbnb"
  final String avatarUrl;
  final String industry;         // e.g., "FinTech", "SaaS", "HealthTech"
  final int yearsOfExperience;
  final double rating;           // e.g., 4.9
  final List<String> skills;     // e.g., ["Scaling Teams", "M&A", "AI Integration", "Product Strategy"]
  final String biography;
  final bool isVetted;
  final String lastKnownCompany;
  final String location;

  AdvisorModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.industry,
    required this.yearsOfExperience,
    required this.rating,
    required this.skills,
    required this.biography,
    required this.isVetted,
    required this.lastKnownCompany,
    required this.location,
  });
}
