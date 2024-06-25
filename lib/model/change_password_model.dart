class ChangePasswordApi {
  bool status;
  String message;

  ChangePasswordApi({
    required this.status,
    required this.message,
  });

  factory ChangePasswordApi.fromJson(Map<String, dynamic> json) => ChangePasswordApi(
        status: json['Status'],
        message: json['Message'],
      );

  Map<String, dynamic> toJson() => {
        'Status': status,
        'Message': message,
      };
}