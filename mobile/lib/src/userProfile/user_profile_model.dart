class UserProfile {
  String username;
  String? avatarUrl;

  UserProfile({required this.username, this.avatarUrl});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json['username'],
        avatarUrl: json['avatarUrl'],
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'avatarUrl': avatarUrl,
      };

  @override
  String toString() {
    return '{$username}';
  }
}
