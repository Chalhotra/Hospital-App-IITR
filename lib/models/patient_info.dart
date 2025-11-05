import 'package:equatable/equatable.dart';

class PatientInfo extends Equatable {
  final String bookletNo;
  final String identificationNo;
  final String fullName;
  final String relativeName;
  final String relation;
  final String age;
  final String weight;
  final String gender;
  final String dob;
  final String address;
  final String emailID;
  final String mobileNo;
  final String bloodGroup;
  final String remark;
  final String? designation;
  final String? department;
  final String? postType;
  final String? panNo;
  final String? bankAccountNo;
  final String? bankName;
  final String? ifsCcode;
  final String? aadharNo;
  final String bookletValidDate;
  final String fullFacility;
  final String validBooklet;

  const PatientInfo({
    required this.bookletNo,
    required this.identificationNo,
    required this.fullName,
    required this.relativeName,
    required this.relation,
    required this.age,
    required this.weight,
    required this.gender,
    required this.dob,
    required this.address,
    required this.emailID,
    required this.mobileNo,
    required this.bloodGroup,
    required this.remark,
    this.designation,
    this.department,
    this.postType,
    this.panNo,
    this.bankAccountNo,
    this.bankName,
    this.ifsCcode,
    this.aadharNo,
    required this.bookletValidDate,
    required this.fullFacility,
    required this.validBooklet,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      bookletNo: json['bookletNo'] as String? ?? '',
      identificationNo: json['identificationNo'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      relativeName: json['relativeName'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      age: json['age'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      address: json['address'] as String? ?? '',
      emailID: json['emailID'] as String? ?? '',
      mobileNo: json['mobileNo'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      postType: json['postType'] as String?,
      panNo: json['panNo'] as String?,
      bankAccountNo: json['bankAccountNo'] as String?,
      bankName: json['bankName'] as String?,
      ifsCcode: json['ifsCcode'] as String?,
      aadharNo: json['aadharNo'] as String?,
      bookletValidDate: json['bookletValidDate'] as String? ?? '',
      fullFacility: json['fullFacility'] as String? ?? '',
      validBooklet: json['validBooklet'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookletNo': bookletNo,
      'identificationNo': identificationNo,
      'fullName': fullName,
      'relativeName': relativeName,
      'relation': relation,
      'age': age,
      'weight': weight,
      'gender': gender,
      'dob': dob,
      'address': address,
      'emailID': emailID,
      'mobileNo': mobileNo,
      'bloodGroup': bloodGroup,
      'remark': remark,
      'designation': designation,
      'department': department,
      'postType': postType,
      'panNo': panNo,
      'bankAccountNo': bankAccountNo,
      'bankName': bankName,
      'ifsCcode': ifsCcode,
      'aadharNo': aadharNo,
      'bookletValidDate': bookletValidDate,
      'fullFacility': fullFacility,
      'validBooklet': validBooklet,
    };
  }

  @override
  List<Object?> get props => [
    bookletNo,
    identificationNo,
    fullName,
    relativeName,
    relation,
    age,
    weight,
    gender,
    dob,
    address,
    emailID,
    mobileNo,
    bloodGroup,
    remark,
    designation,
    department,
    postType,
    panNo,
    bankAccountNo,
    bankName,
    ifsCcode,
    aadharNo,
    bookletValidDate,
    fullFacility,
    validBooklet,
  ];
}
