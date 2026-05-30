import '../models/project_model.dart';
import '../models/advisor_model.dart';

class MockService {
  static List<ProjectModel> getMockProjects() {
    return [
      ProjectModel(
        id: 'p1',
        title: 'Interim Chief Technology Officer',
        companyName: 'FintechScale Co.',
        logoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=100',
        industry: 'FinTech',
        engagementType: 'Interim',
        duration: '6 Months',
        timeCommitment: 'Full-time',
        budget: '\$22,000/mo',
        location: 'Remote (US)',
        description: 'Leading a series B fintech scale-up through an architecture overhaul and core system migration. You will manage a team of 45 engineers and directly interface with the board regarding scaling security and infrastructure.',
        requirements: [
          '10+ years of engineering leadership experience in banking or fintech.',
          'Proven track record of successful cloud migrations (AWS/GCP).',
          'Excellent command of high-throughput transactional database architectures.'
        ],
        techStack: ['Go', 'TypeScript', 'Kubernetes', 'PostgreSQL', 'AWS'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProjectModel(
        id: 'p2',
        title: 'Fractional Chief Marketing Officer',
        companyName: 'Stratos Health',
        logoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=100',
        industry: 'HealthTech',
        engagementType: 'Fractional',
        duration: '12 Months',
        timeCommitment: '15-20 hrs/week',
        budget: '\$12,500/mo',
        location: 'Hybrid (Boston, MA)',
        description: 'Design and deploy a direct-to-consumer digital acquisition pipeline for a new personalized health monitoring service. You will define the brand hierarchy, orchestrate paid campaign architectures, and hire the permanent growth lead.',
        requirements: [
          'Prior experience as CMO/VP of Marketing in a venture-backed HealthTech startup.',
          'Demonstrated command of B2C digital user acquisition, SEO, and brand strategy.',
          'Ability to collaborate with medical compliance and legal departments.'
        ],
        techStack: ['HubSpot', 'Google Analytics', 'Figma', 'Webflow'],
        postedDate: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ProjectModel(
        id: 'p3',
        title: 'Chief Product Officer (M&A Strategy)',
        companyName: 'Nexus Enterprise',
        logoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=100',
        industry: 'SaaS',
        engagementType: 'Advisory',
        duration: '3 Months',
        timeCommitment: '10 hrs/week',
        budget: '\$180/hr',
        location: 'Remote (Global)',
        description: 'Assisting a multi-product enterprise B2B company in evaluating product integrations and due diligence of two potential AI acquisition targets. You will write comprehensive capability reports and deliver strategic architecture recommendations.',
        requirements: [
          'Completed at least 3 successful SaaS M&A due diligence evaluations.',
          'Expertise in Generative AI architectures, LLMs, and enterprise safety.',
          'Exceptional board presentation and corporate reporting skills.'
        ],
        techStack: ['Enterprise Architectures', 'AI/LLM Platforms', 'Due Diligence Frameworks'],
        postedDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
      ProjectModel(
        id: 'p4',
        title: 'VP of Global Enterprise Sales',
        companyName: 'Vertex Logic',
        logoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=100',
        industry: 'Logistics',
        engagementType: 'Interim',
        duration: '9 Months',
        timeCommitment: 'Full-time',
        budget: '\$18,000/mo + Bonus',
        location: 'Onsite (Chicago, IL)',
        description: 'Taking over and re-energizing a flatlining midwest enterprise sales division. You will implement structured CRM governance, retrain the mid-market account executives, and close the pending Fortune 500 logistics pipeline.',
        requirements: [
          '15+ years of enterprise B2B sales management in supply chain or logistics.',
          'Experience running and coaching large sales forces using Sandler/MEDDPICC.',
          'Strong regional network of supply-chain executives.'
        ],
        techStack: ['Salesforce', 'MEDDPICC', 'Tableau', 'GSuite'],
        postedDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  static List<AdvisorModel> getMockAdvisors() {
    return [
      AdvisorModel(
        id: 'a1',
        name: 'Sarah Jenkins',
        role: 'Former CTO at Stripe',
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=400',
        industry: 'FinTech & Payments',
        yearsOfExperience: 18,
        rating: 4.95,
        skills: ['Scaling Infrastructure', 'API Strategy', 'Global Compliance', 'Tech Architecture'],
        biography: 'Sarah spent 7 years leading Stripe\'s core payments engineering group, scaling transaction volume from tens of millions to hundreds of billions. She specializes in helping series A/B fintechs cross the chasm of reliability, security, and scaling.',
        isVetted: true,
        lastKnownCompany: 'Stripe',
        location: 'San Francisco, CA',
      ),
      AdvisorModel(
        id: 'a2',
        name: 'Marcus Vance',
        role: 'Interim CFO & Board Member',
        avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=400',
        industry: 'SaaS & Enterprise',
        yearsOfExperience: 22,
        rating: 4.89,
        skills: ['M&A Due Diligence', 'Series B-D Funding', 'Financial Operations', 'Board Governance'],
        biography: 'Marcus is a veteran CFO who has taken two SaaS platforms public and guided five others through successful acquisitions. He provides tactical financial governance, runway modeling, and strategic negotiation support during crucial funding rounds.',
        isVetted: true,
        lastKnownCompany: 'DocuSign',
        location: 'New York, NY',
      ),
      AdvisorModel(
        id: 'a3',
        name: 'Dr. Samantha Chen',
        role: 'Fractional CMO / Brand Expert',
        avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=400',
        industry: 'HealthTech & D2C',
        yearsOfExperience: 15,
        rating: 4.92,
        skills: ['Growth Marketing', 'Brand Strategy', 'Regulatory Compliance', 'User Acquisition'],
        biography: 'Samantha is an expert in digital user acquisition and brand positioning within regulated fields. She has spent the last decade building high-converting growth pipelines that satisfy healthcare compliance requirements.',
        isVetted: true,
        lastKnownCompany: 'One Medical',
        location: 'Boston, MA',
      ),
      AdvisorModel(
        id: 'a4',
        name: 'Dave Kincaid',
        role: 'Scaleup COO & PMO Architect',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=400',
        industry: 'B2B SaaS & Logistics',
        yearsOfExperience: 20,
        rating: 4.97,
        skills: ['Operational Excellence', 'PMO Governance', 'OKR Frameworks', 'Change Management'],
        biography: 'Dave is an operational architect who standardizes delivery and execution pipelines. He specializes in establishing structured project management offices, clearing friction from delivery teams, and driving clear milestone accountability.',
        isVetted: true,
        lastKnownCompany: 'Flexport',
        location: 'Chicago, IL',
      ),
    ];
  }
}
