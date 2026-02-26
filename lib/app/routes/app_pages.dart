import 'package:community/views/auth/login/login_page.dart';
import 'package:community/views/auth/register/register_page.dart';
import 'package:community/views/community/community_dashboard/community_dashboard_page.dart';
import 'package:community/views/community/create_community/create_community_page.dart';
import 'package:community/views/community/invite_member/invite_member_page.dart';
import 'package:community/views/community/join_community/join_community_page.dart';
import 'package:community/views/community/memebers_list/members_list_page.dart';
import 'package:community/views/community_settings/community_settings_page.dart';
import 'package:community/views/history/activity_log_page.dart';
import 'package:community/views/notifications/notifications_page.dart';
import 'package:community/views/profile/profile_page.dart';
import 'package:community/views/projects/create_edit_project/create_edit_project_page.dart';
import 'package:community/views/projects/projects_list/projects_list_page.dart';
import 'package:community/views/public/features/features_page.dart';
import 'package:community/views/public/princing_info/pricing_info_page.dart';
import 'package:community/views/public/splash/splash_page.dart';
import 'package:community/views/public/welcome/welcome_page.dart';
import 'package:community/views/tasks/create_edit/create_edit_task_page.dart';
import 'package:community/views/tasks/kanban_board/kanban_board_page.dart';
import 'package:community/views/tasks/task_detail/task_detail_page.dart';
import 'package:community/views/tasks/task_comments/task_comments_page.dart';
import 'package:community/views/users/community_select_page.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
    GetPage(name: AppRoutes.features, page: () => const FeaturesPage()),
    GetPage(name: AppRoutes.pricingInfo, page: () => const PricingInfoPage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(
      name: AppRoutes.communitySelect,
      page: () => const CommunitySelectPage(),
    ),
    GetPage(
      name: AppRoutes.createCommunity,
      page: () => const CreateCommunityPage(),
    ),
    GetPage(
      name: AppRoutes.joinCommunity,
      page: () => const JoinCommunityPage(),
    ),
    GetPage(
      name: AppRoutes.communityDashboard,
      page: () => const CommunityDashboardPage(),
    ),
    GetPage(name: AppRoutes.membersList, page: () => const MembersListPage()),
    GetPage(name: AppRoutes.inviteMember, page: () => const InviteMemberPage()),
    GetPage(name: AppRoutes.projectsList, page: () => const ProjectsListPage()),
    GetPage(
      name: AppRoutes.createEditProject,
      page: () => const CreateEditProjectPage(),
    ),
    GetPage(name: AppRoutes.kanbanBoard, page: () => const KanbanBoardPage()),
    GetPage(
      name: AppRoutes.createEditTask,
      page: () => const CreateEditTaskPage(),
    ),
    GetPage(name: AppRoutes.taskDetail, page: () => const TaskDetailPage()),
    GetPage(name: AppRoutes.taskComments, page: () => const TaskCommentsPage()),
    GetPage(name: AppRoutes.activityLog, page: () => const ActivityLogPage()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const Scaffold(body: Center(child: Text('Notifications'))),
    ),
    GetPage(
      name: AppRoutes.communitySettings,
      page: () => const Scaffold(body: Center(child: Text('Settings'))),
    ),
  ];
}
