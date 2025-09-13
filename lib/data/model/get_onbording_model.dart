class OnboardingData {
  int? id;
  String? title;
  String? image;
  String? description;
  int? status;
  String? createdAt;
  String? updatedAt;

  OnboardingData(
      {this.id,
      this.title,
      this.image,
      this.description,
      this.status,
      this.createdAt,
      this.updatedAt});

  OnboardingData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['description'] = this.description;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
