import 'dart:convert';

// --- Supabase / Form Onboarding Models ---

class CompanyApplication {
  final String id;
  final String companyName;
  final String tagline;
  final String about;
  final String industry;
  final String orgSize;
  final String orgType;
  final String companyAge;
  final String foundedYear;
  final String website;
  final String email;
  final String contactNumber;
  final String linkedin;
  final List<Map<String, String>> additionalLinks;
  final String adminName;
  final String adminEmail;
  final String gstin;
  final String cinNumber;
  final String logoUrl;
  final String coiUrl;
  final String? userId;

  CompanyApplication({
    required this.id,
    required this.companyName,
    required this.tagline,
    required this.about,
    required this.industry,
    required this.orgSize,
    required this.orgType,
    required this.companyAge,
    required this.foundedYear,
    required this.website,
    required this.email,
    required this.contactNumber,
    required this.linkedin,
    required this.additionalLinks,
    required this.adminName,
    required this.adminEmail,
    required this.gstin,
    required this.cinNumber,
    required this.logoUrl,
    required this.coiUrl,
    this.userId,
  });

  factory CompanyApplication.fromMap(Map<String, dynamic> map) {
    return CompanyApplication(
      id: map['id'] ?? '',
      companyName: map['company_name'] ?? '',
      tagline: map['tagline'] ?? '',
      about: map['about'] ?? '',
      industry: map['industry'] ?? '',
      orgSize: map['org_size'] ?? '',
      orgType: map['org_type'] ?? '',
      companyAge: map['company_age'] ?? '',
      foundedYear: map['founded_year'] ?? '',
      website: map['website'] ?? '',
      email: map['email'] ?? '',
      contactNumber: map['contact_number'] ?? '',
      linkedin: map['linkedin'] ?? '',
      additionalLinks: List<Map<String, String>>.from(
        (map['additional_links'] as List? ?? []).map((e) => Map<String, String>.from(e)),
      ),
      adminName: map['admin_name'] ?? '',
      adminEmail: map['admin_email'] ?? '',
      gstin: map['gstin'] ?? '',
      cinNumber: map['cin_number'] ?? '',
      logoUrl: map['logo_url'] ?? '',
      coiUrl: map['coi_url'] ?? '',
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'tagline': tagline,
      'about': about,
      'industry': industry,
      'org_size': orgSize,
      'org_type': orgType,
      'company_age': companyAge,
      'founded_year': foundedYear,
      'website': website,
      'email': email,
      'contact_number': contactNumber,
      'linkedin': linkedin,
      'additional_links': additionalLinks,
      'admin_name': adminName,
      'admin_email': adminEmail,
      'gstin': gstin,
      'cin_number': cinNumber,
      'logo_url': logoUrl,
      'coi_url': coiUrl,
      'user_id': userId,
    };
  }
}

class ExpertApplication {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String headline;
  final String bio;
  final String servicesOffered;
  final String currentRole;
  final String yearsExperience;
  final List<String> keySkills;
  final String profileUrl;
  final String linkedin;
  final String portfolioWebsite;
  final List<Map<String, dynamic>> experienceHistory;
  final List<Map<String, dynamic>> educationHistory;
  final List<String> industries;
  final Map<String, dynamic> engagementTypes; // Fractional, Interim, Advisory, Project flags
  final String? userId;

  ExpertApplication({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.headline,
    required this.bio,
    required this.servicesOffered,
    required this.currentRole,
    required this.yearsExperience,
    required this.keySkills,
    required this.profileUrl,
    required this.linkedin,
    required this.portfolioWebsite,
    required this.experienceHistory,
    required this.educationHistory,
    required this.industries,
    required this.engagementTypes,
    this.userId,
  });

  factory ExpertApplication.fromMap(Map<String, dynamic> map) {
    return ExpertApplication(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      headline: map['headline'] ?? '',
      bio: map['bio'] ?? '',
      servicesOffered: map['services_offered'] ?? '',
      currentRole: map['current_role'] ?? '',
      yearsExperience: map['years_experience'] ?? '',
      keySkills: List<String>.from(map['key_skills'] is String 
        ? (map['key_skills'] as String).split(',').map((e) => e.trim())
        : (map['key_skills'] as List? ?? [])),
      profileUrl: map['profile_url'] ?? '',
      linkedin: map['linkedin'] ?? '',
      portfolioWebsite: map['portfolio_website'] ?? '',
      experienceHistory: List<Map<String, dynamic>>.from(map['experience_history'] ?? []),
      educationHistory: List<Map<String, dynamic>>.from(map['education_history'] ?? []),
      industries: List<String>.from(map['industries'] ?? []),
      engagementTypes: Map<String, dynamic>.from(map['engagement_types'] ?? {}),
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'headline': headline,
      'bio': bio,
      'services_offered': servicesOffered,
      'current_role': currentRole,
      'years_experience': yearsExperience,
      'key_skills': keySkills,
      'profile_url': profileUrl,
      'linkedin': linkedin,
      'portfolio_website': portfolioWebsite,
      'experience_history': experienceHistory,
      'education_history': educationHistory,
      'industries': industries,
      'engagement_types': engagementTypes,
      'user_id': userId,
    };
  }
}

class CompanyRequirement {
  final String id;
  final String companyId;
  final String title;
  final String roleType;
  final String budget;
  final String duration;
  final String keyObjectives;
  final List<String> skillsRequired;
  final String status; // Active, Shortlisted, Draft

  CompanyRequirement({
    required this.id,
    required this.companyId,
    required this.title,
    required this.roleType,
    required this.budget,
    required this.duration,
    required this.keyObjectives,
    required this.skillsRequired,
    required this.status,
  });

  factory CompanyRequirement.fromMap(Map<String, dynamic> map) {
    return CompanyRequirement(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      title: map['title'] ?? '',
      roleType: map['role_type'] ?? '',
      budget: map['budget'] ?? '',
      duration: map['duration'] ?? '',
      keyObjectives: map['key_objectives'] ?? '',
      skillsRequired: List<String>.from(map['skills_required'] ?? []),
      status: map['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'title': title,
      'role_type': roleType,
      'budget': budget,
      'duration': duration,
      'key_objectives': keyObjectives,
      'skills_required': skillsRequired,
      'status': status,
    };
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String type; // payment, contract, info
  final bool unread;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.unread,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'info',
      unread: map['unread'] ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}

// --- Mock Transaction Systems ---

class Engagement {
  final String id;
  final String companyId;
  final String companyName;
  final String expertId;
  final String expertName;
  final String title;
  final String startDate;
  final String endDate;
  final double progress; // e.g. 0.50 for 50%
  final String totalBudget;
  final String status; // Active, Under Review, Completed, Terminated
  final String pmoContact;

  Engagement({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.expertId,
    required this.expertName,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.totalBudget,
    required this.status,
    required this.pmoContact,
  });

  factory Engagement.fromMap(Map<String, dynamic> map) {
    return Engagement(
      id: map['id'] ?? '',
      companyId: map['company_id'] ?? '',
      companyName: map['company_name'] ?? '',
      expertId: map['expert_id'] ?? '',
      expertName: map['expert_name'] ?? '',
      title: map['title'] ?? '',
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'] ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      totalBudget: map['total_budget'] ?? '',
      status: map['status'] ?? 'Active',
      pmoContact: map['pmo_contact'] ?? 'Sarah Jenkins',
    );
  }
}

class Milestone {
  final String id;
  final String engagementId;
  final String title;
  final String description;
  final String cost;
  final String status; // completed, pending_approval, in_progress, upcoming
  final String paymentStatus; // released, in_escrow, locked
  final String dueDate;
  final String? completedDate;

  Milestone({
    required this.id,
    required this.engagementId,
    required this.title,
    required this.description,
    required this.cost,
    required this.status,
    required this.paymentStatus,
    required this.dueDate,
    this.completedDate,
  });

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'] ?? '',
      engagementId: map['engagement_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      cost: map['cost'] ?? '',
      status: map['status'] ?? 'upcoming',
      paymentStatus: map['payment_status'] ?? 'locked',
      dueDate: map['due_date'] ?? '',
      completedDate: map['completed_date'],
    );
  }
}

class EscrowTransaction {
  final String id;
  final String engagementId;
  final String ref;
  final String description;
  final String type; // escrow_add, milestone_release, platform_fee
  final String amount;
  final String status; // Paid, Pending, Released
  final String date;
  final String method; // NetBanking, Escrow Balance, Card

  EscrowTransaction({
    required this.id,
    required this.engagementId,
    required this.ref,
    required this.description,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
    required this.method,
  });

  factory EscrowTransaction.fromMap(Map<String, dynamic> map) {
    return EscrowTransaction(
      id: map['id'] ?? '',
      engagementId: map['engagement_id'] ?? '',
      ref: map['ref'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'info',
      amount: map['amount'] ?? '',
      status: map['status'] ?? '',
      date: map['date'] ?? '',
      method: map['method'] ?? '',
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String engagementId;
  final String description;
  final String amount;
  final String date;
  final String status; // Paid, Pending, Locked

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.engagementId,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      invoiceNumber: map['invoice_number'] ?? '',
      engagementId: map['engagement_id'] ?? '',
      description: map['description'] ?? '',
      amount: map['amount'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }
}
