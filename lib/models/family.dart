class Family {
  String? id; 
  String name;
  String relation;
  String? description;
  String? imageURL;

  Family({
    this.id,
    required this.name,
    required this.relation,
    this.description,
    this.imageURL,
  });

  factory Family.fromFirestore(Map<String, dynamic> json) {
    return Family(
      name: json['name'],
      relation: json['relation'],
      description: json['description'],
      imageURL: json['imageURL'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'relation': relation,
        'description': description,
        'imageURL': imageURL,
      };
}
