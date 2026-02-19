class PostModel {
  final String postId;
  final String username;

  // For now you're using local file path for feed preview
  final String imagePath;

  // Later when Firebase works, you can store download URL here
  final String? imageUrl;

  final String caption;
  final DateTime createdAt;

  int likeCount;
  bool isLiked;

  final List<CommentModel> comments;

  PostModel({
    required this.postId,
    required this.username,
    required this.imagePath,
    this.imageUrl,
    required this.caption,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
    List<CommentModel>? comments,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "username": username,
        "imagePath": imagePath,
        "imageUrl": imageUrl,
        "caption": caption,
        "createdAt": createdAt.toIso8601String(),
        "likeCount": likeCount,
        "isLiked": isLiked,
        "comments": comments.map((c) => c.toJson()).toList(),
      };

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json["postId"] ?? "",
      username: json["username"] ?? "unknown",
      imagePath: json["imagePath"] ?? "",
      imageUrl: json["imageUrl"],
      caption: json["caption"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      likeCount: (json["likeCount"] ?? 0) as int,
      isLiked: (json["isLiked"] ?? false) as bool,
      comments: (json["comments"] as List<dynamic>? ?? [])
          .map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class CommentModel {
  final String id;
  final String username;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "text": text,
        "createdAt": createdAt.toIso8601String(),
      };

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json["id"] ?? "",
      username: json["username"] ?? "unknown",
      text: json["text"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    );
  }
}
