import 'package:equatable/equatable.dart';
import '../models/patient_info.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final List<PatientInfo> booklets;
  final PatientInfo activeBooklet;

  const PatientLoaded({required this.booklets, required this.activeBooklet});

  PatientLoaded copyWith({
    List<PatientInfo>? booklets,
    PatientInfo? activeBooklet,
  }) {
    return PatientLoaded(
      booklets: booklets ?? this.booklets,
      activeBooklet: activeBooklet ?? this.activeBooklet,
    );
  }

  @override
  List<Object?> get props => [booklets, activeBooklet];
}

class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object?> get props => [message];
}
