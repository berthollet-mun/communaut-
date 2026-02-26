class InviteModel {
  final String inviteCode;
  final String message;

  InviteModel({required this.inviteCode, required this.message});

  factory InviteModel.fromJson(Map<String, dynamic> json) {
    return InviteModel(
      inviteCode: json['invite_code'],
      message: json['message'],
    );
  }
}
