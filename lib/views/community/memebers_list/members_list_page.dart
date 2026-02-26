import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/data/models/community_model.dart';
import 'package:community/data/models/member_model.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/views/shared/widgets/empty_state.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';
import 'package:community/views/shared/widgets/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MembersListPage extends StatefulWidget {
  const MembersListPage({super.key});

  @override
  State<MembersListPage> createState() => _MembersListPageState();
}

class _MembersListPageState extends State<MembersListPage> {
  final CommunityController _communityController = Get.find();

  bool _hasLoadedOnce = false;

  Future<void> _loadMembers() async {
    final community = _communityController.currentCommunity.value;
    if (community == null) return;

    await _communityController.getCommunityMembers(community.community_id);
  }

  @override
  Widget build(BuildContext context) {
    final community = _communityController.currentCommunity.value;

    // Si aucune communauté n'est sélectionnée
    if (community == null) {
      return const Scaffold(
        body: Center(child: Text('Communauté non sélectionnée')),
      );
    }

    // 🔁 Charge automatiquement les membres une seule fois à l’ouverture
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMembers();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Membres - ${community.nom}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMembers,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Obx(() {
        final isLoading = _communityController.isLoading.value;
        final error = _communityController.error.value;
        final members = _communityController.currentMembers;

        if (isLoading && members.isEmpty) {
          return const LoadingWidget(message: 'Chargement des membres...');
        }

        if (error.isNotEmpty) {
          return EmptyStateWidget(
            title: 'Erreur',
            message: error,
            icon: Icons.error_outline,
            onAction: _loadMembers,
            actionLabel: 'Réessayer',
          );
        }

        if (members.isEmpty) {
          return EmptyStateWidget(
            title: 'Aucun membre',
            message: 'Aucun membre dans cette communauté pour le moment.',
            icon: Icons.people_outline,
          );
        }

        final responsive = ResponsiveHelper(context);

        return ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: _loadMembers,
            child: GridView.builder(
              padding: EdgeInsets.all(responsive.spacing(16)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: responsive.gridColumns,
                crossAxisSpacing: responsive.spacing(16),
                mainAxisSpacing: responsive.spacing(12),
                mainAxisExtent: responsive.value<double>(
                  mobile: 105,
                  tablet: 115,
                  desktop: 125,
                ),
              ),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return _buildMemberCard(member, community);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMemberCard(MemberModel member, CommunityModel community) {
    final responsive = ResponsiveHelper(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: InkWell(
        onTap: () => _showMemberDetails(member),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(12)),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: responsive.value<double>(mobile: 22, tablet: 26),
                backgroundColor: _getMemberColor(member),
                child: Text(
                  _getMemberInitials(member),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.fontSize(14),
                  ),
                ),
              ),
              SizedBox(width: responsive.spacing(12)),

              // Infos (Texte flexible)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      member.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.fontSize(15),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.spacing(2)),
                    Text(
                      member.email,
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: responsive.fontSize(12),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.spacing(6)),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: responsive.fontSize(10),
                          color: Colors.grey,
                        ),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          'Rejoint le ${_formatDate(member.joinedAt)}',
                          style: AppTheme.bodyText2.copyWith(
                            fontSize: responsive.fontSize(10),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rôle et Options
              SizedBox(width: responsive.spacing(8)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RoleBadge(role: member.role),
                  if (community.role == 'ADMIN' && member.role != 'ADMIN')
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        size: responsive.iconSize(20),
                      ),
                      onPressed: () => _showMemberOptions(member, community),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    // Spacer pour maintenir l'alignement
                    const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberOptions(MemberModel member, CommunityModel community) {
    if (community.role != 'ADMIN') return;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member.role != 'ADMIN')
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifier le rôle'),
                onTap: () {
                  Get.back();
                  _changeMemberRole(member, community);
                },
              ),
            if (member.role != 'ADMIN') const Divider(),
            if (member.role != 'ADMIN')
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.red),
                title: const Text(
                  'Retirer du groupe',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  _confirmRemoveMember(member, community);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _changeMemberRole(MemberModel member, CommunityModel community) {
    Get.dialog(
      AlertDialog(
        title: const Text('Changer le rôle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Membre'),
              leading: const Icon(Icons.person_outline),
              onTap: () {
                Get.back();
                _updateMemberRole(member, community, 'MEMBRE');
              },
            ),
            ListTile(
              title: const Text('Responsable'),
              leading: const Icon(Icons.star_border),
              onTap: () {
                Get.back();
                _updateMemberRole(member, community, 'RESPONSABLE');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateMemberRole(
    MemberModel member,
    CommunityModel community,
    String newRole,
  ) async {
    final success = await _communityController.updateMemberRole(
      communityId: community.community_id,
      memberId: member.id,
      role: newRole,
    );

    if (success) {
      await _loadMembers();
      Get.snackbar(
        'Rôle mis à jour',
        'Le rôle de ${member.fullName} a été changé en $newRole',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le rôle',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmRemoveMember(MemberModel member, CommunityModel community) {
    Get.dialog(
      AlertDialog(
        title: const Text('Retirer du groupe'),
        content: Text(
          'Êtes-vous sûr de vouloir retirer ${member.fullName} de la communauté ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              _removeMember(member, community);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMember(
    MemberModel member,
    CommunityModel community,
  ) async {
    final success = await _communityController.removeMember(
      communityId: community.community_id,
      memberId: member.id,
    );

    if (success) {
      await _loadMembers();
      Get.snackbar(
        'Membre retiré',
        '${member.fullName} a été retiré de la communauté',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer le membre',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showMemberDetails(MemberModel member) {
    Get.dialog(
      AlertDialog(
        title: Text(member.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${member.email}'),
            const SizedBox(height: 8),
            Text('Rôle: ${member.role}'),
            const SizedBox(height: 8),
            Text('Rejoint le: ${_formatDate(member.joinedAt)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Color _getMemberColor(MemberModel member) {
    final hash = member.email.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[hash.abs() % colors.length];
  }

  // ✅ plus robuste si prenom/nom sont vides
  String _getMemberInitials(MemberModel member) {
    final p = (member.prenom).trim();
    final n = (member.nom).trim();
    final p1 = p.isNotEmpty ? p[0] : 'U';
    final n1 = n.isNotEmpty ? n[0] : 'U';
    return '$p1$n1'.toUpperCase();
  }

  // ✅ FIX: accepte DateTime? (joinedAt est nullable)
  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final d = date;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}
