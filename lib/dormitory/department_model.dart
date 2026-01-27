class DepartmentModel {
  final String name; // IT
  final String dept; // IT-Hardware
  final String mail; // it@dormitory.com

  DepartmentModel({
    required this.name,
    required this.dept,
    required this.mail,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      name: json['name'],
      dept: json['dept'],
      mail: json['mail'],
    );
  }
}
