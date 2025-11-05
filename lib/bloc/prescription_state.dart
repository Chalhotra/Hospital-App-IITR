import 'package:equatable/equatable.dart';
import '../models/opd.dart';
import '../models/prescription.dart';

abstract class PrescriptionState extends Equatable {
  const PrescriptionState();

  @override
  List<Object> get props => [];
}

class PrescriptionInitial extends PrescriptionState {}

class PrescriptionOpdListLoading extends PrescriptionState {}

class PrescriptionOpdListLoaded extends PrescriptionState {
  final List<Opd> opds;

  const PrescriptionOpdListLoaded(this.opds);

  @override
  List<Object> get props => [opds];
}

class PrescriptionDetailsLoading extends PrescriptionState {
  final List<Opd> opds;

  const PrescriptionDetailsLoading(this.opds);

  @override
  List<Object> get props => [opds];
}

class PrescriptionDetailsLoaded extends PrescriptionState {
  final List<Opd> opds;
  final List<Prescription> prescriptions;

  const PrescriptionDetailsLoaded(this.opds, this.prescriptions);

  @override
  List<Object> get props => [opds, prescriptions];
}

class PrescriptionError extends PrescriptionState {
  final String message;

  const PrescriptionError(this.message);

  @override
  List<Object> get props => [message];
}
