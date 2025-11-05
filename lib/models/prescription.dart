import 'package:equatable/equatable.dart';
import 'opd.dart';

class Prescription extends Equatable {
  final int prescriptionID;
  final int appointmentID;
  final Opd opd;
  final int code;
  final String drugName;
  final String drugSalt;
  final String drugType;
  final String dossage;
  final String remark;
  final int qty;
  final String medFrom;
  final int issued;
  final String issuedBy;
  final String issuedOn;

  const Prescription({
    required this.prescriptionID,
    required this.appointmentID,
    required this.opd,
    required this.code,
    required this.drugName,
    required this.drugSalt,
    required this.drugType,
    required this.dossage,
    required this.remark,
    required this.qty,
    required this.medFrom,
    required this.issued,
    required this.issuedBy,
    required this.issuedOn,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionID: json['prescriptionID'] as int,
      appointmentID: json['appointmentID'] as int,
      opd: Opd.fromJson(json['opd'] as Map<String, dynamic>),
      code: json['code'] as int,
      drugName: json['drugName'] as String,
      drugSalt: json['drugSalt'] as String,
      drugType: json['drugType'] as String,
      dossage: json['dossage'] as String,
      remark: json['remark'] as String,
      qty: json['qty'] as int,
      medFrom: json['medFrom'] as String,
      issued: json['issued'] as int,
      issuedBy: json['issuedBy'] as String,
      issuedOn: json['issuedOn'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionID': prescriptionID,
      'appointmentID': appointmentID,
      'opd': opd.toJson(),
      'code': code,
      'drugName': drugName,
      'drugSalt': drugSalt,
      'drugType': drugType,
      'dossage': dossage,
      'remark': remark,
      'qty': qty,
      'medFrom': medFrom,
      'issued': issued,
      'issuedBy': issuedBy,
      'issuedOn': issuedOn,
    };
  }

  @override
  List<Object?> get props => [
    prescriptionID,
    appointmentID,
    opd,
    code,
    drugName,
    drugSalt,
    drugType,
    dossage,
    remark,
    qty,
    medFrom,
    issued,
    issuedBy,
    issuedOn,
  ];
}
