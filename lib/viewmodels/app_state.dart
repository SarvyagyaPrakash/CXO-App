import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../models/advisor_model.dart';
import '../services/mock_service.dart';

// --- Scroll Anchor Keys Providers ---
// Providing identical global key instances across tabs and sidebar drawers
final homeKeyProvider = Provider<GlobalKey>((ref) => GlobalKey(debugLabel: 'home_key'));
final howItWorksKeyProvider = Provider<GlobalKey>((ref) => GlobalKey(debugLabel: 'how_it_works_key'));
final benefitsKeyProvider = Provider<GlobalKey>((ref) => GlobalKey(debugLabel: 'benefits_key'));
final contactKeyProvider = Provider<GlobalKey>((ref) => GlobalKey(debugLabel: 'contact_key'));

// --- Bottom Navigation State ---
class TabNavigationNotifier extends StateNotifier<int> {
  TabNavigationNotifier() : super(0);

  void setTab(int index) => state = index;
}

final tabNavigationProvider = StateNotifierProvider<TabNavigationNotifier, int>((ref) {
  return TabNavigationNotifier();
});

// --- Authentication / User Role States ---
enum UserRole { guest, company, expert }

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.guest);

// --- Chatbot Toggle State ---
final isChatOpenProvider = StateProvider<bool>((ref) => false);

// --- TARS Chatbot Message Structures ---
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier()
      : super([
          ChatMessage(
            text: 'Welcome! I am TARS, here to guide you to the right expertise. What can I help with today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]);

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  void addMessage(String text) {
    // Add user message
    state = [
      ...state,
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    ];

    // Trigger smart automated reply from TARS
    _triggerTarsReply(text.toLowerCase());
  }

  void _triggerTarsReply(String query) {
    _isTyping = true;
    
    // Simulate natural typing delay (e.g. 1.2 seconds)
    Future.delayed(const Duration(milliseconds: 1200), () {
      String replyText = '';

      if (query.contains('hi') || query.contains('hello') || query.contains('hey')) {
        replyText = 'Hello! How can I assist you with your executive needs or expert applications today?';
      } else if (query.contains('cto') || query.contains('tech') || query.contains('engineer') || query.contains('dev')) {
        replyText = 'We have elite former CTOs from payments (Stripe) and logistics (Flexport). You can search active Tech roles in our "Projects" tab, or request a curated match!';
      } else if (query.contains('hiring') || query.contains('company') || query.contains('recruit') || query.contains('project')) {
        replyText = 'Hiring is managed by our PMO. Click "Get Started" in our hero area to open the gateway and register your firm!';
      } else if (query.contains('expert') || query.contains('apply') || query.contains('join') || query.contains('advisor')) {
        replyText = 'Applying as an advisor is simple! Click "Become a Member" in benefits to submit your LinkedIn credentials for vetting.';
      } else if (query.contains('pricing') || query.contains('cost') || query.contains('escrow') || query.contains('governance')) {
        replyText = 'We standardise advisor rates from \$150-\$250+/hr with escrow milestones. Tap "PMO Governance" under benefits to learn about our success oversight!';
      } else {
        replyText = 'That sounds like a vital initiative. I recommend requesting a private introduction in our "Network" directory, or clicking "Book Urgent Briefing" for live support.';
      }

      state = [
        ...state,
        ChatMessage(text: replyText, isUser: false, timestamp: DateTime.now()),
      ];
      _isTyping = false;
    });
  }

  void resetChat() {
    state = [
      ChatMessage(
        text: 'Welcome! I am TARS, here to guide you to the right expertise. What can I help with today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

// --- Projects Filter & Search States ---
class ProjectSearchNotifier extends StateNotifier<String> {
  ProjectSearchNotifier() : super('');

  void setSearch(String query) => state = query;
}

final projectSearchProvider = StateNotifierProvider<ProjectSearchNotifier, String>((ref) {
  return ProjectSearchNotifier();
});

enum ProjectFilter { all, fractional, interim, advisory }

class ProjectFilterNotifier extends StateNotifier<ProjectFilter> {
  ProjectFilterNotifier() : super(ProjectFilter.all);

  void setFilter(ProjectFilter filter) => state = filter;
}

final projectFilterProvider = StateNotifierProvider<ProjectFilterNotifier, ProjectFilter>((ref) {
  return ProjectFilterNotifier();
});

// Filtered Projects List Provider
final filteredProjectsProvider = Provider<List<ProjectModel>>((ref) {
  final query = ref.watch(projectSearchProvider).toLowerCase();
  final filter = ref.watch(projectFilterProvider);
  final allProjects = MockService.getMockProjects();

  return allProjects.where((project) {
    final matchesQuery = project.title.toLowerCase().contains(query) ||
        project.companyName.toLowerCase().contains(query) ||
        project.industry.toLowerCase().contains(query) ||
        project.description.toLowerCase().contains(query);

    if (!matchesQuery) return false;
    switch (filter) {
      case ProjectFilter.all:
        return true;
      case ProjectFilter.fractional:
        return project.engagementType.toLowerCase() == 'fractional';
      case ProjectFilter.interim:
        return project.engagementType.toLowerCase() == 'interim';
      case ProjectFilter.advisory:
        return project.engagementType.toLowerCase() == 'advisory';
    }
  }).toList();
});

// --- Advisors Filter & Search States ---
class AdvisorSearchNotifier extends StateNotifier<String> {
  AdvisorSearchNotifier() : super('');

  void setSearch(String query) => state = query;
}

final advisorSearchProvider = StateNotifierProvider<AdvisorSearchNotifier, String>((ref) {
  return AdvisorSearchNotifier();
});

// List of active request introduction IDs
class IntroductionRequestsNotifier extends StateNotifier<Set<String>> {
  IntroductionRequestsNotifier() : super({});

  void requestIntroduction(String advisorId) {
    state = {...state, advisorId};
  }

  bool isRequested(String advisorId) => state.contains(advisorId);
}

final introductionRequestsProvider = StateNotifierProvider<IntroductionRequestsNotifier, Set<String>>((ref) {
  return IntroductionRequestsNotifier();
});

// Filtered Advisors List Provider
final filteredAdvisorsProvider = Provider<List<AdvisorModel>>((ref) {
  final query = ref.watch(advisorSearchProvider).toLowerCase();
  final allAdvisors = MockService.getMockAdvisors();

  return allAdvisors.where((advisor) {
    return advisor.name.toLowerCase().contains(query) ||
        advisor.role.toLowerCase().contains(query) ||
        advisor.industry.toLowerCase().contains(query) ||
        advisor.skills.any((skill) => skill.toLowerCase().contains(query)) ||
        advisor.biography.toLowerCase().contains(query);
  }).toList();
});
