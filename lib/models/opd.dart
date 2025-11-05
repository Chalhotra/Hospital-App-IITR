import 'package:equatable/equatable.dart';

class Opd extends Equatable {
  final int opdid;
  final int regNo;
  final int tokenNo;
  final String patientCode;
  final String patientName;
  final String doctorCode;
  final String mobileNo;
  final String parentName;
  final String age;
  final String weight;
  final String gender;
  final String address;
  final double fee;
  final String opdDate;
  final String opdShift;
  final String financialYear;
  final int opdStatus;
  final String feeMode;
  final String details;
  final String complaints;
  final String examination;
  final String diagnosis;
  final String? shiftedToIPD;
  final String? refferedOutSide;
  final String? refferedTo;
  final String opD_EMR;
  final String nextOPD;
  final String bookedatIP;
  final String bookedBy;
  final String bookedDateTime;

  const Opd({
    required this.opdid,
    required this.regNo,
    required this.tokenNo,
    required this.patientCode,
    required this.patientName,
    required this.doctorCode,
    required this.mobileNo,
    required this.parentName,
    required this.age,
    required this.weight,
    required this.gender,
    required this.address,
    required this.fee,
    required this.opdDate,
    required this.opdShift,
    required this.financialYear,
    required this.opdStatus,
    required this.feeMode,
    required this.details,
    required this.complaints,
    required this.examination,
    required this.diagnosis,
    this.shiftedToIPD,
    this.refferedOutSide,
    this.refferedTo,
    required this.opD_EMR,
    required this.nextOPD,
    required this.bookedatIP,
    required this.bookedBy,
    required this.bookedDateTime,
  });

  factory Opd.fromJson(Map<String, dynamic> json) {
    return Opd(
      opdid: json['opdid'] as int,
      regNo: json['regNo'] as int,
      tokenNo: json['tokenNo'] as int,
      patientCode: json['patientCode'] as String,
      patientName: json['patientName'] as String,
      doctorCode: json['doctorCode'] as String,
      mobileNo: json['mobileNo'] as String,
      parentName: json['parentName'] as String,
      age: json['age'] as String,
      weight: json['weight'] as String,
      gender: json['gender'] as String,
      address: json['address'] as String,
      fee: (json['fee'] as num).toDouble(),
      opdDate: json['opdDate'] as String,
      opdShift: json['opdShift'] as String,
      financialYear: json['financialYear'] as String,
      opdStatus: json['opdStatus'] as int,
      feeMode: json['feeMode'] as String,
      details: json['details'] as String,
      complaints: json['complaints'] as String,
      examination: json['examination'] as String,
      diagnosis: json['diagnosis'] as String,
      shiftedToIPD: json['shiftedToIPD'] as String?,
      refferedOutSide: json['refferedOutSide'] as String?,
      refferedTo: json['refferedTo'] as String?,
      opD_EMR: json['opD_EMR'] as String,
      nextOPD: json['nextOPD'] as String,
      bookedatIP: json['bookedatIP'] as String,
      bookedBy: json['bookedBy'] as String,
      bookedDateTime: json['bookedDateTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opdid': opdid,
      'regNo': regNo,
      'tokenNo': tokenNo,
      'patientCode': patientCode,
      'patientName': patientName,
      'doctorCode': doctorCode,
      'mobileNo': mobileNo,
      'parentName': parentName,
      'age': age,
      'weight': weight,
      'gender': gender,
      'address': address,
      'fee': fee,
      'opdDate': opdDate,
      'opdShift': opdShift,
      'financialYear': financialYear,
      'opdStatus': opdStatus,
      'feeMode': feeMode,
      'details': details,
      'complaints': complaints,
      'examination': examination,
      'diagnosis': diagnosis,
      'shiftedToIPD': shiftedToIPD,
      'refferedOutSide': refferedOutSide,
      'refferedTo': refferedTo,
      'opD_EMR': opD_EMR,
      'nextOPD': nextOPD,
      'bookedatIP': bookedatIP,
      'bookedBy': bookedBy,
      'bookedDateTime': bookedDateTime,
    };
  }

  @override
  List<Object?> get props => [
    opdid,
    regNo,
    tokenNo,
    patientCode,
    patientName,
    doctorCode,
    mobileNo,
    parentName,
    age,
    weight,
    gender,
    address,
    fee,
    opdDate,
    opdShift,
    financialYear,
    opdStatus,
    feeMode,
    details,
    complaints,
    examination,
    diagnosis,
    shiftedToIPD,
    refferedOutSide,
    refferedTo,
    opD_EMR,
    nextOPD,
    bookedatIP,
    bookedBy,
    bookedDateTime,
  ];
}
