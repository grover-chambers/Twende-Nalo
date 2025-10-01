import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userImageUrl;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userImageUrl,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: userImageUrl != null
                ? NetworkImage(userImageUrl!)
                : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          if (onEditPressed != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: onEditPressed,
            ),
        ],
      ),
    );
  }
}
