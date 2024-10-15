class Friend {
  String? id;
  String name;
  String? description;
  String? imageURL;

  Friend({this.id, required this.name, this.description, this.imageURL});

  factory Friend.fromFirestore(Map<String, dynamic> json) {
    return Friend(
      name: json['name'],
      description: json['description'],
      imageURL: json['imageURL'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'imageURL': imageURL,
      };
}
