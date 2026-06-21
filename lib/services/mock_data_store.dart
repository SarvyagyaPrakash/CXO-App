import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// --- Default Mock Data ---

final defaultRequirements = [
  CompanyRequirement(
    id: 'req1',
    companyId: 'comp_demo',
    title: 'Interim CFO for Fundraising & Board Setup',
    roleType: 'Interim',
    budget: '₹2.5L - ₹3.5L / mo',
    duration: '6 Months',
    keyObjectives: 'Lead Series A strategy, setup Board financial reporting, overhaul cash flow runway models.',
    skillsRequired: ['Financial Modeling', 'Board Reporting', 'Fundraising Strategy', 'Treasury'],
    status: 'Active',
  ),
  CompanyRequirement(
    id: 'req2',
    companyId: 'comp_demo',
    title: 'Fractional CMO for DTC Growth Scaling',
    roleType: 'Fractional',
    budget: '₹1.5L - ₹2.2L / mo',
    duration: '12 Months',
    keyObjectives: 'Build brand hierarchy, orchestrate paid campaign architectures, define customer acquisition pipeline.',
    skillsRequired: ['Growth Marketing', 'User Acquisition', 'DTC Brand Strategy', 'AdTech'],
    status: 'Shortlisted',
  ),
];

final defaultEngagements = [
  Engagement(
    id: 'eng1',
    companyId: 'comp_demo',
    companyName: 'Stratos Health',
    expertId: 'a1',
    expertName: 'Sarah Jenkins',
    title: 'Interim Chief Technology Officer',
    startDate: '2026-04-01',
    endDate: '2026-10-01',
    progress: 0.50, // 50%
    totalBudget: '₹18,00,000',
    status: 'Active',
    pmoContact: 'Dave Kincaid',
  ),
  Engagement(
    id: 'eng2',
    companyId: 'comp_demo',
    companyName: 'Stratos Health',
    expertId: 'a2',
    expertName: 'Marcus Vance',
    title: 'Interim CFO & Board Advisory',
    startDate: '2026-05-15',
    endDate: '2026-08-15',
    progress: 0.33,
    totalBudget: '₹9,00,000',
    status: 'Under Review',
    pmoContact: 'Dave Kincaid',
  ),
];

final defaultMilestones = [
  // Engagement 1 Milestones
  Milestone(
    id: 'm1_1',
    engagementId: 'eng1',
    title: 'Architecture Audit & Override Plan',
    description: 'Review existing core payments platform and identify security vulnerabilities, proposing database migration script outlines.',
    cost: '₹4,50,000',
    status: 'completed',
    paymentStatus: 'released',
    dueDate: '2026-05-01',
    completedDate: '2026-04-28',
  ),
  Milestone(
    id: 'm1_2',
    engagementId: 'eng1',
    title: 'Cloud Overhaul Setup (AWS/GCP Migration)',
    description: 'Establish infrastructure provisioning script structures (Terraform) and stage high-throughput database systems.',
    cost: '₹4,50,000',
    status: 'completed',
    paymentStatus: 'released',
    dueDate: '2026-06-15',
    completedDate: '2026-06-10',
  ),
  Milestone(
    id: 'm1_3',
    engagementId: 'eng1',
    title: 'Integrations & API Strategy Rollout',
    description: 'Build web-service layer connections and implement enterprise gateway API tokens with strict security checks.',
    cost: '₹4,50,000',
    status: 'in_progress',
    paymentStatus: 'in_escrow',
    dueDate: '2026-08-01',
  ),
  Milestone(
    id: 'm1_4',
    engagementId: 'eng1',
    title: 'Permanent Leadership Handover',
    description: 'Document architecture roadmap, conduct final system training, and assist HR in hiring the permanent Engineering VP.',
    cost: '₹4,50,000',
    status: 'upcoming',
    paymentStatus: 'locked',
    dueDate: '2026-10-01',
  ),

  // Engagement 2 Milestones
  Milestone(
    id: 'm2_1',
    engagementId: 'eng2',
    title: 'Runway Modeling & Budget Planning',
    description: 'Create multi-scenario financial forecast models assessing post-Series A expansion strategies.',
    cost: '₹3,00,000',
    status: 'completed',
    paymentStatus: 'released',
    dueDate: '2026-06-01',
    completedDate: '2026-05-30',
  ),
  Milestone(
    id: 'm2_2',
    engagementId: 'eng2',
    title: 'Due Diligence Report on AI Acquisition Targets',
    description: 'Review two potential SaaS acquisition targets, assessing technical architectures, debt, and contract liabilities.',
    cost: '₹3,00,000',
    status: 'pending_approval',
    paymentStatus: 'in_escrow',
    dueDate: '2026-07-15',
  ),
  Milestone(
    id: 'm2_3',
    engagementId: 'eng2',
    title: 'Board Presentation Deck & Audit prep',
    description: 'Complete Q2 compliance checklists and present strategic ROI projections to board members.',
    cost: '₹3,00,000',
    status: 'upcoming',
    paymentStatus: 'locked',
    dueDate: '2026-08-15',
  ),
];

final defaultTransactions = [
  EscrowTransaction(
    id: 'tx1',
    engagementId: 'eng1',
    ref: 'CXO-DEP-8472',
    description: 'Escrow deposit for Milestones 1 & 2',
    type: 'escrow_add',
    amount: '₹9,00,000',
    status: 'Paid',
    date: '2026-04-02',
    method: 'NetBanking',
  ),
  EscrowTransaction(
    id: 'tx2',
    engagementId: 'eng1',
    ref: 'CXO-REL-1029',
    description: 'Milestone 1 release payment to Sarah Jenkins',
    type: 'milestone_release',
    amount: '₹4,50,000',
    status: 'Released',
    date: '2026-04-29',
    method: 'Escrow Balance',
  ),
  EscrowTransaction(
    id: 'tx3',
    engagementId: 'eng1',
    ref: 'CXO-FEE-1030',
    description: 'PMO Platform governance fee (5%)',
    type: 'platform_fee',
    amount: '₹22,500',
    status: 'Paid',
    date: '2026-04-29',
    method: 'Escrow Balance',
  ),
  EscrowTransaction(
    id: 'tx4',
    engagementId: 'eng2',
    ref: 'CXO-DEP-9832',
    description: 'Initial funding for Engagement 2 Escrow Wallet',
    type: 'escrow_add',
    amount: '₹6,00,000',
    status: 'Paid',
    date: '2026-05-18',
    method: 'Card',
  ),
  EscrowTransaction(
    id: 'tx5',
    engagementId: 'eng2',
    ref: 'CXO-REL-2201',
    description: 'Milestone 1 release payment to Marcus Vance',
    type: 'milestone_release',
    amount: '₹3,00,000',
    status: 'Released',
    date: '2026-05-31',
    method: 'Escrow Balance',
  ),
];

final defaultInvoices = [
  Invoice(
    id: 'inv1',
    invoiceNumber: 'INV-2026-001',
    engagementId: 'eng1',
    description: 'Milestone 1 Deliverable: Architecture Audit & Plan',
    amount: '₹4,50,000',
    date: '2026-04-28',
    status: 'Paid',
  ),
  Invoice(
    id: 'inv2',
    invoiceNumber: 'INV-2026-002',
    engagementId: 'eng1',
    description: 'Milestone 2 Deliverable: Cloud Overhaul Setup',
    amount: '₹4,50,000',
    date: '2026-06-10',
    status: 'Paid',
  ),
  Invoice(
    id: 'inv3',
    invoiceNumber: 'INV-2026-003',
    engagementId: 'eng2',
    description: 'Milestone 1 Deliverable: Runway Modeling & Planning',
    amount: '₹3,00,000',
    date: '2026-05-30',
    status: 'Paid',
  ),
  Invoice(
    id: 'inv4',
    invoiceNumber: 'INV-2026-004',
    engagementId: 'eng2',
    description: 'Milestone 2 Deliverable: M&A AI Targets Report',
    amount: '₹3,00,000',
    date: '2026-07-10',
    status: 'Pending',
  ),
];

// --- Riverpod State Notifiers ---

class RequirementsNotifier extends StateNotifier<List<CompanyRequirement>> {
  RequirementsNotifier() : super(defaultRequirements);

  void addRequirement(CompanyRequirement req) {
    state = [...state, req];
  }

  void updateStatus(String id, String status) {
    state = state.map((r) => r.id == id ? CompanyRequirement(
      id: r.id,
      companyId: r.companyId,
      title: r.title,
      roleType: r.roleType,
      budget: r.budget,
      duration: r.duration,
      keyObjectives: r.keyObjectives,
      skillsRequired: r.skillsRequired,
      status: status,
    ) : r).toList();
  }
}

class EngagementsNotifier extends StateNotifier<List<Engagement>> {
  EngagementsNotifier() : super(defaultEngagements);

  void updateEngagementProgress(String id, double progress) {
    state = state.map((e) => e.id == id ? Engagement(
      id: e.id,
      companyId: e.companyId,
      companyName: e.companyName,
      expertId: e.expertId,
      expertName: e.expertName,
      title: e.title,
      startDate: e.startDate,
      endDate: e.endDate,
      progress: progress,
      totalBudget: e.totalBudget,
      status: e.status,
      pmoContact: e.pmoContact,
    ) : e).toList();
  }

  void updateEngagementStatus(String id, String status) {
    state = state.map((e) => e.id == id ? Engagement(
      id: e.id,
      companyId: e.companyId,
      companyName: e.companyName,
      expertId: e.expertId,
      expertName: e.expertName,
      title: e.title,
      startDate: e.startDate,
      endDate: e.endDate,
      progress: e.progress,
      totalBudget: e.totalBudget,
      status: status,
      pmoContact: e.pmoContact,
    ) : e).toList();
  }
}

class MilestonesNotifier extends StateNotifier<List<Milestone>> {
  MilestonesNotifier() : super(defaultMilestones);

  void approveMilestone(String milestoneId) {
    state = state.map((m) {
      if (m.id == milestoneId) {
        return Milestone(
          id: m.id,
          engagementId: m.engagementId,
          title: m.title,
          description: m.description,
          cost: m.cost,
          status: 'completed',
          paymentStatus: 'released',
          dueDate: m.dueDate,
          completedDate: DateTime.now().toString().split(' ')[0],
        );
      }
      return m;
    }).toList();
  }

  void submitMilestone(String milestoneId) {
    state = state.map((m) {
      if (m.id == milestoneId) {
        return Milestone(
          id: m.id,
          engagementId: m.engagementId,
          title: m.title,
          description: m.description,
          cost: m.cost,
          status: 'pending_approval',
          paymentStatus: 'in_escrow',
          dueDate: m.dueDate,
        );
      }
      return m;
    }).toList();
  }
}

class EscrowTransactionsNotifier extends StateNotifier<List<EscrowTransaction>> {
  EscrowTransactionsNotifier() : super(defaultTransactions);

  void addDeposit(String engagementId, String amount, String method) {
    final newTx = EscrowTransaction(
      id: 'tx_dep_${state.length + 1}',
      engagementId: engagementId,
      ref: 'CXO-DEP-${1000 + state.length * 7}',
      description: 'Funding Escrow Wallet',
      type: 'escrow_add',
      amount: amount,
      status: 'Paid',
      date: DateTime.now().toString().split(' ')[0],
      method: method,
    );
    state = [newTx, ...state];
  }

  void releaseMilestoneTx(String engagementId, String milestoneTitle, String amount) {
    final releaseTx = EscrowTransaction(
      id: 'tx_rel_${state.length + 1}',
      engagementId: engagementId,
      ref: 'CXO-REL-${1000 + state.length * 7}',
      description: 'Milestone Released: $milestoneTitle',
      type: 'milestone_release',
      amount: amount,
      status: 'Released',
      date: DateTime.now().toString().split(' ')[0],
      method: 'Escrow Balance',
    );
    final feeTx = EscrowTransaction(
      id: 'tx_fee_${state.length + 2}',
      engagementId: engagementId,
      ref: 'CXO-FEE-${1001 + state.length * 7}',
      description: 'PMO Platform fee (5%)',
      type: 'platform_fee',
      amount: '₹' + ((double.parse(amount.replaceAll('₹', '').replaceAll(',', '').replaceAll('/mo', '').trim()) * 0.05).toInt()).toString(),
      status: 'Paid',
      date: DateTime.now().toString().split(' ')[0],
      method: 'Escrow Balance',
    );
    state = [releaseTx, feeTx, ...state];
  }
}

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  InvoicesNotifier() : super(defaultInvoices);

  void payInvoice(String id) {
    state = state.map((inv) => inv.id == id ? Invoice(
      id: inv.id,
      invoiceNumber: inv.invoiceNumber,
      engagementId: inv.engagementId,
      description: inv.description,
      amount: inv.amount,
      date: inv.date,
      status: 'Paid',
    ) : inv).toList();
  }

  void addInvoice(Invoice invoice) {
    state = [invoice, ...state];
  }
}

// --- Providers ---

final requirementsProvider = StateNotifierProvider<RequirementsNotifier, List<CompanyRequirement>>((ref) {
  return RequirementsNotifier();
});

final engagementsProvider = StateNotifierProvider<EngagementsNotifier, List<Engagement>>((ref) {
  return EngagementsNotifier();
});

final milestonesProvider = StateNotifierProvider<MilestonesNotifier, List<Milestone>>((ref) {
  return MilestonesNotifier();
});

final escrowTransactionsProvider = StateNotifierProvider<EscrowTransactionsNotifier, List<EscrowTransaction>>((ref) {
  return EscrowTransactionsNotifier();
});

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<Invoice>>((ref) {
  return InvoicesNotifier();
});
