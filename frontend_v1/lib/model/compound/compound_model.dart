class CompoundModel {
  String? compNo;
  String? kodhasil;
  String? compPlateNo;
  String? compName;
  String? compType;
  String? violationDesc;
  String? compDate;
  String? compTime;
  String? compPaymentStatus;
  String? compLocation;
  String? compIssuer;
  double amount;

  CompoundModel({
    this.compNo,
    this.kodhasil,
    this.compPlateNo,
    this.compName,
    this.compType,
    this.violationDesc,
    this.compDate,
    this.compTime,
    this.compPaymentStatus,
    this.compLocation,
    this.compIssuer,
    this.amount = 0.0,
  });
}
