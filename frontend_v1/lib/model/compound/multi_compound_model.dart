class MultiCompoundModel {
  int? id; // optional internal ID
  String? name; // offender name
  String compoundNum; // compound number
  String plate; // vehicle plate number
  String? date; // date of violation
  String? time; // time of violation
  String? offense; // type of offense / perintah
  String? perintah; // specific perintah
  double amount; // compound amount (RM)
  String status; // UNPAID / PAID

  MultiCompoundModel({
    this.id,
    this.name,
    required this.compoundNum,
    required this.plate,
    this.date,
    this.time,
    this.offense,
    this.perintah,
    required this.amount,
    required this.status,
  });

  factory MultiCompoundModel.fromJson(Map<String, dynamic> json) {
    String? timestamp = json['violation_timestamp'];
    String? date;
    String? time;

    if (timestamp != null && timestamp.contains('T')) {
      final parts = timestamp.split('T');
      date = parts[0];
      time = parts[1].split('+')[0];
    }

    return MultiCompoundModel(
      compoundNum: json['service_reference_1'] ?? '',
      plate: json['registration_number'] ?? '',
      date: date,
      time: time,
      offense: json['violation_type'],
      perintah: json['violation_type'],
      amount: (double.parse(json['compound_amount'].toString()) / 100),
      status: (json['status'] ?? 'UNPAID').toString().toUpperCase(),
    );
  }

  @override
  String toString() {
    return 'MultiCompoundModel(compoundNum: $compoundNum, plate: $plate, '
        'offense: $offense, perintah: $perintah, date: $date, time: $time, '
        'amount: $amount, status: $status)';
  }
}
