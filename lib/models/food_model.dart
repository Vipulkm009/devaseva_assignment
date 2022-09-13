class Food {
  String? id;
  String? name;
  String? category;

  Food({
    this.id,
    this.name,
    this.category,
  });

  factory Food.fromJson(Map<String, dynamic> json, String category) {
    return Food(
      id: json['_id'].toString(),
      name: json['name'].toString(),
      category: category,
    );
  }
}
