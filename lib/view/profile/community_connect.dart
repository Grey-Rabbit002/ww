import 'dart:math';

import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
import 'package:com.example.while_app/view_model/providers/connect_community_provider.dart';
//import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:com.example.while_app/view_model/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityConnect extends ConsumerWidget {
  const CommunityConnect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth
        .instance.currentUser!.uid; // Assume the current user ID is available
    final allCommunitiesAsyncValue = ref.watch(allCommunitiesProvider);
    final joinedCommunitiesAsyncValue = ref.watch(joinedCommuntiesProvider(userId));

    return Scaffold(
      //appBar: AppBar(title: const Text('Discover Communities')),
      body: allCommunitiesAsyncValue.when(
        data: (allCommunities) => joinedCommunitiesAsyncValue.when(
          data: (followingUsers) {
            final nonJoinedCommunities = allCommunities
                .where((user) => !followingUsers.contains(user.id))
                .toList();

            return ListView.builder(
              itemCount: nonJoinedCommunities.length,
              itemBuilder: (context, index) {
                final user = nonJoinedCommunities[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.image),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.about),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // Assuming 'user' is the ChatUser instance you want to follow
                      final userProvider = ref.watch(userDataProvider);
                      log(699999999999);

                      // Use the provider to follow the user
                      final didJoin = await ref.read(joinCommunityProvider)(
                          userProvider.auth!.uid, user.id);

                      if (didJoin) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You have joined ${user.name}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to join ${user.name}')),
                        );
                      }
                    },
                    child: const Text('Join'),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}