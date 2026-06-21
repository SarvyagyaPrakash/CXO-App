import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/app_state.dart';
import '../../views/landing_view.dart';
import '../../views/company_onboarding_view.dart';
import '../../views/expert_onboarding_view.dart';
import '../../views/portal_views.dart';
import '../../views/shell_layouts.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final role = ref.read(userRoleProvider);
      final loggingIn = state.matchedLocation == '/signin';
      final isGuest = role == UserRole.guest;

      // Protected routes
      final protectedRoutes = [
        '/company-dashboard',
        '/expert-dashboard',
        '/experts',
        '/analytics',
        '/payments',
        '/requirements',
        '/messages',
        '/meetings',
        '/expert-opportunities',
        '/expert-engagements',
        '/expert-contracts',
        '/expert-earnings',
        '/expert-profile',
        '/expert-settings',
        '/company-settings',
        '/engagements',
      ];

      final isProtected = protectedRoutes.any((route) => state.matchedLocation.startsWith(route));

      if (isProtected && isGuest) {
        return '/signin';
      }

      // If logged in and going to signin, redirect to their respective dashboard
      if (loggingIn && !isGuest) {
        return role == UserRole.company ? '/company-dashboard' : '/expert-dashboard';
      }

      // Enforce Role Separation (Anti-Hallucination Guard)
      if (!isGuest) {
        final companyOnlyRoutes = [
          '/company-dashboard',
          '/requirements',
          '/experts',
          '/analytics',
          '/payments',
          '/company-settings',
        ];

        final expertOnlyRoutes = [
          '/expert-dashboard',
          '/expert-opportunities',
          '/expert-engagements',
          '/expert-contracts',
          '/expert-earnings',
          '/expert-profile',
          '/expert-settings',
        ];

        final matchesCompanyOnly = companyOnlyRoutes.any((route) => state.matchedLocation.startsWith(route));
        final matchesExpertOnly = expertOnlyRoutes.any((route) => state.matchedLocation.startsWith(route));

        if (role == UserRole.expert && matchesCompanyOnly) {
          return '/expert-dashboard';
        }
        if (role == UserRole.company && matchesExpertOnly) {
          return '/company-dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: LandingView()),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutView(),
      ),
      GoRoute(
        path: '/join-company',
        builder: (context, state) => const CompanyOnboardingView(),
      ),
      GoRoute(
        path: '/join-expert',
        builder: (context, state) => const ExpertOnboardingView(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) {
          final roleParam = state.uri.queryParameters['role'];
          return SignInView(initialRole: roleParam);
        },
      ),
      // --- COMPANY SHELL PAGES ---
      GoRoute(
        path: '/company-dashboard',
        builder: (context, state) => const CompanyShellLayout(child: CompanyDashboardView()),
      ),
      GoRoute(
        path: '/requirements',
        builder: (context, state) => const CompanyShellLayout(child: CompanyRequirementsView()),
      ),
      GoRoute(
        path: '/requirements/create',
        builder: (context, state) => const CompanyShellLayout(child: PostRequirementView()),
      ),
      GoRoute(
        path: '/experts',
        builder: (context, state) => const CompanyShellLayout(child: ExpertDiscoveryCatalogView()),
      ),
      GoRoute(
        path: '/experts/:expertId',
        builder: (context, state) {
          final expertId = state.pathParameters['expertId'] ?? '';
          return CompanyShellLayout(
            child: DetailedExpertProfileView(expertId: expertId),
          );
        },
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const CompanyShellLayout(child: EscrowFinancialControlView()),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const CompanyShellLayout(child: AnalyticsHubView()),
      ),
      GoRoute(
        path: '/company-settings',
        builder: (context, state) => const CompanyShellLayout(child: CompanySettingsView()),
      ),
      // --- EXPERT SHELL PAGES ---
      GoRoute(
        path: '/expert-dashboard',
        builder: (context, state) => const ExpertShellLayout(child: ExpertDashboardView()),
      ),
      GoRoute(
        path: '/expert-opportunities',
        builder: (context, state) => const ExpertShellLayout(child: ExpertOpportunitiesView()),
      ),
      GoRoute(
        path: '/expert-engagements',
        builder: (context, state) => const ExpertShellLayout(child: ExpertEngagementsView()),
      ),
      GoRoute(
        path: '/expert-contracts',
        builder: (context, state) => const ExpertShellLayout(child: ExpertContractsView()),
      ),
      GoRoute(
        path: '/expert-earnings',
        builder: (context, state) => const ExpertShellLayout(child: ExpertEarningsView()),
      ),
      GoRoute(
        path: '/expert-profile',
        builder: (context, state) => const ExpertShellLayout(child: ExpertProfileBuilderView()),
      ),
      GoRoute(
        path: '/expert-settings',
        builder: (context, state) => const ExpertShellLayout(child: ExpertSettingsView()),
      ),
      // --- SHARED ROUTED PAGES (Wrapped based on role) ---
      GoRoute(
        path: '/engagements/:engagementId',
        builder: (context, state) {
          final engagementId = state.pathParameters['engagementId'] ?? '';
          final view = EngagementWorkspaceView(engagementId: engagementId);
          final role = ref.read(userRoleProvider);
          return role == UserRole.company
              ? CompanyShellLayout(child: view)
              : ExpertShellLayout(child: view);
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) {
          final view = const MessagingHubView();
          final role = ref.read(userRoleProvider);
          return role == UserRole.company
              ? CompanyShellLayout(child: view)
              : ExpertShellLayout(child: view);
        },
      ),
      GoRoute(
        path: '/meetings',
        builder: (context, state) {
          final view = const ScheduledMeetingsCalendarView();
          final role = ref.read(userRoleProvider);
          return role == UserRole.company
              ? CompanyShellLayout(child: view)
              : ExpertShellLayout(child: view);
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyView(),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (context, state) => const TermsOfServiceView(),
      ),
    ],
  );
});
