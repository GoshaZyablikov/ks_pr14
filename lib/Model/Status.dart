class Status {
  final int idStatus;
  final String nameStatus;

  Status({
    required this.idStatus,
    required this.nameStatus,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      idStatus: json['idStatus'],
      nameStatus: json['nameStatus'],
    );
  }
}